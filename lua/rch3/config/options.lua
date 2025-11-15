vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.tabstop = 4
vim.opt.mouse = "" -- Disable mouse support
vim.cmd(":hi statusline guibg=NONE")
vim.cmd(":hi LineNr guibg=NONE")
vim.cmd(":hi CursorLineNr guibg=NONE")
vim.cmd(":hi SignColumn guibg=NONE")

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"
vim.opt.cursorline = true

-- Make current line darker than background
vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#0f1014' })

vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
        spacing = 4,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})
