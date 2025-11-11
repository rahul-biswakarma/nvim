--[[
  Nvim-Lint - Asynchronous Linting
  
  Provides linting via external tools (ESLint, etc.).
  Complements LSP diagnostics with additional linter checks.
]]

return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require('lint')

    -- ============================================================================
    -- LINTERS BY FILETYPE
    -- ============================================================================
    lint.linters_by_ft = {
      javascript = { 'eslint' },
      javascriptreact = { 'eslint' },
      typescript = { 'eslint' },
      typescriptreact = { 'eslint' },
    }

    -- ============================================================================
    -- AUTO-LINT TRIGGERS
    -- ============================================================================
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()  -- Run linters for current filetype
      end,
    })
  end,
}
