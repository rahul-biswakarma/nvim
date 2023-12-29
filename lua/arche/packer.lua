vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use({'wbthomason/packer.nvim'})
    use({'nvim-tree/nvim-web-devicons'})
    use({
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        requires = {{'nvim-lua/plenary.nvim'}}
    })
    use({'stevearc/dressing.nvim'})
    use({"craftzdog/solarized-osaka.nvim", priority = 1000, opts = {}})
    use({"kdheepak/lazygit.nvim", requires = {"nvim-lua/plenary.nvim"}})
    use({'mbbill/undotree'})
    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
    use({"windwp/nvim-ts-autotag", after = "nvim-treesitter"})
    use({
        "nvim-telescope/telescope-file-browser.nvim",
        requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"}
    })
    use({
        "neovim/nvim-lspconfig",
        config = function() require("arche.plugins.lsp") end
    })

    use("onsails/lspkind-nvim")
    use({
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        tag = "v<CurrentMajor>.*"
    })

    -- cmp: Autocomplete
    use({
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        config = function() require("arche.plugins.cmp") end
    })

    use("hrsh7th/cmp-nvim-lsp")

    use({"hrsh7th/cmp-path", after = "nvim-cmp"})

    use({"hrsh7th/cmp-buffer", after = "nvim-cmp"})

    -- LSP diagnostics, code actions, and more via Lua.
    use({
        "jose-elias-alvarez/null-ls.nvim",
        config = function() require("arche.plugins.null-ls") end,
        requires = {"nvim-lua/plenary.nvim"}
    })

    -- Mason: Portable package manager
    use({
        "williamboman/mason.nvim",
        config = function() require("mason").setup() end
    })

    use({
        "williamboman/mason-lspconfig.nvim",
        config = function() require("arche.plugins.mason-lsp") end
    })
    use({
        'nvim-lualine/lualine.nvim',
        requires = {'nvim-tree/nvim-web-devicons', opts = true}
    })
    use({'APZelos/blamer.nvim'})
    use({'nvim-telescope/telescope-fzf-native.nvim', run = 'make'})

end, {display = {open_fn = require('packer.util').float}})
