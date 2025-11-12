--[[
  Session Module
  
  Handles session restoration after startup screen unlock.
]]

local M = {}
local utils = require('core.utils')

-- Restore the previous session
function M.restore()
  vim.defer_fn(function()
    -- Restore auto-session if available
    local ok, auto_session = pcall(require, 'auto-session')
    if ok then
      local original_notify = vim.notify
      vim.notify = function() end
      local success, err = pcall(auto_session.RestoreSession)
      vim.notify = original_notify
      if not success then
        original_notify(err, vim.log.levels.ERROR)
      end
    end
    
    -- Open file tree after session restore
    utils.ensure_neotree(500)
  end, 100)
end

return M
