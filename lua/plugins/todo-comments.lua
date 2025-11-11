--[[
  Todo Comments - Highlight & Search TODO Comments
  
  Highlights TODO, FIX, HACK, WARN, PERF, NOTE, and TEST comments.
  Provides navigation and Telescope search for finding all todos in project.
]]

return {
  'folke/todo-comments.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry')
    
    require('todo-comments').setup {
      -- ============================================================================
      -- SIGN COLUMN
      -- ============================================================================
      signs = true,         -- Show icons in sign column
      sign_priority = 8,    -- Priority for signs
      
      -- ============================================================================
      -- KEYWORDS & ICONS
      -- ============================================================================
      keywords = {
        FIX = {
          icon = ' ',
          color = 'error',
          alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' },
        },
        TODO = { icon = ' ', color = 'info' },
        HACK = { icon = ' ', color = 'warning' },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
        TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },
      
      merge_keywords = true,  -- Merge with default keywords
      
      -- ============================================================================
      -- GUI STYLE
      -- ============================================================================
      gui_style = {
        fg = 'NONE',   -- Use default foreground
        bg = 'BOLD',   -- Bold background
      },
      
      -- ============================================================================
      -- HIGHLIGHT SETTINGS
      -- ============================================================================
      highlight = {
        multiline = true,              -- Enable multiline comments
        multiline_pattern = '^.',      -- Pattern for continuation
        multiline_context = 10,        -- Context lines for multiline
        before = '',                   -- Highlight before keyword
        keyword = 'wide',              -- Highlight style (wide, fg, bg)
        after = 'fg',                  -- Highlight after keyword
        pattern = [[.*<(KEYWORDS)\s*:]], -- Lua pattern to match keywords
        comments_only = true,          -- Only highlight in comments
        max_line_len = 400,            -- Max line length to highlight
        exclude = {},                  -- Excluded filetypes
      },
      
      -- ============================================================================
      -- COLORS
      -- ============================================================================
      colors = {
        error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
        warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
        info = { 'DiagnosticInfo', '#2563EB' },
        hint = { 'DiagnosticHint', '#10B981' },
        default = { 'Identifier', '#7C3AED' },
        test = { 'Identifier', '#FF00FF' },
      },
      
      -- ============================================================================
      -- SEARCH CONFIGURATION
      -- ============================================================================
      search = {
        command = 'rg',  -- Use ripgrep
        args = {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
        },
        pattern = [[\b(KEYWORDS):]],  -- Ripgrep pattern
      },
    }

    -- ============================================================================
    -- KEYMAPS (Using centralized registry)
    -- ============================================================================
    kb.register_keymap('todo-comments', 'n', keys.next_todo, function()
      require('todo-comments').jump_next()
    end, { desc = 'Next todo comment' })

    kb.register_keymap('todo-comments', 'n', keys.prev_todo, function()
      require('todo-comments').jump_prev()
    end, { desc = 'Previous todo comment' })

    kb.register_keymap('todo-comments', 'n', keys.search_todos, ':TodoTelescope<CR>', { desc = 'Search todos' })
  end,
}
