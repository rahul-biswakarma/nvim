return {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Git Diff View" },
        { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close Git Diff View" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git File History" },
    },
    opts = {
        enhanced_diff_hl = true,
        view = {
            default = {
                layout = "diff2_horizontal",
            },
            file_history = {
                layout = "diff2_horizontal",
            },
        },
    },
}

