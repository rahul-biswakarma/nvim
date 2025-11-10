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
          notification = {
            window = { winblend = 0 },
          },
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
      
      local function is_use_statement(uri, line)
        local bufnr = vim.uri_to_bufnr(uri)
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
      
      local function is_definition(location)
        local uri = location.uri or location.filename
        local bufnr = vim.uri_to_bufnr(uri)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return false
        end
        
        local line = (location.lnum or location.line or 0) - 1
        local start_line = math.max(0, line - 5)
        local end_line = line + 5
        local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
        if not lines or #lines == 0 then
          return false
        end
        
        for _, line_content in ipairs(lines) do
          local content = line_content:gsub('%s+', ' ')
          if content:match('^%s*use%s+') or content:match('^%s*pub%s+use%s+') or content:match('^%s*mod%s+') then
            return false
          end
          if content:match('^%s*pub%s+fn%s+') or content:match('^%s*fn%s+') or 
             content:match('^%s*pub%s+struct%s+') or content:match('^%s*struct%s+') or
             content:match('^%s*pub%s+enum%s+') or content:match('^%s*enum%s+') or
             content:match('^%s*pub%s+impl%s+') or content:match('^%s*impl%s+') or
             content:match('^%s*pub%s+trait%s+') or content:match('^%s*trait%s+') then
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

          local preferred_location = nil
          local use_locations = {}
          local other_locations = {}

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
          
          local function jump_to_file(location)
            if not location then
              return
            end
            vim.lsp.util.jump_to_location(location, offset_encoding)
            vim.cmd('normal! zz')
          end

          if preferred_location then
            jump_to_file(preferred_location)
          elseif #other_locations > 0 then
            jump_to_file(other_locations[1])
          elseif #use_locations > 0 then
            if #use_locations == 1 then
              jump_to_file(use_locations[1])
            else
              require('telescope.builtin').lsp_definitions()
            end
          else
            jump_to_file(locations[1])
          end
        end)
      end

      nmap('gd', goto_definition_smart, '[G]oto [D]efinition')
      nmap('<leader>gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinitions (Telescope)')
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
