--[[
  HLArgs - Highlight Function Arguments
  
  Highlights function arguments with a distinct color using Treesitter.
  Helps identify parameter usage throughout your code.
]]

return {
  'm-demare/hlargs.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('hlargs').setup({
      -- ============================================================================
      -- APPEARANCE
      -- ============================================================================
      color = '#ef9062',  -- Orange color for highlighted arguments
      highlight = {},     -- Custom highlight overrides
      excluded_filetypes = {},  -- Filetypes to exclude from highlighting
      
      -- ============================================================================
      -- HIGHLIGHTING BEHAVIOR
      -- ============================================================================
      paint_arg_declarations = true,  -- Highlight function parameter declarations
      paint_arg_usages = true,        -- Highlight argument usage in function body
      
      paint_catch_blocks = {
        declarations = false,  -- Don't highlight catch block declarations
        usages = false,        -- Don't highlight catch block usages
      },
      
      extras = {
        named_parameters = false,  -- Don't highlight named parameters
      },
      
      hl_priority = 10000,  -- High priority to ensure visibility
      
      -- ============================================================================
      -- EXCLUSIONS
      -- ============================================================================
      excluded_argnames = {
        declarations = {},  -- No excluded declaration names
        usages = {
          python = { 'self', 'cls' },  -- Don't highlight 'self' and 'cls' in Python
          lua = { 'self' },            -- Don't highlight 'self' in Lua
        },
      },
      
      -- ============================================================================
      -- PERFORMANCE TUNING
      -- ============================================================================
      performance = {
        parse_delay = 1,              -- Initial parse delay (ms)
        slow_parse_delay = 50,        -- Delay for slow parses (ms)
        max_iterations = 400,         -- Max parsing iterations
        max_concurrent_partial_parses = 30,  -- Max concurrent partial parses
        
        debounce = {
          partial_parse = 3,           -- Partial parse debounce (ms)
          partial_insert_mode = 100,   -- Insert mode debounce (ms)
          total_parse = 700,           -- Total parse debounce (ms)
          slow_parse = 5000,           -- Slow parse debounce (ms)
        },
      },
    })
  end,
}
