return {
  'saecki/crates.nvim',
  event = { 'BufRead Cargo.toml' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('crates').setup({
      null_ls = {
        enabled = true,
        name = 'crates.nvim',
      },
      popup = {
        border = 'rounded',
      },
    })
    
    -- Keybindings for Cargo.toml
    vim.api.nvim_create_autocmd('BufRead', {
      group = vim.api.nvim_create_augroup('CmpSourceCargo', { clear = true }),
      pattern = 'Cargo.toml',
      callback = function()
        local opts = { buffer = true, noremap = true, silent = true }
        
        vim.keymap.set('n', '<leader>ct', require('crates').toggle, opts)
        vim.keymap.set('n', '<leader>cr', require('crates').reload, opts)
        vim.keymap.set('n', '<leader>cv', require('crates').show_versions_popup, opts)
        vim.keymap.set('n', '<leader>cf', require('crates').show_features_popup, opts)
        vim.keymap.set('n', '<leader>cd', require('crates').show_dependencies_popup, opts)
        vim.keymap.set('n', '<leader>cu', require('crates').update_crate, opts)
        vim.keymap.set('v', '<leader>cu', require('crates').update_crates, opts)
        vim.keymap.set('n', '<leader>ca', require('crates').update_all_crates, opts)
        vim.keymap.set('n', '<leader>cU', require('crates').upgrade_crate, opts)
        vim.keymap.set('v', '<leader>cU', require('crates').upgrade_crates, opts)
        vim.keymap.set('n', '<leader>cA', require('crates').upgrade_all_crates, opts)
      end,
    })
  end,
}

