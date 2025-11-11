--[[
  Illuminate - Highlight Word Under Cursor
  
  Automatically highlights other occurrences of the word under cursor.
  Helps quickly see where a variable/function is used.
]]

return {
  'RRethy/vim-illuminate',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    delay = 200,               -- Delay before highlighting (ms)
    large_file_cutoff = 2000,  -- Disable for files larger than 2000 lines
    large_file_overrides = {
      providers = { 'lsp' },   -- Use only LSP for large files
    },
  },
  config = function(_, opts)
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry')
    
    require('illuminate').configure(opts)

    -- ============================================================================
    -- KEYMAPS (Using centralized registry)
    -- ============================================================================
    local function map(key, dir, buffer)
      kb.register_keymap('illuminate', 'n', key, function()
        require('illuminate')['goto_' .. dir .. '_reference'](false)
      end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference', buffer = buffer })
    end

    -- Set keymaps
    map(keys.next_reference, 'next')
    map(keys.prev_reference, 'prev')

    -- Re-apply keymaps after FileType event (some ftplugins override ]] and [[)
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()
        map(keys.next_reference, 'next', buffer)
        map(keys.prev_reference, 'prev', buffer)
      end,
    })
  end,
  keys = function()
    local keys = require('core.keybindings-registry')
    return {
      { keys.next_reference, desc = 'Next Reference' },
      { keys.prev_reference, desc = 'Prev Reference' },
    }
  end,
}
