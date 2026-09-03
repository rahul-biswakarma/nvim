vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true       -- spaces, not tabs (formatters assume this)
vim.opt.mouse = "" -- Disable mouse support

-- Quality of life: safe, near-universal defaults
vim.opt.undofile = true        -- persist undo history across sessions
vim.opt.ignorecase = true      -- case-insensitive search...
vim.opt.smartcase = true       -- ...unless you type a capital
vim.opt.scrolloff = 8          -- keep context above/below cursor
vim.opt.updatetime = 250       -- faster diagnostics float / gitsigns
vim.opt.splitright = true      -- vertical splits open to the right
vim.opt.splitbelow = true      -- horizontal splits open below
vim.opt.confirm = true         -- prompt to save instead of failing :q
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

-- Spell check for prose filetypes (native, toggle with `:set spell!`)
vim.opt.spelllang = "en_us"
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text", "gitcommit" },
    callback = function()
        vim.opt_local.spell = true
    end,
})

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
