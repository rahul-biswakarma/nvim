return {
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        opts = {
            direction = "float",
            float_opts = {
                border = "curved",
            },
        },
        keys = {
            { "<leader>/", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
        },
    }
}
