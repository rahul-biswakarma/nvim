return {
    "mason-org/mason.nvim",
    opts = {
        ensure_installed = {
            "sql-formatter",
            "stylua",
            "prettier",
            "rustfmt",
        },
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            }
        }
    }
}
