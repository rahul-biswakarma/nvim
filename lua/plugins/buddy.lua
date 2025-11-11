return {
  dir = vim.fn.stdpath("config"),
  name = "buddy",
  enabled = true,
  config = function()
    require("buddy").setup()
  end,
}

