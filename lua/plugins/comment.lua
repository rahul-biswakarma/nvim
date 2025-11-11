--[[
  Comment - Smart Code Commenting
  
  Quickly comment/uncomment code with context-aware commenting.
  Supports line and block comments for all languages via Treesitter.
  
  NOTE: Keymaps use plugin's internal config (can't be centralized).
]]

return {
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
  opts = {
    -- ============================================================================
    -- BEHAVIOR
    -- ============================================================================
    padding = true,         -- Add space after comment string
    sticky = true,          -- Cursor stays at position
    ignore = '^$',          -- Ignore empty lines
    
    -- ============================================================================
    -- KEYMAPS (Plugin Config - Not Centralized)
    -- ============================================================================
    -- Toggle mappings in NORMAL mode
    toggler = {
      line = '<leader>/',   -- Toggle line comment
      block = '<leader>bc', -- Toggle block comment
    },
    
    -- Operator-pending mappings in NORMAL and VISUAL mode
    opleader = {
      line = '<leader>/',   -- Line comment operator
      block = '<leader>bc', -- Block comment operator
    },
    
    -- Extra mappings
    extra = {
      above = '<leader>cO', -- Add comment above
      below = '<leader>co', -- Add comment below
      eol = '<leader>cA',   -- Add comment at end of line
    },
    
    -- ============================================================================
    -- MAPPING FEATURES
    -- ============================================================================
    mappings = {
      basic = true,  -- Enable gcc, gbc, gc[count]{motion}, gb[count]{motion}
      extra = true,  -- Enable gco, gcO, gcA
    },
    
    -- ============================================================================
    -- HOOKS
    -- ============================================================================
    pre_hook = nil,   -- Function to call before (un)comment
    post_hook = nil,  -- Function to call after (un)comment
  },
  config = function(_, opts)
    require('Comment').setup(opts)
    
    -- ============================================================================
    -- REGISTER KEYMAPS FOR TRACKING
    -- ============================================================================
    local kb = require('core.keybindings-registry')
    
    -- Register for conflict detection (keymaps defined above in plugin config)
    kb.register_keymaps('comment', {
      { 'n', '<leader>/', 'comment', { desc = 'Toggle line comment' } },
      { 'v', '<leader>/', 'comment', { desc = 'Toggle line comment' } },
      { 'n', '<leader>bc', 'comment', { desc = 'Toggle block comment' } },
      { 'v', '<leader>bc', 'comment', { desc = 'Toggle block comment' } },
      { 'n', '<leader>cO', 'comment', { desc = 'Comment above' } },
      { 'n', '<leader>co', 'comment', { desc = 'Comment below' } },
      { 'n', '<leader>cA', 'comment', { desc = 'Comment end of line' } },
      { 'n', 'gcc', 'comment', { desc = 'Toggle line comment' } },
      { 'n', 'gbc', 'comment', { desc = 'Toggle block comment' } },
      { 'n', 'gc', 'comment', { desc = 'Comment operator' } },
      { 'v', 'gc', 'comment', { desc = 'Comment selection' } },
      { 'n', 'gb', 'comment', { desc = 'Block comment operator' } },
      { 'v', 'gb', 'comment', { desc = 'Block comment selection' } },
    })
  end,
}
