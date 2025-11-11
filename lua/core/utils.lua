--[[
  Core Utilities
  
  Shared helper functions used across the config.
]]

local M = {}

-- Check if Neo-tree is already open
function M.has_neotree()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'neo-tree' then
      return true
    end
  end
  return false
end

-- Open Neo-tree if not already open
function M.ensure_neotree(delay)
  delay = delay or 200
  
  vim.defer_fn(function()
    if not M.has_neotree() then
      vim.cmd('Neotree reveal')
    end
  end, delay)
end

-- Check if startup screen is active
function M.has_startup_screen()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf):match('startup%-screen') then
      return true
    end
  end
  return false
end

return M

