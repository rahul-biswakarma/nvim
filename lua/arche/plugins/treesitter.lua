require'nvim-treesitter.configs'.setup {

    ensure_installed = {
        "html", "typescript", "javascript", "css", "scss", "gitignore", "json",
        "yaml", "tsx", "jsdoc", "lua"
    },

    auto_install = true,

    highlight = {enable = true, additional_vim_regex_highlighting = false}

}

