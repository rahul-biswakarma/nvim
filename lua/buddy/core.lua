-- lua/buddy/core.lua
-- The core logic of the buddy framework.

local M = {}

local config = require("buddy.config")
local state = require("buddy.state")
local profiles = require("buddy.profiles")
local ollama = require("buddy.ollama")
local external = require("buddy.external")
local ui = require("buddy.ui")
local events = require("buddy.events")

local function extract_json(str)
  if not str then return nil end
  -- Find the first '{' and the last '}' to extract the JSON block.
  -- This is more robust than brace counting if the string contains braces.
  local first_brace = str:find("{")
  if not first_brace then return nil end

  local last_brace
  for i = #str, first_brace, -1 do
    if str:sub(i, i) == "}" then
      last_brace = i
      break
    end
  end

  if last_brace then
    return str:sub(first_brace, last_brace)
  end
  return nil
end

local function build_user_prompt()
  local buddy_name = state.get_active_buddy()
  local event_accumulator = state.get_event_accumulator()
  local internal_state = state.get_llm_internal_state()
  local chat_history = state.get_chat_history()

  -- Gather context
  local git_comments = external.get_last_git_comments(5)

  local context_lines = {
    "[START OF CONTEXT]",
    "User: Rahul",
    "Project: " .. vim.fn.getcwd(),
    "Current File: " .. vim.api.nvim_buf_get_name(0),
    "Last 5 Git Commits:\n" .. git_comments,
  }

  if event_accumulator and #event_accumulator > 0 then
    table.insert(context_lines, "\nRecent Activity (Since last talk):")
    -- Simple summary for now
    table.insert(context_lines, string.format("- %d editor events occurred.", #event_accumulator))
  end

  table.insert(context_lines, "\nLLM Internal State (Your Scratchpad):\n" .. internal_state)
  table.insert(context_lines, "\n[CHAT HISTORY]")
  for _, msg in ipairs(chat_history) do
    local sender = msg.sender == "user" and "Rahul" or buddy_name
    table.insert(context_lines, string.format("%s: %s", sender, msg.text))
  end

  table.insert(context_lines, "\n[YOUR TASK]")
  table.insert(context_lines, string.format(
    "You are %s. Given all this new context, what do you do?",
    buddy_name
  ))
  table.insert(context_lines, "Respond ONLY with the JSON format defined in your system prompt.")

  return table.concat(context_lines, "\n")
end

local function handle_llm_response(response_content)
  state.set_pending_response(false) -- No longer pending
  if not response_content then
    -- This can happen if the request failed (e.g., on_stderr)
    return
  end

  local json_str = extract_json(response_content)
  if not json_str then
    vim.notify("Could not find valid JSON in LLM response: " .. response_content, vim.log.levels.ERROR, { timeout = false })
    return
  end

  local ok, parsed = pcall(vim.json.decode, json_str)
  if not ok then
    vim.notify("Failed to parse LLM JSON response: " .. json_str, vim.log.levels.ERROR, { timeout = false })
    return
  end

  if parsed.response_type == "speak" and parsed.message then
    local clean_message = parsed.message:gsub("\n", " "):gsub("^%s+", ""):gsub("%s+$", "")
    local last_buddy_message = state.get_last_buddy_message()
    if not (last_buddy_message and last_buddy_message == clean_message) then
      state.add_chat_message("buddy", clean_message)
      ui.render()
    end
  end

  if parsed.new_topic_ideas then
    profiles.add_topics(state.get_active_buddy(), parsed.new_topic_ideas)
  end

  if parsed.internal_state_update then
    state.set_llm_internal_state(parsed.internal_state_update)
  end
end

local function trigger_llm(reason)
  if state.is_pending_response() then
    return
  end

  state.set_pending_response(true)

  local buddy_name = state.get_active_buddy()
  local profile = profiles.get_buddy_profile(buddy_name)
  local system_prompt = profiles.get_system_prompt(buddy_name)
  if not system_prompt then
    state.set_pending_response(false)
    return
  end

  local user_prompt = build_user_prompt()
  local history = state.get_chat_history()

  state.clear_event_accumulator()

  ollama.request(profile, system_prompt, user_prompt, history, reason, handle_llm_response)
end

function M.add_event(event_type, details)
  state.add_event(event_type, details)
  if #state.get_event_accumulator() >= config.options.core.event_threshold then
    trigger_llm("Event threshold reached")
  end
end

function M.on_user_message(message)
  state.add_chat_message("user", message)
  ui.render()
  trigger_llm("User sent a message")
end

local function setup_timers()
  -- Idle timer
  vim.fn.timer_start(config.options.core.idle_threshold, function()
    trigger_llm("Idle threshold reached")
  end, { ["repeat"] = -1 })
end

---Initializes the core module.
function M.init()
  config.setup()
  state.init()
  events.setup_listeners(M.add_event)
  setup_timers()

  -- Trigger on startup
  vim.defer_fn(function()
    trigger_llm("Neovim startup")
  end, 1000)
end

return M
