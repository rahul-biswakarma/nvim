--[[
  Bufferline - Visual Buffer Tabs
  
  Displays open buffers as tabs at the top of the window.
  Integrates with LSP to show diagnostics and file icons.
]]

return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('bufferline').setup {
      options = {
        -- ============================================================================
        -- GENERAL
        -- ============================================================================
        mode = 'buffers',
        themable = true,
        numbers = 'none',
        
        -- ============================================================================
        -- MOUSE ACTIONS
        -- ============================================================================
        close_command = 'bdelete! %d',
        right_mouse_command = 'bdelete! %d',
        left_mouse_command = 'buffer %d',
        middle_mouse_command = nil,
        
        -- ============================================================================
        -- VISUAL INDICATORS
        -- ============================================================================
        indicator = {
          icon = '▎',
          style = 'icon',
        },
        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        
        -- ============================================================================
        -- SIZING & TRUNCATION
        -- ============================================================================
        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 18,
        
        -- ============================================================================
        -- LSP DIAGNOSTICS
        -- ============================================================================
        diagnostics = 'nvim_lsp',
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level)
          local icon = level:match('error') and ' ' or ' '
          return ' ' .. icon .. count
        end,
        
        -- ============================================================================
        -- FILE EXPLORER OFFSET
        -- ============================================================================
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'File Explorer',
            text_align = 'center',
            separator = true,
          },
        },
        
        -- ============================================================================
        -- DISPLAY OPTIONS
        -- ============================================================================
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        separator_style = 'thin',
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        
        -- ============================================================================
        -- HOVER BEHAVIOR
        -- ============================================================================
        hover = {
          enabled = true,
          delay = 200,
          reveal = { 'close' },
        },
        
        -- ============================================================================
        -- SORTING
        -- ============================================================================
        sort_by = 'insert_after_current',
      },
      
      -- ============================================================================
      -- CUSTOM COLORS (Dark Theme)
      -- ============================================================================
      highlights = {
        buffer_selected = {
          fg = '#ff9e64',  -- Orange for active buffer
          bg = '#0f1a20',
          bold = true,
        },
        buffer_visible = {
          fg = '#7aa2f7',  -- Blue for visible buffer
          bg = '#0a1217',
        },
        background = {
          fg = '#565f89',  -- Gray for inactive
          bg = '#0a1217',
        },
        tab_selected = {
          fg = '#ff9e64',
          bg = '#0f1a20',
        },
        tab = {
          fg = '#565f89',
          bg = '#0a1217',
        },
        tab_close = {
          fg = '#565f89',
          bg = '#0a1217',
        },
        close_button = {
          fg = '#565f89',
          bg = '#0a1217',
        },
        close_button_visible = {
          fg = '#565f89',
          bg = '#0a1217',
        },
        close_button_selected = {
          fg = '#ff9e64',
          bg = '#0f1a20',
        },
        indicator_selected = {
          fg = '#ff9e64',
          bg = '#0f1a20',
        },
        modified = {
          fg = '#f7768e',  -- Red for modified
          bg = '#0a1217',
        },
        modified_visible = {
          fg = '#f7768e',
          bg = '#0a1217',
        },
        modified_selected = {
          fg = '#f7768e',
          bg = '#0f1a20',
        },
        duplicate_selected = {
          fg = '#ff9e64',
          bg = '#0f1a20',
          italic = true,
        },
        duplicate_visible = {
          fg = '#7aa2f7',
          bg = '#0a1217',
          italic = true,
        },
        duplicate = {
          fg = '#565f89',
          bg = '#0a1217',
          italic = true,
        },
        separator_selected = {
          fg = '#0f1a20',
          bg = '#0f1a20',
        },
        separator_visible = {
          fg = '#0a1217',
          bg = '#0a1217',
        },
        separator = {
          fg = '#0a1217',
          bg = '#0a1217',
        },
      },
    }

    -- ============================================================================
    -- KEYMAPS (Using centralized registry)
    -- ============================================================================
    local keys = require('core.keybindings-registry')
    
    -- Buffer navigation
    -- keys.register_keymap('bufferline', 'n', keys.next_buffer, ':BufferLineCycleNext<CR>', { desc = 'Next buffer' }) -- Removed to free up <Tab> for nvim-cmp
    -- keys.register_keymap('bufferline', 'n', keys.prev_buffer, ':BufferLineCyclePrev<CR>', { desc = 'Previous buffer' }) -- Removed to free up <S-Tab> for nvim-cmp
    
    -- Smart buffer close: switches to next buffer before closing current
    keys.register_keymap('bufferline', 'n', keys.close_buffer, ':bdelete<CR>', { desc = 'Close buffer' })
    
    -- Buffer pinning (keeps buffer fixed in position)
    keys.register_keymap('bufferline', 'n', keys.pin_buffer, ':BufferLineTogglePin<CR>', { desc = 'Pin/unpin buffer' })
    keys.register_keymap('bufferline', 'n', keys.close_unpinned_buffers, ':BufferLineGroupClose ungrouped<CR>', { desc = 'Close unpinned buffers' })
  end,
}
