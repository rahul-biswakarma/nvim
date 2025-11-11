--[[
  Plugin Manifest
  
  Lightweight plugin declarations without configuration.
  Each plugin listed here has its full configuration in a dedicated file.
  This file is for plugins that:
  - Need no configuration (just installation)
  - Have simple opts-only configuration
  - Are dependencies that don't need explicit setup
]]

return {
  -- ============================================================================
  -- CORE UTILITIES
  -- ============================================================================
  { 'folke/neoconf.nvim', cmd = 'Neoconf' },  -- Project-local config
  { 'folke/neodev.nvim' },                     -- Neovim Lua dev setup
  
  -- ============================================================================
  -- UI & APPEARANCE
  -- ============================================================================
  { 'rebelot/solarized-osaka.nvim', lazy = false, priority = 1000 },  -- Colorscheme
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },  -- Status line
  { 'akinsho/bufferline.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },    -- Buffer tabs
  { 'nvim-neo-tree/neo-tree.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } }, -- File explorer
  { 'danilamihailov/beacon.nvim' },            -- Cursor flash on jump
  { 'lukas-reineke/indent-blankline.nvim' },   -- Indent guides
  { 'NvChad/nvim-colorizer.lua' },             -- Color code preview
  { 'rcarriga/nvim-notify' },                  -- Notification UI
  { 'stevearc/dressing.nvim' },                -- Better vim.ui
  
  -- ============================================================================
  -- LSP & LANGUAGE SUPPORT
  -- ============================================================================
  { 
    'neovim/nvim-lspconfig',  -- LSP configuration
    dependencies = {
      'williamboman/mason.nvim',                   -- LSP/tool installer
      'williamboman/mason-lspconfig.nvim',         -- Bridge mason & lspconfig
      'WhoIsSethDaniel/mason-tool-installer.nvim', -- Auto-install tools
      { 'j-hui/fidget.nvim', tag = 'legacy' },     -- LSP progress UI
    },
  },
  { 
    'hrsh7th/nvim-cmp',  -- Autocompletion
    dependencies = {
      'L3MON4D3/LuaSnip',              -- Snippet engine
      'saadparwaiz1/cmp_luasnip',      -- LuaSnip source
      'hrsh7th/cmp-nvim-lsp',          -- LSP source
      'hrsh7th/cmp-path',              -- Path source
      'rafamadriz/friendly-snippets',  -- Snippet collection
    },
  },
  { 'mrcjkb/rustaceanvim', ft = { 'rust' } },  -- Rust LSP
  { 
    'nvim-treesitter/nvim-treesitter',  -- Treesitter
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',  -- Text objects
    }, 
    build = ':TSUpdate',
  },
  { 'windwp/nvim-ts-autotag' },                              -- Auto-close HTML tags
  { 'm-demare/hlargs.nvim', dependencies = { 'nvim-treesitter/nvim-treesitter' } },  -- Highlight arguments
  { 'mfussenegger/nvim-lint' },                              -- Linting
  { 'stevearc/conform.nvim' },                               -- Formatting
  { 'folke/trouble.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },  -- Diagnostics UI
  
  -- ============================================================================
  -- EDITING & TEXT MANIPULATION
  -- ============================================================================
  { 'windwp/nvim-autopairs' },         -- Auto-close brackets
  { 'numToStr/Comment.nvim', lazy = false },  -- Commenting
  { 'kylechui/nvim-surround' },        -- Surround operations
  { 'RRethy/vim-illuminate' },         -- Highlight word under cursor
  
  -- ============================================================================
  -- NAVIGATION & SEARCH
  -- ============================================================================
  { 
    'nvim-telescope/telescope.nvim',  -- Fuzzy finder
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },  -- FZF sorter
      { 'nvim-telescope/telescope-ui-select.nvim' },                    -- UI select override
      { 'nvim-tree/nvim-web-devicons' },
    },
  },
  { 'phaazon/hop.nvim', branch = 'v2' },  -- Fast navigation
  
  -- ============================================================================
  -- GIT INTEGRATION
  -- ============================================================================
  { 'lewis6991/gitsigns.nvim' },  -- Git signs in gutter
  { 
    'kdheepak/lazygit.nvim',  -- LazyGit TUI
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    }, 
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  
  -- ============================================================================
  -- RUST-SPECIFIC TOOLS
  -- ============================================================================
  { 'saecki/crates.nvim', event = { 'BufRead Cargo.toml' }, dependencies = { 'nvim-lua/plenary.nvim' } },  -- Cargo.toml helper
  
  -- ============================================================================
  -- PRODUCTIVITY & UTILITIES
  -- ============================================================================
  { 'folke/todo-comments.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },  -- TODO highlighting
  { 'akinsho/toggleterm.nvim', version = '*' },  -- Terminal
  { 'rmagatti/auto-session' },                   -- Session management
}
