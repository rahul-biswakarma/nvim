vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search in current file" })

-- Exact match search keymaps
vim.keymap.set("n", "<leader>fS", function()
    require('telescope.builtin').grep_string({
        search = vim.fn.input("Exact search: "),
        use_regex = false,
        search_dirs = { vim.fn.expand("%:p") },
    })
end, { desc = "Exact search in current file" })

vim.keymap.set("n", "<leader>fw", function()
    require('telescope.builtin').grep_string({
        search_dirs = { vim.fn.expand("%:p") },
    })
end, { desc = "Search word under cursor in current file" })

vim.keymap.set("n", "<leader>fW", function()
    require('telescope.builtin').live_grep({
        additional_args = function()
            return { "--fixed-strings" }
        end
    })
end, { desc = "Exact string search (all files)" })
-- Neo-tree toggle
vim.keymap.set("n", "<C-n>", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neo-tree" })

vim.keymap.set("n", "<leader>q", ":quit<CR>")
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")

-- Session management
vim.keymap.set("n", "<leader>ss", "<cmd>SessionSave<cr>", { desc = "Save session" })
vim.keymap.set("n", "<leader>sr", "<cmd>SessionRestore<cr>", { desc = "Restore session" })
vim.keymap.set("n", "<leader>sd", "<cmd>SessionDelete<cr>", { desc = "Delete session" })
vim.keymap.set("n", "<leader>sf", "<cmd>SessionSearch<cr>", { desc = "Search sessions" })
vim.keymap.set("n", "<leader>re", function() vim.cmd.RustLsp('explainError') end)
vim.keymap.set("n", "<leader>rd", function() vim.cmd.RustLsp('renderDiagnostic') end)
vim.keymap.set("n", "<leader>rc", function() vim.cmd.RustLsp('flyCheck') end)

-- Diagnostic keybindings
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic in float" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

-- LSP keybindings
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
-- Yank into system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y') -- yank motion
vim.keymap.set({ 'n', 'v' }, '<leader>Y', '"+Y') -- yank line

-- Delete into system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"+d') -- delete motion
vim.keymap.set({ 'n', 'v' }, '<leader>D', '"+D') -- delete line

-- Paste from system clipboard
vim.keymap.set('n', '<leader>p', '"+p') -- paste after cursor
vim.keymap.set('n', '<leader>P', '"+P') -- paste before cursor

-- Auto-close quickfix/location list after selecting an item
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>:lclose<CR>", { buffer = true, silent = true })
    end,
})
