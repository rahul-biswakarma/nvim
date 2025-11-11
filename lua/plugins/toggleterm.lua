--[[
  Toggleterm - Terminal Integration
  
  Provides floating, horizontal, and vertical terminal windows within Neovim.
  Includes custom LazyGit integration with styled borders.
  
  Features:
  - Multiple terminal directions (float, horizontal, vertical)
  - LazyGit integration with custom orange borders
  - Terminal mode keymaps for navigation
  - Persistent terminal size and mode
]]

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  event = 'VeryLazy',
  config = function()
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry')
    
    -- ============================================================================
    -- TOGGLETERM SETUP
    -- ============================================================================
    require('toggleterm').setup {
      -- Dynamic sizing based on direction
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      
      -- ============================================================================
      -- BEHAVIOR
      -- ============================================================================
      open_mapping = [[<C-\>]],       -- Toggle with Ctrl+\
      hide_numbers = true,            -- Hide line numbers
      shade_terminals = true,         -- Shade terminal background
      shading_factor = 2,             -- Darkness factor
      start_in_insert = true,         -- Start in insert mode
      insert_mappings = true,         -- Mappings work in insert mode
      terminal_mappings = true,       -- Mappings work in terminal mode
      persist_size = true,            -- Remember terminal size
      persist_mode = true,            -- Remember insert/normal mode
      direction = 'float',            -- Default: floating terminal
      close_on_exit = true,           -- Close when process exits
      shell = vim.o.shell,            -- Use default shell
      auto_scroll = true,             -- Auto-scroll to bottom
      
      -- ============================================================================
      -- FLOAT OPTIONS
      -- ============================================================================
      float_opts = {
        border = 'curved',
        winblend = 0,
        highlights = {
          border = 'Normal',
          background = 'Normal',
        },
      },
    }

    -- ============================================================================
    -- TERMINAL MODE KEYMAPS
    -- ============================================================================
    -- Set keymaps for terminal mode navigation
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)     -- Escape to normal mode
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)  -- Navigate left
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)  -- Navigate down
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)  -- Navigate up
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)  -- Navigate right
      vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)    -- Window commands
    end

    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

    -- ============================================================================
    -- LAZYGIT CUSTOM BORDER STYLING
    -- ============================================================================
    local Terminal = require('toggleterm.terminal').Terminal

    -- Define custom orange border for LazyGit
    vim.api.nvim_set_hl(0, 'LazyGitBorder', { fg = '#ff9e64', bg = '#0a1217' })
    
    -- Store original FloatBorder highlight
    local original_float_border = vim.api.nvim_get_hl(0, { name = 'FloatBorder' })
    
    local function apply_lazygit_border()
      vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ff9e64', bg = '#0a1217' })
    end
    
    local function restore_float_border()
      if original_float_border then
        vim.api.nvim_set_hl(0, 'FloatBorder', original_float_border)
      end
    end

    -- Apply LazyGit border when terminal opens
    vim.api.nvim_create_autocmd('TermOpen', {
      pattern = 'term://*lazygit*',
      callback = function()
        vim.schedule(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_name:match('lazygit') or vim.bo[buf].filetype == 'toggleterm' then
              vim.api.nvim_win_set_option(win, 'winhl', 'FloatBorder:LazyGitBorder')
              
              -- Apply to border windows
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

    -- Maintain LazyGit border on window enter
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

    -- ============================================================================
    -- LAZYGIT TERMINAL INSTANCE
    -- ============================================================================
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
        
        -- Apply border to all floating windows
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

    -- Global function to toggle LazyGit
    function _LAZYGIT_TOGGLE()
      lazygit:toggle()
    end

    -- ============================================================================
    -- KEYMAPS (Using centralized registry)
    -- ============================================================================
    kb.register_keymap('toggleterm', 'n', keys.terminal_float, '<cmd>ToggleTerm direction=float<cr>', { desc = 'Floating terminal' })
    kb.register_keymap('toggleterm', 'n', keys.terminal_horizontal, '<cmd>ToggleTerm direction=horizontal<cr>', { desc = 'Horizontal terminal' })
    kb.register_keymap('toggleterm', 'n', keys.terminal_vertical, '<cmd>ToggleTerm direction=vertical<cr>', { desc = 'Vertical terminal' })
    kb.register_keymap('toggleterm', 'n', keys.lazygit, '<cmd>lua _LAZYGIT_TOGGLE()<CR>', { desc = 'LazyGit' })
  end,
}
