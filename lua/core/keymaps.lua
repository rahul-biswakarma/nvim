--[[
  Core Keymaps
  
  Essential Neovim keybindings for editing and navigation.
  These are standard Vim-style keybinds that don't need the registry.
  
  Plugin-specific shortcuts use keybindings-registry.lua for centralization.
]]

-- ============================================================================
-- LEADER KEY
-- ============================================================================

-- Disable space in normal/visual mode (we use it as leader)
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- ============================================================================
-- LINE NAVIGATION (Respect word wrap)
-- ============================================================================

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = 'Move up (wrap-aware)' })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = 'Move down (wrap-aware)' })

-- ============================================================================
-- INSERT MODE: Word Navigation
-- ============================================================================

vim.keymap.set('i', '<M-Left>', '<C-o>b', { desc = 'Move word backward' })
vim.keymap.set('i', '<M-Right>', '<C-o>w', { desc = 'Move word forward' })
vim.keymap.set('i', '<C-Left>', '<C-o>b', { desc = 'Move word backward (alt)' })
vim.keymap.set('i', '<C-Right>', '<C-o>w', { desc = 'Move word forward (alt)' })

-- ============================================================================
-- INSERT MODE: Line Navigation
-- ============================================================================

vim.keymap.set('i', '<C-a>', '<C-o>^', { desc = 'Move to line start' })
vim.keymap.set('i', '<C-e>', '<C-o>$', { desc = 'Move to line end' })
vim.keymap.set('i', '<Home>', '<C-o>^', { desc = 'Move to line start' })
vim.keymap.set('i', '<End>', '<C-o>$', { desc = 'Move to line end' })

-- ============================================================================
-- INSERT MODE: Text Selection
-- ============================================================================

vim.keymap.set('i', '<S-Left>', '<Esc>vh', { desc = 'Select char left' })
vim.keymap.set('i', '<S-Right>', '<Esc>vl', { desc = 'Select char right' })
vim.keymap.set('i', '<S-Up>', '<Esc>vk', { desc = 'Select line up' })
vim.keymap.set('i', '<S-Down>', '<Esc>vj', { desc = 'Select line down' })
vim.keymap.set('i', '<M-S-Left>', '<Esc>vb', { desc = 'Select word left' })
vim.keymap.set('i', '<M-S-Right>', '<Esc>ve', { desc = 'Select word right' })

-- ============================================================================
-- VISUAL MODE: Extend Selection
-- ============================================================================

vim.keymap.set('v', '<S-Left>', 'h', { desc = 'Extend selection left' })
vim.keymap.set('v', '<S-Right>', 'l', { desc = 'Extend selection right' })
vim.keymap.set('v', '<S-Up>', 'k', { desc = 'Extend selection up' })
vim.keymap.set('v', '<S-Down>', 'j', { desc = 'Extend selection down' })
vim.keymap.set('v', '<M-S-Left>', 'b', { desc = 'Extend selection word left' })
vim.keymap.set('v', '<M-S-Right>', 'e', { desc = 'Extend selection word right' })
vim.keymap.set('v', '<M-Left>', 'b', { desc = 'Extend selection word left (alt)' })
vim.keymap.set('v', '<M-Right>', 'e', { desc = 'Extend selection word right (alt)' })

-- ============================================================================
-- INSERT MODE: Delete Operations
-- ============================================================================

vim.keymap.set('i', '<M-BS>', '<C-w>', { desc = 'Delete word backward' })
vim.keymap.set('i', '<C-BS>', '<C-w>', { desc = 'Delete word backward (alt)' })
vim.keymap.set('i', '<C-Del>', '<C-o>dw', { desc = 'Delete word forward' })
vim.keymap.set('i', '<M-Del>', '<C-o>dw', { desc = 'Delete word forward (alt)' })
vim.keymap.set('i', '<C-u>', '<C-u>', { desc = 'Delete to line start' })
vim.keymap.set('i', '<C-k>', '<C-o>D', { desc = 'Delete to line end' })

-- ============================================================================
-- INSERT MODE: Line Movement & Duplication
-- ============================================================================

vim.keymap.set('i', '<M-Up>', '<Esc>:m-2<CR>==gi', { desc = 'Move line up' })
vim.keymap.set('i', '<M-Down>', '<Esc>:m+<CR>==gi', { desc = 'Move line down' })
vim.keymap.set('i', '<M-S-Up>', '<Esc>:t-1<CR>==gi', { desc = 'Duplicate line up' })
vim.keymap.set('i', '<M-S-Down>', '<Esc>:t.<CR>==gi', { desc = 'Duplicate line down' })
