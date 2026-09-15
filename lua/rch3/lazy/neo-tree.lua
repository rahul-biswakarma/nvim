return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        lazy = false,
        opts = {
            -- Auto-clean broken neo-tree buffers saved in sessions to prevent
            -- "Vim:E95: Buffer with this name already exists" errors
            auto_clean_after_session_restore = true,
            close_if_last_window = false,
            filesystem = {
                hijack_netrw_behavior = "open_default",
                use_libuv_file_watcher = true,
                filtered_items = {
                    visible = true, -- Show hidden files
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
            },
        },
    }
}
