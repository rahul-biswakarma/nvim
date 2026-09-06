# nvim

A minimal, fast Neovim config — lean but effortless. Built on
[lazy.nvim](https://github.com/folke/lazy.nvim), tuned for Rust, TypeScript/React,
Python, and Lua. Starts in ~85ms.

## Requirements

- Neovim **0.12+**
- `git`, a C compiler (`cc`/`make`) — for `telescope-fzf-native` and `blink.cmp`'s fuzzy matcher
- `tree-sitter` CLI (`brew install tree-sitter-cli`) — nvim-treesitter's `main` branch compiles parsers with it
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- Optional: `lazygit`, `ripgrep` + `fd` (better Telescope), language toolchains (`rustup`, `node`, `python`)

## Install

```sh
git clone https://github.com/rahul-biswakarma/nvim ~/.config/nvim
nvim   # lazy.nvim bootstraps and installs everything on first launch
```

LSP servers and formatters install automatically via Mason.

## Layout

```
init.lua                     -> require("rch3")
lua/rch3/
├─ init.lua                  leader, module loading, colorscheme
├─ config/
│  ├─ lazy.lua               lazy.nvim bootstrap (spec = "rch3.lazy")
│  ├─ options.lua            editor options + diagnostics
│  ├─ keymap.lua             all keymaps
│  └─ lsp.lua                shared LSP behavior
└─ lazy/                     one file per plugin, each returns a lazy spec
```

## Plugins

| Area           | Plugin |
|----------------|--------|
| Package manager| `folke/lazy.nvim` |
| Completion     | `saghen/blink.cmp` (+ `friendly-snippets`) |
| LSP            | `mason.nvim`, `mason-lspconfig.nvim`, `nvim-lspconfig` |
| Rust           | `mrcjkb/rustaceanvim` |
| TypeScript     | `pmizio/typescript-tools.nvim` |
| Formatting     | `stevearc/conform.nvim` |
| Syntax         | `nvim-treesitter/nvim-treesitter` |
| Fuzzy finder   | `nvim-telescope/telescope.nvim` (+ `fzf-native`) |
| File tree      | `nvim-neo-tree/neo-tree.nvim` |
| Git            | `gitsigns.nvim`, `diffview.nvim`, `lazygit.nvim` |
| Sessions       | `rmagatti/auto-session` |
| Editing        | `nvim-autopairs`, `Comment.nvim`, `vim-illuminate`, `indent-blankline.nvim` |
| Terminal       | `akinsho/toggleterm.nvim` |
| UI             | `craftzdog/solarized-osaka.nvim`, `nvim-web-devicons` |

**LSP servers** (auto-installed): `lua_ls`, `rust_analyzer`, `basedpyright`, `ruff`,
`ts_ls`/typescript-tools, `eslint`, `tailwindcss`, `html`, `cssls`, `ols`.

## Keymaps

Leader is `<Space>`.

### Find (Telescope)
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fs` | Fuzzy find in current file |
| `<leader>fw` | Search word under cursor (current file) |
| `<leader>fW` | Exact string search (all files) |
| `<leader>fS` | Exact search in current file |

### LSP
| Key | Action |
|-----|--------|
| `gd` / `gD` / `gt` | Definition / declaration / type definition |
| `gr` | References |
| `K` | Hover docs |
| `<leader>ca` | Code action (quick fixes) |
| `<leader>rn` | Rename symbol |
| `<leader>lf` | Format buffer (also on save) |

### Diagnostics
| Key | Action |
|-----|--------|
| `<leader>e` | Show diagnostic float |
| `[d` / `]d` | Prev / next diagnostic |
| `<leader>re` / `<leader>rd` / `<leader>rc` | Rust: explain error / render diagnostic / fly-check |

### Files, Git, Terminal
| Key | Action |
|-----|--------|
| `<C-n>` | Toggle Neo-tree |
| `<leader>gg` | LazyGit |

### Sessions
| Key | Action |
|-----|--------|
| `<leader>ss` / `sr` / `sd` / `sf` | Save / restore / delete / search sessions |

### System clipboard
| Key | Action |
|-----|--------|
| `<leader>y` / `<leader>Y` | Yank motion / line |
| `<leader>d` / `<leader>D` | Delete motion / line |
| `<leader>p` / `<leader>P` | Paste after / before |

### Misc
| Key | Action |
|-----|--------|
| `<leader>w` / `<leader>q` | Write / quit |
| `<leader>o` | Save & re-source current file |

## Notes

- Mouse is disabled (`mouse = ""`); system clipboard is used via explicit `<leader>` maps.
- `lazy-lock.json` is gitignored — plugins track their latest compatible versions.
- Update plugins with `:Lazy update`, parsers with `:TSUpdate`.
- nvim-treesitter tracks the **`main`** branch (required for Neovim 0.11+); highlighting/indent
  are enabled per-buffer via a `FileType` autocmd, not a global config table.
