-- lua/buddy/state.lua
-- Manages the session state for the buddy framework.

local M = {}

local config = require("buddy.config")

-- This table holds the current session state.
local session_state = {
  active_buddy_name = nil,
  session_chat_history = {},
  event_accumulator = {},
  llm_internal_state = "",
  browser_tabs_cache = {},
  last_llm_call_time = 0,
  pending_response = false,
}

---Initializes the state module.
function M.init()
  session_state.active_buddy_name = config.options.default_buddy
  M.reset_for_buddy_switch()
end

---Resets state that is specific to a buddy.
function M.reset_for_buddy_switch()
  session_state.session_chat_history = {}
  session_state.event_accumulator = {}
  session_state.llm_internal_state = ""
end

---Sets the active buddy.
---@param buddy_name string
function M.set_active_buddy(buddy_name)
  if session_state.active_buddy_name ~= buddy_name then
    session_state.active_buddy_name = buddy_name
    M.reset_for_buddy_switch()
    vim.notify("Switched buddy to: " .. buddy_name)
  end
end

---Gets the currently active buddy's name.
---@return string
function M.get_active_buddy()
  return session_state.active_buddy_name
end

---Adds a message to the session's chat history.
---@param sender string 'user' or 'buddy'
---@param message string The chat message.
function M.add_chat_message(sender, message)
  table.insert(session_state.session_chat_history, {
    sender = sender,
    text = message,
    timestamp = os.time(),
  })
end

---Gets the current chat history.
---@return table
function M.get_chat_history()
  return session_state.session_chat_history
end

---Adds a neovim event to the accumulator.
---@param event_type string
---@param details table
function M.add_event(event_type, details)
  table.insert(session_state.event_accumulator, {
    type = event_type,
    details = details,
    timestamp = os.time(),
  })
end

---Clears the event accumulator.
---@return table The events that were cleared.
function M.clear_event_accumulator()
  local events = session_state.event_accumulator
  session_state.event_accumulator = {}
  return events
end

---Gets the current event accumulator.
---@return table
function M.get_event_accumulator()
    return session_state.event_accumulator
end

---Updates the LLM's internal state (scratchpad).
---@param new_state string
function M.set_llm_internal_state(new_state)
  session_state.llm_internal_state = new_state
end

---Gets the LLM's internal state.
---@return string
function M.get_llm_internal_state()
  return session_state.llm_internal_state
end

---Updates the browser tabs cache.
---@param tabs table
function M.set_browser_tabs(tabs)
  session_state.browser_tabs_cache = tabs
end

---Gets the browser tabs cache.
---@return table
function M.get_browser_tabs()
  return session_state.browser_tabs_cache
end

function M.is_pending_response()
    return session_state.pending_response
end

function M.set_pending_response(pending)
    session_state.pending_response = pending
end

function M.get_last_buddy_message()
  for i = #session_state.session_chat_history, 1, -1 do
    local entry = session_state.session_chat_history[i]
    if entry.sender == "buddy" then
      return entry.text
    end
  end
  return nil
end

return M
