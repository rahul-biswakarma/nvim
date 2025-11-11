--[[
  Rustaceanvim - Enhanced Rust LSP
  
  Provides advanced Rust development features via rust-analyzer.
  Includes smart goto-definition that skips use statements.
  
  Features:
  - Smart goto-definition (skips use statements, finds actual definitions)
  - Code actions, runnables, testables, debuggables
  - Macro expansion and error explanations
  - Comprehensive inlay hints
  - Clippy integration for linting
]]

return {
  'mrcjkb/rustaceanvim',
  version = '^5',
  lazy = false,
  ft = { 'rust' },
  config = function()
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry')
    
    vim.g.rustaceanvim = {
      -- ============================================================================
      -- TOOLS CONFIGURATION
      -- ============================================================================
      tools = {
        -- Inlay hints configuration
        inlay_hints = {
          auto = true,                      -- Enable inlay hints
          show_parameter_hints = true,      -- Show parameter names
          parameter_hints_prefix = '<- ',   -- Prefix for parameter hints
          other_hints_prefix = '=> ',       -- Prefix for other hints
        },
        
        -- Hover actions configuration
        hover_actions = {
          auto_focus = true,   -- Auto-focus hover window
          border = 'rounded',  -- Rounded borders
        },
      },
      
      -- ============================================================================
      -- LSP SERVER CONFIGURATION
      -- ============================================================================
      server = {
        -- ========================================================================
        -- ON_ATTACH: SETUP KEYMAPS AND SMART GOTO-DEFINITION
        -- ========================================================================
        on_attach = function(client, bufnr)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          
          -- ======================================================================
          -- HELPER: CHECK IF LOCATION IS A USE STATEMENT
          -- ======================================================================
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
          
          -- ======================================================================
          -- SMART GOTO-DEFINITION (SKIPS USE STATEMENTS)
          -- ======================================================================
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
              
              -- Filter out use statements
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
              
              -- Jump to location helper
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
              
              -- Jump to preferred location (non-use statement)
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
          
          -- ======================================================================
          -- KEYMAPS (Using centralized registry)
          -- ======================================================================
          -- Smart goto-definition (overrides default LSP gd)
          kb.register_keymap('rustaceanvim', 'n', keys.lsp_goto_definition, goto_definition_smart, 
            vim.tbl_extend('force', opts, { desc = 'Go to Definition (skip use)' }))
          
          -- Rust-specific actions
          kb.register_keymap('rustaceanvim', 'n', keys.rust_code_action, function() vim.cmd.RustLsp('codeAction') end, 
            vim.tbl_extend('force', opts, { desc = 'Rust code action' }))
          kb.register_keymap('rustaceanvim', 'n', keys.rust_debuggables, function() vim.cmd.RustLsp('debuggables') end,
            vim.tbl_extend('force', opts, { desc = 'Rust debuggables' }))
          kb.register_keymap('rustaceanvim', 'n', keys.rust_runnables, function() vim.cmd.RustLsp('runnables') end,
            vim.tbl_extend('force', opts, { desc = 'Rust runnables' }))
          kb.register_keymap('rustaceanvim', 'n', keys.rust_testables, function() vim.cmd.RustLsp('testables') end,
            vim.tbl_extend('force', opts, { desc = 'Rust testables' }))
          kb.register_keymap('rustaceanvim', 'n', keys.rust_expand_macro, function() vim.cmd.RustLsp('expandMacro') end,
            vim.tbl_extend('force', opts, { desc = 'Rust expand macro' }))
          kb.register_keymap('rustaceanvim', 'n', keys.rust_open_cargo, function() vim.cmd.RustLsp('openCargo') end,
            vim.tbl_extend('force', opts, { desc = 'Open Cargo.toml' }))
          kb.register_keymap('rustaceanvim', 'n', keys.rust_parent_module, function() vim.cmd.RustLsp('parentModule') end,
            vim.tbl_extend('force', opts, { desc = 'Go to parent module' }))
          kb.register_keymap('rustaceanvim', 'n', keys.rust_join_lines, function() vim.cmd.RustLsp('joinLines') end,
            vim.tbl_extend('force', opts, { desc = 'Join lines' }))
          kb.register_keymap('rustaceanvim', 'n', keys.rust_explain_error, function() vim.cmd.RustLsp('explainError') end,
            vim.tbl_extend('force', opts, { desc = 'Explain error' }))
          kb.register_keymap('rustaceanvim', 'n', keys.rust_render_diagnostic, function() vim.cmd.RustLsp('renderDiagnostic') end,
            vim.tbl_extend('force', opts, { desc = 'Render diagnostic' }))
          
          -- Enhanced hover (overrides default LSP K)
          kb.register_keymap('rustaceanvim', 'n', keys.lsp_hover, function() vim.cmd.RustLsp({ 'hover', 'actions' }) end,
            vim.tbl_extend('force', opts, { desc = 'Hover actions' }))
        end,
        
        -- ========================================================================
        -- RUST-ANALYZER DEFAULT SETTINGS
        -- ========================================================================
        default_settings = {
          ['rust-analyzer'] = {
            -- Cargo configuration
            cargo = {
              allFeatures = true,             -- Enable all cargo features
              loadOutDirsFromCheck = true,    -- Load output directories
              buildScripts = {
                enable = true,                -- Enable build scripts
              },
            },
            
            -- Check configuration (using Clippy)
            checkOnSave = true,
            check = {
              allFeatures = true,
              command = 'clippy',             -- Use Clippy instead of check
              extraArgs = { '--no-deps' },    -- Don't check dependencies
            },
            
            -- Experimental features
            experimental = {
              locallinks = 'full',            -- Enable local links
            },
            
            -- Proc macro configuration
            procMacro = {
              enable = true,
              ignored = {
                ['async-trait'] = { 'async_trait' },
                ['napi-derive'] = { 'napi' },
                ['async-recursion'] = { 'async_recursion' },
              },
            },
            
            -- ====================================================================
            -- INLAY HINTS CONFIGURATION
            -- ====================================================================
            inlayHints = {
              bindingModeHints = {
                enable = true,                -- Show binding mode hints
              },
              chainingHints = {
                enable = true,                -- Show chaining hints
              },
              closingBraceHints = {
                enable = true,                -- Show closing brace hints
                minLines = 10,                -- Minimum lines to show
              },
              closureReturnTypeHints = {
                enable = 'always',            -- Show closure return types
              },
              lifetimeElisionHints = {
                enable = 'skip_trivial',      -- Show lifetime hints (skip trivial)
                useParameterNames = true,     -- Use parameter names
              },
              parameterHints = {
                enable = true,                -- Show parameter hints
              },
              reborrowHints = {
                enable = 'always',            -- Show reborrow hints
              },
              renderColons = true,            -- Render colons in hints
              typeHints = {
                enable = true,                -- Show type hints
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
          },
        },
      },
      
      -- ============================================================================
      -- DAP (DEBUG ADAPTER PROTOCOL)
      -- ============================================================================
      dap = {},
    }
  end,
}
