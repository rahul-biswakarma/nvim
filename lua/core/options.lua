-- ============================================================================
-- Core Options
-- ============================================================================
-- Neovim options and settings that affect editor behavior.
-- See `:help vim.o` for more information.
-- ============================================================================

-- ============================================================================
-- Editor Behavior
-- ============================================================================
vim.o.hlsearch = false              -- Disable highlight on search
vim.o.number = true                  -- Show line numbers
vim.o.mouse = ''                     -- Disable mouse support
vim.o.clipboard = 'unnamedplus'      -- Sync clipboard with OS
vim.o.breakindent = true             -- Enable break indent
vim.o.undofile = true                -- Save undo history
vim.o.ignorecase = true              -- Case-insensitive search
vim.o.smartcase = true               -- Case-sensitive when capital letter used
vim.o.signcolumn = 'yes'             -- Always show sign column
vim.o.updatetime = 250               -- Faster completion (default 4000)
vim.o.timeoutlen = 300               -- Time to wait for mapped sequence
vim.o.completeopt = 'menuone,noselect' -- Better completion experience
vim.o.termguicolors = true           -- Enable 24-bit RGB colors

-- Disable netrw (use neo-tree instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ============================================================================
-- LSP & Diagnostics
-- ============================================================================
-- Configure diagnostic floating windows with rounded borders
vim.diagnostic.config({
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
    focusable = true,
  },
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Override default LSP floating preview to always use rounded borders
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or 'rounded'
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- ============================================================================
-- UI & Visual Enhancements
-- ============================================================================
-- Set inactive buffer background to black
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#000000' })
    -- Set neo-tree inactive background to black
    vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { bg = '#000000' })
    vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = 'NONE' }) -- Active uses theme default
  end,
})

-- Apply immediately (in case colorscheme already loaded)
vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#000000' })
vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { bg = '#000000' })
vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = 'NONE' })
