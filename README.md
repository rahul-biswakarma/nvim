# Neovim Configuration

A clean, maintainable Neovim configuration optimized for Rust development.

## Structure

```
.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── core/            # Core settings
│   │   ├── options.lua  # Editor options
│   │   ├── keymaps.lua  # Keybindings
│   │   └── autocmds.lua # Autocommands
│   └── plugins/         # Plugin configs
│       ├── init.lua     # Plugin loader
│       └── *.lua        # Plugin configs
```

## Features

- **LSP**: rust-analyzer, completion, diagnostics
- **Rust**: rustaceanvim, crates.nvim, inlay hints
- **UI**: Neo-tree, Telescope, Bufferline, Lualine
- **Productivity**: Trouble, Todo comments, Terminal, Git

## Quick Start

1. Install Neovim (v0.9.0+)
2. Clone this repo to `~/.config/nvim`
3. Open Neovim - plugins auto-install
4. See `KEYBINDINGS.md` for shortcuts

## Keybindings

See `KEYBINDINGS.md` for complete reference.

**Quick reference:**
- `<Space>e` - File tree
- `<Space>sf` - Find files
- `<Space>sg` - Search files
- `gd` - Go to definition
- `K` - Documentation
- `<Space>ca` - Code actions
