return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup {
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      float_opts = {
        border = 'curved',
        winblend = 0,
        highlights = {
          border = 'Normal',
          background = 'Normal',
        },
      },
    }

    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    end

    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

    local Terminal = require('toggleterm.terminal').Terminal

    vim.api.nvim_set_hl(0, 'LazyGitBorder', { fg = '#ff9e64', bg = '#0a1217' })
    
    local original_float_border = vim.api.nvim_get_hl(0, { name = 'FloatBorder' })
    
    local function apply_lazygit_border()
      vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ff9e64', bg = '#0a1217' })
    end
    
    local function restore_float_border()
      if original_float_border then
        vim.api.nvim_set_hl(0, 'FloatBorder', original_float_border)
      end
    end

    vim.api.nvim_create_autocmd('TermOpen', {
      pattern = 'term://*lazygit*',
      callback = function()
        vim.schedule(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_name:match('lazygit') or vim.bo[buf].filetype == 'toggleterm' then
              vim.api.nvim_win_set_option(win, 'winhl', 'FloatBorder:LazyGitBorder')
              
              for _, border_win in ipairs(vim.api.nvim_list_wins()) do
                if border_win ~= win then
                  local win_config = vim.api.nvim_win_get_config(border_win)
                  if win_config and win_config.relative == 'editor' then
                    local border_buf = vim.api.nvim_win_get_buf(border_win)
                    if vim.api.nvim_buf_get_name(border_buf) == '' then
                      vim.api.nvim_win_set_option(border_win, 'winhl', 'FloatBorder:LazyGitBorder')
                    end
                  end
                end
              end
            end
          end
        end)
      end,
    })

    vim.api.nvim_create_autocmd('WinEnter', {
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name:match('lazygit') or vim.bo[buf].filetype == 'toggleterm' then
          local win = vim.api.nvim_get_current_win()
          local win_config = vim.api.nvim_win_get_config(win)
          if win_config and win_config.relative == 'editor' then
            vim.api.nvim_win_set_option(win, 'winhl', 'FloatBorder:LazyGitBorder')
          end
        end
      end,
    })

    local lazygit = Terminal:new({
      cmd = 'lazygit',
      dir = 'git_dir',
      direction = 'float',
      float_opts = {
        border = 'curved',
        highlights = {
          border = 'LazyGitBorder',
        },
      },
      on_open = function(term)
        vim.cmd('startinsert!')
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
        
        apply_lazygit_border()
        
        vim.schedule(function()
          if term.window_id and vim.api.nvim_win_is_valid(term.window_id) then
            vim.api.nvim_win_set_option(term.window_id, 'winhl', 'FloatBorder:LazyGitBorder')
            
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if win ~= term.window_id then
                local win_config = vim.api.nvim_win_get_config(win)
                if win_config and win_config.relative == 'editor' then
                  local buf = vim.api.nvim_win_get_buf(win)
                  local buf_name = vim.api.nvim_buf_get_name(buf)
                  if buf_name == '' or vim.bo[buf].filetype == '' then
                    vim.api.nvim_win_set_option(win, 'winhl', 'FloatBorder:LazyGitBorder')
                  end
                end
              end
            end
          end
        end)
      end,
      on_close = function(term)
        restore_float_border()
      end,
    })

    function _LAZYGIT_TOGGLE()
      lazygit:toggle()
    end

    vim.keymap.set('n', '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', { desc = 'Toggle [F]loating terminal' })
    vim.keymap.set('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', { desc = 'Toggle [H]orizontal terminal' })
    vim.keymap.set('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', { desc = 'Toggle [V]ertical terminal' })
    vim.keymap.set('n', '<leader>gg', '<cmd>lua _LAZYGIT_TOGGLE()<CR>', { noremap = true, silent = true, desc = 'Toggle lazy[g]it' })
  end,
}

