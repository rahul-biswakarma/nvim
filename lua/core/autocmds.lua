-- ============================================================================
-- Core Autocommands
-- ============================================================================
-- Autocommands that run automatically based on events.
-- See `:help autocmd` for more information.
-- ============================================================================

-- ============================================================================
-- Highlight on Yank
-- ============================================================================
-- Highlights yanked text briefly to show what was copied.
-- Try it with `yap` in normal mode.
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- ============================================================================
-- Startup: Open File Tree
-- ============================================================================
-- Open neo-tree on startup when no file arguments
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Close netrw if it opens
    if vim.bo.filetype == 'netrw' then
      vim.cmd('bd')
    end
    
    -- Close directory buffers
    if vim.fn.isdirectory(vim.fn.expand('%')) == 1 then
      vim.cmd('bd')
    end
    
    -- Open neo-tree if not already open and no file arguments
    if vim.fn.argc() == 0 then
      vim.defer_fn(function()
        local has_tree = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'neo-tree' then
            has_tree = true
            break
          end
        end
        
        if not has_tree then
          vim.cmd('Neotree reveal')
        end
      end, 200)
    end
  end,
  group = vim.api.nvim_create_augroup('Startup', { clear = true }),
})
