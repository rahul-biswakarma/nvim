return {
  'craftzdog/solarized-osaka.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('solarized-osaka').setup {
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = 'dark',
        floats = 'dark',
      },
      sidebars = { 'qf', 'help', 'NvimTree' },
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = true,
    }
    -- Load the colorscheme
    vim.cmd.colorscheme 'solarized-osaka'
  end,
}

