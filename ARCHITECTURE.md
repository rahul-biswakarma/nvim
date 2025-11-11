# Neovim Configuration Architecture

**Version:** 1.0  
**Last Updated:** November 11, 2025  
**Purpose:** Complete documentation of the Neovim configuration structure for LLMs and developers

---

## Table of Contents

1. [Overview](#overview)
2. [Design Principles](#design-principles)
3. [Directory Structure](#directory-structure)
4. [Core Systems](#core-systems)
5. [Plugin Organization](#plugin-organization)
6. [Keybinding System](#keybinding-system)
7. [Adding New Plugins](#adding-new-plugins)
8. [Modifying Keybindings](#modifying-keybindings)
9. [Conventions & Standards](#conventions--standards)
10. [Startup Flow](#startup-flow)
11. [Troubleshooting](#troubleshooting)

---

## Overview

This Neovim configuration is built with the following goals:

- **Modularity**: Each component is self-contained and can be modified independently
- **Clarity**: Code is documented thoroughly for both humans and LLMs
- **Maintainability**: Centralized systems prevent duplication and conflicts
- **Performance**: Lazy loading wherever possible to minimize startup time
- **Conflict-Free**: Single source of truth for all keybindings

### Technology Stack

- **Plugin Manager**: lazy.nvim (automatic lazy loading)
- **LSP**: nvim-lspconfig + mason.nvim (language server management)
- **Completion**: nvim-cmp (completion engine)
- **Parsing**: Treesitter (syntax parsing and highlighting)
- **UI**: Custom startup screen, Lualine (statusline), Bufferline (tabs)

---

## Design Principles

### 1. Single Source of Truth
All keybindings are defined in `lua/core/keybindings-registry.lua`. Plugins reference these variables rather than hardcoding shortcuts.

### 2. Documentation First
Every file has:
- A header block explaining its purpose
- Section headers for logical grouping
- Inline comments for every configuration option
- Examples where appropriate

### 3. Centralized Conflict Detection
The keybindings registry includes helper functions to detect and warn about duplicate shortcuts.

### 4. Lazy Loading
Plugins load only when needed:
- `event`: Load on specific Vim events
- `cmd`: Load when command is executed
- `keys`: Load when keybinding is pressed
- `ft`: Load for specific filetypes

### 5. Performance Optimizations
- Treesitter disables for files >100KB
- Modular startup screen with PIN protection
- Deferred loading for non-critical plugins

---

## Directory Structure

```
~/.config/nvim/
├── init.lua                    # Entry point (loads lazy.nvim)
├── lazy-lock.json              # Plugin version lockfile
├── ARCHITECTURE.md             # This file
├── KEYBINDINGS.md              # User-friendly keybinding reference
├── README.md                   # General overview
│
├── lua/
│   ├── core/                   # Core Neovim configuration
│   │   ├── autocmds.lua        # Autocommands (TextYankPost, VimEnter)
│   │   ├── keymaps.lua         # Standard Vim keymaps (not plugin-specific)
│   │   ├── options.lua         # Vim options (line numbers, indentation, etc.)
│   │   ├── keybindings-registry.lua  # CENTRALIZED keybinding definitions
│   │   └── utils.lua           # Shared utility functions
│   │
│   ├── plugins/                # Plugin configurations (one file per plugin)
│   │   ├── init.lua            # Plugin loader (returns table of all plugins)
│   │   ├── auto-session.lua    # Session management
│   │   ├── autopairs.lua       # Auto-pairing brackets/quotes
│   │   ├── autotag.lua         # Auto-close HTML/JSX tags
│   │   ├── beacon.lua          # Cursor flash on jumps
│   │   ├── bufferline.lua      # Buffer tabs
│   │   ├── cmp.lua             # Completion engine
│   │   ├── colorizer.lua       # Color highlighting
│   │   ├── comment.lua         # Commenting plugin
│   │   ├── conform.lua         # Code formatting
│   │   ├── crates.lua          # Rust Cargo.toml management
│   │   ├── dressing.lua        # UI enhancements
│   │   ├── gitsigns.lua        # Git integration
│   │   ├── hlargs.lua          # Highlight function arguments
│   │   ├── hop.lua             # Fast navigation
│   │   ├── illuminate.lua      # Highlight references
│   │   ├── indent-blankline.lua # Indent guides
│   │   ├── lsp.lua             # LSP configuration
│   │   ├── lualine.lua         # Statusline
│   │   ├── neo-tree.lua        # File explorer
│   │   ├── notify.lua          # Notifications
│   │   ├── nvim-lint.lua       # Linting
│   │   ├── rustaceanvim.lua    # Rust LSP
│   │   ├── solarized-osaka.lua # Colorscheme
│   │   ├── surround.lua        # Surround text objects
│   │   ├── telescope.lua       # Fuzzy finder
│   │   ├── todo-comments.lua   # Highlight TODO comments
│   │   ├── toggleterm.lua      # Terminal integration
│   │   ├── treesitter.lua      # Syntax parsing
│   │   └── trouble.lua         # Diagnostics viewer
│   │
│   └── ui/                     # UI-related modules
│       ├── art.lua             # ASCII art for startup screen
│       └── startup/            # Startup screen modules
│           ├── init.lua        # Main startup screen logic
│           ├── pin-handler.lua # PIN entry system
│           ├── session.lua     # Session restoration
│           └── ui.lua          # UI rendering
```

---

## Core Systems

### 1. Keybindings Registry (`lua/core/keybindings-registry.lua`)

**Purpose**: Centralized definition of ALL keyboard shortcuts.

**Structure**:
```lua
local M = {}

-- Define shortcuts as variables
M.search_files = '<leader>sf'
M.toggle_file_tree = '<leader>e'
-- ... (152+ total shortcuts)

-- Helper functions for conflict detection
M.register_keymap(plugin_name, mode, lhs, rhs, opts)
M.check_duplicates()
M.print_all()

return M
```

**Categories** (in order):
1. Leader Key
2. File Navigation (Neo-tree)
3. Search (Telescope)
4. Hop (Fast Navigation)
5. LSP
6. Rust Specific (Rustaceanvim)
7. Buffers & Windows
8. Terminal (Toggleterm)
9. Git (Gitsigns)
10. Surround
11. Comments
12. Formatting
13. Crates (Cargo.toml)
14. TODO Comments
15. Session Management
16. Text Objects (Treesitter)
17. Diagnostics (Trouble)
18. Misc

**Key Functions**:

- `register_keymap(plugin, mode, lhs, rhs, opts)`: Registers a keymap and checks for conflicts
- `register_keymaps(plugin, table)`: Registers multiple keymaps at once
- `check_duplicates()`: Scans registry for duplicate shortcuts
- `get_all_shortcuts()`: Returns all shortcuts as a table
- `print_all()`: Prints all shortcuts to console

**Usage Example**:
```lua
local keys = require('core.keybindings-registry')
vim.keymap.set('n', keys.search_files, telescope.find_files, { desc = 'Search files' })
```

### 2. Options (`lua/core/options.lua`)

**Purpose**: Standard Vim/Neovim options.

**Categories**:
- General Settings (mouse, clipboard, swap files)
- Search Settings (ignorecase, smartcase, highlighting)
- UI Settings (line numbers, signcolumn, cursorline)
- Indentation (expandtab, shiftwidth, tabstop)
- Splits (splitbelow, splitright)
- Performance (updatetime, timeoutlen)

### 3. Autocmds (`lua/core/autocmds.lua`)

**Purpose**: Global autocommands.

**Current Autocommands**:
1. `TextYankPost`: Highlight text after yanking
2. `VimEnter`: Auto-open Neo-tree if no files specified

### 4. Keymaps (`lua/core/keymaps.lua`)

**Purpose**: Standard Vim keymaps (NOT plugin-specific).

**Categories**:
- Leader Key (disable Space as movement)
- Line Navigation (wrap-aware j/k)
- Insert Mode: Word Navigation
- Insert Mode: Line Navigation
- Insert Mode: Text Selection
- Visual Mode: Extend Selection
- Insert Mode: Delete Operations
- Insert Mode: Line Movement & Duplication

**Note**: These are fundamental Vim keymaps. Plugin-specific shortcuts use the registry.

### 5. Utils (`lua/core/utils.lua`)

**Purpose**: Shared helper functions.

**Functions**:
- `has_neotree()`: Check if Neo-tree is open
- `ensure_neotree(delay)`: Open Neo-tree if not already open
- `has_startup_screen()`: Check if startup screen is active

---

## Plugin Organization

### Plugin File Structure

Every plugin file follows this standard structure:

```lua
--[[
  Plugin Name - Brief Description
  
  Detailed explanation of what this plugin does.
  List of key features.
  
  Additional notes if needed.
]]

return {
  'author/plugin-name',
  dependencies = { ... },
  event = 'VeryLazy', -- or cmd, keys, ft
  config = function()
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry') -- For registering keymaps
    
    -- ============================================================================
    -- SECTION NAME
    -- ============================================================================
    -- Configuration here
    
    -- Register keymaps for conflict tracking
    kb.register_keymap('plugin-name', 'n', keys.some_action, function() ... end, { desc = 'Description' })
  end,
}
```

### Section Headers

Use section headers to organize plugin configuration:

```lua
-- ============================================================================
-- SECTION NAME
-- ============================================================================
```

Common sections:
- General Settings
- Appearance
- Behavior
- Keymaps
- Actions
- Autocommands
- Custom Functions

### Loading Strategies

| Strategy | When to Use | Example |
|----------|-------------|---------|
| `lazy = false` | Small, frequently used plugins | Comment.nvim |
| `event = 'VeryLazy'` | After startup, not time-critical | Most UI plugins |
| `event = 'InsertEnter'` | Only in insert mode | nvim-cmp, autopairs |
| `event = 'BufReadPre'` | When opening a file | Gitsigns, nvim-lint |
| `cmd = 'CommandName'` | Only when command is run | Telescope, Trouble |
| `keys = { ... }` | Only when keybinding pressed | Some toggles |
| `ft = 'filetype'` | Filetype-specific | Rustaceanvim |

---

## Keybinding System

### Architecture

```
┌─────────────────────────────────────────┐
│   lua/core/keybindings-registry.lua     │
│   (Single source of truth)              │
│                                         │
│   M.search_files = '<leader>sf'        │
│   M.toggle_file_tree = '<leader>e'     │
│   M.lsp_goto_definition = 'gd'         │
│   ... (152+ shortcuts)                 │
└─────────────────────────────────────────┘
              │
              │ require('core.keybindings-registry')
              │
        ┌─────┴──────┐
        │            │
        ▼            ▼
┌──────────────┐  ┌──────────────┐
│ telescope.lua│  │  lsp.lua     │
│              │  │              │
│ local keys = │  │ local keys = │
│ require(...) │  │ require(...) │
│              │  │              │
│ keys.search_ │  │ keys.lsp_    │
│ files        │  │ goto_def     │
└──────────────┘  └──────────────┘
```

### Keybinding Lifecycle

1. **Definition**: Define in `keybindings-registry.lua`
   ```lua
   M.search_files = '<leader>sf'
   ```

2. **Reference**: Use in plugin config
   ```lua
   local keys = require('core.keybindings-registry')
   vim.keymap.set('n', keys.search_files, ...)
   ```

3. **Registration**: Track for conflict detection
   ```lua
   local kb = require('core.keybindings-registry')
   kb.register_keymap('telescope', 'n', keys.search_files, builtin.find_files, { desc = 'Search files' })
   ```

### Conflict Detection

The registry provides automatic conflict detection:

```lua
-- Check for duplicates programmatically
local duplicates = require('core.keybindings-registry').check_duplicates()

-- Print all shortcuts
require('core.keybindings-registry').print_all()
```

### Special Cases

#### Context-Dependent Keymaps

Some plugins define keymaps in their own config (like nvim-cmp). These are still registered for documentation:

```lua
-- cmp.lua
mapping = cmp.mapping.preset.insert {
  ['<C-n>'] = cmp.mapping.select_next_item(),
  -- ...
}

-- Still register for tracking
kb.register_keymaps('cmp', {
  { 'i', '<C-n>', 'cmp', { desc = 'Next completion item' } },
})
```

#### Buffer-Local Keymaps

Some keymaps are only active in specific buffers (like LSP keymaps):

```lua
on_attach = function(client, bufnr)
  local opts = { buffer = bufnr }
  kb.register_keymap('lsp', 'n', keys.lsp_goto_definition, vim.lsp.buf.definition, opts)
end
```

#### Filetype-Specific Keymaps

Some keymaps only apply to specific filetypes (like Crates.nvim for Cargo.toml):

```lua
vim.api.nvim_create_autocmd('BufRead', {
  pattern = 'Cargo.toml',
  callback = function()
    kb.register_keymap('crates', 'n', keys.crates_toggle, require('crates').toggle, { buffer = true })
  end,
})
```

### Naming Conventions

Keymap variable names follow a pattern: `category_action`

Examples:
- `search_files` (category: search, action: files)
- `lsp_goto_definition` (category: lsp, action: goto_definition)
- `git_stage_hunk` (category: git, action: stage_hunk)
- `terminal_float` (category: terminal, action: float)

### Conflict Resolution Strategies

When conflicts are found:

1. **Prefix Change**: Add plugin-specific prefix
   - Example: Terminal keymaps changed from `<leader>t*` to `<leader>T*`
   - Example: Crates keymaps changed from `<leader>c*` to `<leader>C*`

2. **Mnemonic Prefix**: Use meaningful prefix
   - Example: Treesitter swap changed from `<leader>a` to `<leader>sa/sA` (s for swap)

3. **Alternative Key**: Use different key entirely
   - Example: LSP workspace keymaps use `<leader>lw*` prefix

4. **Priority**: Important/frequent actions get shorter shortcuts

---

## Adding New Plugins

### Step-by-Step Guide

#### 1. Add to `init.lua`

Add the plugin to the appropriate section in `lua/plugins/init.lua`:

```lua
return {
  -- ... other plugins ...
  
  -- ============================================================================
  -- YOUR SECTION
  -- ============================================================================
  { 'author/plugin-name', lazy = false },
}
```

#### 2. Create Plugin File

Create `lua/plugins/plugin-name.lua`:

```lua
--[[
  Plugin Name - Brief Description
  
  What this plugin does.
  Key features.
]]

return {
  'author/plugin-name',
  dependencies = { 'other/plugin' },
  event = 'VeryLazy', -- Choose appropriate loading strategy
  config = function()
    local keys = require('core.keybindings-registry')
    local kb = require('core.keybindings-registry')
    
    -- ============================================================================
    -- SETUP
    -- ============================================================================
    require('plugin-name').setup({
      -- Configuration here
    })
    
    -- ============================================================================
    -- KEYMAPS
    -- ============================================================================
    kb.register_keymap('plugin-name', 'n', keys.some_action, function()
      -- Action here
    end, { desc = 'Description' })
  end,
}
```

#### 3. Add Keybindings to Registry

Edit `lua/core/keybindings-registry.lua`:

```lua
-- ============================================================================
-- YOUR PLUGIN NAME
-- ============================================================================
M.plugin_action_one = '<leader>pa'
M.plugin_action_two = '<leader>pb'
```

#### 4. Check for Conflicts

Run conflict detection:

```vim
:lua require('core.keybindings-registry').check_duplicates()
```

Resolve any conflicts by changing the shortcut in the registry.

#### 5. Update Documentation

Add to `KEYBINDINGS.md`:

```markdown
### Your Plugin
| Shortcut | Description |
|----------|-------------|
| `Space + pa` | Plugin action one |
| `Space + pb` | Plugin action two |
```

#### 6. Test

1. Restart Neovim
2. Verify plugin loads correctly
3. Test all keybindings
4. Check for linter errors: `:lua vim.diagnostic.get()`

---

## Modifying Keybindings

### Changing a Single Shortcut

**Only edit one file**: `lua/core/keybindings-registry.lua`

Example: Change file search from `<leader>sf` to `<leader>ff`:

```lua
-- Before
M.search_files = '<leader>sf'

-- After
M.search_files = '<leader>ff'
```

All plugins automatically use the new shortcut!

### Adding a New Shortcut to Existing Plugin

1. **Add to registry**:
   ```lua
   M.plugin_new_action = '<leader>pn'
   ```

2. **Add to plugin file**:
   ```lua
   kb.register_keymap('plugin', 'n', keys.plugin_new_action, function() ... end, { desc = 'New action' })
   ```

3. **Update documentation**

### Removing a Shortcut

1. **Remove from registry** (or comment out)
2. **Remove from plugin file**
3. **Update documentation**

### Reorganizing Keybinding Prefixes

Example: Moving all git commands from `<leader>h*` to `<leader>g*`:

```lua
-- In keybindings-registry.lua
M.git_stage_hunk = '<leader>gs'  -- was '<leader>hs'
M.git_reset_hunk = '<leader>gr'  -- was '<leader>hr'
M.git_preview_hunk = '<leader>gp'  -- was '<leader>hp'
-- etc.
```

All plugins automatically update!

---

## Conventions & Standards

### File Naming

- **Plugin files**: `plugin-name.lua` (kebab-case, matches plugin name)
- **Core files**: `descriptive-name.lua` (kebab-case)
- **UI modules**: `module-name.lua` (kebab-case)

### Code Style

#### Documentation Headers

```lua
--[[
  File/Plugin Name - Brief Description
  
  Detailed explanation spanning multiple lines.
  Include key features, important notes, and examples.
  
  Example:
    local thing = require('module')
    thing.do_something()
]]
```

#### Section Headers

```lua
-- ============================================================================
-- SECTION NAME (UPPERCASE)
-- ============================================================================
```

#### Inline Comments

- **Every configuration option** should have an inline comment
- Place comments on the same line or line above
- Be descriptive but concise

```lua
enable = true, -- Enable this feature
max_width = 80, -- Maximum width before wrapping
```

#### Function Comments

```lua
--- Description of what this function does
--- @param param_name type Description of parameter
--- @return type Description of return value
function M.function_name(param_name)
  -- Implementation
end
```

### Variable Naming

- **Registry variables**: `category_action` (snake_case)
- **Local variables**: `descriptive_name` (snake_case)
- **Module tables**: `M` (uppercase single letter)
- **Constants**: `MAX_WIDTH` (uppercase snake_case)

### Lazy Loading Best Practices

1. **Default to lazy**: Use `event = 'VeryLazy'` unless plugin needs to load early
2. **Specific events**: Use specific events when possible (`InsertEnter`, `BufReadPre`)
3. **Commands**: Use `cmd` for plugins with primary commands
4. **Keys**: Use `keys` for plugins primarily accessed via keybindings
5. **Always load**: Use `lazy = false` only for small, critical plugins

### Comment Removal

**Remove**:
- Commented-out code (unless it's an example or explicitly marked as alternative)
- Default values that don't need explanation
- Redundant explanations

**Keep**:
- Non-obvious configuration
- Performance-related settings
- Workarounds for bugs
- Examples of usage

---

## Startup Flow

### 1. Init Phase (`init.lua`)

```
init.lua
  ├── Load lazy.nvim (bootstrap if needed)
  ├── require('core.options')        # Vim options
  ├── require('core.keymaps')        # Standard keymaps
  ├── require('core.autocmds')       # Global autocommands
  └── Setup lazy.nvim
      └── require('plugins.init')    # Load all plugins
```

### 2. Core Loading

```
core/options.lua   → Set Vim options
core/keymaps.lua   → Set standard keymaps (not plugin-specific)
core/autocmds.lua  → Register global autocommands
```

### 3. Plugin Loading (Lazy)

```
plugins/init.lua returns table:
  ├── Core Utilities (neoconf, neodev)
  ├── UI & Appearance (colorscheme, statusline, bufferline, etc.)
  ├── LSP & Language Support (lspconfig, cmp, treesitter, etc.)
  ├── Editing & Text Manipulation (autopairs, comment, surround, etc.)
  ├── Navigation & Search (telescope, hop)
  ├── Git Integration (gitsigns, lazygit)
  ├── Rust-Specific Tools (rustaceanvim, crates)
  └── Productivity & Utilities (todo-comments, toggleterm, auto-session)
```

### 4. VimEnter Autocommand

```
VimEnter fires:
  ├── Check if startup screen is active
  │   └── If yes: Show PIN screen, then restore session
  └── If no: Open Neo-tree if no files specified
```

### 5. Startup Screen Flow (if active)

```
ui/startup/init.lua
  ├── Create buffer
  ├── Load ASCII art from ui/art.lua
  ├── Apply highlights
  ├── Show PIN prompt (ui/startup/pin-handler.lua)
  ├── On correct PIN:
  │   └── Restore session (ui/startup/session.lua)
  │       ├── Call auto-session.RestoreSession()
  │       └── Open Neo-tree (via core/utils.lua)
  └── On wrong PIN: Show error, allow retry
```

---

## Troubleshooting

### Keybinding Conflicts

**Symptom**: Keymap not working as expected

**Solution**:
```vim
:lua require('core.keybindings-registry').check_duplicates()
```

This will print all conflicts. Edit `keybindings-registry.lua` to resolve.

### Plugin Not Loading

**Symptom**: `:Telescope` or other command not found

**Check**:
1. Is plugin in `init.lua`? (It might be using a direct return statement)
2. Is lazy loading configured correctly?
3. Run `:Lazy` to see plugin status
4. Check `:messages` for errors

**Solution**:
```vim
:Lazy reload plugin-name
:Lazy sync
```

### LSP Not Attaching

**Symptom**: LSP features not working in file

**Check**:
1. `:LspInfo` - Shows attached LSP servers
2. `:Mason` - Shows installed servers
3. Check `lua/plugins/lsp.lua` - Ensure server is in `ensure_installed`

**Solution**:
```vim
:MasonInstall server-name
:LspRestart
```

### Startup Screen Not Showing

**Symptom**: Regular Neovim starts instead of PIN screen

**Check**:
1. Is `require('ui.startup').config()` in `init.lua`?
2. Are session files interfering? Delete `~/.local/share/nvim/sessions/`
3. Check console for errors: `:messages`

### Performance Issues

**Symptom**: Neovim starts slowly

**Profile startup**:
```bash
nvim --startuptime startup.log
```

**Common causes**:
- Too many plugins loading eagerly (`lazy = false`)
- Large files triggering Treesitter (should disable at >100KB)
- Many autocommands

**Solution**: Review lazy loading configuration in plugin files.

### Linter Errors

**Check errors**:
```vim
:lua vim.diagnostic.get()
```

**Common issues**:
- Missing `require` statements
- Typos in variable names
- Incorrect function signatures

---

## Best Practices for LLMs

When modifying this configuration:

### ✅ DO:

1. **Always** check `keybindings-registry.lua` before adding new keymaps
2. **Always** run conflict detection after changes
3. **Always** add documentation headers to new files
4. **Always** use section headers for organization
5. **Always** register keymaps for tracking
6. **Always** use lazy loading unless plugin needs early loading
7. **Always** add inline comments for non-obvious configuration
8. **Always** update `KEYBINDINGS.md` when adding shortcuts

### ❌ DON'T:

1. **Never** hardcode keybindings in plugin files
2. **Never** skip conflict detection
3. **Never** remove performance optimizations without understanding them
4. **Never** use `lazy = false` without good reason
5. **Never** modify `init.lua` plugin table directly (plugins should have own files)
6. **Never** duplicate code (use `core/utils.lua` for shared functions)
7. **Never** skip documentation for new features
8. **Never** commit without checking linter errors

### Modification Checklist

Before committing changes:

- [ ] No hardcoded keybindings (all use registry)
- [ ] Run `:lua require('core.keybindings-registry').check_duplicates()`
- [ ] All new files have documentation headers
- [ ] All sections have headers
- [ ] All configuration options have inline comments
- [ ] Keymaps are registered for tracking
- [ ] `KEYBINDINGS.md` is updated
- [ ] No linter errors (`:lua vim.diagnostic.get()`)
- [ ] Test all modified functionality
- [ ] Startup time is reasonable (`:Lazy profile`)

---

## Quick Reference

### File Purposes

| File | Purpose |
|------|---------|
| `init.lua` | Entry point, loads lazy.nvim and plugins |
| `core/keybindings-registry.lua` | **CENTRALIZED** keybinding definitions |
| `core/options.lua` | Vim/Neovim options |
| `core/keymaps.lua` | Standard Vim keymaps |
| `core/autocmds.lua` | Global autocommands |
| `core/utils.lua` | Shared utility functions |
| `plugins/init.lua` | Plugin table (loaded by lazy.nvim) |
| `plugins/*.lua` | Individual plugin configurations |
| `ui/art.lua` | ASCII art for startup screen |
| `ui/startup/*.lua` | Startup screen modules |

### Common Tasks

| Task | Command/File |
|------|--------------|
| Change a keybinding | Edit `core/keybindings-registry.lua` |
| Add a plugin | Create `plugins/plugin-name.lua` + add to `init.lua` |
| Check conflicts | `:lua require('core.keybindings-registry').check_duplicates()` |
| View all shortcuts | `:lua require('core.keybindings-registry').print_all()` |
| Update plugins | `:Lazy sync` |
| Install LSP server | `:Mason` or `:MasonInstall server-name` |
| Check LSP status | `:LspInfo` |
| Profile startup | `nvim --startuptime startup.log` |
| View plugin status | `:Lazy` |

### Registry Categories (in order)

1. Leader Key
2. File Navigation (Neo-tree)
3. Search (Telescope)
4. Hop (Fast Navigation)
5. LSP
6. Rust Specific (Rustaceanvim)
7. Buffers & Windows
8. Terminal (Toggleterm)
9. Git (Gitsigns)
10. Surround
11. Comments
12. Formatting
13. Crates (Cargo.toml)
14. TODO Comments
15. Session Management
16. Text Objects (Treesitter)
17. Diagnostics (Trouble)
18. Misc

---

## Conclusion

This Neovim configuration is designed to be:

- **Self-documenting**: Every file explains its purpose
- **Maintainable**: Single source of truth prevents conflicts
- **Extensible**: Easy to add new plugins and features
- **Performant**: Lazy loading minimizes startup time
- **LLM-friendly**: Clear structure and comprehensive documentation

When in doubt, refer to:
1. This document (architecture and patterns)
2. `keybindings-registry.lua` (all shortcuts)
3. `KEYBINDINGS.md` (user-friendly reference)
4. Existing plugin files (examples of best practices)

---

**Last Updated**: November 11, 2025  
**Maintainer**: rch3  
**Questions?**: Review this document, check existing plugin files for examples, or search for similar implementations in the codebase.

