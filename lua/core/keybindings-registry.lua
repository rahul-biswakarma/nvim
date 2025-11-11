--[[
  Centralized Keybindings Registry
  
  Purpose: Define ALL keyboard shortcuts in one place as variables.
  Benefits:
  - Change shortcuts in ONE place
  - No conflicts - easy to see at a glance
  - Clear documentation
  - Easy for humans and LLMs to understand
  
  Usage:
    local keys = require('core.keybindings-registry')
    vim.keymap.set('n', keys.search_files, command, { desc = 'Search files' })
]]

local M = {}

-- ============================================================================
-- LEADER KEY
-- ============================================================================
M.leader = '<Space>'

-- ============================================================================
-- FILE NAVIGATION
-- ============================================================================
M.toggle_file_tree = '<leader>e'
M.reveal_in_tree = '<leader>fe'
M.git_status = '<leader>fg'
M.buffers_view = '<leader>fb'

-- ============================================================================
-- SEARCH (Telescope)
-- ============================================================================
M.search_files = '<leader>sf'
M.search_grep = '<leader>sg'
M.search_word = '<leader>sw'
M.search_buffer = '<leader>sb'
M.search_buffers = '<leader><leader>'
M.search_help = '<leader>sh'
M.search_keymaps = '<leader>sk'
M.search_diagnostics = '<leader>sd'
M.search_resume = '<leader>sr'
M.search_recent = '<leader>s.'
M.search_open_files = '<leader>s/'
M.search_neovim_config = '<leader>sn'
M.search_telescope_builtins = '<leader>ss'

-- ============================================================================
-- HOP (Fast Navigation)
-- ============================================================================
M.hop_char2 = 's'
M.hop_word = '<leader>hw'  
M.hop_line = '<leader>j'
M.hop_pattern = '<leader>hj'  

-- ============================================================================
-- LSP
-- ============================================================================
-- Navigation
M.lsp_goto_definition = 'gd'
M.lsp_goto_definitions_telescope = '<leader>gd'
M.lsp_goto_references = 'gr'
M.lsp_goto_implementation = 'gI'
M.lsp_goto_declaration = 'gD'
M.lsp_type_definition = '<leader>D'

-- Symbols
M.lsp_document_symbols = '<leader>ds'
M.lsp_workspace_symbols = '<leader>ls'

-- Documentation
M.lsp_hover = 'K'
M.lsp_signature_help = '<C-k>'

-- Actions
M.lsp_code_action = '<leader>ca'
M.lsp_code_action_alt = '<leader>a'
M.lsp_rename = '<leader>rn'

-- Diagnostics
M.lsp_diagnostics = 'gl'
M.lsp_diagnostics_popup = '<leader>d'
M.lsp_next_diagnostic = ']d'
M.lsp_prev_diagnostic = '[d'
M.lsp_quickfix = '<leader>q'

-- Workspace folders (using <leader>lw prefix to avoid conflict with session <leader>w)
M.lsp_workspace_add_folder = '<leader>lwa'
M.lsp_workspace_remove_folder = '<leader>lwr'
M.lsp_workspace_list_folders = '<leader>lwl'

-- Toggles
M.lsp_toggle_inlay_hints = '<leader>th'

-- ============================================================================
-- RUST SPECIFIC (Rustaceanvim)
-- ============================================================================
M.rust_code_action = '<leader>ra'
M.rust_debuggables = '<leader>rd'
M.rust_runnables = '<leader>rr'
M.rust_testables = '<leader>rt'
M.rust_expand_macro = '<leader>rm'
M.rust_open_cargo = '<leader>rc'
M.rust_parent_module = '<leader>rp'
M.rust_join_lines = '<leader>rj'
M.rust_explain_error = '<leader>re'
M.rust_render_diagnostic = '<leader>rD'

-- ============================================================================
-- BUFFERS & WINDOWS
-- ============================================================================
M.next_buffer = '<Tab>'
M.prev_buffer = '<S-Tab>'
M.close_buffer = '<leader>x'
M.pin_buffer = '<leader>bp'
M.close_unpinned_buffers = '<leader>bP'

-- ============================================================================
-- TERMINAL (Toggleterm) - Uses <leader>T prefix to avoid conflicts
-- ============================================================================
M.toggle_terminal = '<C-\\>'
M.terminal_float = '<leader>Tf'
M.terminal_horizontal = '<leader>Th'
M.terminal_vertical = '<leader>Tv'
M.lazygit = '<leader>gg'

-- ============================================================================
-- GIT (Gitsigns)
-- ============================================================================
M.git_next_hunk = ']c'
M.git_prev_hunk = '[c'
M.git_stage_hunk = '<leader>hs'
M.git_stage_buffer = '<leader>hS'
M.git_reset_hunk = '<leader>hr'
M.git_reset_buffer = '<leader>hR'
M.git_undo_stage_hunk = '<leader>hu'
M.git_preview_hunk = '<leader>hp'
M.git_blame_line = '<leader>hb'
M.git_blame = '<leader>gb'
M.git_toggle_blame = '<leader>tb'
M.git_diff_this = '<leader>hd'
M.git_diff_this_cached = '<leader>hD'
M.git_toggle_deleted = '<leader>td'
M.git_select_hunk = 'ih'

-- ============================================================================
-- SURROUND
-- ============================================================================
M.surround_add = 'ys'
M.surround_add_line = 'yss'
M.surround_add_line_alt = 'yS'
M.surround_add_whole_line = 'ySS'
M.surround_visual = 'S'
M.surround_visual_line = 'gS'
M.surround_delete = 'ds'
M.surround_change = 'cs'
M.surround_change_line = 'cS'
M.surround_insert = '<C-g>s'
M.surround_insert_line = '<C-g>S'

-- ============================================================================
-- COMMENTS
-- ============================================================================
M.comment_toggle_line = '<leader>/'
M.comment_toggle_block = '<leader>bc'
M.comment_above = '<leader>cO'
M.comment_below = '<leader>co'
M.comment_eol = '<leader>cA'

-- ============================================================================
-- FORMATTING
-- ============================================================================
M.format_buffer = '<leader>f'

-- ============================================================================
-- CRATES (Cargo.toml) - Uses <leader>C prefix to avoid conflicts
-- ============================================================================
M.crates_toggle = '<leader>Ct'
M.crates_reload = '<leader>Cr'
M.crates_versions = '<leader>Cv'
M.crates_features = '<leader>Cf'
M.crates_dependencies = '<leader>Cd'
M.crates_update = '<leader>Cu'
M.crates_update_all = '<leader>CA'
M.crates_upgrade = '<leader>CU'
M.crates_upgrade_all = '<leader>Ca'

-- ============================================================================
-- TODO COMMENTS
-- ============================================================================
M.search_todos = '<leader>st'
M.next_todo = ']t'
M.prev_todo = '[t'

-- ============================================================================
-- SESSION MANAGEMENT
-- ============================================================================
M.session_save = '<leader>ws'
M.session_restore = '<leader>wr'
M.session_delete = '<leader>wd'

-- ============================================================================
-- TEXT OBJECTS (Treesitter)
-- ============================================================================
-- Text object selection
M.textobj_param_outer = 'aa'
M.textobj_param_inner = 'ia'
M.textobj_function_outer = 'af'
M.textobj_function_inner = 'if'
M.textobj_class_outer = 'ac'
M.textobj_class_inner = 'ic'

-- Movement (goto next/previous)
M.goto_next_function_start = ']m'
M.goto_next_class_start = ']]'
M.goto_next_function_end = ']M'
M.goto_next_class_end = ']['
M.goto_prev_function_start = '[m'
M.goto_prev_class_start = '[['
M.goto_prev_function_end = '[M'
M.goto_prev_class_end = '[]'

-- Swap parameters (using <leader>s prefix for "swap")
M.swap_param_next = '<leader>sa'
M.swap_param_prev = '<leader>sA'

-- ============================================================================
-- DIAGNOSTICS (Trouble)
-- ============================================================================
M.toggle_trouble = '<leader>xx'
M.trouble_workspace = '<leader>xw'
M.trouble_document = '<leader>xd'
M.trouble_quickfix = '<leader>xq'
M.trouble_loclist = '<leader>xl'
M.trouble_references = 'gR'

-- ============================================================================
-- MISC
-- ============================================================================
M.next_reference = ']]'  -- Note: Conflicts with Treesitter class navigation in some contexts
M.prev_reference = '[['  -- Note: Conflicts with Treesitter class navigation in some contexts

-- ============================================================================
-- HELPER FUNCTIONS (for conflict checking if needed)
-- ============================================================================

-- Internal registry for tracking all registered keymaps
local registry = {}

-- Register a single keymap for conflict tracking
-- Handles both single mode (string) and multiple modes (table)
function M.register_keymap(plugin_name, mode, lhs, rhs, opts)
  -- If mode is a table (multiple modes), register for each mode
  if type(mode) == 'table' then
    for _, m in ipairs(mode) do
      M.register_keymap(plugin_name, m, lhs, rhs, opts)
    end
    return
  end
  
  -- Single mode (string)
  local key = mode .. ':' .. lhs
  
  -- Only warn if a DIFFERENT plugin is trying to use the same shortcut
  if registry[key] and registry[key].plugin ~= plugin_name then
    print(string.format("⚠️  WARNING: Duplicate shortcut found! %s is used by: %s and %s", lhs, registry[key].plugin, plugin_name))
  end
  
  registry[key] = { plugin = plugin_name, mode = mode, lhs = lhs, rhs = rhs, opts = opts }
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Register multiple keymaps at once
function M.register_keymaps(plugin_name, keymaps_table)
  for _, keymap_info in ipairs(keymaps_table) do
    M.register_keymap(plugin_name, keymap_info[1], keymap_info[2], keymap_info[3], keymap_info[4])
  end
end

-- Get all defined shortcuts (useful for debugging)
function M.get_all_shortcuts()
  local shortcuts = {}
  for key, value in pairs(M) do
    if type(value) == 'string' and key ~= 'leader' then
      table.insert(shortcuts, { name = key, shortcut = value })
    end
  end
  return shortcuts
end

-- Print all shortcuts (for debugging)
function M.print_all()
  local shortcuts = M.get_all_shortcuts()
  table.sort(shortcuts, function(a, b) return a.shortcut < b.shortcut end)
  
  print('=== All Keyboard Shortcuts ===')
  for _, item in ipairs(shortcuts) do
    print(string.format('%-30s = %s', item.name, item.shortcut))
  end
end

-- Check for duplicate shortcuts
function M.check_duplicates()
  local seen = {}
  local duplicates = {}
  
  for key, value in pairs(M) do
    if type(value) == 'string' and key ~= 'leader' then
      if seen[value] then
        table.insert(duplicates, {
          shortcut = value,
          names = { seen[value], key }
        })
      else
        seen[value] = key
      end
    end
  end
  
  if #duplicates > 0 then
    print('⚠️  WARNING: Duplicate shortcuts found!')
    for _, dup in ipairs(duplicates) do
      print(string.format('  %s is used by: %s', dup.shortcut, table.concat(dup.names, ', ')))
    end
  else
    print('✅ No duplicate shortcuts found')
  end
  
  return duplicates
end

return M
