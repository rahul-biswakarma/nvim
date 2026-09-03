return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>lf",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = "",
            desc = "Format buffer",
        },
    },
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            sql = { "sql_formatter" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            javascriptreact = { "prettier" },
            typescriptreact = { "prettier" },
            html = { "prettier" },
            css = { "prettier" },
            json = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            rust = { "rustfmt" },
            python = { "ruff_organize_imports", "ruff_format" },
            -- odin: no standalone formatter in mason; ols formats via lsp_fallback
        },
        format_on_save = {
            timeout_ms = 500,
            lsp_fallback = true,
        },
    },
}
