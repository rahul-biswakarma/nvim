# Neovim Configuration

A clean, maintainable Neovim configuration optimized for Rust development and general productivity.

## 📁 Structure

```
.config/nvim/
├── init.lua                 # Main entry point
├── lazy-lock.json          # Plugin lock file (auto-generated)
│
├── lua/
│   ├── core/               # Core Neovim settings
│   │   ├── options.lua     # Editor options and settings
│   │   ├── keymaps.lua     # Global keybindings
│   │   └── autocmds.lua    # Autocommands
│   │
│   └── plugins/            # Plugin configurations
│       ├── init.lua        # Plugin loader (organized by category)
│       ├── *.lua           # Individual plugin configs
│       │
│       ├── UI & Appearance
│       │   ├── solarized-osaka.lua
│       │   ├── lualine.lua
│       │   ├── bufferline.lua
│       │   ├── neo-tree.lua
│       │   └── ...
│       │
│       ├── LSP & Language Support
│       │   ├── lsp.lua
│       │   ├── cmp.lua
│       │   ├── rustaceanvim.lua
│       │   ├── treesitter.lua
│       │   └── ...
│       │
│       └── Other Categories...
│           └── ...
```

## 🎯 Key Features

### Core Functionality
- **LSP**: Full Language Server Protocol support with rust-analyzer
- **Completion**: Smart autocompletion with nvim-cmp
- **Syntax**: Tree-sitter for advanced syntax highlighting
- **Git**: Integrated git support with gitsigns

### Rust Development
- **rust-analyzer**: Full Rust LSP support
- **rustaceanvim**: Enhanced Rust tooling
- **crates.nvim**: Cargo.toml dependency management
- **Inlay Hints**: Type hints and parameter names inline

### UI & Navigation
- **Neo-tree**: Modern file explorer with auto-reveal
- **Telescope**: Powerful fuzzy finder
- **Hop**: Quick navigation to any visible text
- **Bufferline**: Tab-like buffer navigation

### Productivity
- **Trouble**: Beautiful diagnostics viewer
- **Todo Comments**: Highlight and search TODOs
- **Terminal**: Integrated terminal with toggleterm
- **Git**: LazyGit integration

## 🔧 Configuration Philosophy

### Separation of Concerns
- **Core settings** (`core/`) are separate from **plugin configs** (`plugins/`)
- Each plugin has its own file for easy maintenance
- Plugin loader (`plugins/init.lua`) is organized by category

### Maintainability
- Clear comments and documentation
- Consistent code style
- Logical file organization
- Easy to understand structure

### AI-Friendly
- Well-documented code
- Clear naming conventions
- Organized by functionality
- Comments explain purpose, not just what

## 📝 Adding New Plugins

1. **Add to plugin loader** (`lua/plugins/init.lua`):
   ```lua
   { 'author/plugin-name', config = function() ... end }
   ```

2. **Create plugin config** (`lua/plugins/plugin-name.lua`):
   ```lua
   return {
     'author/plugin-name',
     config = function()
       require('plugin-name').setup({ ... })
     end,
   }
   ```

3. **Or use inline config** in `init.lua` for simple plugins

## 🎮 Key Bindings

See `KEYBINDINGS.md` for a complete list of keybindings.

### Quick Reference
- `<leader>` = `<Space>`
- `<leader>e` = Toggle file explorer
- `<leader>sf` = Find files
- `<leader>sg` = Search in files
- `K` = Hover documentation
- `gd` = Go to definition
- `Space + ca` = Code actions

## 🚀 Getting Started

1. **Install Neovim** (v0.9.0+)
2. **Clone or copy** this configuration
3. **Open Neovim** - plugins will auto-install
4. **Wait for** Mason to install LSP servers
5. **Start coding!**

## 📚 Plugin Categories

### UI & Appearance
- Colorscheme, statusline, file explorer, visual enhancements

### LSP & Language Support  
- Language servers, completion, syntax highlighting

### Editing & Text Manipulation
- Autopairs, comments, surround, text objects

### Navigation & Search
- File finder, text navigation, quick movement

### Git Integration
- Git signs, lazygit integration

### Rust-Specific
- Rust tooling, Cargo management

### Productivity
- Todo tracking, terminal, diagnostics

## 🔍 Troubleshooting

### Plugins not loading?
```vim
:Lazy sync
```

### LSP not working?
```vim
:LspInfo
:Mason
```

### Check health
```vim
:checkhealth
```

## 📖 Documentation

- `:help` - Neovim help
- `KEYBINDINGS.md` - Complete keybinding reference
- Plugin READMEs - Check each plugin's GitHub page

## 🤝 Contributing

When modifying this config:
1. Keep code organized by category
2. Add comments explaining why, not just what
3. Maintain consistent style
4. Update this README if structure changes

---

**Happy Vimming!** 🚀

