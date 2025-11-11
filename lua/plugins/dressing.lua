--[[
  Dressing - Better UI for vim.ui.select and vim.ui.input
  
  Enhances Neovim's built-in UI prompts with modern interfaces.
  Uses Telescope for select menus when available.
  
  NOTE: No keymaps - enhances existing Neovim UI functions.
]]

return {
  'stevearc/dressing.nvim',
  event = 'VeryLazy',
  opts = {
    -- ============================================================================
    -- INPUT PROMPTS (vim.ui.input)
    -- ============================================================================
    input = {
      enabled = true,
      default_prompt = '➤ ',
      title_pos = 'left',
      insert_only = true,
      start_in_insert = true,
      border = 'rounded',
      relative = 'cursor',
      
      -- Window size
      prefer_width = 40,
      width = nil,
      max_width = { 140, 0.9 },
      min_width = { 20, 0.2 },
      
      win_options = {
        winblend = 0,
        wrap = false,
      },
      
      -- Keymaps for input prompt
      mappings = {
        n = {
          ['<Esc>'] = 'Close',
          ['<CR>'] = 'Confirm',
        },
        i = {
          ['<C-c>'] = 'Close',
          ['<CR>'] = 'Confirm',
          ['<Up>'] = 'HistoryPrev',
          ['<Down>'] = 'HistoryNext',
        },
      },
    },
    
    -- ============================================================================
    -- SELECT MENUS (vim.ui.select)
    -- ============================================================================
    select = {
      enabled = true,
      
      -- Backend priority (tries in order)
      backend = { 'telescope', 'fzf_lua', 'fzf', 'builtin', 'nui' },
      trim_prompt = true,
      
      -- Telescope backend (default settings)
      telescope = nil,
      
      -- FZF backend settings
      fzf = {
        window = {
          width = 0.5,
          height = 0.4,
        },
      },
      
      -- FZF Lua backend settings
      fzf_lua = {
        winopts = {
          height = 0.5,
          width = 0.5,
        },
      },
      
      -- Nui backend settings
      nui = {
        position = '50%',
        size = nil,
        relative = 'editor',
        border = {
          style = 'rounded',
        },
        buf_options = {
          swapfile = false,
          filetype = 'DressingSelect',
        },
        win_options = {
          winblend = 0,
        },
        max_width = 80,
        max_height = 40,
        min_width = 40,
        min_height = 10,
      },
      
      -- Built-in backend settings (fallback)
      builtin = {
        show_numbers = true,
        border = 'rounded',
        relative = 'editor',
        win_options = {
          winblend = 0,
        },
        
        -- Window size
        width = nil,
        max_width = { 140, 0.8 },
        min_width = { 40, 0.2 },
        height = nil,
        max_height = 0.9,
        min_height = { 10, 0.2 },
        
        -- Keymaps for select menu
        mappings = {
          ['<Esc>'] = 'Close',
          ['<C-c>'] = 'Close',
          ['<CR>'] = 'Confirm',
        },
      },
      
      format_item_override = {},
      get_config = nil,
    },
  },
}
