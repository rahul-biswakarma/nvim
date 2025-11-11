--[[
  Telescope - Fuzzy Finder
  
  Fast and extensible fuzzy finder over lists.
]]

return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
  },
  config = function()
    local keys = require('core.keybindings-registry')

    require('telescope').setup {
      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
          },
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require 'telescope.builtin'
    
    -- All keymaps reference the centralized registry
    vim.keymap.set('n', keys.search_help, builtin.help_tags, { desc = 'Search Help' })
    vim.keymap.set('n', keys.search_keymaps, builtin.keymaps, { desc = 'Search Keymaps' })
    vim.keymap.set('n', keys.search_files, builtin.find_files, { desc = 'Search Files' })
    vim.keymap.set('n', keys.search_telescope_builtins, builtin.builtin, { desc = 'Search Select Telescope' })
    vim.keymap.set('n', keys.search_word, builtin.grep_string, { desc = 'Search current Word' })
    vim.keymap.set('n', keys.search_grep, builtin.live_grep, { desc = 'Search by Grep' })
    vim.keymap.set('n', keys.search_diagnostics, builtin.diagnostics, { desc = 'Search Diagnostics' })
    vim.keymap.set('n', keys.search_resume, builtin.resume, { desc = 'Search Resume' })
    vim.keymap.set('n', keys.search_recent, builtin.oldfiles, { desc = 'Search Recent Files' })
    vim.keymap.set('n', keys.search_buffers, builtin.buffers, { desc = 'Find buffers' })
    
    -- Neovim config search
    vim.keymap.set('n', keys.search_neovim_config, function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = 'Search Neovim config' })
    
    -- Fuzzy search in current buffer
    vim.keymap.set('n', keys.search_buffer, function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = 'Search Buffer' })

    -- Search in open files
    vim.keymap.set('n', keys.search_open_files, function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = 'Search in Open Files' })
  end,
}
