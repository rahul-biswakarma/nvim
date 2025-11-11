--[[
  Keystroke Analytics - Record and Analyze Typing Patterns
  
  Records all keystrokes with context (mode, filetype, buffer) for later
  analysis by LLMs to identify workflow patterns, inefficiencies, and
  opportunities for optimization.
  
  Features:
  - Records keystrokes with timestamps and context
  - Privacy-aware (excludes password prompts, sensitive buffers)
  - Session-based recording (separate files per session)
  - Pause/resume capability
  - Export to LLM-friendly JSON format
  - Pattern analysis helpers
  
  Keybindings:
  - <leader>ka  - Toggle analytics recording
  - <leader>kp  - Pause/resume recording
  - <leader>ks  - Show analytics status
  - <leader>ke  - Export current session for LLM analysis
]]

-- ============================================================================
-- MODULE SETUP
-- ============================================================================

-- Set to true to enable keystroke analytics
local ENABLED = true -- Enabled by default - auto-starts recording

if not ENABLED then
  -- Return empty table for lazy.nvim (module disabled)
  return {}
end

local keys = require('core.keybindings-registry')
local kb = require('core.keybindings-registry')
    
    -- ============================================================================
    -- CONFIGURATION
    -- ============================================================================
    local config = {
      enabled = true, -- Start enabled (toggle with keybinding)
      auto_start = true, -- Automatically start recording on Neovim launch
      data_dir = vim.fn.expand('~/Documents/.raw/neovim'),
      max_session_size = 10000, -- Max events per session
      capture_interval = 100, -- Batch write interval (ms)
      auto_export = true, -- Automatically export to LLM format
      export_interval = 60000, -- Auto-export interval (60 seconds)
      
      -- Privacy settings
      exclude_filetypes = { 'TelescopePrompt', 'neo-tree', 'toggleterm', 'Trouble' },
      exclude_bufnames = { 'startup-screen', '*git*', '*ssh*' },
      exclude_modes = {}, -- Can add modes to exclude
      
      -- Context capture
      capture_buffer_name = true,
      capture_filetype = true,
      capture_mode = true,
      capture_cursor_pos = true,
      capture_line_content = false, -- Privacy: don't capture actual text
    }
    
    -- ============================================================================
    -- STATE
    -- ============================================================================
    local state = {
      recording = false,
      paused = false,
      session_id = nil,
      session_start = nil,
      event_count = 0,
      event_buffer = {},
      last_write = 0,
    }
    
    -- ============================================================================
    -- HELPER FUNCTIONS
    -- ============================================================================
    
    -- Forward declarations (functions used before they're defined)
    local start_auto_export
    local stop_auto_export
    local silent_export
    
    --- Generate a unique session ID
    local function generate_session_id()
      return os.date('%Y%m%d_%H%M%S') .. '_' .. vim.fn.getpid()
    end
    
    --- Get the session file path
    local function get_session_file()
      return config.data_dir .. '/session_' .. state.session_id .. '.jsonl'
    end
    
    --- Check if current buffer should be excluded
    local function should_exclude_buffer()
      local ft = vim.bo.filetype
      local bufname = vim.api.nvim_buf_get_name(0)
      
      -- Check filetype exclusions
      for _, excluded_ft in ipairs(config.exclude_filetypes) do
        if ft == excluded_ft then
          return true
        end
      end
      
      -- Check buffer name patterns
      for _, pattern in ipairs(config.exclude_bufnames) do
        if bufname:match(pattern:gsub('*', '.*')) then
          return true
        end
      end
      
      return false
    end
    
    --- Capture context information
    local function capture_context()
      local context = {
        timestamp = os.time(),
        mode = vim.api.nvim_get_mode().mode,
      }
      
      if config.capture_filetype then
        context.filetype = vim.bo.filetype
      end
      
      if config.capture_buffer_name then
        local bufname = vim.api.nvim_buf_get_name(0)
        -- Strip home directory for privacy
        bufname = bufname:gsub(vim.fn.expand('~'), '~')
        context.buffer = bufname
      end
      
      if config.capture_cursor_pos then
        local pos = vim.api.nvim_win_get_cursor(0)
        context.line = pos[1]
        context.col = pos[2]
      end
      
      return context
    end
    
    --- Record a keystroke event
    local function record_keystroke(key)
      if not state.recording or state.paused or should_exclude_buffer() then
        return
      end
      
      -- Create event
      local event = {
        key = key,
        context = capture_context(),
        seq = state.event_count,
      }
      
      -- Add to buffer
      table.insert(state.event_buffer, event)
      state.event_count = state.event_count + 1
      
      -- Check if we should write to disk
      local now = vim.loop.hrtime() / 1000000 -- Convert to milliseconds
      if now - state.last_write > config.capture_interval or #state.event_buffer >= 100 then
        flush_events()
      end
      
      -- Check session size limit
      if state.event_count >= config.max_session_size then
        vim.notify('Keystroke Analytics: Session size limit reached. Starting new session.', vim.log.levels.WARN)
        stop_recording()
        start_recording()
      end
    end
    
    --- Flush events to disk
    function flush_events()
      if #state.event_buffer == 0 then
        return
      end
      
      local file_path = get_session_file()
      local file = io.open(file_path, 'a')
      if not file then
        vim.notify('Failed to open keystroke analytics file', vim.log.levels.ERROR)
        return
      end
      
      -- Write each event as a JSON line
      for _, event in ipairs(state.event_buffer) do
        file:write(vim.json.encode(event) .. '\n')
      end
      
      file:close()
      state.event_buffer = {}
      state.last_write = vim.loop.hrtime() / 1000000
    end
    
    --- Start recording session
    function start_recording()
      -- Create data directory if it doesn't exist
      vim.fn.mkdir(config.data_dir, 'p')
      
      -- Initialize new session
      state.session_id = generate_session_id()
      state.session_start = os.time()
      state.event_count = 0
      state.event_buffer = {}
      state.recording = true
      state.paused = false
      
      -- Write session metadata
      local metadata = {
        session_id = state.session_id,
        start_time = os.date('%Y-%m-%d %H:%M:%S', state.session_start),
        neovim_version = vim.fn.execute('version'):match('NVIM v([%d%.]+)'),
        config = {
          max_session_size = config.max_session_size,
          excluded_filetypes = config.exclude_filetypes,
        },
      }
      
      local file = io.open(get_session_file(), 'w')
      if file then
        file:write('-- Session Metadata\n')
        file:write(vim.json.encode(metadata) .. '\n')
        file:write('-- Keystroke Events (one JSON object per line)\n')
        file:close()
      end
      
      vim.notify('Keystroke Analytics: Recording started (Session: ' .. state.session_id .. ')', vim.log.levels.INFO)
      
      -- Start auto-export timer
      start_auto_export()
    end
    
    --- Stop recording session
    function stop_recording()
      if not state.recording then
        return
      end
      
      -- Flush remaining events
      flush_events()
      
      -- Stop auto-export timer
      stop_auto_export()
      
      -- Write session end metadata
      local file = io.open(get_session_file(), 'a')
      if file then
        file:write('-- Session End\n')
        file:write(vim.json.encode({
          session_end = os.date('%Y-%m-%d %H:%M:%S'),
          total_events = state.event_count,
          duration_seconds = os.time() - state.session_start,
        }) .. '\n')
        file:close()
      end
      
      -- Do final export in LLM format
      if config.auto_export then
        silent_export()
      end
      
      vim.notify('Keystroke Analytics: Recording stopped. ' .. state.event_count .. ' events recorded.', vim.log.levels.INFO)
      
      state.recording = false
      state.paused = false
    end
    
    --- Toggle pause
    local function toggle_pause()
      if not state.recording then
        vim.notify('Keystroke Analytics: Not currently recording', vim.log.levels.WARN)
        return
      end
      
      state.paused = not state.paused
      if state.paused then
        flush_events()
        vim.notify('Keystroke Analytics: Recording paused', vim.log.levels.INFO)
      else
        vim.notify('Keystroke Analytics: Recording resumed', vim.log.levels.INFO)
      end
    end
    
    --- Show status
    local function show_status()
      local status = {
        'Keystroke Analytics Status:',
        '  Recording: ' .. (state.recording and 'YES' or 'NO'),
        '  Paused: ' .. (state.paused and 'YES' or 'NO'),
        '  Session ID: ' .. (state.session_id or 'N/A'),
        '  Events Recorded: ' .. state.event_count,
        '  Events in Buffer: ' .. #state.event_buffer,
        '',
        'Data Directory: ' .. config.data_dir,
      }
      
      if state.recording then
        local duration = os.time() - state.session_start
        table.insert(status, 'Session Duration: ' .. duration .. ' seconds')
      end
      
      vim.notify(table.concat(status, '\n'), vim.log.levels.INFO)
    end
    
    --- Export session for LLM analysis
    local function export_for_analysis()
      if not state.session_id then
        vim.notify('No active session to export', vim.log.levels.WARN)
        return
      end
      
      -- Flush current events
      if state.recording then
        flush_events()
      end
      
      local export_file = config.data_dir .. '/export_' .. state.session_id .. '_analysis.json'
      
      -- Read all events from session file
      local session_file = get_session_file()
      local events = {}
      local metadata = {}
      
      local file = io.open(session_file, 'r')
      if not file then
        vim.notify('Failed to read session file', vim.log.levels.ERROR)
        return
      end
      
      for line in file:lines() do
        if line:sub(1, 2) ~= '--' and line ~= '' then
          local ok, decoded = pcall(vim.json.decode, line)
          if ok then
            if decoded.session_id then
              metadata = decoded
            elseif decoded.key then
              table.insert(events, decoded)
            end
          end
        end
      end
      file:close()
      
      -- Create analysis-ready export
      local export_data = {
        metadata = metadata,
        statistics = {
          total_events = #events,
          unique_keys = {},
          mode_distribution = {},
          filetype_distribution = {},
        },
        events = events,
        analysis_prompt = [[
This is a keystroke analytics session from a Neovim user.
Please analyze the data and provide insights on:
1. Most frequently used commands and patterns
2. Potential inefficiencies or repetitive patterns
3. Suggestions for custom keybindings or macros
4. Navigation patterns that could be optimized
5. Modes where the user spends most time
6. Recommendations for workflow improvements
        ]],
      }
      
      -- Calculate statistics
      local key_counts = {}
      local mode_counts = {}
      local filetype_counts = {}
      
      for _, event in ipairs(events) do
        -- Count keys
        key_counts[event.key] = (key_counts[event.key] or 0) + 1
        
        -- Count modes
        if event.context.mode then
          mode_counts[event.context.mode] = (mode_counts[event.context.mode] or 0) + 1
        end
        
        -- Count filetypes
        if event.context.filetype then
          filetype_counts[event.context.filetype] = (filetype_counts[event.context.filetype] or 0) + 1
        end
      end
      
      -- Sort and add top items
      local function get_top_items(counts, n)
        local items = {}
        for key, count in pairs(counts) do
          table.insert(items, { key = key, count = count })
        end
        table.sort(items, function(a, b) return a.count > b.count end)
        
        local result = {}
        for i = 1, math.min(n, #items) do
          result[items[i].key] = items[i].count
        end
        return result
      end
      
      export_data.statistics.top_keys = get_top_items(key_counts, 20)
      export_data.statistics.mode_distribution = mode_counts
      export_data.statistics.filetype_distribution = filetype_counts
      
      -- Write export file
      local export = io.open(export_file, 'w')
      if not export then
        vim.notify('Failed to create export file', vim.log.levels.ERROR)
        return
      end
      
      export:write(vim.json.encode(export_data))
      export:close()
      
      vim.notify('Keystroke Analytics: Exported to ' .. export_file .. '\n' .. 
                 'Total events: ' .. #events .. '\n' ..
                 'Ready for LLM analysis!', vim.log.levels.INFO)
      
      -- Open the export file (when manually triggered)
      vim.cmd('edit ' .. export_file)
      
      return export_file
    end
    
    --- Silent export (for auto-export, no notifications or file opening)
    silent_export = function()
      if not state.session_id or state.event_count == 0 then
        return
      end
      
      -- Flush current events
      if state.recording then
        flush_events()
      end
      
      local export_file = config.data_dir .. '/latest_analysis.json'
      
      -- Read all events from session file
      local session_file = get_session_file()
      local events = {}
      local metadata = {}
      
      local file = io.open(session_file, 'r')
      if not file then
        return -- Silently fail
      end
      
      for line in file:lines() do
        if line:sub(1, 2) ~= '--' and line ~= '' then
          local ok, decoded = pcall(vim.json.decode, line)
          if ok then
            if decoded.session_id then
              metadata = decoded
            elseif decoded.key then
              table.insert(events, decoded)
            end
          end
        end
      end
      file:close()
      
      -- Create analysis-ready export
      local export_data = {
        metadata = metadata,
        statistics = {
          total_events = #events,
          unique_keys = {},
          mode_distribution = {},
          filetype_distribution = {},
        },
        events = events,
        analysis_prompt = [[
This is a keystroke analytics session from a Neovim user.
Please analyze the data and provide insights on:
1. Most frequently used commands and patterns
2. Potential inefficiencies or repetitive patterns
3. Suggestions for custom keybindings or macros
4. Navigation patterns that could be optimized
5. Modes where the user spends most time
6. Recommendations for workflow improvements
        ]],
      }
      
      -- Calculate statistics
      local key_counts = {}
      local mode_counts = {}
      local filetype_counts = {}
      
      for _, event in ipairs(events) do
        key_counts[event.key] = (key_counts[event.key] or 0) + 1
        if event.context.mode then
          mode_counts[event.context.mode] = (mode_counts[event.context.mode] or 0) + 1
        end
        if event.context.filetype then
          filetype_counts[event.context.filetype] = (filetype_counts[event.context.filetype] or 0) + 1
        end
      end
      
      -- Sort and add top items
      local function get_top_items(counts, n)
        local items = {}
        for key, count in pairs(counts) do
          table.insert(items, { key = key, count = count })
        end
        table.sort(items, function(a, b) return a.count > b.count end)
        
        local result = {}
        for i = 1, math.min(n, #items) do
          result[items[i].key] = items[i].count
        end
        return result
      end
      
      export_data.statistics.top_keys = get_top_items(key_counts, 20)
      export_data.statistics.mode_distribution = mode_counts
      export_data.statistics.filetype_distribution = filetype_counts
      
      -- Write export file
      local export = io.open(export_file, 'w')
      if export then
        export:write(vim.json.encode(export_data))
        export:close()
      end
    end
    
    -- ============================================================================
    -- AUTO-EXPORT (Periodic LLM format updates)
    -- ============================================================================
    
    local auto_export_timer = nil
    
    start_auto_export = function()
      if not config.auto_export then
        return
      end
      
      -- Stop existing timer if any
      if auto_export_timer then
        auto_export_timer:stop()
        auto_export_timer:close()
      end
      
      -- Create new timer
      auto_export_timer = vim.loop.new_timer()
      auto_export_timer:start(config.export_interval, config.export_interval, vim.schedule_wrap(function()
        if state.recording and not state.paused then
          silent_export()
        end
      end))
    end
    
    stop_auto_export = function()
      if auto_export_timer then
        auto_export_timer:stop()
        auto_export_timer:close()
        auto_export_timer = nil
      end
    end
    
    -- ============================================================================
    -- KEY CAPTURE (Using vim.on_key)
    -- ============================================================================
    
    -- Set up key capture
    vim.on_key(function(key)
      -- Convert key to readable format
      local readable_key = vim.fn.keytrans(key)
      record_keystroke(readable_key)
    end, vim.api.nvim_create_namespace('keystroke_analytics'))
    
    -- ============================================================================
    -- AUTO-FLUSH ON EXIT
    -- ============================================================================
    
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        if state.recording then
          stop_recording()
        end
      end,
      group = vim.api.nvim_create_augroup('KeystrokeAnalytics', { clear = true }),
    })
    
    -- ============================================================================
    -- COMMANDS
    -- ============================================================================
    
    vim.api.nvim_create_user_command('KeystrokeAnalyticsStart', start_recording, {})
    vim.api.nvim_create_user_command('KeystrokeAnalyticsStop', stop_recording, {})
    vim.api.nvim_create_user_command('KeystrokeAnalyticsPause', toggle_pause, {})
    vim.api.nvim_create_user_command('KeystrokeAnalyticsStatus', show_status, {})
    vim.api.nvim_create_user_command('KeystrokeAnalyticsExport', export_for_analysis, {})
    
    -- ============================================================================
    -- KEYMAPS
    -- ============================================================================
    
    -- Toggle recording
    kb.register_keymap('keystroke-analytics', 'n', keys.analytics_toggle, function()
      if state.recording then
        stop_recording()
      else
        start_recording()
      end
    end, { desc = 'Toggle keystroke analytics' })
    
    -- Pause/resume
    kb.register_keymap('keystroke-analytics', 'n', keys.analytics_pause, toggle_pause, 
      { desc = 'Pause/resume keystroke analytics' })
    
    -- Show status
    kb.register_keymap('keystroke-analytics', 'n', keys.analytics_status, show_status,
      { desc = 'Show keystroke analytics status' })
    
-- Export for analysis
kb.register_keymap('keystroke-analytics', 'n', keys.analytics_export, export_for_analysis,
  { desc = 'Export session for LLM analysis' })

-- ============================================================================
-- AUTO-START (Start recording automatically on launch)
-- ============================================================================

if config.auto_start then
  -- Defer start to after all plugins have loaded
  vim.defer_fn(function()
    start_recording()
  end, 100) -- 100ms delay to ensure everything is ready
end

-- Return empty table for lazy.nvim compatibility
-- (lazy.nvim scans plugins/ directory and expects a plugin spec)
return {}
