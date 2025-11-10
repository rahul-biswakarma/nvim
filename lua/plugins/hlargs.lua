return {
  'm-demare/hlargs.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('hlargs').setup({
      color = '#ef9062',
      highlight = {},
      excluded_filetypes = {},
      -- disable = function(_, bufnr)
      --   if vim.b.semantic_tokens then
      --     return true
      --   end
      --   local clients = vim.lsp.get_active_clients { bufnr = bufnr }
      --   for _, c in pairs(clients) do
      --     local caps = c.server_capabilities
      --     if c.name ~= 'null-ls' and caps.semanticTokensProvider and caps.semanticTokensProvider.full then
      --       vim.b.semantic_tokens = true
      --       return vim.b.semantic_tokens
      --     end
      --   end
      -- end,
      paint_arg_declarations = true,
      paint_arg_usages = true,
      paint_catch_blocks = {
        declarations = false,
        usages = false,
      },
      extras = {
        named_parameters = false,
      },
      hl_priority = 10000,
      excluded_argnames = {
        declarations = {},
        usages = {
          python = { 'self', 'cls' },
          lua = { 'self' },
        },
      },
      performance = {
        parse_delay = 1,
        slow_parse_delay = 50,
        max_iterations = 400,
        max_concurrent_partial_parses = 30,
        debounce = {
          partial_parse = 3,
          partial_insert_mode = 100,
          total_parse = 700,
          slow_parse = 5000,
        },
      },
    })
  end,
}

