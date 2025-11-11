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
    -- CHECK IF ESLINT IS AVAILABLE
    -- ============================================================================
    local has_eslint = vim.fn.executable('eslint') == 1

    -- ============================================================================
    -- LINTERS BY FILETYPE
    -- ============================================================================
    lint.linters_by_ft = {
      -- Only enable ESLint if it's installed
      -- javascript = { 'eslint' },
      -- javascriptreact = { 'eslint' },
      -- typescript = { 'eslint' },
      -- typescriptreact = { 'eslint' },
    }

    -- Enable ESLint only if available
    if has_eslint then
      lint.linters_by_ft.javascript = { 'eslint' }
      lint.linters_by_ft.javascriptreact = { 'eslint' }
      lint.linters_by_ft.typescript = { 'eslint' }
      lint.linters_by_ft.typescriptreact = { 'eslint' }
    end

    -- ============================================================================
    -- AUTO-LINT TRIGGERS
    -- ============================================================================
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        -- Only lint if linters are configured for this filetype
        local ft = vim.bo.filetype
        if lint.linters_by_ft[ft] and #lint.linters_by_ft[ft] > 0 then
          lint.try_lint()
        end
      end,
    })
  end,
}
