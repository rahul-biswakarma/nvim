--[[
  Beacon - Cursor Position Flash
  
  Flashes the cursor position when jumping to make it easier to find.
  Triggers on large cursor movements, window jumps, and search navigation.
]]

return {
  'danilamihailov/beacon.nvim',
  event = 'VeryLazy',
  config = function()
    -- Beacon configuration (global variables)
    vim.g.beacon_enable = 1
    vim.g.beacon_size = 40
    vim.g.beacon_fade = 1
    vim.g.beacon_shrink = 1
    vim.g.beacon_minimal_jump = 10
    vim.g.beacon_show_jumps = 1
    vim.g.beacon_ignore_buffers = { '\\w*git*\\w', 'NvimTree' }
    
    -- Beacon flashes on:
    --   • Jumping between windows
    --   • Jumping to search results  
    --   • Using Telescope
    --   • Using Hop
    --   • Any large cursor movement
  end,
}
