-- lua/buddy/events.lua
-- Listens to Neovim events to gather context for the buddy.

local M = {}

local add_event_callback = nil

local function is_buffer_ignorable(bufnr)
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
  if
    buftype == "nofile"
    or buftype == "prompt"
    or buftype == "quickfix"
    or buftype == "terminal"
  then
    return true
  end

  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if filetype == "NvimTree" or filetype:match("buddy") then
    return true
  end

  return false
end

---Adds an event to the accumulator.
---@param event_type string The type of event (e.g., 'BufEnter', 'TextChanged').
---@param details table Additional details about the event.
local function add_event(event_type, details)
  if add_event_callback then
    add_event_callback(event_type, details)
  end
end

---Sets up all the autocmds for event listening.
---@param callback function The function to call when an event occurs.
function M.setup_listeners(callback)
  add_event_callback = callback
  local event_group = vim.api.nvim_create_augroup("NvimBuddyEvents", { clear = true })

  local events = {
    "BufEnter",
    "TextChanged",
    "TextChangedI",
    "CursorHold",
    "CursorHoldI",
  }

  vim.api.nvim_create_autocmd(events, {
    group = event_group,
    callback = function(args)
      if is_buffer_ignorable(args.buf) then
        return
      end

      local details = {
        file = vim.api.nvim_buf_get_name(args.buf),
        event_type = args.event,
      }

      if args.event == "TextChanged" or args.event == "TextChangedI" then
        -- In a real scenario, we might add more info, like line count changes.
        details.lines_changed = "??" -- Placeholder
      end

      add_event(args.event, details)
    end,
  })
end

return M
