return {
    "rmagatti/auto-session",
    config = function()
        require("auto-session").setup({
            log_level = "error",
            auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
            auto_session_use_git_branch = false,

            -- Automatically save session
            auto_save_enabled = true,
            auto_restore_enabled = true,

            -- Prevent Neo-tree buffers from polluting saved sessions (fixes E95 buffer collision)
            bypass_save_filetypes = { "neo-tree", "neo-tree-popup", "notify" },
            pre_save_cmds = { "Neotree close" },

            -- Session lens integration (optional telescope picker)
            -- Disabled on setup so Telescope picker does not trigger unexpectedly on save/startup
            session_lens = {
                load_on_setup = false,
                theme_conf = { border = true },
                previewer = false,
            },
        })
    end,
}
