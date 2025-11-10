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
Space + /           Search in buffer
s                   Hop to 2 chars
S                   Hop to word
```

## LSP

```
gd                  Go to definition
gr                  Go to references
gI                  Go to implementation
K                   Hover documentation
Ctrl+k              Signature help
gl                  Show diagnostics
Space + ca          Code actions
Space + rn          Rename symbol
Space + a           Code actions (alternative)
[d, ]d              Previous/Next diagnostic
```

## Rust

```
Space + ra          Rust code actions
Space + rr          Rust runnables
Space + rt          Rust testables
Space + rm          Expand macro
Space + re          Explain error
K                   Enhanced hover
```

## Buffers & Windows

```
Tab                 Next buffer
Shift+Tab           Previous buffer
Space + x           Close buffer
Ctrl+w s/v          Split horizontal/vertical
Ctrl+w h/j/k/l      Navigate windows
Ctrl+w q            Close window
```

## Terminal

```
Ctrl+\              Toggle terminal
Space + tf          Floating terminal
Space + th          Horizontal terminal
Space + tv          Vertical terminal
Space + gg          LazyGit
```

## Diagnostics (Trouble)

```
Space + xx          Toggle Trouble
Space + xw          Workspace diagnostics
Space + xd          Document diagnostics
Space + xq          Quickfix list
gR                  LSP references
```

## Git

```
Space + gg          LazyGit
Space + gb          Show git line contributor (blame popup)
Space + hb          Show git blame line (alternative)
Space + hs          Stage hunk
Space + hr          Reset hunk
Space + hp          Preview hunk
```

## Text Selection (Insert Mode)

```
Shift+Arrow         Select character
Option+Shift+Arrow  Select word
Ctrl+Backspace      Delete word backward
Ctrl+Delete         Delete word forward
Ctrl+Left/Right     Move by word
```

## Comments & Surround

```
gcc                 Toggle comment line
gc{motion}          Toggle comment
ys{motion}{char}    Add surround
ds{char}            Delete surround
cs{old}{new}        Change surround
```

## Other

```
Space + st          Search todos
]t, [t              Next/Previous todo
]]                  Next reference
[[                  Previous reference
```
