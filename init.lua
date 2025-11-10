-- ============================================================================
-- Neovim Configuration
-- ============================================================================
-- This is the main entry point for Neovim configuration.
-- It loads core settings, keymaps, autocmds, and plugins in order.
--
-- Structure:
--   core/          - Core Neovim settings (options, keymaps, autocmds)
--   plugins/       - Plugin configurations organized by category
-- ============================================================================

-- Set leader keys (must be set before plugins load)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load core configuration
require('core.options')    -- Neovim options and settings
require('core.keymaps')    -- Keybindings
require('core.autocmds')   -- Autocommands

-- Load plugins via lazy.nvim
require('lazy').setup('plugins')

-- vim: ts=2 sts=2 sw=2 et
