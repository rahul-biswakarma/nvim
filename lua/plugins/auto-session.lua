--[[
  Auto Session - Session Management
  
  Automatically saves and restores Neovim sessions.
  Integrates with startup screen - sessions restore after PIN entry.
]]

return {
  'rmagatti/auto-session',
  config = function()
    local keys = require('core.keybindings-registry')
    
    require('auto-session').setup({
      log_level = 'error',
      auto_session_enable_last_session = true,
      auto_session_root_dir = vim.fn.stdpath('data') .. '/sessions/',
      auto_session_enabled = true,
      auto_save_enabled = true,
      auto_restore_enabled = false,  -- Disabled initially, enabled after PIN entry
      auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      pre_save_cmds = { 'Neotree close' },
      post_restore_cmds = { 'Neotree reveal' },
    })
    
    -- Keymaps using centralized registry
    vim.keymap.set('n', keys.session_save, require('auto-session').SaveSession, { desc = 'Save Session' })
    vim.keymap.set('n', keys.session_restore, require('auto-session').RestoreSession, { desc = 'Restore Session' })
    vim.keymap.set('n', keys.session_delete, require('auto-session').DeleteSession, { desc = 'Delete Session' })
  end,
}
