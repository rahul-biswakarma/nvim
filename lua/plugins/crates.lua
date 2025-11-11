--[[
  Crates - Cargo.toml Dependency Management
  
  Manage Rust crate dependencies directly from Cargo.toml.
  Shows available versions, features, and enables quick updates.
  
  NOTE: Keymaps only active when editing Cargo.toml files.
]]

return {
  'saecki/crates.nvim',
  event = { 'BufRead Cargo.toml' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('crates').setup({
      -- ============================================================================
      -- INTEGRATION
      -- ============================================================================
      null_ls = {
        enabled = true,
        name = 'crates.nvim',
      },
      
      -- ============================================================================
      -- POPUP STYLE
      -- ============================================================================
      popup = {
        border = 'rounded',
      },
    })
    
    -- ============================================================================
    -- CARGO.TOML KEYBINDINGS (Buffer-local)
    -- ============================================================================
    -- These keymaps only work in Cargo.toml files
    vim.api.nvim_create_autocmd('BufRead', {
      group = vim.api.nvim_create_augroup('CmpSourceCargo', { clear = true }),
      pattern = 'Cargo.toml',
      callback = function()
        local keys = require('core.keybindings-registry')
        local kb = require('core.keybindings-registry')
        local crates = require('crates')
        local opts = { buffer = true, noremap = true, silent = true }
        
        -- Toggle crates display
        kb.register_keymap('crates', 'n', keys.crates_toggle, crates.toggle, 
          vim.tbl_extend('force', opts, { desc = 'Toggle crates display' }))
        
        -- Reload crate data
        kb.register_keymap('crates', 'n', keys.crates_reload, crates.reload, 
          vim.tbl_extend('force', opts, { desc = 'Reload crates' }))
        
        -- Show popups
        kb.register_keymap('crates', 'n', keys.crates_versions, crates.show_versions_popup, 
          vim.tbl_extend('force', opts, { desc = 'Show versions' }))
        kb.register_keymap('crates', 'n', keys.crates_features, crates.show_features_popup, 
          vim.tbl_extend('force', opts, { desc = 'Show features' }))
        kb.register_keymap('crates', 'n', keys.crates_dependencies, crates.show_dependencies_popup, 
          vim.tbl_extend('force', opts, { desc = 'Show dependencies' }))
        
        -- Update crates (normal mode: single crate, visual mode: multiple)
        kb.register_keymap('crates', 'n', keys.crates_update, crates.update_crate, 
          vim.tbl_extend('force', opts, { desc = 'Update crate' }))
        kb.register_keymap('crates', 'v', keys.crates_update, crates.update_crates, 
          vim.tbl_extend('force', opts, { desc = 'Update selected crates' }))
        kb.register_keymap('crates', 'n', keys.crates_update_all, crates.update_all_crates, 
          vim.tbl_extend('force', opts, { desc = 'Update all crates' }))
        
        -- Upgrade crates (update to latest, potentially breaking)
        kb.register_keymap('crates', 'n', keys.crates_upgrade, crates.upgrade_crate, 
          vim.tbl_extend('force', opts, { desc = 'Upgrade crate' }))
        kb.register_keymap('crates', 'v', keys.crates_upgrade, crates.upgrade_crates, 
          vim.tbl_extend('force', opts, { desc = 'Upgrade selected crates' }))
        kb.register_keymap('crates', 'n', keys.crates_upgrade_all, crates.upgrade_all_crates, 
          vim.tbl_extend('force', opts, { desc = 'Upgrade all crates' }))
      end,
    })
  end,
}
