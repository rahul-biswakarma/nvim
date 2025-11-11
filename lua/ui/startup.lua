--[[
  Startup Screen Loader
  
  Loads the startup screen module and exposes its config function.
  This file is required by init.lua before lazy.nvim loads.
]]

local startup_module = require('ui.startup.init')

return {
  config = startup_module.config,
}

