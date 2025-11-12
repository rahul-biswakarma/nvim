-- lua/buddy/ui.lua
-- Manages the floating modal window for the buddy chat.

local M = {}

local config = require("buddy.config")
local state = require("buddy.state")

local ui_state = {
  bufnr = nil,
  win_id = nil,
  collapsed = false,
}

local on_user_message_callback = nil

---Sets up the highlight groups for the buddy UI.
local function setup_highlights()
  -- Using a base color of a pleasant blue
  local base_fg = "#7AA2F7"
  local tint1_fg = "#A9B1D6" -- Lighter tint for message text
  local bg_color = "#1F2335"
  local border_color = "#3B4261"

  vim.api.nvim_set_hl(0, "BuddyName", { fg = base_fg, bold = true })
  vim.api.nvim_set_hl(0, "BuddyMessage", { fg = tint1_fg })
  vim.api.nvim_set_hl(0, "BuddyHeader", { fg = tint1_fg, bold = true })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = bg_color })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_color, bg = bg_color })
end

function M.init(callbacks)
  on_user_message_callback = callbacks.on_user_message
end

local function get_win_config()
  local width = config.options.ui.width
  local height = ui_state.collapsed and 1 or config.options.ui.height
  local screen_width = vim.o.columns
  local screen_height = vim.o.lines

  return {
    relative = "editor",
    width = width,
    height = height,
    col = screen_width - width - 2,
    row = screen_height - height - 2,
    border = ui_state.collapsed and "none" or config.options.ui.border,
    style = "minimal",
    focusable = false,
    zindex = 100,
  }
end

function M.get_win_info()
  if not ui_state.win_id or not vim.api.nvim_win_is_valid(ui_state.win_id) then
    return nil
  end
  return {
    win_id = ui_state.win_id,
    config = get_win_config(),
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
  if not ui_state.bufnr or not vim.api.nvim_buf_is_valid(ui_state.bufnr) then
    return
  end

  vim.api.nvim_buf_set_option(ui_state.bufnr, "modifiable", true)
  vim.api.nvim_buf_clear_namespace(ui_state.bufnr, -1, 0, -1)

  local lines = {}
  if ui_state.collapsed then
    lines = { string.format("— %s (Press - to expand) —", state.get_active_buddy()) }
    vim.api.nvim_buf_set_lines(ui_state.bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_add_highlight(ui_state.bufnr, -1, "BuddyHeader", 0, 0, -1)
  else
    local history = state.get_chat_history()
    local max_msg_width = config.options.ui.width - 4
    local line_num = 0

    for _, msg in ipairs(history) do
      local sender
      if msg.sender == "user" then
        sender = "Rahul"
      elseif msg.sender == "rahul_event" then
        sender = "Rahul"
      else
        sender = msg.sender or state.get_active_buddy()
      end
      local sender_line = string.format("%s:", sender)
      table.insert(lines, sender_line)
      vim.api.nvim_buf_add_highlight(ui_state.bufnr, -1, "BuddyName", line_num, 0, #sender_line)
      line_num = line_num + 1

      local wrapped_text = word_wrap(msg.text, max_msg_width)
      for _, line in ipairs(wrapped_text) do
        local indented_line = "  " .. line
        table.insert(lines, indented_line)
        vim.api.nvim_buf_add_highlight(ui_state.bufnr, -1, "BuddyMessage", line_num, 0, #indented_line)
        line_num = line_num + 1
      end
      table.insert(lines, "") -- Spacer
      line_num = line_num + 1
    end
    vim.api.nvim_buf_set_lines(ui_state.bufnr, 0, -1, false, lines)
  end

  vim.api.nvim_buf_set_option(ui_state.bufnr, "modifiable", false)

  -- Auto-scroll to bottom
  if ui_state.win_id and vim.api.nvim_win_is_valid(ui_state.win_id) and not ui_state.collapsed then
    local line_count = vim.api.nvim_buf_line_count(ui_state.bufnr)
    if line_count > 0 then
      vim.api.nvim_win_set_cursor(ui_state.win_id, { line_count, 0 })
    end
  end
end

local function create_chat_window()
  setup_highlights()
  ui_state.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(ui_state.bufnr, "buftype", "nofile")

  local win_opts = get_win_config()
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
end

---Toggles the buddy window visibility.
function M.toggle()
  if ui_state.win_id and vim.api.nvim_win_is_valid(ui_state.win_id) then
    M.close()
  else
    M.open()
  end
end

function M.toggle_collapse()
  if not M.is_open() then return end
  ui_state.collapsed = not ui_state.collapsed
  
  local new_config = get_win_config()
  vim.api.nvim_win_set_config(ui_state.win_id, new_config)
  M.render()
end

function M.is_open()
  return ui_state.win_id and vim.api.nvim_win_is_valid(ui_state.win_id)
end

return M
