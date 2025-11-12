return {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = {
                "lua",
                "vim",
                "sql",
                "vimdoc",
                "javascript",
                "typescript",
                "gitignore",
                "gitcommit",
                "c",
                "cpp",
                "python",
                "java",
                "kotlin",
                "scala",
                "haskell",
                "ocaml",
                "ruby",
                "rust",
                "html",
                "css",
                "json",
                "markdown",
                "markdown_inline",
            },
            auto_install = true,
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
        })
    end
}
