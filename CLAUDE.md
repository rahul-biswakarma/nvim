# CLAUDE.md — Neovim config

Personal Neovim config. Keep it **minimal, fast, and effortless** — lean, but with
quality-of-life defaults so editing is painless. No over-engineering, no plugin for
what a few lines can do.

## Layout
- `init.lua` → `require("rch3")`
- `lua/rch3/init.lua` — leader, loads config modules, colorscheme
- `lua/rch3/config/` — `lazy.lua` (bootstrap), `keymap.lua`, `options.lua`, `lsp.lua`
- `lua/rch3/lazy/` — one file per plugin, returned as a lazy.nvim spec (`spec = "rch3.lazy"`)

Stack: lazy.nvim · blink.cmp · rustaceanvim · conform · nvim-treesitter · telescope · neo-tree · mason-lspconfig.

## Working here
- **Diagnose from data, not guesses.** Use focused profiling for perf/UX issues.
- Verify a change loads: `nvim --headless -c 'qa'` (exit 0 = clean).
- Startup is ~85ms — already fast. Don't "optimize" startup.
- Respect deliberate choices, don't revert them: `mouse = ""`, explicit `<leader>y/p`
  system-clipboard maps (no `clipboard=unnamedplus`), `swapfile = false`.
- When adding options/keymaps, group + comment them so they're easy to revert.

## Memory
Persistent notes for Claude live in the session memory dir (indexed by `MEMORY.md` there):
`nvim-completion-perf`, `user-config-style`. Record *why* a change was made, not just
what changed.
