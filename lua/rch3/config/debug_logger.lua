local M = {}

local log_file = vim.fn.expand("~/.config/nvim/debug.log")

function M.log(msg)
    local f = io.open(log_file, "a")
    if f then
        f:write(string.format("[%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), msg))
        f:close()
    end
end

local function dump_state(tag)
    local cur_win = vim.api.nvim_get_current_win()
    local cur_buf = vim.api.nvim_get_current_buf()
    local mode = vim.api.nvim_get_mode().mode
    local lines = {
        string.format("[%s] Mode: %s | CurWin: %d | CurBuf: %d ('%s', ft='%s')",
            tag, mode, cur_win, cur_buf, vim.api.nvim_buf_get_name(cur_buf), vim.bo[cur_buf].filetype)
    }
    local wins = vim.api.nvim_list_wins()
    table.insert(lines, string.format("  Total windows (%d):", #wins))
    for _, win in ipairs(wins) do
        if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            local cfg = vim.api.nvim_win_get_config(win)
            local is_float = cfg.relative ~= ""
            table.insert(lines, string.format("    - Win %d: buf %d ('%s'), ft='%s', buftype='%s', float=%s",
                win, buf, vim.api.nvim_buf_get_name(buf), vim.bo[buf].filetype, vim.bo[buf].buftype, tostring(is_float)))
        end
    end
    M.log(table.concat(lines, "\n"))
end

M.dump_state = dump_state

function M.setup()
    M.log("=========================================")
    M.log("=== Neovim session started / reloaded ===")
    M.log("=========================================")

    -- Intercept notifications
    local orig_notify = vim.notify
    vim.notify = function(msg, level, opts)
        M.log(string.format("[NOTIFY] (level=%s) %s", tostring(level), tostring(msg)))
        return orig_notify(msg, level, opts)
    end

    -- Monitor buffer write events
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        callback = function(args)
            dump_state(string.format("EVENT BufWritePre buf=%d '%s'", args.buf, vim.api.nvim_buf_get_name(args.buf)))
        end,
    })

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function(args)
            dump_state(string.format("EVENT BufWritePost buf=%d '%s'", args.buf, vim.api.nvim_buf_get_name(args.buf)))
        end,
    })

    -- Monitor command-line execution
    vim.api.nvim_create_autocmd("CmdlineLeave", {
        callback = function()
            local cmd = vim.fn.getcmdline()
            M.log(string.format("[CMDLINE] Executed: :%s", cmd))
        end,
    })

    -- Monitor window creation and closing
    vim.api.nvim_create_autocmd("WinNew", {
        callback = function()
            dump_state("EVENT WinNew")
        end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        callback = function(args)
            M.log(string.format("[EVENT WinClosed] win=%s", tostring(args.match)))
        end,
    })
end

return M
