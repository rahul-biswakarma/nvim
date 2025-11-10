return {
  'numToStr/Comment.nvim',
  opts = {
    -- Add a space in the comment string
    padding = true,
    -- Whether the cursor should stay at its position
    sticky = true,
    -- Lines to be ignored while comment/uncomment. Perfect for leaving shebang at the top of files
    ignore = '^$',
    -- LHS of toggle mappings in NORMAL mode
    toggler = {
      -- Line-comment toggle keymap
      line = '<leader>/',
      -- Block-comment toggle keymap
      block = '<leader>bc',
    },
    -- LHS of operator-pending mappings in NORMAL and VISUAL mode
    opleader = {
      -- Line-comment keymap
      line = '<leader>/',
      -- Block-comment keymap
      block = '<leader>bc',
    },
    -- LHS of extra mappings
    extra = {
      -- Add comment on the line above
      above = '<leader>cO',
      -- Add comment on the line below
      below = '<leader>co',
      -- Add comment at the end of line
      eol = '<leader>cA',
    },
    -- Enable keybindings
    mappings = {
      -- Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
      basic = true,
      -- Extra mapping; `gco` `gcO` `gcA`
      extra = true,
    },
    -- Function to call before (un)comment
    pre_hook = nil,
    -- Function to call after (un)comment
    post_hook = nil,
  },
}