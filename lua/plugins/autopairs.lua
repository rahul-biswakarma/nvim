--[[
  Auto Pairs - Automatic Bracket/Quote Pairing
  
  Automatically inserts closing brackets, quotes, and parentheses.
  Integrates with Treesitter for smart pairing in different contexts.
]]

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup {
      check_ts = true,  -- Use Treesitter for context-aware pairing
      ts_config = {
        lua = { 'string' },  -- Don't add pairs in Lua strings
        javascript = { 'template_string' },  -- Don't add pairs in JS template strings
        java = false,  -- Don't check Treesitter on Java
      },
    }
  end,
}
