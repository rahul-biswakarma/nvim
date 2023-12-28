vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'nvim-tree/nvim-web-devicons'
    use({
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        requires = {{'nvim-lua/plenary.nvim'}}
    })
    use({"craftzdog/solarized-osaka.nvim", priority = 1000, opts = {}})
    use({"kdheepak/lazygit.nvim", requires = {"nvim-lua/plenary.nvim"}})
    use 'mbbill/undotree'
    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
    use({
        "nvim-telescope/telescope-file-browser.nvim",
        requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"}
    })
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            --- to manage LSP servers from neovim
            {'williamboman/mason.nvim'}, {'williamboman/mason-lspconfig.nvim'},

            -- LSP Support
            {'neovim/nvim-lspconfig'}, -- Autocompletion
            {'hrsh7th/nvim-cmp'}, {'hrsh7th/cmp-nvim-lsp'}, {'L3MON4D3/LuaSnip'}
        }
    }
    use({
        'nvim-lualine/lualine.nvim',
        requires = {'nvim-tree/nvim-web-devicons', opts = true}
    })
end, {display = {open_fn = require('packer.util').float}})
