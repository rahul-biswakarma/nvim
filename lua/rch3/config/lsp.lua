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

-- Organize TypeScript/JavaScript imports once before Conform formats. Python uses
-- Conform's ruff_organize_imports; Rust imports stay a manual <leader>ca action.
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
    callback = function(args)
        local bufnr = args.buf
        local last = vim.api.nvim_buf_line_count(bufnr)
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if client.name == "typescript-tools" and client:supports_method("textDocument/codeAction") then
                local params = {
                    textDocument = vim.lsp.util.make_text_document_params(bufnr),
                    range = { start = { line = 0, character = 0 }, ["end"] = { line = last, character = 0 } },
                    context = { only = { "source.organizeImports" }, diagnostics = {} },
                }
                local res = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
                for _, action in ipairs(res and res.result or {}) do
                    -- Only apply buffer edits. Do not execute interactive commands (such as
                    -- picker commands that trigger Telescope) during synchronous BufWritePre.
                    if action.edit then
                        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                    end
                end
            end
        end
    end,
})
