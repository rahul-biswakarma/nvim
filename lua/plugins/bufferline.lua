return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('bufferline').setup {
      options = {
        mode = 'buffers',
        themable = true,
        numbers = 'none',
        close_command = 'bdelete! %d',
        right_mouse_command = 'bdelete! %d',
        left_mouse_command = 'buffer %d',
        middle_mouse_command = nil,
        indicator = {
          icon = '▎',
          style = 'icon',
        },
        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 18,
        diagnostics = 'nvim_lsp',
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level)
          local icon = level:match('error') and ' ' or ' '
          return ' ' .. icon .. count
        end,
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'File Explorer',
            text_align = 'center',
            separator = true,
          },
        },
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
        hover = {
          enabled = true,
          delay = 200,
          reveal = { 'close' },
        },
        sort_by = 'insert_after_current',
      },
      highlights = {
        buffer_selected = {
          fg = '#ff9e64',
          bg = '#0f1a20',
          bold = true,
        },
        buffer_visible = {
          fg = '#7aa2f7',
          bg = '#0a1217',
        },
        background = {
          fg = '#565f89',
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
          fg = '#f7768e',
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

    -- Keymaps for buffer navigation
    vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { noremap = true, silent = true, desc = 'Next buffer' })
    vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true, desc = 'Previous buffer' })
    vim.keymap.set('n', '<leader>x', ':bdelete<CR>', { noremap = true, silent = true, desc = 'Close buffer' })
    vim.keymap.set('n', '<leader>bp', ':BufferLineTogglePin<CR>', { noremap = true, silent = true, desc = 'Pin buffer' })
    vim.keymap.set('n', '<leader>bP', ':BufferLineGroupClose ungrouped<CR>', { noremap = true, silent = true, desc = 'Close unpinned buffers' })
  end,
}

