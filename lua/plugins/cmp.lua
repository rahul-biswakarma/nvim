--[[
  Nvim-cmp - Autocompletion
  
  Provides intelligent autocompletion with LSP integration.
  Sources: LSP, snippets (LuaSnip), file paths.
  
  NOTE: Keymaps here are context-dependent (insert mode, completion menu).
  They don't conflict with normal mode shortcuts.
]]

return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    'L3MON4D3/LuaSnip',           -- Snippet engine
    'saadparwaiz1/cmp_luasnip',   -- LuaSnip completion source
    'hrsh7th/cmp-nvim-lsp',       -- LSP completion source
    'hrsh7th/cmp-path',           -- File path completion
    'rafamadriz/friendly-snippets', -- Preconfigured snippets
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    
    -- ============================================================================
    -- SNIPPET SETUP
    -- ============================================================================
    require('luasnip.loaders.from_vscode').lazy_load()
    luasnip.config.setup {}

    -- ============================================================================
    -- COMPLETION SETUP
    -- ============================================================================
    cmp.setup {
      -- Snippet expansion
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      
      -- Completion window appearance
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      
      -- ============================================================================
      -- KEYMAPS (Insert Mode - Context-Dependent)
      -- ============================================================================
      mapping = cmp.mapping.preset.insert {
        -- Navigate completion menu
        ['<C-n>'] = cmp.mapping.select_next_item(),      -- Next suggestion
        ['<C-p>'] = cmp.mapping.select_prev_item(),      -- Previous suggestion
        
        -- Scroll documentation
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),         -- Scroll up
        ['<C-f>'] = cmp.mapping.scroll_docs(4),          -- Scroll down
        
        -- Trigger/confirm completion
        ['<C-Space>'] = cmp.mapping.complete {},         -- Manually trigger completion
        ['<CR>'] = cmp.mapping.confirm {                 -- Accept completion
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        
        -- Smart Tab: Navigate completion OR expand/jump snippets
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()                       -- Next in menu
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()                     -- Expand/jump snippet
          else
            fallback()                                    -- Default Tab behavior
          end
        end, { 'i', 's' }),  -- Insert & Select modes
        
        -- Smart Shift-Tab: Navigate completion OR jump back in snippets
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()                       -- Previous in menu
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)                             -- Jump back in snippet
          else
            fallback()                                    -- Default Shift-Tab behavior
          end
        end, { 'i', 's' }),  -- Insert & Select modes
      },
      
      -- ============================================================================
      -- COMPLETION SOURCES (Priority Order)
      -- ============================================================================
      sources = {
        { name = 'nvim_lsp' },  -- LSP completion (highest priority)
        { name = 'luasnip' },   -- Snippet completion
        { name = 'path' },      -- File path completion
      },
    }
    
    -- ============================================================================
    -- REGISTER KEYMAPS FOR TRACKING (Context-dependent, insert mode only)
    -- ============================================================================
    local kb = require('core.keybindings-registry')
    
    -- Note: These are registered for documentation/conflict detection only.
    -- They only work in insert mode when completion menu is visible.
    kb.register_keymaps('cmp', {
      { 'i', '<C-n>', 'cmp', { desc = 'Next completion' } },
      { 'i', '<C-p>', 'cmp', { desc = 'Previous completion' } },
      { 'i', '<C-d>', 'cmp', { desc = 'Scroll docs up' } },
      { 'i', '<C-f>', 'cmp', { desc = 'Scroll docs down' } },
      { 'i', '<C-Space>', 'cmp', { desc = 'Trigger completion' } },
      { 'i', '<CR>', 'cmp', { desc = 'Confirm completion' } },
      { 'i', '<Tab>', 'cmp', { desc = 'Next item/expand snippet' } },
      { 'i', '<S-Tab>', 'cmp', { desc = 'Previous item/jump back' } },
    })
  end,
}
