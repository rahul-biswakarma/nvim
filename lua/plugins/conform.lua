--[[
  Conform - Code Formatting
  
  Modern formatter plugin with support for multiple formatters per filetype.
  Automatically formats on save with LSP fallback.
]]

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = function()
    local keys = require('core.keybindings-registry')
    return {
    {
        keys.format_buffer,
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
        mode = { 'n', 'v' },
        desc = 'Format buffer',
    },
    }
  end,
  config = function()
    local conform = require('conform')

    -- ============================================================================
    -- FORMATTER CONFIGURATION
    -- ============================================================================
    conform.setup {
      -- Map file types to formatters (priority order)
      formatters_by_ft = {
        -- Lua
        lua = { 'stylua' },
        
        -- JavaScript/TypeScript ecosystem
        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        
        -- Web formats
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
        html = { 'prettier' },
        css = { 'prettier' },
        scss = { 'prettier' },
      },
      
      -- ============================================================================
      -- AUTO-FORMAT ON SAVE
      -- ============================================================================
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,  -- Use LSP formatter if conform formatter unavailable
      },
    }
  end,
}
