vim.g.mapleader = " " -- Set leader key before Lazy

require("rch3.config.lazy")

vim.cmd [[colorscheme solarized-osaka]]

require("rch3.config.keymap")
require("rch3.config.options")


vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })
vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "#000000" })
