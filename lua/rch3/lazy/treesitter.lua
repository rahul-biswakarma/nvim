return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- master is EOL / incompatible with Neovim 0.11+; main is the supported branch
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup()

        -- install parsers (async; no-op for ones already installed)
        require("nvim-treesitter").install({
            "lua", "vim", "vimdoc", "sql", "javascript", "typescript",
            "gitignore", "gitcommit", "c", "cpp", "python", "java", "kotlin",
            "scala", "haskell", "ocaml", "ruby", "rust", "odin", "html", "css",
            "json", "markdown", "markdown_inline",
        })

        -- main branch: highlighting/indent are enabled per-buffer, not via a global table
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(ev)
                if pcall(vim.treesitter.start, ev.buf) then
                    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
