--[[
  Hop - Fast Navigation
  
  Jump to any location on screen with minimal keystrokes.
  Uses 2-character search to reach any visible text quickly.
]]

return {
  'phaazon/hop.nvim',
  branch = 'v2',
  event = 'VeryLazy',
  config = function()
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry')
    
    require('hop').setup { 
      keys = 'etovxqpdygfblzhckisuran'  -- Home row optimized key sequence
    }
    
    -- ============================================================================
    -- KEYMAPS (Using centralized registry)
    -- ============================================================================
    kb.register_keymap('hop', 'n', keys.hop_char2, ':HopChar2<CR>', { desc = 'Hop to 2 chars' })
    kb.register_keymap('hop', 'n', keys.hop_word, ':HopWord<CR>', { desc = 'Hop to word' })
    kb.register_keymap('hop', 'n', keys.hop_line, ':HopLine<CR>', { desc = 'Hop to line' })
    kb.register_keymap('hop', 'n', keys.hop_pattern, ':HopPattern<CR>', { desc = 'Hop to pattern' })
  end,
}
