--[[
  Startup Screen Module - Entry Point
  
  Displays a PIN-protected startup screen with ASCII art.
  Organized into separate modules for clarity.
]]

local M = {}

M.config = function()
  local pin_handler = require('ui.startup.pin-handler')
  local ui = require('ui.startup.ui')
  local session = require('ui.startup.session')
  
  -- Initialize PIN handler
  pin_handler.init()
  
  -- Setup VimEnter autocmd to show startup screen
  local startup_augroup = vim.api.nvim_create_augroup('StartupScreen', { clear = true })
  
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      vim.defer_fn(function()
        ui.show_startup_screen(pin_handler)
      end, 50)
    end,
    group = startup_augroup,
  })
  
  -- Lock buffer switching until unlocked
  vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
      if not pin_handler.is_unlocked() and vim.fn.argc() == 0 then
        local buf = vim.api.nvim_get_current_buf()
        local bufname = vim.api.nvim_buf_get_name(buf)
        if bufname ~= 'startup-screen' and bufname ~= '' then
          local win = ui.get_startup_win()
          if win and vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
          end
        end
      end
    end,
    group = vim.api.nvim_create_augroup('StartupScreenLock', { clear = true }),
  })
  
  -- Handle resize events
  vim.api.nvim_create_autocmd('VimResized', {
    callback = function()
      ui.handle_resize(pin_handler)
    end,
    group = startup_augroup,
  })
end

return M

