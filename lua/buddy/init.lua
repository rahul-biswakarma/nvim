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
  core.init()

  local function open_buddy_window_safely()
    -- The user's startup sequence fires "StartupUnlocked" when it's done.
    -- We wait for that event to avoid opening our window too early.
    if vim.g.startup_unlocked then
      -- If startup is already done, open the window after a short delay.
      vim.defer_fn(ui.open, 300)
    else
      -- Otherwise, wait for the signal.
      vim.api.nvim_create_autocmd("User", {
        pattern = "StartupUnlocked",
        once = true,
        callback = function()
          vim.defer_fn(ui.open, 300)
        end,
      })
    end
  end

  -- Attempt to open the window once Neovim has entered.
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = open_buddy_window_safely,
  })

  -- Register user commands
  vim.api.nvim_create_user_command("BuddyToggle", ui.toggle, { desc = "Toggle the buddy chat window." })

  vim.api.nvim_create_user_command("BuddySet", function(args)
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
    -- For now, this is just an alias for BuddySet as per the plan.
    local group_name = args.fargs[1]
    if group_name and #group_name > 0 then
      state.set_active_buddy(group_name)
    else
      vim.notify("Usage: :BuddyGroup <group_name>", vim.log.levels.WARN)
    end
  end, {
    nargs = 1,
    complete = function()
      -- We can't easily distinguish groups from single buddies yet,
      -- so we show all available profiles.
      return profiles.get_available_buddies()
    end,
    desc = "Set the active buddy to a group profile.",
  })

  -- Keymap for sending messages
  vim.keymap.set("n", "<leader>aa", function()
    vim.ui.input({ prompt = "Message to " .. state.get_active_buddy() .. ": " }, function(input)
      if input and #input > 0 then
        core.on_user_message(input)
      end
    end)
  end, { desc = "Send message to buddy" })

  vim.notify("Buddy framework loaded!", vim.log.levels.INFO)
end

return M
