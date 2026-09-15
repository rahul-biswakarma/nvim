return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },

    config = function()
        local actions = require("telescope.actions")
        local logger = require("rch3.config.debug_logger")

        -- Hook into builtin find_files to capture caller stack traces
        local builtin = require("telescope.builtin")
        local orig_find_files = builtin.find_files
        builtin.find_files = function(opts)
            logger.log("[TELESCOPE] builtin.find_files() called!\nCaller traceback:\n" .. debug.traceback())
            return orig_find_files(opts)
        end

        local orig_live_grep = builtin.live_grep
        builtin.live_grep = function(opts)
            logger.log("[TELESCOPE] builtin.live_grep() called!\nCaller traceback:\n" .. debug.traceback())
            return orig_live_grep(opts)
        end

        require("telescope").setup({
            defaults = {
                file_ignore_patterns = { "node_modules", "target", "%.git/" },
                mappings = {
                    i = {
                        ["<esc>"] = function(prompt_bufnr)
                            logger.log("[TELESCOPE] User closed via <esc> in insert mode")
                            actions.close(prompt_bufnr)
                        end,
                        ["<C-c>"] = function(prompt_bufnr)
                            logger.log("[TELESCOPE] User closed via <C-c> in insert mode")
                            actions.close(prompt_bufnr)
                        end,
                        ["<CR>"] = function(prompt_bufnr)
                            logger.log("[TELESCOPE] User selected entry via <CR>")
                            actions.select_default(prompt_bufnr)
                            logger.log("[TELESCOPE] select_default completed")
                        end,
                    },
                    n = {
                        ["q"] = function(prompt_bufnr)
                            logger.log("[TELESCOPE] User closed via 'q' in normal mode")
                            actions.close(prompt_bufnr)
                        end,
                        ["<esc>"] = function(prompt_bufnr)
                            logger.log("[TELESCOPE] User closed via <esc> in normal mode")
                            actions.close(prompt_bufnr)
                        end,
                    },
                },
            },
        })
        pcall(require("telescope").load_extension, "fzf")
    end,
}
