return {
  'phaazon/hop.nvim',
  branch = 'v2',
  config = function()
    require('hop').setup { keys = 'etovxqpdygfblzhckisuran' }
    
    -- Keybindings for fast navigation
    vim.keymap.set('n', 's', ':HopChar2<CR>', { desc = 'Hop to 2 chars' })
    vim.keymap.set('n', 'S', ':HopWord<CR>', { desc = 'Hop to word' })
    vim.keymap.set('n', '<leader>j', ':HopLine<CR>', { desc = 'Hop to line' })
    vim.keymap.set('n', '<leader>/', ':HopPattern<CR>', { desc = 'Hop to pattern' })
  end,
}

