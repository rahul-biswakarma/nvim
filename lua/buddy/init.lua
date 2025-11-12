-- lua/buddy/init.lua
-- Main plugin file for buddy

local M = {}

local core = require("buddy.core")
local ui = require("buddy.ui")
local state = require("buddy.state")
local profiles = require("buddy.profiles")
local config = require("buddy.config")

function M.setup(user_opts)
  config.setup(user_opts)

  local core_initialized = false
  local function ensure_core()
    if not core_initialized then
      core.init()
      core_initialized = true
    end
  end

  local function on_startup_unlocked()
    ensure_core()
    vim.api.nvim_del_augroup_by_name("BuddyStartupInit")
  end

  local group = vim.api.nvim_create_augroup("BuddyStartupInit", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "StartupUnlocked",
    callback = on_startup_unlocked,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      if vim.g.startup_unlocked then
        ensure_core()
      end
    end,
  })

  -- Register user commands
  vim.api.nvim_create_user_command("BuddyToggle", function()
    ensure_core()
    ui.toggle()
  end, { desc = "Toggle the buddy chat window." })

  vim.api.nvim_create_user_command("BuddySet", function(args)
    ensure_core()
    local buddy_name = args.fargs[1]
    if buddy_name and #buddy_name > 0 then
      state.set_active_buddy(buddy_name)
    else
      vim.notify("Usage: :BuddySet <buddy_name>", vim.log.levels.WARN)
    end
  end, {
    nargs = 1,
    complete = function()
      return profiles.get_available_buddies()
    end,
    desc = "Set the active buddy.",
  })

  vim.api.nvim_create_user_command("BuddyGroup", function(args)
    ensure_core()
    local group_name = args.fargs[1]
    if group_name and #group_name > 0 then
      state.set_active_buddy(group_name)
    else
      vim.notify("Usage: :BuddyGroup <group_name>", vim.log.levels.WARN)
    end
  end, {
    nargs = 1,
    complete = function()
      return profiles.get_available_buddies()
    end,
    desc = "Set the active buddy to a group profile.",
  })

  -- Keymap for sending messages
  vim.keymap.set("n", "<leader>aa", function()
    ensure_core()
    local ui_info = ui.get_win_info()
    local opts = {
      prompt = "Message to " .. state.get_active_buddy() .. ": ",
    }
    if ui_info then
      opts.relative = "win"
      opts.win = ui_info.win_id
      opts.row = -1
      opts.col = 1
    end

    vim.ui.input(opts, function(input)
      if input and #input > 0 then
        core.on_user_message(input)
      end
    end)
  end, { desc = "Send message to buddy" })
end

return M
