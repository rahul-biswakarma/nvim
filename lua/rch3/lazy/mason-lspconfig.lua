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
        },
    },
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
}
