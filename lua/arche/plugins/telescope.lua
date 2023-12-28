local telescope = require('telescope')
local builtin = require('telescope.builtin')

-- File picker form git files
vim.keymap.set('n', '<leader>ff', function()
    require("arche.utils.picker").prettyFilesPicker({picker = 'git_files'})
end, {})

-- File picker form all files
vim.keymap.set('n', '<leader>fF', function()
    require("arche.utils.picker").prettyFilesPicker({picker = 'find_files'})
end, {})

-- Buffer picker
vim.keymap.set('n', "<leader>fb", function()
    require("arche.utils.picker").prettyBuffersPicker()
end, {})

-- live global search
vim.keymap.set('n', "<leader> fg", function()
    require("arche.utils.picker").prettyGrepPicker({picker = 'live_grep'})
end, {})

-- search word under your cursor
vim.keymap.set('n', "<leader>fw", function()
    require("arche.utils.picker").prettyGrepPicker({picker = 'grep_string'})
end, {})

telescope.config = function(_, opts)
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local fb_actions = require("telescope").extensions.file_browser.actions

    opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
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
                    ["/"] = function() vim.cmd("startinsert") end,
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
