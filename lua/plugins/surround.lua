--[[
  Surround - Add/Delete/Change Surroundings
  
  Quickly manipulate surrounding characters like quotes, brackets, tags.
  
  Examples:
    ysiw"   - Surround word with "
    ds"     - Delete surrounding "
    cs"'    - Change " to '
]]

return {
  'kylechui/nvim-surround',
  version = '*',
  event = 'VeryLazy',
  config = function()
    local keys = require('core.keybindings-registry')
    
    -- All keymaps reference the centralized registry
    require('nvim-surround').setup({
      keymaps = {
        insert = keys.surround_insert,
        insert_line = keys.surround_insert_line,
        normal = keys.surround_add,
        normal_cur = keys.surround_add_line,
        normal_line = keys.surround_add_line_alt,
        normal_cur_line = keys.surround_add_whole_line,
        visual = keys.surround_visual,
        visual_line = keys.surround_visual_line,
        delete = keys.surround_delete,
        change = keys.surround_change,
        change_line = keys.surround_change_line,
      },
    })
  end,
}
