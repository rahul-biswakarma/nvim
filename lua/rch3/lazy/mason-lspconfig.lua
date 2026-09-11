return {
    "williamboman/mason-lspconfig.nvim",
    opts = {
        ensure_installed = {
            "lua_ls",
            "rust_analyzer",
            "tailwindcss",
            "html",
            "cssls",
            "ts_ls",
            "basedpyright", -- python: types, completion
            "ruff",         -- python: lint diagnostics
            "eslint",       -- js/ts: lint diagnostics
            "ols",          -- odin language server
        },
        -- These have dedicated integrations (or are deliberately disabled).
        -- mason-lspconfig v2 uses automatic_enable; the old handlers table is ignored.
        automatic_enable = {
            exclude = {
                "rust_analyzer", -- rustaceanvim owns Rust LSP
                "ts_ls",         -- typescript-tools owns TypeScript LSP
                "sqls",          -- avoid unwanted database connection attempts
            },
        },
    },
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
}
