return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        {"nvim-telescope/telescope-fzf-native.nvim", build = "make"},
        "nvim-telescope/telescope-file-browser.nvim", "nvim-lua/plenary.nvim",
        'nvim-tree/nvim-web-devicons'
    },
    branch = '0.1.x',
    keys = {
        {
            "<leader>fF",
            function()
                require("utils.picker").prettyFilesPicker({picker = 'git_files'})
            end,
            desc = "Find Git File"
        }, {
            "<leader>ff",
            function()
                require("utils.picker").prettyFilesPicker({
                    picker = 'find_files'
                })
            end,
            desc = "Find cwd File"
        }, {
            "<leader>fb",
            function() require("utils.picker").prettyBuffersPicker() end,
            desc = "Buffer Picker"
        }, {
            "<leader>fg",
            function()
                require("utils.picker").prettyGrepPicker({picker = 'live_grep'})
            end,
            desc = "Live Grep"
        }, {
            "<leader>fs",
            function()
                require("utils.picker").prettyGrepPicker({
                    picker = 'grep_string'
                })
            end,
            desc = "Live Grep String"
        }, {
            ";s",
            function()
                local builtin = require("telescope.builtin")
                builtin.treesitter()
            end,
            desc = "Lists Function names, variables, from Treesitter"
        }
    },
    config = function(_, opts)
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local fb_actions = require("telescope").extensions.file_browser.actions

        local defaultOpts

        if (opts.defaults) then
            defaultOpts = opts.defaults
        else
            defaultOpts = {}
        end

        opts.defaults = vim.tbl_deep_extend("force", defaultOpts, {
            wrap_results = true,
            layout_strategy = "horizontal",
            layout_config = {prompt_position = "top"},
            sorting_strategy = "ascending",
            winblend = 0,
            mappings = {n = {}}
        })
        opts.pickers = {
            diagnostics = {
                theme = "ivy",
                initial_mode = "normal",
                layout_config = {preview_cutoff = 9999},
                sorting = {
                    previewer = {
                        get_generic_file = function(entry)
                            return string.format("%s (%s)",
                                                 entry.path:match("([^/]+)$"),
                                                 entry.path)
                        end
                    }
                }
            }
        }
        opts.extensions = {
            file_browser = {
                theme = "dropdown",
                -- disables netrw and use telescope-file-browser in its place
                hijack_netrw = true,
                mappings = {
                    -- your custom insert mode mappings
                    ["n"] = {
                        -- your custom normal mode mappings
                        ["N"] = fb_actions.create,
                        ["h"] = fb_actions.goto_parent_dir,
                        ["/"] = function()
                            vim.cmd("startinsert")
                        end,
                        ["<C-u>"] = function(prompt_bufnr)
                            for i = 1, 10 do
                                actions.move_selection_previous(prompt_bufnr)
                            end
                        end,
                        ["<C-d>"] = function(prompt_bufnr)
                            for i = 1, 10 do
                                actions.move_selection_next(prompt_bufnr)
                            end
                        end,
                        ["<PageUp>"] = actions.preview_scrolling_up,
                        ["<PageDown>"] = actions.preview_scrolling_down
                    }
                }
            }
        }
        telescope.setup(opts)
        require("telescope").load_extension("fzf")
        require("telescope").load_extension("file_browser")
    end
}
