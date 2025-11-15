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
            
            -- Session lens integration (optional telescope picker)
            session_lens = {
                load_on_setup = true,
                theme_conf = { border = true },
                previewer = false,
            },
        })
    end,
}

