return {
  'mrcjkb/rustaceanvim',
  version = '^5',
  lazy = false,
  ft = { 'rust' },
  config = function()
    vim.g.rustaceanvim = {
      tools = {
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
      server = {
        on_attach = function(client, bufnr)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          
          local function is_use_statement(uri_or_filename, line)
            local bufnr
            if uri_or_filename:match('^file://') or uri_or_filename:match('^[a-z]+://') then
              bufnr = vim.uri_to_bufnr(uri_or_filename)
            else
              local uri = vim.uri_from_fname(uri_or_filename)
              bufnr = vim.uri_to_bufnr(uri)
            end
            
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return false
            end
            
            local lines = vim.api.nvim_buf_get_lines(bufnr, math.max(0, line - 2), line + 2, false)
            if not lines or #lines == 0 then
              return false
            end
            
            for _, line_content in ipairs(lines) do
              local content = line_content:gsub('%s+', ' ')
              if content:match('^%s*use%s+') or content:match('^%s*pub%s+use%s+') or content:match('^%s*mod%s+') then
                return true
              end
            end
            return false
          end
          
          local function goto_definition_smart()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            local offset_encoding = clients[1] and clients[1].offset_encoding or 'utf-16'
            local params = vim.lsp.util.make_position_params(0, offset_encoding)
            vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx)
              if err then
                vim.notify('Error finding definition: ' .. tostring(err), vim.log.levels.ERROR)
                vim.notify('Try: :LspInfo to check rust-analyzer status', vim.log.levels.INFO)
                return
              end
              
              if not result or vim.tbl_isempty(result) then
                vim.notify('No definition found. Check: :LspLog for errors', vim.log.levels.INFO)
                return
              end
              
              local client = vim.lsp.get_client_by_id(ctx.client_id)
              local offset_encoding = client and client.offset_encoding or 'utf-16'
              
              if type(result) == 'table' and #result > 1 then
                vim.notify(string.format('Found %d locations, filtering...', #result), vim.log.levels.INFO)
              end
              
              local locations = vim.lsp.util.locations_to_items(result, offset_encoding)
              if not locations or #locations == 0 then
                return
              end
              
              local preferred_location = nil
              local use_locations = {}
              
              for _, location in ipairs(locations) do
                local uri = location.uri or location.filename
                local line = (location.lnum or location.line or 0) - 1
                
                if is_use_statement(uri, line) then
                  table.insert(use_locations, location)
                else
                  preferred_location = location
                  break
                end
              end
              
              local function jump_to_location(location)
                if not location then
                  return
                end
                
                local uri = location.uri or location.filename
                local file_path
                local target_bufnr
                
                if uri:match('^file://') or uri:match('^[a-z]+://') then
                  file_path = vim.uri_to_fname(uri)
                  target_bufnr = vim.uri_to_bufnr(uri)
                else
                  file_path = uri
                  local proper_uri = vim.uri_from_fname(uri)
                  target_bufnr = vim.uri_to_bufnr(proper_uri)
                end
                
                if not vim.api.nvim_buf_is_valid(target_bufnr) then
                  vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
                  target_bufnr = vim.api.nvim_get_current_buf()
                else
                  vim.api.nvim_set_current_buf(target_bufnr)
                end
                
                local line = (location.lnum or location.line or 1) - 1
                local col = (location.col or location.character or 0)
                
                vim.api.nvim_win_set_cursor(0, { line + 1, col })
                vim.cmd('normal! zz')
              end
              
              if preferred_location then
                jump_to_location(preferred_location)
              elseif #use_locations > 0 then
                if #use_locations == 1 then
                  jump_to_location(use_locations[1])
                else
                  require('telescope.builtin').lsp_definitions()
                end
              else
                jump_to_location(locations[1])
              end
            end)
          end
          
          vim.keymap.set('n', 'gd', goto_definition_smart, { buffer = bufnr, noremap = true, silent = true, desc = 'Go to Definition (skip use)' })
          
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
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            checkOnSave = true,
            check = {
              allFeatures = true,
              command = 'clippy',
              extraArgs = { '--no-deps' },
            },
            experimental = {
              locallinks = 'full',
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
      dap = {},
    }
  end,
}
