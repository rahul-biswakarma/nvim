# Neovim Configuration

A highly organized, fully documented Neovim configuration with centralized keybinding management and comprehensive LLM-friendly documentation.

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Complete architecture documentation for developers and LLMs
- **[KEYBINDINGS.md](KEYBINDINGS.md)** - User-friendly keybinding reference (~152 shortcuts)
- **README.md** - This file (quick overview)

## ✨ Key Features

### Design Philosophy
- **Centralized Keybindings**: All shortcuts defined in one place (`keybindings-registry.lua`)
- **Zero Conflicts**: Automatic conflict detection for keybindings
- **LLM-Friendly**: Comprehensive documentation for AI assistants
- **Modular**: Each plugin in its own file with clear structure
- **Performance**: Aggressive lazy loading for fast startup
- **Well-Documented**: Every file has headers, section markers, and inline comments

### Technology Stack
- **Plugin Manager**: lazy.nvim
- **LSP**: nvim-lspconfig + mason.nvim (30+ language servers)
- **Completion**: nvim-cmp with snippets
- **Parsing**: Treesitter (advanced syntax parsing)
- **UI**: Custom startup screen, Lualine, Bufferline, Neo-tree
- **Rust**: rustaceanvim, crates.nvim with full integration
- **Git**: gitsigns, lazygit integration
- **Search**: Telescope, Hop for fast navigation

## 📁 Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── ARCHITECTURE.md             # Complete architecture docs
├── KEYBINDINGS.md              # Keybinding reference
├── README.md                   # This file
│
├── lua/
│   ├── core/                   # Core configuration
│   │   ├── keybindings-registry.lua  # ⭐ CENTRALIZED keybindings
│   │   ├── options.lua         # Vim options
│   │   ├── keymaps.lua         # Standard Vim keymaps
│   │   ├── autocmds.lua        # Autocommands
│   │   └── utils.lua           # Shared utilities
│   │
│   ├── plugins/                # Plugin configs (27 files)
│   │   ├── init.lua            # Plugin loader
│   │   ├── lsp.lua             # LSP configuration
│   │   ├── cmp.lua             # Completion
│   │   ├── treesitter.lua      # Syntax parsing
│   │   ├── telescope.lua       # Fuzzy finder
│   │   ├── neo-tree.lua        # File explorer
│   │   └── ...                 # 21+ more plugins
│   │
│   └── ui/                     # UI components
│       ├── art.lua             # ASCII art
│       └── startup/            # Custom startup screen
│           ├── init.lua
│           ├── pin-handler.lua
│           ├── session.lua
│           └── ui.lua
```

## 🚀 Quick Start

### Prerequisites
- Neovim 0.9.0+ (0.10.0+ recommended)
- Git
- A Nerd Font (for icons)
- ripgrep (for Telescope)
- fd (optional, for faster file finding)

### Installation

```bash
# Backup existing config (if any)
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this configuration
git clone <your-repo-url> ~/.config/nvim

# Start Neovim (plugins will auto-install)
nvim
```

### First Launch

1. Plugins will automatically install via lazy.nvim
2. LSP servers will install via Mason (may take a few minutes)
3. Press `<Space>` to see leader key bindings
4. See `KEYBINDINGS.md` for complete shortcut reference

## ⌨️ Keybindings Highlights

**All 152+ keybindings are centralized in `lua/core/keybindings-registry.lua`**

### Essential Shortcuts

| Shortcut | Description |
|----------|-------------|
| `Space + e` | Toggle file tree |
| `Space + sf` | Search files |
| `Space + sg` | Search in files (grep) |
| `Space + <Space>` | Switch buffers |
| `Space + /` | Toggle comment |
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Show documentation |
| `Space + ca` | Code actions |
| `Space + f` | Format buffer |

### Categories
- **File Navigation**: Neo-tree (file explorer)
- **Search**: Telescope (fuzzy finder)
- **LSP**: Definitions, references, diagnostics, code actions
- **Rust**: Cargo actions, runnables, debuggables
- **Git**: Staging, hunks, blame, diff
- **Terminal**: Integrated terminal, LazyGit
- **Text Objects**: Treesitter-powered smart text manipulation
- **Diagnostics**: Trouble (diagnostics viewer)

See `KEYBINDINGS.md` for complete reference.

## 🛠️ Customization

### Changing Keybindings

**Only edit one file**: `lua/core/keybindings-registry.lua`

```lua
-- Change search files from <leader>sf to <leader>ff
M.search_files = '<leader>ff'  -- was '<leader>sf'
```

All plugins automatically use the new shortcut!

### Adding a Plugin

1. Create `lua/plugins/plugin-name.lua`
2. Add to `init.lua` plugin table
3. Add keybindings to `keybindings-registry.lua`
4. Run `:Lazy sync`

See `ARCHITECTURE.md` for detailed guide.

### Checking for Conflicts

```vim
:lua require('core.keybindings-registry').check_duplicates()
```

## 📊 Statistics

- **27** plugin configuration files
- **152+** centralized keybindings
- **0** keybinding conflicts
- **30+** LSP servers available
- **100%** documented code
- **100%** conflict-free keybindings

## 🎯 Design Principles

1. **Single Source of Truth**: All keybindings in one place
2. **Documentation First**: Every file fully documented
3. **Modular**: Each plugin self-contained
4. **Performance**: Lazy loading everywhere possible
5. **LLM-Friendly**: Clear structure for AI assistants
6. **Human-Friendly**: Easy to understand and modify

## 🔧 Troubleshooting

### Common Commands

```vim
:Lazy                    # View plugin status
:Lazy sync               # Update plugins
:Mason                   # Manage LSP servers
:LspInfo                 # Check LSP status
:checkhealth             # Check Neovim health
:messages                # View error messages
```

### Get Help

1. Check `ARCHITECTURE.md` for detailed documentation
2. Check `KEYBINDINGS.md` for shortcuts
3. Check individual plugin files for configuration details
4. Run `:checkhealth` to diagnose issues

## 🌟 Highlights

- **Custom Startup Screen**: PIN-protected with ASCII art
- **Session Management**: Auto-save and restore sessions
- **Smart Rust Support**: Smart goto-definition (skips use statements)
- **Conflict Detection**: Automatic keybinding conflict detection
- **Performance Optimized**: Treesitter disables for large files
- **Well Organized**: 13+ section headers per plugin file
- **Type-Safe**: Extensive use of Lua type hints and validation

## 📖 For Developers & LLMs

This configuration is designed to be easily understood and modified by both humans and AI assistants.

**Key documents**:
- `ARCHITECTURE.md` - Complete architecture guide
- `keybindings-registry.lua` - Central keybinding registry
- Each plugin file - Self-documenting with headers and comments

**Modification checklist**:
- [ ] Check keybindings registry before adding shortcuts
- [ ] Run conflict detection after changes
- [ ] Add documentation headers to new files
- [ ] Use section headers for organization
- [ ] Register keymaps for tracking
- [ ] Test all functionality

See `ARCHITECTURE.md` for complete development guide.

## 📝 License

This configuration is provided as-is. Feel free to use, modify, and distribute.

## 🙏 Acknowledgments

Built with:
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configuration
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) - Completion engine
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Syntax parsing
- And 20+ other excellent plugins!

---

**Last Updated**: November 11, 2025  
**Maintainer**: rch3
