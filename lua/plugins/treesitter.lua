return {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter.configs")
        ts.setup({
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false
            },
            context_commentstring = {enable = true, enable_autocmd = false},
            ensure_installed = {
                "html", "typescript", "javascript", "css", "scss", "gitignore",
                "json", "yaml", "tsx", "jsdoc", "lua"
            },
            rainbow = {
                enable = true,
                disable = {"html"},
                extended_mode = false,
                max_file_lines = nil
            },
            autotag = {enable = true},
            incremental_selection = {enable = true},
            indent = {enable = true}
        })

        local parser_config =
            require("nvim-treesitter.parsers").get_parser_configs()
        parser_config.tsx.filetype_to_parsername = {
            "javascript", "typescript.tsx"
        }
        require("nvim-treesitter.install").prefer_git = true
    end
}
