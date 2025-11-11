--[[
  Nvim-Notify - Better Notifications
  
  Provides beautiful, animated notification popups for vim.notify().
  Replaces default Neovim notifications with a modern UI.
]]

return {
  'rcarriga/nvim-notify',
  event = 'VeryLazy',
  config = function()
    local notify = require('notify')
    
    notify.setup({
      -- ============================================================================
      -- APPEARANCE
      -- ============================================================================
      background_colour = '#000000',  -- Background color for transparency
      render = 'default',             -- Rendering style
      stages = 'fade_in_slide_out',   -- Animation style
      top_down = true,                -- Notifications appear from top
      
      -- ============================================================================
      -- BEHAVIOR
      -- ============================================================================
      fps = 30,           -- Animation framerate
      timeout = 3000,     -- Auto-dismiss timeout (ms)
      minimum_width = 50, -- Minimum notification width
      level = 2,          -- Minimum log level (2 = INFO)
      
      -- ============================================================================
      -- ICONS
      -- ============================================================================
      icons = {
        DEBUG = '',
        ERROR = '',
        INFO = '',
        TRACE = '✎',
        WARN = '',
      },
    })

    -- Replace default vim.notify with nvim-notify
    vim.notify = notify
  end,
}
