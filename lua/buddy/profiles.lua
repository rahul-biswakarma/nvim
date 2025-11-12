-- lua/buddy/profiles.lua
-- Manages buddy profiles, including loading them from the filesystem.

local M = {}

local config = require("buddy.config")
local buddy_root = vim.fn.stdpath("config") .. "/buddies/"

---Loads the system prompt for a given buddy.
---@param buddy_name string The name of the buddy (e.g., "asta").
---@return string | nil The system prompt content or nil if not found.
function M.get_system_prompt(buddy_name)
  local common_path = buddy_root .. "common_prompt.txt"
  local common_file = io.open(common_path, "r")
  local common_content = ""
  if common_file then
    common_content = common_file:read("*a")
    common_file:close()
  end

  local path = buddy_root .. buddy_name .. "/system.txt"
  local file = io.open(path, "r")
  if not file then
    vim.notify("Could not find system prompt for buddy: " .. buddy_name, vim.log.levels.ERROR, { timeout = false })
    return nil
  end
  local specific_content = file:read("*a")
  file:close()

  return common_content .. "\n\n" .. specific_content
end

---Gets the path for a buddy's data directory.
---@param buddy_name string
---@return string
function M.get_buddy_data_path(buddy_name)
  local path = config.options.data_path .. buddy_name
  vim.fn.mkdir(path, "p")
  return path
end

---Loads the buddy-specific topic bank.
---@param buddy_name string
---@return table
function M.get_topic_bank(buddy_name)
  local path = M.get_buddy_data_path(buddy_name) .. "/topics-bank.json"
  local file = io.open(path, "r")
  if not file then
    return {}
  end
  local content = file:read("*a")
  file:close()

  if content == "" then
    return {}
  end

  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    vim.notify("Failed to parse topic bank for " .. buddy_name, vim.log.levels.WARN)
    return {}
  end
  return data
end

---Loads the buddy's long-term memory entries as a string.
---@param buddy_name string
---@return string
function M.get_memory(buddy_name)
  local path = M.get_buddy_data_path(buddy_name) .. "/memory.txt"
  local file = io.open(path, "r")
  if not file then
    return ""
  end
  local content = file:read("*a")
  file:close()
  return content or ""
end

---Appends one or more memory lines to the buddy's memory file.
---@param buddy_name string
---@param memory_entry string | table
function M.append_memory(buddy_name, memory_entry)
  if not memory_entry then
    return
  end

  local lines = {}
  if type(memory_entry) == "string" then
    if memory_entry:match("%S") then
      table.insert(lines, memory_entry)
    end
  elseif vim.islist(memory_entry) then
    for _, entry in ipairs(memory_entry) do
      if type(entry) == "string" and entry:match("%S") then
        table.insert(lines, entry)
      end
    end
  end

  if vim.tbl_isempty(lines) then
    return
  end

  local path = M.get_buddy_data_path(buddy_name) .. "/memory.txt"
  local file = io.open(path, "a")
  if not file then
    return
  end
  for _, line in ipairs(lines) do
    file:write(line, "\n")
  end
  file:close()
end

---Appends new topic ideas to the buddy's topic bank.
---@param buddy_name string
---@param new_ideas table
function M.add_topics(buddy_name, new_ideas)
  if not new_ideas then
    return
  end

  local ideas_list = {}
  if type(new_ideas) == "table" then
    if new_ideas.idea then
      ideas_list = { new_ideas }
    elseif vim.islist(new_ideas) then
      ideas_list = new_ideas
    end
  elseif type(new_ideas) == "string" then
    ideas_list = { { idea = new_ideas, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") } }
  end

  if vim.tbl_isempty(ideas_list) then
    return
  end

  local existing_topics = M.get_topic_bank(buddy_name)
  for _, idea in ipairs(ideas_list) do
    table.insert(existing_topics, idea)
  end
  local path = M.get_buddy_data_path(buddy_name) .. "/topics-bank.json"
  local file = io.open(path, "w")
  if file then
    file:write(vim.fn.json_encode(existing_topics))
    file:close()
  end
end

---Discovers all available buddy profiles in the buddies/ directory.
---@return table A list of buddy names.
function M.get_available_buddies()
  local buddies = {}
  local handle = vim.loop.fs_scandir(buddy_root)
  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    if type == "directory" then
      table.insert(buddies, name)
    end
  end
  return buddies
end

---Placeholder for getting buddy profile details (e.g. from a metadata file).
---This would replace the old registry.lua.
---@param buddy_name string
---@return table
function M.get_buddy_profile(buddy_name)
  local profile_path = buddy_root .. buddy_name .. "/profile.json"
  local file = io.open(profile_path, "r")
  
  local profile_data = {}
  if file then
    local content = file:read("*a")
    file:close()
    local ok, data = pcall(vim.json.decode, content)
    if ok then
      profile_data = data
    else
      vim.notify("Failed to parse profile.json for " .. buddy_name, vim.log.levels.WARN)
    end
  end

  -- Merge with defaults to ensure all fields are present.
  local defaults = {
    name = buddy_name,
    llm = {
      model = "llama3",
      temperature = 0.8,
      max_tokens = 256,
    },
  }

  return vim.tbl_deep_extend("force", defaults, profile_data)
end

return M
