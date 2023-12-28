vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use({
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        requires = {{'nvim-lua/plenary.nvim'}}
    })
    use({"craftzdog/solarized-osaka.nvim", priority = 1000, opts = {}})
    use({"kdheepak/lazygit.nvim", requires = {"nvim-lua/plenary.nvim"}})
    use 'mbbill/undotree'
    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
end)
