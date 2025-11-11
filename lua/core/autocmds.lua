--[[
  Core Autocommands
  
  Automatic behaviors triggered by Neovim events.
]]

local utils = require('core.utils')

-- ============================================================================
-- VISUAL FEEDBACK
-- ============================================================================

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  pattern = '*',
})

-- ============================================================================
-- STARTUP BEHAVIOR
-- ============================================================================

-- Open file tree on startup (if no files opened and no startup screen)
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Skip if startup screen is active (it handles Neo-tree)
    if utils.has_startup_screen() then
      return
    end
    
    -- Close default file browser if it opened
    if vim.bo.filetype == 'netrw' then
      vim.cmd('bd')
    end
    
    -- Close buffer if a directory was opened
    if vim.fn.isdirectory(vim.fn.expand('%')) == 1 then
      vim.cmd('bd')
    end
    
    -- Open Neo-tree if no files were opened
    if vim.fn.argc() == 0 then
      utils.ensure_neotree(200)
    end
  end,
  group = vim.api.nvim_create_augroup('Startup', { clear = true }),
})
