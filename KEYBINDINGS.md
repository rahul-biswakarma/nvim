# Neovim Keybindings

**Leader Key:** `<Space>`

## Essential Motions

```
h, j, k, l          Left, Down, Up, Right
w, b                Next/Previous word
0, $                Start/End of line
gg, G               Top/Bottom of file
/, ?                Search forward/backward
n, N                Next/Previous match
```

## Editing

```
i, a                Insert before/after cursor
o, O                New line below/above
dd, yy              Delete/Copy line
p, P                Paste after/before
u, Ctrl+r           Undo/Redo
.                   Repeat last command
```

## File Explorer (Neo-tree)

```
Space + e           Toggle file tree
Space + fe          Reveal current file
Space + fg          Git status
Space + fb          Buffers view
```

## Search & Navigation

```
Space + sf          Find files
Space + sg          Search in files (grep)
Space + sw          Search current word
Space + Space       Switch buffers
Space + sb          Search in buffer (fuzzy)
s                   Hop to 2 chars
Space + hw          Hop to word
Space + j           Hop to line
Space + hj          Hop to pattern
```

## LSP

```
Navigation:
  gd                  Go to definition (smart)
  Space + gd          Go to definitions (Telescope)
  gr                  Go to references
  gI                  Go to implementation
  gD                  Go to declaration
  Space + D           Type definition
  ]], [[              Next/Previous reference (illuminate)

Symbols:
  Space + ds          Document symbols
  Space + ls          Workspace symbols

Documentation:
  K                   Hover documentation
  Ctrl+k              Signature help

Actions:
  Space + ca          Code actions
  Space + a           Code actions (alternative)
  Space + rn          Rename symbol

Diagnostics:
  gl                  Show line diagnostics
  Space + d           Show diagnostics popup
  ]d, [d              Next/Previous diagnostic
  Space + q           Diagnostics quickfix list

Workspace:
  Space + lwa         Add workspace folder
  Space + lwr         Remove workspace folder
  Space + lwl         List workspace folders

Toggles:
  Space + th          Toggle inlay hints
```

## Rust (Rustaceanvim)

```
gd                  Go to definition (smart - skips use statements)
K                   Enhanced hover with actions
Space + ra          Rust code actions
Space + rd          Rust debuggables
Space + rr          Rust runnables
Space + rt          Rust testables
Space + rm          Expand macro
Space + rc          Open Cargo.toml
Space + rp          Go to parent module
Space + rj          Join lines
Space + re          Explain error
Space + rD          Render diagnostic
```

## Buffers & Windows

```
Tab                 Next buffer
Shift+Tab           Previous buffer
Space + x           Close buffer
Space + bp          Pin/unpin buffer
Space + bP          Close unpinned buffers
Ctrl+w s/v          Split horizontal/vertical
Ctrl+w h/j/k/l      Navigate windows
Ctrl+w q            Close window
```

## Terminal (Toggleterm)

```
Ctrl+\              Toggle terminal
Space + Tf          Floating terminal (capital T)
Space + Th          Horizontal terminal (capital T)
Space + Tv          Vertical terminal (capital T)
Space + gg          LazyGit (custom orange borders)

Terminal mode navigation:
  Esc               Exit terminal mode
  Ctrl+h/j/k/l      Navigate between windows
```

## Diagnostics (Trouble)

```
Space + xx          Toggle Trouble
Space + xw          Workspace diagnostics
Space + xd          Document diagnostics
Space + xq          Quickfix list
gR                  LSP references
```

## Git (Gitsigns)

```
]c, [c              Next/Previous git hunk
Space + hs          Stage hunk
Space + hS          Stage buffer
Space + hr          Reset hunk
Space + hR          Reset buffer
Space + hu          Undo stage hunk
Space + hp          Preview hunk
Space + hb          Blame line (inline)
Space + gb          Show git line contributor (full blame popup)
Space + tb          Toggle current line blame
Space + hd          Diff this
Space + hD          Diff this (cached)
Space + td          Toggle deleted lines
ih (visual/op)      Select hunk (text object)
Space + gg          LazyGit
```

## Text Selection (Insert Mode)

```
Shift+Arrow         Select character
Option+Shift+Arrow  Select word
Ctrl+Backspace      Delete word backward
Ctrl+Delete         Delete word forward
Ctrl+Left/Right     Move by word
```

## Formatting

```
Space + f           Format buffer (async, LSP fallback)
```

## Comments

```
Space + /           Toggle line comment
Space + bc          Toggle block comment
Space + cO          Add comment above line
Space + co          Add comment below line
Space + cA          Add comment at end of line
gcc                 Toggle line comment
gbc                 Toggle block comment
gc{motion}          Comment operator
gb{motion}          Block comment operator
```

## Surround

```
ys{motion}{char}    Add surround
yss                 Surround entire line
ds{char}            Delete surround
cs{old}{new}        Change surround
S (visual)          Surround selection
```

## Crates (Cargo.toml only)

```
Space + Ct          Toggle crates display
Space + Cr          Reload crate data
Space + Cv          Show versions popup
Space + Cf          Show features popup
Space + Cd          Show dependencies popup
Space + Cu          Update crate under cursor
Space + CA          Update all crates
Space + CU          Upgrade crate (potentially breaking)
Space + Ca          Upgrade all crates
```

## Session Management

```
Space + ws          Save session
Space + wr          Restore session
Space + wd          Delete session
```

## Other

```
Space + st          Search todos
]t, [t              Next/Previous todo
]]                  Next reference
[[                  Previous reference
```
