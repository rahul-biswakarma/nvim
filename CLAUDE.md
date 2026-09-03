# CLAUDE.md — Neovim config

Personal Neovim config. Keep it **minimal, fast, and effortless** — lean, but with
quality-of-life defaults so editing is painless. No over-engineering, no plugin for
what a few lines can do.

## Layout
- `init.lua` → `require("rch3")`
- `lua/rch3/init.lua` — leader, loads config modules, colorscheme
- `lua/rch3/config/` — `lazy.lua` (bootstrap), `keymap.lua`, `options.lua`, `metrics.lua`
- `lua/rch3/lazy/` — one file per plugin, returned as a lazy.nvim spec (`spec = "rch3.lazy"`)

Stack: lazy.nvim · blink.cmp · rustaceanvim · conform · nvim-treesitter · telescope · neo-tree · mason-lspconfig.

## Working here
- **Diagnose from data, not guesses.** Perf/UX issues → read the logs first (see Metrics below).
- Verify a change loads: `nvim --headless -c 'qa'` (exit 0 = clean).
- Startup is ~85ms — already fast. Don't "optimize" startup.
- Respect deliberate choices, don't revert them: `mouse = ""`, explicit `<leader>y/p`
  system-clipboard maps (no `clipboard=unnamedplus`), `swapfile = false`.
- When adding options/keymaps, group + comment them so they're easy to revert.

## Metrics / logging (temporary, diagnostic)
`lua/rch3/config/metrics.lua` logs to stdpath("log"):
- `cmp-lag.log` — completion timing (source fetch vs render) per keystroke
- `usage.log` — startup time + every `:command` typed by hand
- `errors.log` — warnings/errors via `vim.notify` (LSP, plugins, diagnostics); `lsp.log` for LSP protocol errors
- `:Metrics` — summary (last startup, most-typed commands, slowest completions, recent errors)

**Clean up when perf is confirmed stable:** delete `metrics.lua`, remove its `require`
and the `vim.g.nvim_start_ns` line from `lua/rch3/init.lua`. It does small per-keystroke
file I/O; keep it only while actively tuning.

## Memory
Persistent notes for Claude live in the session memory dir (indexed by `MEMORY.md` there):
`nvim-completion-perf`, `user-config-style`. **Update them** when config decisions change
— e.g. once the metrics logging is removed, update `nvim-completion-perf`. Record *why*
a change was made and *when to undo it*, not just what changed.
