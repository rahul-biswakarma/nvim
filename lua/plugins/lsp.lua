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
    -- ============================================================================
    -- LSP Handlers Configuration
    -- ============================================================================
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
    -- Diagnostics Configuration
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
    -- Helper Functions
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
    -- LSP on_attach Configuration
    -- ============================================================================
    local function on_attach(client, bufnr)
      local nmap = function(keys, func, desc)
        vim.keymap.set('n', keys, func, {
          buffer = bufnr,
          noremap = true,
          silent = true,
          desc = desc and 'LSP: ' .. desc or nil,
        })
      end

      -- Code actions
      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
      nmap('<leader>a', vim.lsp.buf.code_action, 'Code [A]ction')
      vim.keymap.set({ 'v' }, '<leader>ca', vim.lsp.buf.code_action, {
        buffer = bufnr,
        noremap = true,
        silent = true,
        desc = 'LSP: [C]ode [A]ction',
      })
      vim.keymap.set({ 'v' }, '<leader>a', vim.lsp.buf.code_action, {
        buffer = bufnr,
        noremap = true,
        silent = true,
        desc = 'LSP: Code [A]ction',
      })

      -- Navigation
      nmap('gd', goto_definition_smart, '[G]oto [D]efinition')
      nmap('<leader>gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinitions (Telescope)')
      nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
      nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
      nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- Symbols
      nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

      -- Documentation
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

      -- Workspace
      nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
      nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
      nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, '[W]orkspace [L]ist Folders')

      -- Diagnostics
      nmap('gl', function()
        vim.diagnostic.open_float(nil, { focus = false, scope = 'line' })
      end, 'Show [L]ine diagnostics')
      nmap('<leader>d', function()
        vim.diagnostic.open_float()
      end, 'Show [D]iagnostics popup')
      nmap('[d', vim.diagnostic.goto_prev, 'Go to previous [d]iagnostic')
      nmap(']d', vim.diagnostic.goto_next, 'Go to next [d]iagnostic')
      nmap('<leader>q', vim.diagnostic.setloclist, 'Open diagnostics [q]uickfix list')

      -- Inlay hints
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        nmap('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
        end, '[T]oggle Inlay [H]ints')
      end

      -- Format command
      vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
        vim.lsp.buf.format()
      end, { desc = 'Format current buffer with LSP' })
    end

    -- ============================================================================
    -- Server Configuration
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

    -- Setup servers via mason-lspconfig
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

    -- Setup ts_ls separately
    vim.lsp.config('ts_ls', {
      capabilities = capabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable('ts_ls')
  end,
}
