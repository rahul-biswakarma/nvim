return {
  'danilamihailov/beacon.nvim',
  event = 'VeryLazy',
  config = function()
    vim.g.beacon_size = 40
    vim.g.beacon_fade = 1
    vim.g.beacon_minimal_jump = 10
    vim.g.beacon_show_jumps = 1
    vim.g.beacon_ignore_buffers = { '\\w*git*\\w', 'NvimTree' }
    vim.g.beacon_enable = 1
    
    -- Customize beacon appearance
    vim.g.beacon_shrink = 1
    
    -- Beacon will flash when:
    -- - Jumping between windows
    -- - Jumping to search results
    -- - Using Telescope
    -- - Using Hop
    -- - Any large cursor movement
  end,
}

