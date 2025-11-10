return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 
      'j-hui/fidget.nvim',
      opts = {
        notification = {
          window = { winblend = 0 },
        },
      },
    },
    'folke/neodev.nvim',
  },
  config = function()
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = 'rounded',
    })
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = 'rounded',
    })

    vim.diagnostic.config({
      float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
        focusable = true,
      },
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    local on_attach = function(client, bufnr)
      local nmap = function(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = bufnr, noremap = true, silent = true, desc = desc })
      end

      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
      nmap('<leader>a', vim.lsp.buf.code_action, 'Code [A]ction')
      
      vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, noremap = true, silent = true, desc = 'LSP: [C]ode [A]ction' })
      vim.keymap.set('v', '<leader>a', vim.lsp.buf.code_action, { buffer = bufnr, noremap = true, silent = true, desc = 'LSP: Code [A]ction' })
      
      nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
      nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
      nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
      nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
      nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
      nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
      nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, '[W]orkspace [L]ist Folders')
      
      nmap('gl', function() vim.diagnostic.open_float(nil, { focus = false, scope = 'line' }) end, 'Show [L]ine diagnostics')
      nmap('<leader>d', function() vim.diagnostic.open_float() end, 'Show [D]iagnostics popup')
      nmap('[d', vim.diagnostic.goto_prev, 'Go to previous [d]iagnostic')
      nmap(']d', vim.diagnostic.goto_next, 'Go to next [d]iagnostic')
      nmap('<leader>q', vim.diagnostic.setloclist, 'Open diagnostics [q]uickfix list')

      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        nmap('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
        end, '[T]oggle Inlay [H]ints')
      end

      vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
      end, { desc = 'Format current buffer with LSP' })
    end

    local servers = {
      html = {},
      lua_ls = {
        Lua = {
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
      rust_analyzer = {
        ['rust-analyzer'] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
          },
          checkOnSave = {
            command = 'clippy',
          },
          procMacro = {
            enable = true,
          },
          inlayHints = {
            bindingModeHints = { enable = true },
            chainingHints = { enable = true },
            closingBraceHints = { enable = true, minLines = 10 },
            closureReturnTypeHints = { enable = 'always' },
            lifetimeElisionHints = { enable = 'skip_trivial', useParameterNames = true },
            parameterHints = { enable = true },
            reborrowHints = { enable = 'always' },
            renderColons = true,
            typeHints = {
              enable = true,
              hideClosureInitialization = false,
              hideNamedConstructor = false,
            },
          },
        },
      },
    }

    require('neodev').setup()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    require('mason-lspconfig').setup {
      ensure_installed = vim.tbl_keys(servers),
      handlers = {
        function(server_name)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
          }
        end,
      }
    }
  end,
}
