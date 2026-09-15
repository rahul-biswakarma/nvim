return {
    "rmagatti/auto-session",
    config = function()
        local logger = require("rch3.config.debug_logger")
        require("auto-session").setup({
            log_level = "error",
            auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
            auto_session_use_git_branch = false,

            auto_save_enabled = true,
            auto_restore_enabled = true,

            bypass_save_filetypes = { "neo-tree", "neo-tree-popup", "notify", "TelescopePrompt", "TelescopeResults" },
            pre_save_cmds = {
                function(session_name)
                    logger.log("[AUTO-SESSION] pre_save_cmds hook triggered for session: " .. tostring(session_name))
                    pcall(vim.cmd, "Neotree close")
                end,
            },
            post_save_cmds = {
                function(session_name)
                    logger.log("[AUTO-SESSION] post_save_cmds hook completed for session: " .. tostring(session_name))
                end,
            },
            pre_restore_cmds = {
                function(session_name)
                    logger.log("[AUTO-SESSION] pre_restore_cmds hook triggered for session: " .. tostring(session_name))
                end,
            },
            post_restore_cmds = {
                function(session_name)
                    logger.log("[AUTO-SESSION] post_restore_cmds hook completed for session: " .. tostring(session_name))
                end,
            },

            session_lens = {
                load_on_setup = false,
                theme_conf = { border = true },
                previewer = false,
            },
        })
    end,
}
