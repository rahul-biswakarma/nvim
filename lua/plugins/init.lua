-- ============================================================================
-- Plugin Configuration
-- ============================================================================
-- All plugins are loaded via lazy.nvim.
-- Plugins are organized by category for better maintainability.
-- Each plugin file in lua/plugins/ contains its specific configuration.
-- ============================================================================

return {
  -- ==========================================================================
  -- Plugin Manager & Core Utilities
  -- ==========================================================================
  { 'folke/neoconf.nvim', cmd = 'Neoconf' },
  { 'folke/neodev.nvim' },

  -- ==========================================================================
  -- UI & Appearance
  -- ==========================================================================
  { 'rebelot/solarized-osaka.nvim', lazy = false, priority = 1000 },
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { 'akinsho/bufferline.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { 'nvim-neo-tree/neo-tree.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { 'danilamihailov/beacon.nvim' },
  { 'lukas-reineke/indent-blankline.nvim' },
  { 'NvChad/nvim-colorizer.lua' },
  { 'rcarriga/nvim-notify' },
  { 'stevearc/dressing.nvim' },

  -- ==========================================================================
  -- LSP & Language Support
  -- ==========================================================================
  { 'neovim/nvim-lspconfig', dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', tag = 'legacy' },
  }},
  { 'hrsh7th/nvim-cmp', dependencies = {
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'rafamadriz/friendly-snippets',
  }},
  { 'mrcjkb/rustaceanvim', ft = { 'rust' } },
  { 'nvim-treesitter/nvim-treesitter', dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  }, build = ':TSUpdate' },
  { 'windwp/nvim-ts-autotag' },
  { 'm-demare/hlargs.nvim', dependencies = { 'nvim-treesitter/nvim-treesitter' } },
  { 'jose-elias-alvarez/null-ls.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'folke/trouble.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },

  -- ==========================================================================
  -- Editing & Text Manipulation
  -- ==========================================================================
  { 'windwp/nvim-autopairs' },
  { 'numToStr/Comment.nvim', lazy = false },
  { 'kylechui/nvim-surround' },
  { 'RRethy/vim-illuminate' },

  -- ==========================================================================
  -- Navigation & Search
  -- ==========================================================================
  { 'nvim-telescope/telescope.nvim', dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
  }},
  { 'phaazon/hop.nvim', branch = 'v2' },

  -- ==========================================================================
  -- Git Integration
  -- ==========================================================================
  { 'lewis6991/gitsigns.nvim' },
  { 'kdheepak/lazygit.nvim', cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  }, dependencies = { 'nvim-lua/plenary.nvim' } },

  -- ==========================================================================
  -- Rust-Specific Tools
  -- ==========================================================================
  { 'saecki/crates.nvim', event = { 'BufRead Cargo.toml' }, dependencies = { 'nvim-lua/plenary.nvim' } },

  -- ==========================================================================
  -- Productivity & Utilities
  -- ==========================================================================
  { 'folke/todo-comments.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'akinsho/toggleterm.nvim', version = '*' },
  { 'rmagatti/auto-session' },
}
