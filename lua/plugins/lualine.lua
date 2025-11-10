return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local function lsp_client()
      local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
      if #buf_clients == 0 then
        return ''
      end

      local buf_client_names = {}
      for _, client in pairs(buf_clients) do
        if client.name ~= 'null-ls' then
          table.insert(buf_client_names, client.name)
        end
      end

      local unique_client_names = table.concat(buf_client_names, ', ')
      return string.format('[%s]', unique_client_names)
    end

    local lsp_progress_data = {}
    
    local function lsp_progress()
      local ok, fidget = pcall(require, 'fidget')
      if not ok then
        return ''
      end
      
      local status = fidget.status
      if not status then
        return ''
      end
      
      local progress = status.progress()
      if not progress or type(progress) ~= 'table' then
        return ''
      end
      
      local messages = {}
      for _, item in pairs(progress) do
        if item.percentage and item.percentage > 0 and item.percentage < 100 then
          local title = item.title or item.name or ''
          if title ~= '' then
            table.insert(messages, string.format('%s %d%%', title, item.percentage))
          end
        end
      end
      
      if #messages > 0 then
        return table.concat(messages, ' ')
      end
      return ''
    end
    
    vim.loop.new_timer():start(300, 300, vim.schedule_wrap(function()
      local ok, fidget = pcall(require, 'fidget')
      if ok and fidget.status then
        local progress = fidget.status.progress()
        if progress then
          lsp_progress_data = progress
        end
      end
    end))

    local function treesitter_status()
      local bufnr = vim.api.nvim_get_current_buf()
      local lang = vim.treesitter.get_lang(bufnr)
      if lang then
        return 'TS'
      end
      return ''
    end

    local system_stats_cache = { cpu = '0', mem = '0.0', last_update = 0 }
    
    local function update_system_stats()
      local cpu_cmd = "ps -A -o %cpu | awk '{s+=$1} END {printf \"%.0f\", s}'"
      local mem_cmd = "vm_stat | perl -ne '/page size of (\\d+)/ and $size=$1; /Pages\\s+([^:]+)[^\\d]+(\\d+)/ and $mem{$1}=$2*$size/1073741824; END {printf \"%.1f\", ($mem{\"wired\"}+$mem{\"active\"}+$mem{\"inactive\"}+$mem{\"speculative\"})}'"
      
      local cpu_handle = io.popen(cpu_cmd)
      if cpu_handle then
        local cpu = cpu_handle:read('*a'):gsub('%s+', '')
        cpu_handle:close()
        if cpu and cpu ~= '' then
          system_stats_cache.cpu = cpu
        end
      end
      
      local mem_handle = io.popen(mem_cmd)
      if mem_handle then
        local mem = mem_handle:read('*a'):gsub('%s+', '')
        mem_handle:close()
        if mem and mem ~= '' then
          system_stats_cache.mem = mem
        end
      end
      
      system_stats_cache.last_update = vim.loop.now()
    end
    
    local function system_stats()
      local now = vim.loop.now()
      if now - system_stats_cache.last_update > 2000 then
        update_system_stats()
      end
      
      return string.format('CPU:%s%% RAM:%sGB', system_stats_cache.cpu, system_stats_cache.mem)
    end
    
    update_system_stats()
    vim.loop.new_timer():start(2000, 2000, vim.schedule_wrap(update_system_stats))

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
          statusline = 200,
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
            lsp_progress,
            icon = '󰦨 ',
            color = { fg = '#bb9af7' },
          },
          {
            treesitter_status,
            icon = '󰨤 ',
            color = { fg = '#7aa2f7' },
          },
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
        lualine_y = { 
          {
            system_stats,
            icon = '󰍛 ',
            color = { fg = '#9ece6a' },
          },
          'progress',
        },
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
