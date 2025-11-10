return {
  'windwp/nvim-autopairs',
  config = function()
    require('nvim-autopairs').setup {
      check_ts = true,
      ts_config = {
        lua = { 'string' }, -- don't add pairs in lua string
        javascript = { 'template_string' }, -- don't add pairs in javscript template_string
        java = false, -- don't check treesitter on java
      },
    }
  end,
}