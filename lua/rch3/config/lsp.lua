-- LSP behavior: inlay hints + organize-imports-on-save.

-- Inlay hints (inferred types shown inline) — per buffer, only if the server
-- supports them. Toggle at runtime with :lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
    end,
})

-- Organize imports on save (removes unused imports where the server supports it:
-- typescript-tools, ruff/pyright). rust-analyzer has no such source action — Rust
-- unused imports stay a manual <leader>ca quick-fix. Runs before conform formats.
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function(args)
        local bufnr = args.buf
        local last = vim.api.nvim_buf_line_count(bufnr)
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if client:supports_method("textDocument/codeAction") then
                for _, kind in ipairs({ "source.organizeImports", "source.organizeImports.ruff", "source.fixAll.ruff" }) do
                    local params = {
                        textDocument = vim.lsp.util.make_text_document_params(bufnr),
                        range = { start = { line = 0, character = 0 }, ["end"] = { line = last, character = 0 } },
                        context = { only = { kind }, diagnostics = {} },
                    }
                    local res = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
                    for _, action in ipairs(res and res.result or {}) do
                        if action.edit then
                            vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                        end
                        if action.command then
                            local cmd = type(action.command) == "table" and action.command or action
                            client:request_sync("workspace/executeCommand", cmd, 1000, bufnr)
                        end
                    end
                end
            end
        end
    end,
})
