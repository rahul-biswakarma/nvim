--[[
  Indent Blankline - Indentation Guides
  
  Shows vertical lines for indent levels to improve code readability.
  Highlights the current scope/block you're in.
]]

return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    -- ============================================================================
    -- INDENT CHARACTERS
    -- ============================================================================
    indent = {
      char = '│',      -- Character for indent guides
      tab_char = '│',  -- Character for tab indents
    },
    
    -- ============================================================================
    -- SCOPE HIGHLIGHTING
    -- ============================================================================
    scope = {
      enabled = true,             -- Enable scope highlighting
      show_start = true,          -- Show scope start line
      show_end = false,           -- Don't show scope end line
      injected_languages = false, -- Don't highlight injected languages separately
      highlight = { 'Function', 'Label' },  -- Highlight groups to use
      priority = 500,             -- Priority for scope highlighting
    },
    
    -- ============================================================================
    -- EXCLUDED FILETYPES
    -- ============================================================================
    exclude = {
      filetypes = {
        'help',
        'alpha',
        'dashboard',
        'neo-tree',
        'Trouble',
        'trouble',
        'lazy',
        'mason',
        'notify',
        'toggleterm',
        'lazyterm',
      },
    },
  },
}
