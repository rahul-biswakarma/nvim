--[[
  Treesitter - Advanced Syntax Parsing
  
  Provides incremental parsing for syntax highlighting, code navigation,
  and intelligent text objects. Treesitter understands code structure
  and enables powerful operations on functions, classes, and parameters.
  
  Features:
  - Smart syntax highlighting (disables for large files >100KB)
  - Text objects for functions, classes, and parameters
  - Navigation between code elements
  - Parameter swapping
  - Integration with other plugins (autopairs, autotag, comment, etc.)
]]

return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  build = ':TSUpdate',
  event = 'VeryLazy', -- Only load when Neovim is mostly ready
  config = function()
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry') -- For registering keymaps
    
    require('nvim-treesitter.configs').setup {
      -- ============================================================================
      -- PARSERS
      -- ============================================================================
      -- Languages to always install parsers for
      ensure_installed = { 
        'vim', 'vimdoc', 'query', 'lua', 
        'rust', 'javascript', 'typescript', 'tsx', 
        'css', 'html' 
      },
      sync_install = false, -- Install parsers asynchronously
      auto_install = true, -- Automatically install missing parsers when entering buffer
      
      -- ============================================================================
      -- HIGHLIGHTING
      -- ============================================================================
      highlight = {
        enable = true,
        -- Disable for large files (performance optimization)
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false, -- Disable default vim syntax (Treesitter is better)
      },
      
      -- ============================================================================
      -- INDENTATION
      -- ============================================================================
      indent = { 
        enable = true, 
        disable = { 'yaml' } -- YAML indentation is better handled by filetype plugins
      },
      
      -- ============================================================================
      -- TEXT OBJECTS
      -- ============================================================================
      textobjects = {
        -- Text object selection (e.g., "daf" deletes a function)
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj
          keymaps = {
            -- All keymaps reference the centralized registry
            [keys.textobj_param_outer] = '@parameter.outer', -- aa: around parameter
            [keys.textobj_param_inner] = '@parameter.inner', -- ia: inside parameter
            [keys.textobj_function_outer] = '@function.outer', -- af: around function
            [keys.textobj_function_inner] = '@function.inner', -- if: inside function
            [keys.textobj_class_outer] = '@class.outer', -- ac: around class
            [keys.textobj_class_inner] = '@class.inner', -- ic: inside class
          },
        },
        
        -- Navigation between code elements
        move = {
          enable = true,
          set_jumps = true, -- Add jumps to jumplist
          goto_next_start = {
            [keys.goto_next_function_start] = '@function.outer', -- ]m: next function start
            [keys.goto_next_class_start] = '@class.outer', -- ]]: next class start
          },
          goto_next_end = {
            [keys.goto_next_function_end] = '@function.outer', -- ]M: next function end
            [keys.goto_next_class_end] = '@class.outer', -- ][: next class end
          },
          goto_previous_start = {
            [keys.goto_prev_function_start] = '@function.outer', -- [m: prev function start
            [keys.goto_prev_class_start] = '@class.outer', -- [[: prev class start
          },
          goto_previous_end = {
            [keys.goto_prev_function_end] = '@function.outer', -- [M: prev function end
            [keys.goto_prev_class_end] = '@class.outer', -- []: prev class end
          },
        },
        
        -- Swap parameters/arguments
        swap = {
          enable = true,
          swap_next = {
            [keys.swap_param_next] = '@parameter.inner', -- <leader>sa: swap with next parameter
          },
          swap_previous = {
            [keys.swap_param_prev] = '@parameter.inner', -- <leader>sA: swap with previous parameter
          },
        },
      },
    }
    
    -- ============================================================================
    -- REGISTER KEYMAPS (for documentation/conflict detection)
    -- ============================================================================
    -- These keymaps are defined in Treesitter's config table above
    kb.register_keymaps('treesitter', {
      -- Text object selection
      { 'o', keys.textobj_param_outer, 'treesitter', { desc = 'Around parameter' } },
      { 'o', keys.textobj_param_inner, 'treesitter', { desc = 'Inside parameter' } },
      { 'o', keys.textobj_function_outer, 'treesitter', { desc = 'Around function' } },
      { 'o', keys.textobj_function_inner, 'treesitter', { desc = 'Inside function' } },
      { 'o', keys.textobj_class_outer, 'treesitter', { desc = 'Around class' } },
      { 'o', keys.textobj_class_inner, 'treesitter', { desc = 'Inside class' } },
      
      -- Movement
      { 'n', keys.goto_next_function_start, 'treesitter', { desc = 'Next function start' } },
      { 'n', keys.goto_next_class_start, 'treesitter', { desc = 'Next class start' } },
      { 'n', keys.goto_next_function_end, 'treesitter', { desc = 'Next function end' } },
      { 'n', keys.goto_next_class_end, 'treesitter', { desc = 'Next class end' } },
      { 'n', keys.goto_prev_function_start, 'treesitter', { desc = 'Prev function start' } },
      { 'n', keys.goto_prev_class_start, 'treesitter', { desc = 'Prev class start' } },
      { 'n', keys.goto_prev_function_end, 'treesitter', { desc = 'Prev function end' } },
      { 'n', keys.goto_prev_class_end, 'treesitter', { desc = 'Prev class end' } },
      
      -- Swap
      { 'n', keys.swap_param_next, 'treesitter', { desc = 'Swap with next parameter' } },
      { 'n', keys.swap_param_prev, 'treesitter', { desc = 'Swap with previous parameter' } },
    })
  end,
}