--[[
  Auto Tag - Automatic HTML/JSX Tag Pairing
  
  Automatically closes and renames HTML/JSX/XML tags.
  Works with Treesitter for accurate tag detection.
]]

return {
  'windwp/nvim-ts-autotag',
  event = 'InsertEnter',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('nvim-ts-autotag').setup {
      opts = {
        enable_close = true,  -- Auto close tags
        enable_rename = true,  -- Auto rename pairs of tags
        enable_close_on_slash = true,  -- Auto close on trailing `/>`
      },
    }
  end,
}
