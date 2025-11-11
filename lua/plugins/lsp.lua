--[[
  LSP Configuration
  
  Language Server Protocol configuration with smart goto-definition for Rust.
  Includes Mason for automatic LSP server installation and management.
  
  Features:
  - Smart Rust goto-definition (skips use statements, finds actual definitions)
  - Rounded borders for popups
  - Inlay hints support
  - Comprehensive diagnostics
]]

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 
      'j-hui/fidget.nvim',
      tag = 'legacy',
      config = function()
        require('fidget').setup({
          notification = { window = { winblend = 0 } },
          progress = {
            display = {
              done_icon = '✓',
              done_ttl = 1,
              done_icon_hl_group = 'FidgetDone',
              icon = { pattern = 'dots', period = 1 },
              icon_hl_group = 'FidgetTitle',
              render_limit = 16,
              view = 'mini',
            },
          },
        })
      end,
    },
    'folke/neodev.nvim',
  },
  config = function()
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry')
    
    -- ============================================================================
    -- LSP HANDLERS CONFIGURATION
    -- ============================================================================
    -- Rounded borders for hover and signature help
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = 'rounded',
    })
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = 'rounded',
    })
    
    -- Suppress warnings for unsupported TypeScript commands
    vim.lsp.handlers['workspace/executeCommand'] = function(err)
      if err and err.message and err.message:match('does not support command') then
        return -- Silently ignore unsupported commands
      end
      if err then
        vim.notify('LSP command error: ' .. tostring(err.message), vim.log.levels.WARN)
      end
    end

    -- Suppress specific warning messages about unsupported commands
    local original_notify = vim.notify
    vim.notify = function(msg, level, opts)
      if type(msg) == 'string' and msg:match('does not support command') and msg:match('_typescript') then
        return -- Suppress TypeScript command warnings
      end
      return original_notify(msg, level, opts)
    end

    -- ============================================================================
    -- DIAGNOSTICS CONFIGURATION
    -- ============================================================================
    vim.diagnostic.config({
      float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
        focusable = true,
      },
      virtual_text = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = ' ',
          [vim.diagnostic.severity.WARN] = ' ',
          [vim.diagnostic.severity.INFO] = ' ',
          [vim.diagnostic.severity.HINT] = '󰌵',
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- ============================================================================
    -- HELPER FUNCTIONS FOR SMART RUST GOTO-DEFINITION
    -- ============================================================================
    local function uri_to_bufnr(uri)
      local actual_uri = uri
      if uri and not uri:match('^%w+://') then
        actual_uri = vim.uri_from_fname(uri)
      end
      return vim.uri_to_bufnr(actual_uri)
    end

    local function get_buffer_lines(bufnr, start_line, end_line)
      local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
      return lines and #lines > 0 and lines or nil
    end

    local function is_rust_pattern(content, patterns)
      for _, pattern in ipairs(patterns) do
        if content:match(pattern) then
          return true
        end
      end
      return false
    end
      
      local function is_use_statement(uri, line)
      local bufnr = uri_to_bufnr(uri)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return false
        end
        
      local lines = get_buffer_lines(bufnr, math.max(0, line - 2), line + 2)
      if not lines then
          return false
        end
        
      local use_patterns = { '^%s*use%s+', '^%s*pub%s+use%s+', '^%s*mod%s+' }
        for _, line_content in ipairs(lines) do
        if is_rust_pattern(line_content:gsub('%s+', ' '), use_patterns) then
            return true
          end
        end
        return false
      end
      
      local function is_definition(location)
        local uri = location.uri or location.filename
      if not uri then
        return false
      end

      local bufnr = uri_to_bufnr(uri)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return false
        end
        
        local line = (location.lnum or location.line or 0) - 1
      local lines = get_buffer_lines(bufnr, math.max(0, line - 5), line + 5)
      if not lines then
          return false
        end

      local use_patterns = { '^%s*use%s+', '^%s*pub%s+use%s+', '^%s*mod%s+' }
      local def_patterns = {
        '^%s*pub%s+fn%s+', '^%s*fn%s+',
        '^%s*pub%s+struct%s+', '^%s*struct%s+',
        '^%s*pub%s+enum%s+', '^%s*enum%s+',
        '^%s*pub%s+impl%s+', '^%s*impl%s+',
        '^%s*pub%s+trait%s+', '^%s*trait%s+',
      }
        
        for _, line_content in ipairs(lines) do
          local content = line_content:gsub('%s+', ' ')
        if is_rust_pattern(content, use_patterns) then
            return false
          end
        if is_rust_pattern(content, def_patterns) then
            return true
          end
        end
      return false
    end

    local function jump_to_location(location)
      if not location then
        return
      end

      local uri = location.uri or location.filename
      local file_path = uri:match('^file://') and vim.uri_to_fname(uri) or uri
      local target_bufnr = uri_to_bufnr(uri)

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

      local function goto_definition_smart()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local offset_encoding = clients[1] and clients[1].offset_encoding or 'utf-16'
        local params = vim.lsp.util.make_position_params(0, offset_encoding)

        vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx)
          if err then
            vim.notify('Error finding definition: ' .. tostring(err), vim.log.levels.ERROR)
            return
          end

          if not result or vim.tbl_isempty(result) then
            vim.notify('No definition found', vim.log.levels.INFO)
            return
          end

          local client = vim.lsp.get_client_by_id(ctx.client_id)
          local offset_encoding = client and client.offset_encoding or 'utf-16'
        local locations = vim.lsp.util.locations_to_items(result, offset_encoding)
          
          if not locations or #locations == 0 then
            return
          end

        local preferred_location, use_locations, other_locations = nil, {}, {}

          for _, location in ipairs(locations) do
            local uri = location.uri or location.filename
            local line = (location.lnum or location.line or 0) - 1
            
            if is_use_statement(uri, line) then
              table.insert(use_locations, location)
            elseif is_definition(location) then
              preferred_location = location
              break
            else
              table.insert(other_locations, location)
            end
          end

          if preferred_location then
          jump_to_location(preferred_location)
          elseif #other_locations > 0 then
          jump_to_location(other_locations[1])
        elseif #use_locations == 1 then
          jump_to_location(use_locations[1])
        elseif #use_locations > 1 then
              require('telescope.builtin').lsp_definitions()
          else
          jump_to_location(locations[1])
          end
        end)
      end

    -- ============================================================================
    -- LSP ON_ATTACH CONFIGURATION (Buffer-local keymaps)
    -- ============================================================================
    local function on_attach(client, bufnr)
      -- Helper to set buffer-local keymaps
      local function nmap(lhs, rhs, desc)
        kb.register_keymap('lsp', 'n', lhs, rhs, {
          buffer = bufnr,
          noremap = true,
          silent = true,
          desc = desc and 'LSP: ' .. desc or nil,
        })
      end

      local function vmap(lhs, rhs, desc)
        kb.register_keymap('lsp', 'v', lhs, rhs, {
        buffer = bufnr,
        noremap = true,
        silent = true,
          desc = desc and 'LSP: ' .. desc or nil,
      })
      end

      -- ============================================================================
      -- ACTIONS
      -- ============================================================================
      nmap(keys.lsp_rename, vim.lsp.buf.rename, 'Rename')
      nmap(keys.lsp_code_action, vim.lsp.buf.code_action, 'Code Action')
      nmap(keys.lsp_code_action_alt, vim.lsp.buf.code_action, 'Code Action (alt)')
      vmap(keys.lsp_code_action, vim.lsp.buf.code_action, 'Code Action')
      vmap(keys.lsp_code_action_alt, vim.lsp.buf.code_action, 'Code Action (alt)')

      -- ============================================================================
      -- NAVIGATION
      -- ============================================================================
      nmap(keys.lsp_goto_definition, goto_definition_smart, 'Goto Definition')
      nmap(keys.lsp_goto_definitions_telescope, require('telescope.builtin').lsp_definitions, 'Goto Definitions (Telescope)')
      nmap(keys.lsp_goto_references, require('telescope.builtin').lsp_references, 'Goto References')
      nmap(keys.lsp_goto_implementation, require('telescope.builtin').lsp_implementations, 'Goto Implementation')
      nmap(keys.lsp_type_definition, vim.lsp.buf.type_definition, 'Type Definition')
      nmap(keys.lsp_goto_declaration, vim.lsp.buf.declaration, 'Goto Declaration')

      -- ============================================================================
      -- SYMBOLS
      -- ============================================================================
      nmap(keys.lsp_document_symbols, require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
      nmap(keys.lsp_workspace_symbols, require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

      -- ============================================================================
      -- DOCUMENTATION
      -- ============================================================================
      nmap(keys.lsp_hover, vim.lsp.buf.hover, 'Hover Documentation')
      nmap(keys.lsp_signature_help, vim.lsp.buf.signature_help, 'Signature Documentation')

      -- ============================================================================
      -- WORKSPACE
      -- ============================================================================
      nmap(keys.lsp_workspace_add_folder, vim.lsp.buf.add_workspace_folder, 'Workspace Add Folder')
      nmap(keys.lsp_workspace_remove_folder, vim.lsp.buf.remove_workspace_folder, 'Workspace Remove Folder')
      nmap(keys.lsp_workspace_list_folders, function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, 'Workspace List Folders')
      
      -- ============================================================================
      -- DIAGNOSTICS
      -- ============================================================================
      nmap(keys.lsp_diagnostics, function()
        vim.diagnostic.open_float(nil, { focus = false, scope = 'line' })
      end, 'Show Line Diagnostics')
      nmap(keys.lsp_diagnostics_popup, function()
        vim.diagnostic.open_float()
      end, 'Show Diagnostics Popup')
      nmap(keys.lsp_prev_diagnostic, vim.diagnostic.goto_prev, 'Previous Diagnostic')
      nmap(keys.lsp_next_diagnostic, vim.diagnostic.goto_next, 'Next Diagnostic')
      nmap(keys.lsp_quickfix, vim.diagnostic.setloclist, 'Diagnostics Quickfix List')

      -- ============================================================================
      -- INLAY HINTS
      -- ============================================================================
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        nmap(keys.lsp_toggle_inlay_hints, function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
        end, 'Toggle Inlay Hints')
      end

      -- ============================================================================
      -- FORMAT COMMAND
      -- ============================================================================
      vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
        vim.lsp.buf.format()
      end, { desc = 'Format current buffer with LSP' })
    end

    -- ============================================================================
    -- SERVER CONFIGURATION
    -- ============================================================================
    local servers = {
      html = {},
      lua_ls = {
        Lua = {
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    }

    require('neodev').setup()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    -- ============================================================================
    -- SETUP SERVERS VIA MASON
    -- ============================================================================
    require('mason-lspconfig').setup({
      ensure_installed = vim.tbl_keys(servers),
      handlers = {
      function(server_name)
          require('lspconfig')[server_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
            settings = servers[server_name] or {},
          })
      end,
      },
    })

    -- ============================================================================
    -- SETUP TS_LS SEPARATELY
    -- ============================================================================
    vim.lsp.config('ts_ls', {
      capabilities = capabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable('ts_ls')
  end,
}
