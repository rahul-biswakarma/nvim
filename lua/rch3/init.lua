vim.g.mapleader = " " -- Set leader key before Lazy

require("rch3.config.lazy")
require("rch3.config.keymap")
require("rch3.config.options")

vim.cmd [[colorscheme solarized-osaka]]

-- Apply transparency after colorscheme
vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })
vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "#000000" })
vim.cmd(":hi LineNr guibg=NONE")
vim.cmd(":hi CursorLineNr guibg=NONE")
vim.cmd(":hi SignColumn guibg=NONE")
