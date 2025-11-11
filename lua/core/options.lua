-- Core Options
vim.o.hlsearch = false
vim.o.number = true
vim.o.cursorline = true
vim.o.mouse = ''
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true

-- Disable touchpad/mouse wheel scrolling completely
-- Disable mouse completely
vim.o.mouse = ''

-- Disable scroll events - defer to avoid conflicts with plugins like lualine
vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyDone',
  callback = function()
    vim.schedule(function()
      local scroll_events = {
        '<ScrollWheelUp>',
        '<ScrollWheelDown>',
        '<S-ScrollWheelUp>',
        '<S-ScrollWheelDown>',
        '<C-ScrollWheelUp>',
        '<C-ScrollWheelDown>',
        '<A-ScrollWheelUp>',
        '<A-ScrollWheelDown>',
      }
      
      for _, mode in ipairs({ 'n', 'i', 'v', 'c', 't', 'x', 's', 'o' }) do
        for _, event in ipairs(scroll_events) do
          pcall(function()
            vim.keymap.set(mode, event, '<Nop>', { noremap = true, silent = true })
          end)
        end
      end
    end)
  end,
  once = true,
})

-- Font (for GUI Neovim clients like Neovide)
vim.opt.guifont = 'JetBrainsMono Nerd Font:h14'

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- LSP Diagnostics
vim.diagnostic.config({
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
    focusable = true,
  },
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
      [vim.diagnostic.severity.HINT] = '󰌵',
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- LSP floating windows borders
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or 'rounded'
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'Normal', { bg = '#0a1217' })
    vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#0f1a20' })
    vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#000000' })
    vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { bg = '#000000' })
    vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'LazyGitBorder', { fg = '#ff9e64', bg = '#0a1217' })
  end,
})

vim.api.nvim_set_hl(0, 'Normal', { bg = '#0a1217' })
vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#0f1a20' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#000000' })
vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { bg = '#000000' })
vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'LazyGitBorder', { fg = '#ff9e64', bg = '#0a1217' })
