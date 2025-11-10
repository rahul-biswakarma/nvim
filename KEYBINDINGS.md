# Neovim Keyboard Shortcuts Cheatsheet

**Leader Key: `Space`**

---

## 🚀 Essential Vim Motions (Must Learn First!)

### Basic Movement
```
h, j, k, l          - Left, Down, Up, Right
w / b               - Next/Previous word
e                   - End of word
0 / $               - Start/End of line
gg / G              - Top/Bottom of file
{ / }               - Previous/Next paragraph
Ctrl+u / Ctrl+d     - Half page up/down
Ctrl+b / Ctrl+f     - Full page up/down
H / M / L           - Top/Middle/Bottom of screen
```

### Insert Mode
```
i                   - Insert before cursor
a                   - Insert after cursor
I                   - Insert at start of line
A                   - Insert at end of line
o / O               - New line below/above
Esc                 - Exit insert mode
Ctrl+c              - Exit insert mode (alternative)
```

### Visual Mode
```
v                   - Visual mode (character)
V                   - Visual line mode
Ctrl+v              - Visual block mode
gv                  - Reselect last selection
```

### Editing
```
d{motion}           - Delete (e.g., dw = delete word)
dd                  - Delete line
c{motion}           - Change (delete and insert)
cc                  - Change entire line
y{motion}           - Yank (copy)
yy                  - Yank line
p / P               - Paste after/before
u                   - Undo
Ctrl+r              - Redo
.                   - Repeat last command
x                   - Delete character
r{char}             - Replace character
```

### Search
```
/{pattern}          - Search forward
?{pattern}          - Search backward
n / N               - Next/Previous match
*                   - Search word under cursor forward
#                   - Search word under cursor backward
```

---

## 📁 File Explorer (NvimTree)

```
Space + e           - Toggle file tree
```

### Inside NvimTree:
```
Enter               - Open file/folder
a                   - Create new file/folder (end with / for folder)
d                   - Delete file/folder
r                   - Rename file/folder
x                   - Cut file/folder
c                   - Copy file/folder
p                   - Paste file/folder
y                   - Copy filename
Y                   - Copy relative path
gy                  - Copy absolute path
?                   - Show help
q                   - Close tree
```

---

## 🔍 Telescope (Fuzzy Finder)

### File & Search
```
Space + sf          - [S]earch [F]iles
Space + sg          - [S]earch by [G]rep (live grep)
Space + sw          - [S]earch current [W]ord
Space + Space       - Find existing buffers
Space + /           - Fuzzy search in current buffer
```

### Help & Info
```
Space + sh          - [S]earch [H]elp
Space + sk          - [S]earch [K]eymaps
Space + ss          - [S]earch [S]elect Telescope
Space + sd          - [S]earch [D]iagnostics
Space + sr          - [S]earch [R]esume
Space + s.          - Search Recent Files
Space + sn          - [S]earch [N]eovim config files
Space + st          - [S]earch [T]odos
```

### Inside Telescope:
```
Ctrl+n / Ctrl+p     - Next/Previous result
Ctrl+u / Ctrl+d     - Scroll preview up/down
Ctrl+x              - Open in horizontal split
Ctrl+v              - Open in vertical split
Ctrl+t              - Open in new tab
Esc                 - Close telescope
```

---

## 📝 LSP (Code Intelligence)

### Navigation
```
gd                  - [G]oto [D]efinition
gr                  - [G]oto [R]eferences
gI                  - [G]oto [I]mplementation
gD                  - [G]oto [D]eclaration
Space + D           - Type [D]efinition
Space + ds          - [D]ocument [S]ymbols
Space + ws          - [W]orkspace [S]ymbols
gR                  - LSP References (in Trouble)
```

### Documentation & Help
```
K                   - Hover Documentation (press twice to enter)
Ctrl+k              - Signature help (in insert mode)
gl                  - Show line diagnostics (floating)
```

### Code Actions
```
Space + rn          - [R]e[n]ame symbol
Space + ca          - [C]ode [A]ction
:Format             - Format current buffer
```

### Diagnostics Navigation
```
[d                  - Previous diagnostic
]d                  - Next diagnostic
Space + q           - Open diagnostics quickfix list
```

### Inlay Hints (Rust)
```
Space + th          - [T]oggle inlay [H]ints
```

### Workspace
```
Space + wa          - [W]orkspace [A]dd folder
Space + wr          - [W]orkspace [R]emove folder
Space + wl          - [W]orkspace [L]ist folders
```

---

## 🗂️ Buffer Management (Bufferline)

```
Tab                 - Next buffer
Shift+Tab           - Previous buffer
Space + x           - Close buffer
Space + bp          - Pin/unpin buffer
Space + bP          - Close unpinned buffers
```

---

## 💻 Terminal (ToggleTerm)

```
Ctrl+\              - Toggle floating terminal
Space + tf          - Toggle [F]loating terminal
Space + th          - Toggle [H]orizontal terminal
Space + tv          - Toggle [V]ertical terminal
Space + gg          - Toggle lazy[g]it
```

### Inside Terminal:
```
Esc                 - Exit insert mode
Ctrl+h/j/k/l        - Navigate between windows
```

---

## 🐛 Trouble (Diagnostics)

```
Space + xx          - Toggle Trouble
Space + xw          - Workspace diagnostics
Space + xd          - Document diagnostics
Space + xq          - Quickfix list
Space + xl          - Location list
```

### Inside Trouble:
```
q                   - Close
Enter               - Jump to error
o                   - Jump and close
K                   - Hover
p                   - Preview
r                   - Refresh
```

---

## 💬 Comments

```
gcc                 - Toggle comment line
gc{motion}          - Toggle comment (e.g., gcap for paragraph)
```

### In Visual Mode:
```
gc                  - Toggle comment selection
```

---

## 🔤 Surround

```
ys{motion}{char}    - Add surround (e.g., ysiw" for word in quotes)
yss{char}           - Surround entire line
ds{char}            - Delete surround (e.g., ds" to remove quotes)
cs{old}{new}        - Change surround (e.g., cs"' to change " to ')
```

### In Visual Mode:
```
S{char}             - Surround selection
```

### Examples:
```
ysiw"               - Surround word with "
ysiw)               - Surround word with ()
dst                 - Delete surrounding tag (HTML)
cs"'                - Change " to '
```

---

## 📍 Reference Navigation (Illuminate)

```
]]                  - Next reference
[[                  - Previous reference
```

---

## 📝 Todo Comments

```
]t                  - Next todo comment
[t                  - Previous todo comment
Space + st          - [S]earch [T]odos in Telescope
```

---

## 🪟 Window Management

```
Ctrl+w s            - Horizontal split
Ctrl+w v            - Vertical split
Ctrl+w q            - Close window
Ctrl+w h/j/k/l      - Navigate windows
Ctrl+w =            - Equalize window sizes
Ctrl+w _            - Maximize height
Ctrl+w |            - Maximize width
Ctrl+w r            - Rotate windows
```

---

## 🎯 Quick Tips & Tricks

### Efficient Editing
```
ciw                 - Change inner word
ci"                 - Change inside quotes
ca{                 - Change around braces (including braces)
dit                 - Delete inside HTML tag
vat                 - Visual select around tag
```

### Line Operations
```
dd                  - Delete line
yy                  - Yank line
cc                  - Change line
>>                  - Indent line
<<                  - Unindent line
==                  - Auto-indent line
```

### Multiple Lines (Visual mode)
```
V                   - Select line
jj                  - Extend selection down
>                   - Indent selection
<                   - Unindent selection
d                   - Delete selection
y                   - Yank selection
```

### Jumping
```
%                   - Jump to matching bracket
Ctrl+o              - Jump to previous location
Ctrl+i              - Jump to next location
``                  - Jump to last position
'.                  - Jump to last edit
```

### Macros
```
q{letter}           - Start recording macro
q                   - Stop recording
@{letter}           - Play macro
@@                  - Repeat last macro
```

---

## 🎓 Learning Path (Recommended Order)

### Week 1: Basic Movement
1. h, j, k, l (arrow keys)
2. w, b, e (word movement)
3. 0, $ (line movement)
4. gg, G (file movement)
5. i, a, o (insert mode)

### Week 2: Editing
1. d, c, y, p (delete, change, yank, paste)
2. dd, cc, yy (line operations)
3. u, Ctrl+r (undo, redo)
4. . (repeat)
5. Visual mode (v, V)

### Week 3: Search & Navigation
1. /, ?, n, N (search)
2. *, # (word search)
3. Telescope basics (Space+sf, Space+sg)
4. File tree (Space+e)

### Week 4: LSP & Advanced
1. gd, gr, K (LSP navigation)
2. Space+rn, Space+ca (refactoring)K
3. Buffer navigation (Tab, Shift+Tab)
4. Window splits (Ctrl+w s/v)

---

## 🚨 Most Important Shortcuts to Remember

```
Space + e           - File tree
Space + sf          - Find files
Space + sg          - Search in files
Space + Space       - Switch buffers
Tab/Shift+Tab       - Next/Previous buffer
K                   - Documentation
gd
Space + ca          - Code action
gcc                 - Toggle comment
u / Ctrl+r          - Undo/Redo
```

---

## 💡 Pro Tips

1. **Practice in order**: Master basic motions before complex commands
2. **Use relative line numbers**: `:set relativenumber` helps with motions like `5j`
3. **Avoid arrow keys**: Force yourself to use hjkl for a week
4. **Use counts**: `3w` moves 3 words, `5dd` deletes 5 lines
5. **Think in text objects**: "change inside quotes" = `ci"`
6. **Use `:help` often**: `:help <command>` for any command
7. **Check Which-Key**: Press `Space` and wait to see available commands

---

## 📚 Resources

- `:Tutor` - Built-in Neovim tutorial
- `:help` - Help documentation
- `Space + sk` - Search your keymaps
- `Space + sh` - Search help

Happy Vimming! 🚀

