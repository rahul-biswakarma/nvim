-- ============================================================================
-- Core Keymaps
-- ============================================================================
-- Global keybindings for Neovim.
-- Plugin-specific keymaps are defined in their respective plugin files.
-- See `:help vim.keymap.set()` for more information.
-- ============================================================================

-- ============================================================================
-- Leader Key Setup
-- ============================================================================
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- ============================================================================
-- Movement Improvements
-- ============================================================================
-- Better movement with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- ============================================================================
-- Insert Mode: Word Navigation (Like Modern Editors)
-- ============================================================================
vim.keymap.set('i', '<M-Left>', '<C-o>b', { desc = 'Move word backward' })
vim.keymap.set('i', '<M-Right>', '<C-o>w', { desc = 'Move word forward' })
vim.keymap.set('i', '<C-Left>', '<C-o>b', { desc = 'Move word backward' })
vim.keymap.set('i', '<C-Right>', '<C-o>w', { desc = 'Move word forward' })

-- ============================================================================
-- Insert Mode: Line Navigation
-- ============================================================================
vim.keymap.set('i', '<C-a>', '<C-o>^', { desc = 'Move to start of line' })
vim.keymap.set('i', '<C-e>', '<C-o>$', { desc = 'Move to end of line' })
vim.keymap.set('i', '<Home>', '<C-o>^', { desc = 'Move to start of line' })
vim.keymap.set('i', '<End>', '<C-o>$', { desc = 'Move to end of line' })

-- ============================================================================
-- Insert Mode: Text Selection (Character)
-- ============================================================================
vim.keymap.set('i', '<S-Left>', '<Esc>vh', { desc = 'Select character backward' })
vim.keymap.set('i', '<S-Right>', '<Esc>vl', { desc = 'Select character forward' })
vim.keymap.set('i', '<S-Up>', '<Esc>vk', { desc = 'Select line up' })
vim.keymap.set('i', '<S-Down>', '<Esc>vj', { desc = 'Select line down' })

-- ============================================================================
-- Insert Mode: Text Selection (Word)
-- ============================================================================
vim.keymap.set('i', '<M-S-Left>', '<Esc>vb', { desc = 'Select word backward' })
vim.keymap.set('i', '<M-S-Right>', '<Esc>ve', { desc = 'Select word forward' })

-- ============================================================================
-- Visual Mode: Extend Selection (Character)
-- ============================================================================
vim.keymap.set('v', '<S-Left>', 'h', { desc = 'Extend selection left' })
vim.keymap.set('v', '<S-Right>', 'l', { desc = 'Extend selection right' })
vim.keymap.set('v', '<S-Up>', 'k', { desc = 'Extend selection up' })
vim.keymap.set('v', '<S-Down>', 'j', { desc = 'Extend selection down' })

-- ============================================================================
-- Visual Mode: Extend Selection (Word)
-- ============================================================================
vim.keymap.set('v', '<M-S-Left>', 'b', { desc = 'Extend selection word backward' })
vim.keymap.set('v', '<M-S-Right>', 'e', { desc = 'Extend selection word forward' })
vim.keymap.set('v', '<M-Left>', 'b', { desc = 'Extend selection word backward' })
vim.keymap.set('v', '<M-Right>', 'e', { desc = 'Extend selection word forward' })

-- ============================================================================
-- Insert Mode: Delete Operations
-- ============================================================================
vim.keymap.set('i', '<M-BS>', '<C-w>', { desc = 'Delete word backward' })
vim.keymap.set('i', '<C-BS>', '<C-w>', { desc = 'Delete word backward' })
vim.keymap.set('i', '<C-Del>', '<C-o>dw', { desc = 'Delete word forward' })
vim.keymap.set('i', '<M-Del>', '<C-o>dw', { desc = 'Delete word forward' })
vim.keymap.set('i', '<C-u>', '<C-u>', { desc = 'Delete to start of line' })
vim.keymap.set('i', '<C-k>', '<C-o>D', { desc = 'Delete to end of line' })

-- ============================================================================
-- Highlight on Yank
-- ============================================================================
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
