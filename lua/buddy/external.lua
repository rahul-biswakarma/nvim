-- lua/buddy/external.lua
-- Handles fetching external context like git comments.

local M = {}

---Get the last N git commit messages.
---@param n number The number of commits to retrieve.
---@return string
function M.get_last_git_comments(n)
  n = n or 5
  local handle = io.popen(string.format("git log -n %d --pretty=format:'- %%s'", n))
  if not handle then
    return ""
  end
  local result = handle:read("*a")
  handle:close()
  return result or ""
end

return M
