--[[
  Colorizer - Color Code Highlighting
  
  Displays color previews inline for color codes (hex, rgb, hsl, etc.).
  Supports CSS, Tailwind, and various color formats.
]]

return {
  'NvChad/nvim-colorizer.lua',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('colorizer').setup {
      -- Enable for all file types
      filetypes = { '*' },
      
      user_default_options = {
        -- Color format support
        RGB = true,           -- #RGB hex codes
        RRGGBB = true,        -- #RRGGBB hex codes
        names = true,         -- Color names like "Blue"
        RRGGBBAA = true,      -- #RRGGBBAA hex codes with alpha
        AARRGGBB = false,     -- 0xAARRGGBB hex codes (disabled)
        
        -- Function formats
        rgb_fn = true,        -- CSS rgb() and rgba() functions
        hsl_fn = true,        -- CSS hsl() and hsla() functions
        css = true,           -- Enable all CSS features
        css_fn = true,        -- Enable all CSS *functions*
        
        -- Display mode
        mode = 'background',  -- Show color as background
        
        -- Framework support
        tailwind = true,      -- Tailwind CSS colors
        sass = { enable = true, parsers = { 'css' } },  -- Sass/SCSS support
        
        -- Visual indicator
        virtualtext = '■',    -- Virtual text indicator
        
        -- Performance
        always_update = false,  -- Don't update on every change (better performance)
      },
      
      buftypes = {},
    }
  end,
}
