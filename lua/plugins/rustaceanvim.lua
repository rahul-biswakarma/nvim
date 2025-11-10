return {
  'mrcjkb/rustaceanvim',
  version = '^5',
  lazy = false,
  ft = { 'rust' },
  config = function()
    vim.g.rustaceanvim = {
      -- Plugin configuration
      tools = {
        -- Automatically set inlay hints
        inlay_hints = {
          auto = true,
          show_parameter_hints = true,
          parameter_hints_prefix = '<- ',
          other_hints_prefix = '=> ',
        },
        hover_actions = {
          auto_focus = true,
          border = 'rounded',
        },
      },
      -- LSP configuration
      server = {
        on_attach = function(client, bufnr)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          
          -- Rustaceanvim keybindings
          vim.keymap.set('n', '<leader>ra', function() vim.cmd.RustLsp('codeAction') end, 
            { buffer = bufnr, desc = 'Rust code action' })
          vim.keymap.set('n', '<leader>rd', function() vim.cmd.RustLsp('debuggables') end,
            { buffer = bufnr, desc = 'Rust debuggables' })
          vim.keymap.set('n', '<leader>rr', function() vim.cmd.RustLsp('runnables') end,
            { buffer = bufnr, desc = 'Rust runnables' })
          vim.keymap.set('n', '<leader>rt', function() vim.cmd.RustLsp('testables') end,
            { buffer = bufnr, desc = 'Rust testables' })
          vim.keymap.set('n', '<leader>rm', function() vim.cmd.RustLsp('expandMacro') end,
            { buffer = bufnr, desc = 'Rust expand macro' })
          vim.keymap.set('n', '<leader>rc', function() vim.cmd.RustLsp('openCargo') end,
            { buffer = bufnr, desc = 'Open Cargo.toml' })
          vim.keymap.set('n', '<leader>rp', function() vim.cmd.RustLsp('parentModule') end,
            { buffer = bufnr, desc = 'Go to parent module' })
          vim.keymap.set('n', '<leader>rj', function() vim.cmd.RustLsp('joinLines') end,
            { buffer = bufnr, desc = 'Join lines' })
          vim.keymap.set('n', 'K', function() vim.cmd.RustLsp({ 'hover', 'actions' }) end,
            { buffer = bufnr, desc = 'Hover actions' })
          vim.keymap.set('n', '<leader>re', function() vim.cmd.RustLsp('explainError') end,
            { buffer = bufnr, desc = 'Explain error' })
          vim.keymap.set('n', '<leader>rD', function() vim.cmd.RustLsp('renderDiagnostic') end,
            { buffer = bufnr, desc = 'Render diagnostic' })
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            -- Add clippy lints for Rust
            checkOnSave = true,
            check = {
              allFeatures = true,
              command = 'clippy',
              extraArgs = { '--no-deps' },
            },
            procMacro = {
              enable = true,
              ignored = {
                ['async-trait'] = { 'async_trait' },
                ['napi-derive'] = { 'napi' },
                ['async-recursion'] = { 'async_recursion' },
              },
            },
            inlayHints = {
              bindingModeHints = {
                enable = true,
              },
              chainingHints = {
                enable = true,
              },
              closingBraceHints = {
                enable = true,
                minLines = 10,
              },
              closureReturnTypeHints = {
                enable = 'always',
              },
              lifetimeElisionHints = {
                enable = 'skip_trivial',
                useParameterNames = true,
              },
              parameterHints = {
                enable = true,
              },
              reborrowHints = {
                enable = 'always',
              },
              renderColons = true,
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
          },
        },
      },
      -- DAP configuration
      dap = {},
    }
  end,
}

