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

local trigger_llm -- forward declaration

local function process_trigger_queue()
  if state.is_pending_response() then
    return
  end
  local next_reason = state.dequeue_trigger()
  if not next_reason then
    return
  end
  vim.schedule(function()
    trigger_llm(next_reason)
  end)
end

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
  local memory_notes = profiles.get_memory(buddy_name)

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

  table.insert(context_lines, "\n[MEMORIES]")
  if memory_notes and memory_notes ~= "" then
    table.insert(context_lines, memory_notes)
  else
    table.insert(context_lines, "(No stored memories yet.)")
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

local function handle_llm_response(response_content, ctx)
  local function finalize()
    state.set_pending_response(false)
    process_trigger_queue()
  end

  if not response_content then
    finalize()
    return
  end

  local function extract_fallback_message(raw, json_segment)
    if not raw or not json_segment then
      return nil
    end
    local start_idx = raw:find(json_segment, 1, true)
    if not start_idx then
      return nil
    end
    local after_json = raw:sub(start_idx + #json_segment)
    after_json = after_json:gsub("^%s+", ""):gsub("%s+$", "")
    if after_json ~= "" then
      return after_json
    end
    return nil
  end

  local function apply_parsed_response(parsed, raw, json_segment)
    local response_type = parsed.response_type
    local message = parsed.message
    local internal_state_update = parsed.internal_state_update

    if response_type == vim.NIL then
      response_type = nil
    end
    if message == vim.NIL then
      message = nil
    elseif type(message) ~= "string" then
      message = tostring(message)
    end
    if internal_state_update == vim.NIL then
      internal_state_update = nil
    elseif type(internal_state_update) ~= "string" then
      internal_state_update = tostring(internal_state_update)
    end

    if response_type == "speak" and (not message or message == "") then
      message = extract_fallback_message(raw, json_segment)
    end
    if response_type == "speak" and (not message or message == "") and internal_state_update and internal_state_update ~= "" then
      message = internal_state_update
    end

    if response_type == "speak" and message and message ~= "" then
      local clean_message = message:gsub("\n", " "):gsub("^%s+", ""):gsub("%s+$", "")
      local last_buddy_message = state.get_last_buddy_message()
      if not (last_buddy_message and last_buddy_message == clean_message) then
        state.add_chat_message("buddy", clean_message)
        if not ui.is_open() then
          ui.open()
        end
        ui.render()
      end
    end

    local new_topic_ideas = parsed.new_topic_ideas
    if new_topic_ideas == vim.NIL then
      new_topic_ideas = nil
    end
    if new_topic_ideas then
      profiles.add_topics(state.get_active_buddy(), new_topic_ideas)
    end

    local memory_to_store = parsed.memory_to_store
    if memory_to_store == vim.NIL then
      memory_to_store = nil
    end
    if memory_to_store then
      profiles.append_memory(ctx and ctx.buddy_name or state.get_active_buddy(), memory_to_store)
    end

    if internal_state_update then
      state.set_llm_internal_state(internal_state_update)
    end
  end

  local function handle_valid_json(parsed, raw, json_segment)
    apply_parsed_response(parsed, raw, json_segment)
    finalize()
  end

  local function request_json_fix(raw_response)
    local fixer_opts = config.options.ollama.json_fixer or {}
    local fixer_model = fixer_opts.model or "gemma3:12b"
    vim.notify(
      string.format("LLM JSON parse failed. Attempting repair via %s.", fixer_model),
      vim.log.levels.WARN
    )

    local fixer_system_prompt = table.concat({
      "You repair JSON responses produced by another assistant.",
      "Return strictly valid JSON that conforms to the schema described in the provided instructions.",
      "Do not include markdown code fences, commentary, or additional explanation.",
    }, "\n")

    local user_prompt_parts = {
      "Assistant instructions (system prompt) that describe the required JSON schema:",
      ctx and ctx.system_prompt or "(missing system prompt)",
      "",
      "Here is the assistant response that failed to parse as JSON:",
      raw_response,
      "",
      "Produce corrected JSON only. Do not wrap the result or add commentary.",
    }
    local fixer_user_prompt = table.concat(user_prompt_parts, "\n")

    local fixer_profile = {
      llm = {
        model = fixer_model,
        temperature = fixer_opts.temperature or 0,
        max_tokens = fixer_opts.max_tokens or 512,
      },
    }

    state.set_pending_response(true)
    ollama.request(fixer_profile, fixer_system_prompt, fixer_user_prompt, {}, "JSON Fixer", function(fix_response)
      if not fix_response then
        vim.notify("JSON fixer failed to return a response.", vim.log.levels.ERROR, { timeout = false })
        finalize()
        return
      end

      local fixed_json = extract_json(fix_response) or fix_response
      local ok_fix, parsed_fix = pcall(vim.json.decode, fixed_json)
      if not ok_fix then
        vim.notify("JSON fixer returned invalid JSON: " .. fixed_json, vim.log.levels.ERROR, { timeout = false })
        finalize()
        return
      end

      handle_valid_json(parsed_fix, fix_response, fixed_json)
    end)
  end

  local json_str = extract_json(response_content)
  if json_str then
    local ok, parsed = pcall(vim.json.decode, json_str)
    if ok then
      handle_valid_json(parsed, response_content, json_str)
      return
    end
    vim.notify("Failed to parse LLM JSON response; attempting repair.", vim.log.levels.WARN)
  else
    vim.notify("Could not find JSON object in LLM response; attempting repair.", vim.log.levels.WARN)
  end

  request_json_fix(response_content)
end

function trigger_llm(reason)
  if state.is_pending_response() then
    state.enqueue_trigger(reason)
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
  ollama.request(profile, system_prompt, user_prompt, history, reason, function(response_content)
    handle_llm_response(response_content, {
      buddy_name = buddy_name,
      system_prompt = system_prompt,
      user_prompt = user_prompt,
      reason = reason,
    })
  end)
end

function M.add_event(event_type, details)
  state.add_event(event_type, details)
  if #state.get_event_accumulator() >= config.options.core.event_threshold then
    trigger_llm("Event threshold reached")
  end
end

function M.on_user_message(message)
  state.add_chat_message("user", message)
  if not ui.is_open() then
    ui.open()
  end
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
function M.init(opts)
  opts = opts or {}
  state.init()
  if opts.buddy_name then
    state.set_active_buddy(opts.buddy_name)
  end
  events.setup_listeners(M.add_event)
  setup_timers()
end

return M
