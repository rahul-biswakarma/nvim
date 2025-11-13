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
        },
        handlers = {
            -- Default handler - will be called for each installed server
            function(server_name)
                require("lspconfig")[server_name].setup({})
            end,
            -- Disable sqls to avoid database connection errors
            ["sqls"] = function() end,
            -- Disable ts_ls, using typescript-tools instead
            ["ts_ls"] = function() end,
        },
    },
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
}
