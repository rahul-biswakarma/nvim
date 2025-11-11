--[[
  Lualine - Status Line
  
  Beautiful and fast statusline with custom components.
  
  Custom components:
  - LSP client names
  - LSP progress (from fidget)
  - Treesitter status
  - System stats (CPU & RAM usage)
]]

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  config = function()
    -- ============================================================================
    -- CUSTOM COMPONENT: LSP CLIENT NAMES
    -- ============================================================================
    local function lsp_client()
      local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
      if #buf_clients == 0 then
        return ''
      end

      local buf_client_names = {}
      for _, client in pairs(buf_clients) do
        table.insert(buf_client_names, client.name)
      end

      local unique_client_names = table.concat(buf_client_names, ', ')
      return string.format('[%s]', unique_client_names)
    end

    -- ============================================================================
    -- CUSTOM COMPONENT: LSP PROGRESS
    -- ============================================================================
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

    -- ============================================================================
    -- CUSTOM COMPONENT: TREESITTER STATUS
    -- ============================================================================
    local function treesitter_status()
      local bufnr = vim.api.nvim_get_current_buf()
      local lang = vim.treesitter.get_lang(bufnr)
      if lang then
        return 'TS'
      end
      return ''
    end

    -- ============================================================================
    -- CUSTOM COMPONENT: SYSTEM STATS (CPU & RAM)
    -- ============================================================================
    local system_stats_cache = { cpu = '0', mem = '0.0', last_update = 0 }
    
    local function update_system_stats()
      -- macOS-specific commands
      local cpu_cmd = "ps -A -o %cpu | awk '{s+=$1} END {printf \"%.0f\", s}'"
      local mem_cmd = "vm_stat | perl -ne '/page size of (\\d+)/ and $size=$1; /Pages\\s+([^:]+)[^\\d]+(\\d+)/ and $mem{$1}=$2*$size/1073741824; END {printf \"%.1f\", ($mem{\"wired\"}+$mem{\"active\"}+$mem{\"inactive\"}+$mem{\"speculative\"})}'"
      
      -- Update CPU
      local cpu_handle = io.popen(cpu_cmd)
      if cpu_handle then
        local cpu = cpu_handle:read('*a'):gsub('%s+', '')
        cpu_handle:close()
        if cpu and cpu ~= '' then
          system_stats_cache.cpu = cpu
        end
      end
      
      -- Update Memory
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
      -- Update every 2 seconds
      if now - system_stats_cache.last_update > 2000 then
        update_system_stats()
      end
      
      local cpu = system_stats_cache.cpu or '0'
      local mem = system_stats_cache.mem or '0.0'
      return string.format('CPU:%s%% RAM:%sGB', cpu, mem)
    end
    
    -- Initial update
    update_system_stats()
    -- Update every 2 seconds in background
    vim.loop.new_timer():start(2000, 2000, vim.schedule_wrap(update_system_stats))

    -- ============================================================================
    -- LUALINE SETUP
    -- ============================================================================
    require('lualine').setup {
      -- ============================================================================
      -- OPTIONS
      -- ============================================================================
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
        globalstatus = true,  -- Single statusline for all windows
        refresh = {
          statusline = 200,
          tabline = 1000,
          winbar = 1000,
        },
      },
      
      -- ============================================================================
      -- ACTIVE SECTIONS
      -- ============================================================================
      sections = {
        -- Left section
        lualine_a = { 'mode' },
        
        -- Left-center section (git & diagnostics)
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
        
        -- Center section (filename)
        lualine_c = {
          {
            'filename',
            file_status = true,
            newfile_status = true,
            path = 1,  -- Relative path
            shorting_target = 40,
            symbols = {
              modified = '[+]',
              readonly = '[-]',
              unnamed = '[No Name]',
              newfile = '[New]',
            },
          },
        },
        
        -- Right-center section (LSP & file info)
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
            icon = '',
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
        
        -- Right section (system stats & position)
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
      
      -- ============================================================================
      -- INACTIVE SECTIONS (Minimal for unfocused windows)
      -- ============================================================================
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      
      -- ============================================================================
      -- EXTENSIONS
      -- ============================================================================
      tabline = {},
      extensions = { 'neo-tree', 'toggleterm', 'trouble' },
    }
  end,
}
