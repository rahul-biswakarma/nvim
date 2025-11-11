--[[
  Gitsigns - Git Integration
  
  Shows git diff signs in the gutter, provides hunk operations,
  and integrates git blame information directly in Neovim.
]]

return {
  'lewis6991/gitsigns.nvim',
  event = 'BufReadPre',
  config = function()
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry')
    
    require('gitsigns').setup {
      -- ============================================================================
      -- SIGN COLUMN SYMBOLS
      -- ============================================================================
      signs = {
        add = { hl = 'GitSignsAdd', text = '│', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        change = { hl = 'GitSignsChange', text = '│', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
        delete = { hl = 'GitSignsDelete', text = '_', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
        topdelete = { hl = 'GitSignsDelete', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
        changedelete = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
      },
      
      -- ============================================================================
      -- DISPLAY OPTIONS
      -- ============================================================================
      signcolumn = true,  -- Show signs in sign column
      numhl = false,      -- Don't highlight line numbers
      linehl = false,     -- Don't highlight entire line
      word_diff = false,  -- Don't show word diff
      
      -- ============================================================================
      -- GIT DIRECTORY WATCHING
      -- ============================================================================
      watch_gitdir = {
        interval = 1000,       -- Check for changes every second
        follow_files = true,   -- Follow file moves
      },
      attach_to_untracked = true,  -- Show signs for untracked files
      
      -- ============================================================================
      -- BLAME CONFIGURATION
      -- ============================================================================
      current_line_blame = false,  -- Don't show blame by default (toggle with :Gitsigns toggle_current_line_blame)
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',  -- Show at end of line
        delay = 1000,           -- Delay before showing blame
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      
      -- ============================================================================
      -- PERFORMANCE
      -- ============================================================================
      sign_priority = 6,
      update_debounce = 100,      -- Debounce update delay (ms)
      status_formatter = nil,     -- Use default formatter
      max_file_length = 40000,    -- Disable for files larger than 40K lines
      
      -- ============================================================================
      -- PREVIEW WINDOW
      -- ============================================================================
      preview_config = {
        border = 'rounded',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
        focusable = false,
      },
      
      -- ============================================================================
      -- BUFFER KEYMAPS (Buffer-local)
      -- ============================================================================
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- Helper to set buffer-local keymaps
        local function map(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr
          kb.register_keymap('gitsigns', mode, lhs, rhs, opts)
        end

        -- ============================================================================
        -- NAVIGATION
        -- ============================================================================
        -- Next hunk
        map('n', keys.git_next_hunk, function()
          if vim.wo.diff then
            return keys.git_next_hunk
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Next git hunk' })

        -- Previous hunk
        map('n', keys.git_prev_hunk, function()
          if vim.wo.diff then
            return keys.git_prev_hunk
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Previous git hunk' })

        -- ============================================================================
        -- STAGING & RESET
        -- ============================================================================
        map({ 'n', 'v' }, keys.git_stage_hunk, ':Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' })
        map('n', keys.git_stage_buffer, gs.stage_buffer, { desc = 'Stage buffer' })
        map({ 'n', 'v' }, keys.git_reset_hunk, ':Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' })
        map('n', keys.git_reset_buffer, gs.reset_buffer, { desc = 'Reset buffer' })
        map('n', keys.git_undo_stage_hunk, gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
        
        -- ============================================================================
        -- PREVIEW & BLAME
        -- ============================================================================
        map('n', keys.git_preview_hunk, gs.preview_hunk, { desc = 'Preview hunk' })
        map('n', keys.git_blame_line, function()
          gs.blame_line { full = true }
        end, { desc = 'Blame line' })
        map('n', keys.git_blame, function()
          gs.blame_line { 
            full = true,
            ignore_whitespace = false,
          }
        end, { desc = 'Show git line contributor' })
        map('n', keys.git_toggle_blame, gs.toggle_current_line_blame, { desc = 'Toggle current line blame' })
        
        -- ============================================================================
        -- DIFF
        -- ============================================================================
        map('n', keys.git_diff_this, gs.diffthis, { desc = 'Diff this' })
        map('n', keys.git_diff_this_cached, function()
          gs.diffthis('~')
        end, { desc = 'Diff this (cached)' })
        map('n', keys.git_toggle_deleted, gs.toggle_deleted, { desc = 'Toggle deleted' })

        -- ============================================================================
        -- TEXT OBJECTS
        -- ============================================================================
        map({ 'o', 'x' }, keys.git_select_hunk, ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select hunk' })
      end,
    }
  end,
}
