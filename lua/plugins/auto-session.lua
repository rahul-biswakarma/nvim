return {
  'rmagatti/auto-session',
  config = function()
    require('auto-session').setup({
      log_level = 'error',
      auto_session_enable_last_session = true,
      auto_session_root_dir = vim.fn.stdpath('data') .. '/sessions/',
      auto_session_enabled = true,
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      pre_save_cmds = { 'Neotree close' },
      post_restore_cmds = { 'Neotree reveal' },
    })
    
    -- Keymaps
    vim.keymap.set('n', '<leader>ss', require('auto-session').SaveSession, { desc = '[S]ave [S]ession' })
    vim.keymap.set('n', '<leader>sr', require('auto-session').RestoreSession, { desc = '[S]ession [R]estore' })
    vim.keymap.set('n', '<leader>sd', require('auto-session').DeleteSession, { desc = '[S]ession [D]elete' })
  end,
}

