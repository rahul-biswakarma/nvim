-- Neovim Configuration Entry Point
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
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

-- Load configuration
require('core.options')
require('core.keymaps')
require('core.autocmds')

-- Load startup screen early (before lazy)
require('ui.startup').config()

require('lazy').setup('plugins')

-- Note: keystroke-analytics.lua is auto-loaded by lazy.nvim from plugins/ directory
