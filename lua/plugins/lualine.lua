return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- LSP clients attached to buffer
    local function lsp_client()
      local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
      if #buf_clients == 0 then
        return 'LSP Inactive'
      end

      local buf_client_names = {}
      for _, client in pairs(buf_clients) do
        if client.name ~= 'null-ls' then
          table.insert(buf_client_names, client.name)
        end
      end

      local unique_client_names = table.concat(buf_client_names, ', ')
      local language_servers = string.format('[%s]', unique_client_names)

      return language_servers
    end

    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = 'solarized-osaka',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = { 'alpha', 'dashboard' },
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 
          'branch',
          'diff',
          {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            sections = { 'error', 'warn', 'info', 'hint' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
            colored = true,
            update_in_insert = false,
            always_visible = false,
          },
        },
        lualine_c = {
          {
            'filename',
            file_status = true,
            newfile_status = true,
            path = 1,
            shorting_target = 40,
            symbols = {
              modified = '[+]',
              readonly = '[-]',
              unnamed = '[No Name]',
              newfile = '[New]',
            },
          },
        },
        lualine_x = {
          {
            lsp_client,
            icon = ' ',
            color = { fg = '#7aa2f7' },
          },
          'encoding',
          {
            'fileformat',
            symbols = {
              unix = '',
              dos = '',
              mac = '',
            },
          },
          'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { 'neo-tree', 'toggleterm', 'trouble' },
    }
  end,
}