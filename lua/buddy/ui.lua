-- lua/buddy/ui.lua
-- Manages the floating modal window for the buddy chat.

local M = {}

local config = require("buddy.config")
local state = require("buddy.state")

local ui_state = {
  bufnr = nil,
  win_id = nil,
  input_bufnr = nil,
  input_win_id = nil,
}

local on_user_message_callback = nil

function M.init(callbacks)
    on_user_message_callback = callbacks.on_user_message
end

local function get_win_config()
  local width = config.options.ui.width
  local height = config.options.ui.height
  local screen_width = vim.o.columns
  local screen_height = vim.o.lines

  return {
    relative = "editor",
    width = width,
    height = height,
    col = screen_width - width - 2,
    row = screen_height - height - 2,
    border = config.options.ui.border,
    style = "minimal",
    focusable = false,
    zindex = 100,
  }
end

local function word_wrap(text, max_width)
  local wrapped_lines = {}
  for raw_line in text:gmatch("[^\n]+") do
    local line = raw_line
    while #line > max_width do
      local segment = line:sub(1, max_width)
      local break_index = segment:match("^.*()%s+")
      if break_index and break_index > 0 then
        table.insert(wrapped_lines, segment:sub(1, break_index - 1))
        line = line:sub(break_index + 1)
      else
        table.insert(wrapped_lines, segment)
        line = line:sub(max_width + 1)
      end
      line = line:gsub("^%s+", "")
    end
    table.insert(wrapped_lines, line)
  end
  return wrapped_lines
end


---Renders the content of the chat window.
function M.render()
  if not ui_state.win_id or not vim.api.nvim_win_is_valid(ui_state.win_id) then
    return
  end

  local lines = {}
  local history = state.get_chat_history()
  local max_msg_width = config.options.ui.width - 4

  for _, msg in ipairs(history) do
    local sender = msg.sender == "user" and "You" or state.get_active_buddy()
    table.insert(lines, string.format("%s:", sender))
    local wrapped_text = word_wrap(msg.text, max_msg_width)
    for _, line in ipairs(wrapped_text) do
        table.insert(lines, "  " .. line)
    end
    table.insert(lines, "") -- Spacer
  end

  vim.api.nvim_buf_set_option(ui_state.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(ui_state.bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(ui_state.bufnr, "modifiable", false)

  -- Auto-scroll to bottom
  if #lines > 0 then
    vim.api.nvim_win_set_cursor(ui_state.win_id, { #lines, 0 })
  end
end

local function create_chat_window()
  ui_state.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui_state.bufnr, "buftype", "nofile")

  local win_opts = get_win_config()
  win_opts.title = "Buddy Chat"
  ui_state.win_id = vim.api.nvim_open_win(ui_state.bufnr, false, win_opts)
end

---Opens the buddy window.
function M.open()
  if ui_state.win_id and vim.api.nvim_win_is_valid(ui_state.win_id) then
    return
  end

  create_chat_window()
  M.render()
end

---Closes the buddy window.
function M.close()
  if ui_state.win_id and vim.api.nvim_win_is_valid(ui_state.win_id) then
    vim.api.nvim_win_close(ui_state.win_id, true)
  end
  ui_state.win_id = nil
  ui_state.bufnr = nil
  ui_state.input_win_id = nil
  ui_state.input_bufnr = nil
end

---Toggles the buddy window visibility.
function M.toggle()
  if ui_state.win_id and vim.api.nvim_win_is_valid(ui_state.win_id) then
    M.close()
  else
    M.open()
  end
end

return M
