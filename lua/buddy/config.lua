-- lua/buddy/config.lua

local M = {}

M.options = {
  -- The default buddy to load on startup
  default_buddy = "bro_asta",

  -- Base directory for all buddy data
  data_path = vim.fn.expand('~/Documents/.raw/buddy/'),

  -- UI settings for the buddy window
  ui = {
    width = 50,
    height = 20,
    border = "rounded",
  },

  -- Core logic settings
  core = {
    -- The total weight of events to accumulate before triggering the LLM
    event_weight_threshold = 50,
    -- How long to wait (in ms) when idle before triggering the LLM
    idle_threshold = 180000, -- 3 minutes
    -- How often to fetch new topic ideas (in ms)
    topic_generation_interval = 600000, -- 10 minutes
    -- Maximum number of recent chat messages to include when prompting buddies
    max_history = 40,
  },

  -- Ollama settings
  ollama = {
    endpoint = "http://localhost:11434/api/chat",
    timeout = 30000, -- 30 seconds
    default_model = "llama3",
    json_fixer = {
      model = "gemma3:4b",
      temperature = 0,
      max_tokens = 10000,
    },
  },

  -- External data fetching settings
  external = {
    -- How often to fetch browser tabs (in seconds)
    browser_tabs_interval = 900, -- 15 minutes
  },
}

---Merges user-provided options with the default options.
---@param user_opts table | nil
function M.setup(user_opts)
  user_opts = user_opts or {}
  M.options = vim.tbl_deep_extend("force", M.options, user_opts)
end

return M
