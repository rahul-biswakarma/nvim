--[[
  Solarized Osaka - Colorscheme
  
  Modern variant of the classic Solarized theme with enhanced colors.
  Features italics for comments and keywords, customizable transparency.
]]

return {
  'craftzdog/solarized-osaka.nvim',
  lazy = false,    -- Load immediately
  priority = 1000, -- Load before other plugins
  config = function()
    require('solarized-osaka').setup {
      -- ============================================================================
      -- APPEARANCE
      -- ============================================================================
      transparent = false,     -- Disable background transparency
      terminal_colors = true,  -- Configure terminal colors
      
      -- ============================================================================
      -- STYLE SETTINGS
      -- ============================================================================
      styles = {
        comments = { italic = true },   -- Italic comments
        keywords = { italic = true },   -- Italic keywords
        functions = {},                 -- Default function style
        variables = {},                 -- Default variable style
        sidebars = 'dark',              -- Dark sidebars
        floats = 'dark',                -- Dark floating windows
      },
      
      -- ============================================================================
      -- SIDEBAR CONFIGURATION
      -- ============================================================================
      sidebars = { 'qf', 'help', 'NvimTree' },  -- Windows to apply sidebar style
      
      -- ============================================================================
      -- STATUSLINE
      -- ============================================================================
      hide_inactive_statusline = false,  -- Keep statusline on inactive windows
      dim_inactive = false,              -- Don't dim inactive windows
      lualine_bold = true,               -- Bold lualine mode indicator
    }
    
    -- Load the colorscheme
    vim.cmd.colorscheme('solarized-osaka')
  end,
}
