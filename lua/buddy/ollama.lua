-- lua/buddy/ollama.lua
-- Handles API calls to the Ollama service.

local M = {}

local config = require("buddy.config")
local log_file_path = config.options.data_path .. "ollama_log.jsonl"

local function log_call(log_data)
  local log_dir = vim.fn.fnamemodify(log_file_path, ":h")
  vim.fn.mkdir(log_dir, "p")
  local file = io.open(log_file_path, "a")
  if file then
    file:write(vim.fn.json_encode(log_data) .. "\n")
    file:close()
  end
end

---Sends a request to the Ollama API.
---@param buddy_profile table The profile of the active buddy.
---@param system_prompt string The system prompt.
---@param user_prompt string The user prompt with all context.
---@param chat_history table The recent chat history.
---@param reason string The reason for the LLM trigger.
---@param callback function The function to call with the response.
function M.request(buddy_profile, system_prompt, user_prompt, chat_history, reason, callback)
  local endpoint = config.options.ollama.endpoint
  local timeout_seconds = (config.options.ollama.timeout or 30000) / 1000
  local llm_options = buddy_profile.llm or {}

  local messages = {}
  table.insert(messages, { role = "system", content = system_prompt })

  -- Add chat history
  for _, message in ipairs(chat_history) do
    local role = message.sender == "You" and "user" or "assistant"
    table.insert(messages, { role = role, content = message.text })
  end

  -- Add current user prompt
  table.insert(messages, { role = "user", content = user_prompt })

  local payload = {
    model = llm_options.model or "llama3",
    messages = messages,
    stream = false,
    options = {
      temperature = llm_options.temperature or 0.8,
      num_predict = llm_options.max_tokens or 256,
    },
  }

  local start_time = vim.loop.hrtime()

  vim.fn.jobstart(string.format(
    [[curl -s -X POST --max-time %d %s -d '%s']],
    timeout_seconds,
    endpoint,
    vim.fn.json_encode(payload):gsub("'", "'\\''")
  ), {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local duration_ms = (vim.loop.hrtime() - start_time) / 1e6
      if not data or #data == 0 then
        vim.notify("Ollama: Received empty response.", vim.log.levels.WARN)
        log_call({ success = false, duration = duration_ms, error = "Empty response" })
        return
      end

      local response_text = table.concat(data, "\n")
      local ok, response = pcall(vim.json.decode, response_text)

      if not ok then
        vim.notify("Ollama: Failed to decode JSON response: " .. response_text, vim.log.levels.ERROR, { timeout = false })
        log_call({ success = false, duration = duration_ms, error = "JSON decode failed", response = response_text })
        return
      end

      if response.error then
        vim.notify("Ollama API Error: " .. response.error, vim.log.levels.ERROR, { timeout = false })
        log_call({ success = false, duration = duration_ms, error = response.error })
        return
      end

      if response.message and response.message.content then
        log_call({
          success = true,
          trigger = reason,
          model = payload.model,
          prompt_tokens = response.prompt_eval_count,
          response_tokens = response.eval_count,
          duration = duration_ms,
          system_prompt = system_prompt,
          user_prompt = user_prompt,
          history = chat_history,
          response = response.message.content,
        })
        callback(response.message.content)
      else
        vim.notify("Ollama: Unexpected response format.", vim.log.levels.WARN)
        log_call({ success = false, duration = duration_ms, error = "Unexpected format", response = response })
      end
    end,
    on_stderr = function(_, data)
      local duration_ms = (vim.loop.hrtime() - start_time) / 1e6
      local stderr_text = (data and table.concat(data, "\n")) or ""
      if stderr_text == "" then
        return -- curl periodically writes empty chunks; ignore them
      end
      local error_msg = "Ollama job failed: " .. stderr_text
      vim.notify(error_msg, vim.log.levels.ERROR, { timeout = false })
      log_call({ success = false, trigger = reason, duration = duration_ms, error = error_msg })
      callback(nil)
    end,
  })
end

return M
