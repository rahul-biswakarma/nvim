return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },

    config = function()
        require("telescope").setup({
            defaults = {
                file_ignore_patterns = { "node_modules", "target", "%.git/" },
            },
        })
        pcall(require("telescope").load_extension, "fzf")
    end,
}
