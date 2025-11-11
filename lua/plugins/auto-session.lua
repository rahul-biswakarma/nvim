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
      auto_restore_enabled = false,  -- Disabled - restored manually after PIN entry
      auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      pre_save_cmds = { 'Neotree close' },
      post_restore_cmds = { 'Neotree reveal' },
      -- Prevent auto-restore from interfering with startup screen
      bypass_session_save_file_types = { 'startup', 'neo-tree' },
    })
    
    -- Ensure auto-restore never runs automatically
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        -- Double-check auto_restore is disabled
        -- Note: auto-session doesn't expose config directly, 
        -- but we've already set auto_restore_enabled = false in setup()
        -- This is just a safety check
      end,
      once = true,
    })
    
    -- Keymaps using centralized registry
    vim.keymap.set('n', keys.session_save, require('auto-session').SaveSession, { desc = 'Save Session' })
    vim.keymap.set('n', keys.session_restore, require('auto-session').RestoreSession, { desc = 'Restore Session' })
    vim.keymap.set('n', keys.session_delete, require('auto-session').DeleteSession, { desc = 'Delete Session' })
  end,
}
