--[[
  Startup UI Module
  
  Handles all visual rendering of the startup screen.
]]

local M = {}

-- Module state
local startup_buf = nil
local startup_win = nil

-- Load ASCII art
local art_header = require('ui.art')

-- Center text horizontally
local function center_text(text, width)
  local text_width = vim.fn.strdisplaywidth(text)
  if text_width >= width then
    return text
  end
  local padding = math.floor((width - text_width) / 2)
  return string.rep(' ', padding) .. text
end

-- Generate text content for the screen
local function get_welcome_text(pin_handler)
  local pin_display = pin_handler.get_pin_display()
  local error_text = pin_handler.get_error_message()
  local width = vim.o.columns
  
  local lines = {}
  table.insert(lines, '')
  
  -- Add centered ASCII art
  for _, art_line in ipairs(art_header.val) do
    table.insert(lines, center_text(art_line, width))
  end
  
  -- Add PIN interface
  table.insert(lines, '')
  table.insert(lines, center_text('Enter PIN: ' .. pin_display, width))
  if error_text ~= '' then
    table.insert(lines, center_text(error_text, width))
  else
    table.insert(lines, '')
  end
  table.insert(lines, '')
  
  return lines
end

-- Apply syntax highlighting
local function apply_highlights()
  if not startup_buf or not vim.api.nvim_buf_is_valid(startup_buf) then
    return
  end
  
  vim.api.nvim_buf_clear_namespace(startup_buf, -1, 0, -1)
  
  local hl_map = art_header.opts.hl
  local first_art_line = art_header.val[1]
  local art_width = vim.fn.strdisplaywidth(first_art_line)
  local width = vim.o.columns
  local padding_offset = math.floor((width - art_width) / 2)
  
  for line_idx, line_hl in ipairs(hl_map) do
    for _, hl_info in ipairs(line_hl) do
      local hl_name = hl_info[1]
      local start_col = hl_info[2] + padding_offset
      local end_col = hl_info[3] + padding_offset
      vim.api.nvim_buf_add_highlight(startup_buf, -1, hl_name, line_idx, start_col, end_col)
    end
  end
end

-- Update buffer content
function M.update_buffer(pin_handler)
  if not startup_buf or not vim.api.nvim_buf_is_valid(startup_buf) then
    return
  end
  
  vim.api.nvim_buf_set_option(startup_buf, 'modifiable', true)
  local lines = get_welcome_text(pin_handler)
  vim.api.nvim_buf_set_lines(startup_buf, 0, -1, false, lines)
  apply_highlights()
  vim.api.nvim_buf_set_option(startup_buf, 'modifiable', false)
end

-- Handle window resize
function M.handle_resize(pin_handler)
  if startup_win and vim.api.nvim_win_is_valid(startup_win) then
    local ui = vim.api.nvim_list_uis()[1]
    local win_width = ui.width
    local win_height = ui.height
    
    -- Update window size to full screen
    vim.api.nvim_win_set_config(startup_win, {
      width = win_width,
      height = win_height,
      row = 0,
      col = 0,
    })
    
    -- Update buffer content
      M.update_buffer(pin_handler)
  end
end

-- Setup keymaps for the buffer
local function setup_keymaps(buf, pin_handler, unlock_callback)
  -- Number keys (0-9)
  for i = 0, 9 do
    vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
      callback = function()
        pin_handler.add_digit(i)
        M.update_buffer(pin_handler)
      end,
    })
  end
  
  -- Backspace
  vim.api.nvim_buf_set_keymap(buf, 'n', '<BS>', '', {
    callback = function()
      pin_handler.backspace()
      M.update_buffer(pin_handler)
    end,
  })
  
  -- Enter key
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    callback = function()
      if pin_handler.validate_pin() then
        unlock_callback()
      else
        M.update_buffer(pin_handler)
      end
    end,
  })
end

-- Create the startup buffer
local function create_startup_buffer(pin_handler, unlock_callback)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, 'startup-screen')
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'startup')
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  
  local lines = get_welcome_text(pin_handler)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  apply_highlights()
  
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  
  setup_keymaps(buf, pin_handler, unlock_callback)
  
  return buf
end

-- Unlock and restore session
local function unlock_and_restore()
  vim.opt.laststatus = 2
  vim.opt.cmdheight = 1
  vim.opt.showmode = true
  
  -- Close startup window first
  if startup_win and vim.api.nvim_win_is_valid(startup_win) then
    vim.api.nvim_win_close(startup_win, true)
  end
  
  if startup_buf and vim.api.nvim_buf_is_valid(startup_buf) then
    vim.api.nvim_buf_delete(startup_buf, { force = true })
  end
  
  startup_buf = nil
  startup_win = nil
  
  -- Signal that startup is unlocked (for buddy chat)
  vim.g.startup_unlocked = true
  
  -- Wait a bit for windows to fully close, then restore session
  vim.defer_fn(function()
    -- Restore session
    local ok, auto_session = pcall(require, 'auto-session')
    if ok then
      auto_session.RestoreSession()
    end
    
    -- Wait for session restore to complete, then open file tree
    vim.defer_fn(function()
      local has_tree = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'neo-tree' then
          has_tree = true
          break
        end
      end
      
      if not has_tree then
        vim.cmd('Neotree reveal')
      end
      
      -- Signal buddy chat to initialize after session restore
      vim.defer_fn(function()
        vim.g.session_restored = true
        vim.api.nvim_exec_autocmds('User', { pattern = 'StartupUnlocked' })
      end, 200)
    end, 500)
  end, 200)
end

-- Show the startup screen
function M.show_startup_screen(pin_handler)
  local has_real_files = false
  for _, arg in ipairs(vim.fn.argv()) do
    if arg ~= '' and arg ~= '.' and not arg:match('^%-') then
      has_real_files = true
      break
    end
  end
  
  if has_real_files or pin_handler.is_unlocked() then
    return
  end
  
  local initial_buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(initial_buf) == '' then
    vim.api.nvim_buf_set_option(initial_buf, 'bufhidden', 'wipe')
  end
  
  startup_buf = create_startup_buffer(pin_handler, unlock_and_restore)
  
  -- Full-screen floating window (like lazygit)
  local ui = vim.api.nvim_list_uis()[1]
  local win_width = ui.width
  local win_height = ui.height
  
  startup_win = vim.api.nvim_open_win(startup_buf, true, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = 0,
    row = 0,
    style = 'minimal',
    border = 'rounded',
    focusable = true,
    zindex = 100,  -- High zindex to stay on top
  })
  
  vim.api.nvim_win_set_option(startup_win, 'number', false)
  vim.api.nvim_win_set_option(startup_win, 'relativenumber', false)
  vim.api.nvim_win_set_option(startup_win, 'cursorline', false)
  vim.api.nvim_win_set_option(startup_win, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(startup_win, 'wrap', true)
  
  vim.api.nvim_set_current_win(startup_win)
  
  vim.opt.laststatus = 0
  vim.opt.cmdheight = 0
  vim.opt.showmode = false
end

-- Get startup window (for external access)
function M.get_startup_win()
  return startup_win
end

return M

