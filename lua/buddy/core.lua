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

local event_weights = {
  Plugin = 15,
  BufEnter = 5,
  BufDelete = 5, -- Added BufDelete with a weight of 5
  TextChanged = 1,
  TextChangedI = 1,
  CursorHold = 1,
  CursorHoldI = 1,
}

local function collect_event_messages(events)
  if not events or #events == 0 then
    return {}
  end

  local function basename(path)
    if not path or path == "" then return nil end
    local name = vim.fn.fnamemodify(path, ":t")
    if name == "" then
      return nil
    end
    return name
  end

  local tools = {}
  local switch_sequence, switch_seen = {}, {}
  local closed_files = {}
  local edits = {}
  local pauses = 0

  for _, event in ipairs(events) do
    local details = event.details or {}
    if event.type == "Plugin" then
      if details.name and not tools[details.name] then
        tools[details.name] = true
      end
    elseif event.type == "BufEnter" then
      local name = basename(details.file)
      if name then
        table.insert(switch_sequence, name)
        switch_seen[name] = true
      end
    elseif event.type == "BufDelete" then
      local name = basename(details.file)
      if name then
        closed_files[name] = (closed_files[name] or 0) + 1
      end
    elseif event.type == "TextChanged" or event.type == "TextChangedI" then
      local name = basename(details.file)
      if name then
        edits[name] = (edits[name] or 0) + 1
      else
        edits["(unsaved buffer)"] = (edits["(unsaved buffer)"] or 0) + 1
      end
    elseif event.type == "CursorHold" or event.type == "CursorHoldI" then
      pauses = pauses + 1
    end
  end

  local messages = {}

  local tool_list = vim.tbl_keys(tools)
  table.sort(tool_list)
  if #tool_list > 0 then
    local joined = table.concat(tool_list, ", ")
    table.insert(messages, "opened tools: " .. joined .. ".")
  end

  if #switch_sequence > 0 then
    -- reduce consecutive duplicates
    local deduped = {}
    local last = nil
    for _, name in ipairs(switch_sequence) do
      if name ~= last then
        table.insert(deduped, name)
        last = name
      end
    end
    if #deduped == 1 then
      table.insert(messages, "switched to " .. deduped[1] .. ".")
    elseif #deduped == 2 then
      table.insert(messages, string.format("bounced between %s and %s.", deduped[1], deduped[2]))
    else
      local all_but_last = { unpack(deduped, 1, #deduped - 1) }
      table.insert(messages, string.format("cycled through %s, and %s.", table.concat(all_but_last, ", "), deduped[#deduped]))
    end
  end

  local closed_names = vim.tbl_keys(closed_files)
  table.sort(closed_names)
  for _, name in ipairs(closed_names) do
    local count = closed_files[name]
    if count > 1 then
      table.insert(messages, string.format("closed %s %d times.", name, count))
    else
      table.insert(messages, "closed " .. name .. ".")
    end
  end

  local edit_names = vim.tbl_keys(edits)
  table.sort(edit_names)
  for _, name in ipairs(edit_names) do
    local count = edits[name]
    if count > 2 then
      table.insert(messages, string.format("edited %s %d times.", name, count))
    elseif count == 2 then
      table.insert(messages, string.format("went back to tweak %s again.", name))
    else
      if name == "(unsaved buffer)" then
        table.insert(messages, "edited an unnamed buffer.")
      else
        table.insert(messages, "edited " .. name .. ".")
      end
    end
  end

  if pauses > 0 then
    if pauses == 1 then
      table.insert(messages, "paused for a moment.")
    else
      table.insert(messages, string.format("hit pause %d times.", pauses))
    end
  end

  if #messages == 0 then
    return { string.format("made %d moves in the editor.", #events) }
  end

  return messages
end

local function record_events_as_chat(events)
  local messages = collect_event_messages(events)
  local count = 0
  local max_messages = math.min(#messages, 5)
  for index = 1, max_messages do
    local msg = messages[index]
    if msg and msg ~= "" then
      msg = msg:gsub("^%l", string.upper)
      state.add_chat_message("rahul_event", msg)
      count = count + 1
    end
  end
  if #messages > max_messages then
    state.add_chat_message("rahul_event", "Kept juggling a few more things in the editor.")
    count = count + 1
  end
  return count
end

local function build_greeting_prompt(buddy_name)
  local context_lines = {
    "[START OF CONTEXT]",
    "User: Rahul",
    "Event: A new Neovim session has just started.",
    "Project: " .. vim.fn.getcwd(),
    "Time: " .. os.date(),
    "",
    "[YOUR TASK]",
    string.format("You are %s. Greet Rahul as he starts his session. Keep it brief and in-character.", buddy_name),
    "Respond ONLY with the JSON format defined in your system prompt.",
  }
  return table.concat(context_lines, "\n")
end

local function build_user_prompt(buddy_name, research_result)
  local internal_state = state.get_llm_internal_state(buddy_name)
  local chat_history = state.get_recent_chat_history()
  local memory_notes = profiles.get_memory(buddy_name)
  local topic_bank = profiles.get_topic_bank(buddy_name)

  -- Gather context
  local git_comments = external.get_last_git_comments(5)

  local context_lines = {
    "[START OF CONTEXT]",
    "User: Rahul",
    "Project: " .. vim.fn.getcwd(),
    "Current File: " .. vim.api.nvim_buf_get_name(0),
    "Last 5 Git Commits:\n" .. git_comments,
  }

  if research_result then
    table.insert(context_lines, "\n[RESEARCH RESULT]")
    table.insert(context_lines, research_result)
  end

  if topic_bank and #topic_bank > 0 then
    table.insert(context_lines, "\n[POTENTIAL TOPICS TO DISCUSS]")
    -- Get up to 5 random topics
    local random_topics = {}
    local topic_count = #topic_bank
    local num_to_get = math.min(5, topic_count)

    -- Simple random sampling
    for i = 1, topic_count do
      local j = math.random(i, topic_count)
      topic_bank[i], topic_bank[j] = topic_bank[j], topic_bank[i]
    end
    for i = 1, num_to_get do
      table.insert(random_topics, "- " .. topic_bank[i].idea)
    end
    table.insert(context_lines, table.concat(random_topics, "\n"))
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
    local sender
    if msg.sender == "user" then
      sender = "Rahul"
    elseif msg.sender and msg.sender ~= "" then
      sender = msg.sender
    else
      sender = buddy_name
    end
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
  local ctx_buddy_name = ctx and ctx.buddy_name or state.get_active_buddy()
  local function finalize()
    if ctx and ctx.finalize then
      ctx.finalize()
    else
      state.set_pending_response(false)
      process_trigger_queue()
    end
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

  local function handle_research_action(parsed)
    local topic = parsed.research_topic
    if not topic or topic == "" then
      finalize()
      return
    end

    state.set_pending_response(false)

    ollama.research(topic, function(research_result)
      if research_result then
        trigger_llm("Research result for '" .. topic .. "'", research_result)
      else
        finalize()
      end
    end)
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

    if response_type == "research" then
      handle_research_action(parsed)
      return -- Research action handles its own finalization path
    end

    if response_type == "speak" and (not message or message == "") then
      message = extract_fallback_message(raw, json_segment)
    end
    if response_type == "speak" and (not message or message == "") and internal_state_update and internal_state_update ~= "" then
      message = internal_state_update
    end

    if response_type == "speak" and message and message ~= "" then
      local clean_message = message:gsub("\n", " "):gsub("^%s+", ""):gsub("%s+$", "")
      local last_buddy_message = state.get_last_buddy_message(ctx_buddy_name)
      if not (last_buddy_message and last_buddy_message == clean_message) then
        state.add_chat_message(ctx_buddy_name, clean_message)
        if not ui.is_open() then
          ui.open()
        end
        ui.render()
      end
    end

    local memory_to_store = parsed.memory_to_store
    if memory_to_store == vim.NIL then
      memory_to_store = nil
    end
    local function append_memory(target, entry)
      if not entry or entry == "" then
        return
      end
      target = target or ctx_buddy_name
      if not target then
        return
      end
      if type(target) == "string" then
        local lowered = target:lower()
        if lowered == "rahul" or lowered == "user" then
          return
        end
      end
      profiles.append_memory(target, entry)
    end

    local function handle_memory_payload(payload, default_target)
      if not payload then
        return
      end

      if type(payload) == "string" then
        append_memory(default_target, payload)
        return
      end

      if vim.islist(payload) then
        for _, item in ipairs(payload) do
          handle_memory_payload(item, default_target)
        end
        return
      end

      if type(payload) == "table" then
        local target = payload.target or payload.buddy or payload.owner or default_target
        local entry = payload.entry or payload.text or payload.note
        if payload.entries and vim.islist(payload.entries) then
          for _, item in ipairs(payload.entries) do
            append_memory(target, item)
          end
        end
        if entry then
          append_memory(target, entry)
        end
        return
      end
    end

    handle_memory_payload(memory_to_store, ctx_buddy_name)

    if internal_state_update then
      state.set_llm_internal_state(ctx_buddy_name, internal_state_update)
    end
  end

  local function handle_valid_json(parsed, raw, json_segment)
    apply_parsed_response(parsed, raw, json_segment)
    finalize()
  end

  local function request_json_fix(raw_response)
    vim.notify("Buddy: LLM JSON parse failed. Attempting repair.", vim.log.levels.WARN)
    local fixer_opts = config.options.ollama.json_fixer or {}
    local fixer_model = fixer_opts.model or "gemma3:4b"

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
        vim.notify("Buddy: JSON fixer failed to return a response.", vim.log.levels.ERROR)
        finalize()
        return
      end

      local fixed_json = extract_json(fix_response) or fix_response
      local ok_fix, parsed_fix = pcall(vim.json.decode, fixed_json)
      if not ok_fix then
        vim.notify("Buddy: JSON fixer returned invalid JSON: " .. fixed_json, vim.log.levels.ERROR)
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
  end

  request_json_fix(response_content)
end

local function start_llm_request(buddy_name, reason, user_prompt, history, finalize_cb, system_prompt_override)
  local profile = profiles.get_buddy_profile(buddy_name)
  local system_prompt = system_prompt_override or profiles.get_system_prompt(buddy_name)
  if not system_prompt then
    if finalize_cb then
      finalize_cb()
    else
      state.set_pending_response(false)
      process_trigger_queue()
    end
    return
  end

  history = history or state.get_recent_chat_history()

  ollama.request(profile, system_prompt, user_prompt, history, reason, function(response_content)
    handle_llm_response(response_content, {
      buddy_name = buddy_name,
      system_prompt = system_prompt,
      user_prompt = user_prompt,
      reason = reason,
      finalize = finalize_cb,
    })
  end)
end

function trigger_llm(reason, research_result)
  if state.is_pending_response() then
    state.enqueue_trigger(reason)
    return
  end

  state.set_pending_response(true)

  local active_buddy = state.get_active_buddy()
  local events_snapshot = state.clear_event_accumulator() or {}
  record_events_as_chat(events_snapshot)

  if profiles.is_group(active_buddy) then
    local members = profiles.get_group_members(active_buddy)
    if #members == 0 then
      state.set_pending_response(false)
      process_trigger_queue()
      return
    end

    local function run_member(index)
      if index > #members then
        state.set_pending_response(false)
        process_trigger_queue()
        return
      end

      local member_name = members[index]
      local user_prompt = build_user_prompt(member_name, research_result)

      start_llm_request(member_name, reason, user_prompt, nil, function()
        run_member(index + 1)
      end)
    end

    run_member(1)
    return
  end

  local user_prompt = build_user_prompt(active_buddy, research_result)
  start_llm_request(active_buddy, reason, user_prompt)
end

function M.add_event(event_type, details)
  state.add_event(event_type, details)

  local weight = event_weights[event_type] or 1
  state.add_to_current_event_weight(weight)

  if state.get_current_event_weight() >= config.options.core.event_weight_threshold then
    trigger_llm("Event weight threshold reached")
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

local function fetch_new_topic_ideas()
  local buddy_name = state.get_active_buddy()
  if not buddy_name then return end
  if profiles.is_group(buddy_name) then
    return
  end

  ollama.generate_topics(function(topics)
    if topics and #topics > 0 then
      local new_ideas = {}
      for _, topic in ipairs(topics) do
        table.insert(new_ideas, { idea = topic, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") })
      end
      profiles.add_topics(buddy_name, new_ideas)
    end
  end)
end

local function setup_timers()
  -- Idle timer
  vim.fn.timer_start(config.options.core.idle_threshold, function()
    trigger_llm("Idle threshold reached")
  end, { ["repeat"] = -1 })

  -- Topic generation timer
  local topic_interval = config.options.core.topic_generation_interval
  if topic_interval and topic_interval > 0 then
    vim.fn.timer_start(topic_interval, function()
      fetch_new_topic_ideas()
    end, { ["repeat"] = -1 })
  end
end

local function trigger_initial_greeting()
  if state.is_pending_response() then
    -- If something is already running, just skip the greeting
    return
  end

  state.set_pending_response(true)

  local active_buddy = state.get_active_buddy()

  if profiles.is_group(active_buddy) then
    local members = profiles.get_group_members(active_buddy)
    if #members == 0 then
      state.set_pending_response(false)
      return
    end

    local function greet_member(index)
      if index > #members then
        state.set_pending_response(false)
        process_trigger_queue()
        return
      end

      local member_name = members[index]
      local user_prompt = build_greeting_prompt(member_name)

      start_llm_request(member_name, "Initial Greeting", user_prompt, {}, function()
        greet_member(index + 1)
      end)
    end

    greet_member(1)
    return
  end

  local user_prompt = build_greeting_prompt(active_buddy)
  start_llm_request(active_buddy, "Initial Greeting", user_prompt, {})
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
  -- Trigger a greeting on startup
  vim.defer_fn(function()
    trigger_initial_greeting()
  end, 1000)
end

return M
