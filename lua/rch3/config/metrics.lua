-- Usage + performance metrics. Minimal, safe, non-invasive.
-- Two log files under stdpath("log"):
--   cmp-lag.log  -- completion timing (sources vs render), per keystroke
--   usage.log    -- startup time + every :command you run (find habits worth a keymap)
-- Read a live summary anytime with  :Metrics   (or open the raw files).
local logdir = vim.fn.stdpath("log")
local cmp_log = logdir .. "/cmp-lag.log"
local usage_log = logdir .. "/usage.log"

local function append(file, line)
    local fd = io.open(file, "a")
    if not fd then return end
    fd:write(os.date("%Y-%m-%d %H:%M:%S ") .. line .. "\n")
    fd:close()
end
local function ms(ns) return string.format("%.1fms", ns / 1e6) end
local function lines(file)
    if vim.fn.filereadable(file) == 0 then return function() return nil end end
    return io.lines(file)
end

-- ── perf: completion lag ──────────────────────────────────────────────────
-- type char -> BlinkCmpShow (sources resolved) -> BlinkCmpMenuOpen (rendered)
local last_type, show_at
vim.api.nvim_create_autocmd("InsertCharPre", {
    callback = function() last_type = vim.loop.hrtime() end,
})
vim.api.nvim_create_autocmd("User", {
    pattern = "BlinkCmpShow",
    callback = function()
        show_at = vim.loop.hrtime()
        if last_type then append(cmp_log, ("sources ready in %s"):format(ms(show_at - last_type))) end
        local ok, items = pcall(function() return require("blink.cmp.completion.list").items end)
        if ok and items then
            local by_src = {}
            for _, it in ipairs(items) do
                local s = it.source_id or "?"
                by_src[s] = (by_src[s] or 0) + 1
            end
            local parts = {}
            for s, n in pairs(by_src) do parts[#parts + 1] = s .. "=" .. n end
            append(cmp_log, "  items: " .. table.concat(parts, " "))
        end
    end,
})
vim.api.nvim_create_autocmd("User", {
    pattern = "BlinkCmpMenuOpen",
    callback = function()
        local now = vim.loop.hrtime()
        if show_at then append(cmp_log, ("render in %s"):format(ms(now - show_at))) end
        if last_type then append(cmp_log, ("  TOTAL type->visible %s"):format(ms(now - last_type))) end
        last_type, show_at = nil, nil
    end,
})

-- ── perf: startup time (spot regressions when you add plugins) ─────────────
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.g.nvim_start_ns then
            append(usage_log, ("startup %s"):format(ms(vim.loop.hrtime() - vim.g.nvim_start_ns)))
        end
    end,
})

-- ── usage: which :commands you type by hand (candidates for a keymap) ──────
vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
        if vim.v.event.abort or vim.fn.getcmdtype() ~= ":" then return end
        local cmd = vim.fn.getcmdline()
        if cmd ~= "" then append(usage_log, "cmd: " .. cmd) end
    end,
})

-- ── :Metrics — human summary of the logs ───────────────────────────────────
vim.api.nvim_create_user_command("Metrics", function()
    local out = {}

    -- command frequency (first word of each `cmd:` line)
    local freq, startup_last = {}, nil
    for line in lines(usage_log) do
        local c = line:match("cmd:%s+(%S+)")
        if c then freq[c] = (freq[c] or 0) + 1 end
        local s = line:match("startup%s+(%S+)")
        if s then startup_last = s end
    end
    local ranked = {}
    for c, n in pairs(freq) do ranked[#ranked + 1] = { c, n } end
    table.sort(ranked, function(a, b) return a[2] > b[2] end)
    out[#out + 1] = "== last startup: " .. (startup_last or "n/a") .. " =="
    out[#out + 1] = "== most-typed :commands (a habit here often wants a keymap) =="
    for i = 1, math.min(15, #ranked) do
        out[#out + 1] = ("  %-20s %d"):format(ranked[i][1], ranked[i][2])
    end

    -- worst completion renders
    out[#out + 1] = ""
    out[#out + 1] = "== slowest completion events (tail of cmp-lag.log) =="
    local slow = {}
    for line in lines(cmp_log) do
        local n = line:match("in%s+([%d%.]+)ms")
        if n and tonumber(n) > 200 then slow[#slow + 1] = line end
    end
    for i = math.max(1, #slow - 10), #slow do
        if slow[i] then out[#out + 1] = "  " .. slow[i] end
    end
    out[#out + 1] = ""
    out[#out + 1] = "raw: " .. usage_log .. "  |  " .. cmp_log

    vim.cmd("botright new")
    vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
    vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
end, { desc = "Show usage + performance metrics summary" })
