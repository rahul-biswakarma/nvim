--[[
  Trouble.nvim - Diagnostics & Location List
  
  A pretty list for showing diagnostics, references, telescope results,
  quickfix, and location lists. Provides a unified interface for
  viewing and navigating through code issues and search results.
  
  Features:
  - Workspace and document diagnostics
  - LSP references viewer
  - Quickfix and location list integration
  - Auto-preview and folding
  - Jump to source with context
]]

return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  cmd = { 'TroubleToggle', 'Trouble' }, -- Lazy load on command
  opts = {
    -- ============================================================================
    -- APPEARANCE
    -- ============================================================================
    position = 'bottom', -- Position of Trouble window
    height = 10, -- Height of Trouble window
    width = 50, -- Width when position is left/right
    icons = true, -- Use devicons for filenames
    fold_open = '', -- Icon for open folds
    fold_closed = '', -- Icon for closed folds
    indent_lines = true, -- Add indent guide lines
    
    -- ============================================================================
    -- BEHAVIOR
    -- ============================================================================
    mode = 'workspace_diagnostics', -- Default mode
    severity = nil, -- nil (all), vim.diagnostic.severity.ERROR, WARN, INFO, HINT
    group = true, -- Group results by file
    padding = true, -- Add extra padding
    cycle_results = true, -- Cycle through results with next/previous
    multiline = true, -- Render multi-line messages
    
    -- ============================================================================
    -- WINDOW CONFIGURATION
    -- ============================================================================
    win_config = { border = 'rounded' }, -- Window border style
    
    -- ============================================================================
    -- AUTO BEHAVIOR
    -- ============================================================================
    auto_open = false, -- Automatically open when issues detected
    auto_close = false, -- Automatically close when no issues
    auto_preview = true, -- Automatically preview item location
    auto_fold = false, -- Automatically fold groups with no items
    auto_jump = { 'lsp_definitions' }, -- Auto-jump for these modes
    
    -- ============================================================================
    -- LSP SETTINGS
    -- ============================================================================
    include_declaration = { 
      'lsp_references', 
      'lsp_implementations', 
      'lsp_definitions' 
    }, -- Include declaration in these modes
    
    -- ============================================================================
    -- SIGNS & ICONS
    -- ============================================================================
    signs = {
      error = '',
      warning = '',
      hint = '',
      information = '',
      other = '',
    },
    use_diagnostic_signs = false, -- Use signs from vim.diagnostic
    
    -- ============================================================================
    -- ACTION KEYS (Internal Trouble keymaps)
    -- ============================================================================
    -- These are keymaps that work INSIDE the Trouble window
    -- They are NOT part of the centralized registry as they're context-specific
    action_keys = {
      -- Window control
      close = 'q', -- Close Trouble window
      cancel = '<esc>', -- Cancel and return to previous window
      refresh = 'r', -- Manually refresh
      
      -- Navigation & opening
      jump = { '<cr>', '<tab>', '<2-leftmouse>' }, -- Jump to item and close
      jump_close = { 'o' }, -- Jump to item but keep Trouble open
      open_split = { '<c-x>' }, -- Open in horizontal split
      open_vsplit = { '<c-v>' }, -- Open in vertical split
      open_tab = { '<c-t>' }, -- Open in new tab
      
      -- View controls
      toggle_mode = 'm', -- Toggle between modes
      switch_severity = 's', -- Switch severity filter
      toggle_preview = 'P', -- Toggle auto-preview
      hover = 'K', -- Show hover information
      preview = 'p', -- Preview item location
      
      -- Folding
      close_folds = { 'zM', 'zm' }, -- Close all folds
      open_folds = { 'zR', 'zr' }, -- Open all folds
      toggle_fold = { 'zA', 'za' }, -- Toggle current fold
      
      -- Navigation within window
      previous = 'k', -- Previous item
      next = 'j', -- Next item
      
      -- Misc
      open_code_href = 'c', -- Open code action URL
      help = '?', -- Show help
    },
  },
  
  -- ============================================================================
  -- KEYMAPS (Global keymaps to open Trouble)
  -- ============================================================================
  keys = function()
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry') -- For registering keymaps
    
    -- Define keymaps table
    local keymaps = {
      { keys.toggle_trouble, '<cmd>TroubleToggle<cr>', desc = 'Toggle Trouble' },
      { keys.trouble_workspace, '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = 'Workspace Diagnostics' },
      { keys.trouble_document, '<cmd>TroubleToggle document_diagnostics<cr>', desc = 'Document Diagnostics' },
      { keys.trouble_quickfix, '<cmd>TroubleToggle quickfix<cr>', desc = 'Quickfix List' },
      { keys.trouble_loclist, '<cmd>TroubleToggle loclist<cr>', desc = 'Location List' },
      { keys.trouble_references, '<cmd>TroubleToggle lsp_references<cr>', desc = 'LSP References' },
    }
    
    -- Register all keymaps for tracking
    kb.register_keymaps('trouble', {
      { 'n', keys.toggle_trouble, 'trouble', { desc = 'Toggle Trouble' } },
      { 'n', keys.trouble_workspace, 'trouble', { desc = 'Workspace Diagnostics' } },
      { 'n', keys.trouble_document, 'trouble', { desc = 'Document Diagnostics' } },
      { 'n', keys.trouble_quickfix, 'trouble', { desc = 'Quickfix List' } },
      { 'n', keys.trouble_loclist, 'trouble', { desc = 'Location List' } },
      { 'n', keys.trouble_references, 'trouble', { desc = 'LSP References' } },
    })
    
    return keymaps
  end,
}
