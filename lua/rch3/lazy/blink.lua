return {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },

    version = '1.*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = 'default',
            ['<CR>'] = { 'accept', 'fallback' },
            ['<C-y>'] = {},  -- Disable Ctrl+Y
            ['<Up>'] = { 'select_prev', 'fallback' },
            ['<Down>'] = { 'select_next', 'fallback' },
        },

        appearance = {
            nerd_font_variant = 'mono'
        },

        completion = {
            documentation = { 
                auto_show = true,  -- Show docs on hover
                auto_show_delay_ms = 200,
                window = { border = 'rounded' }
            },
            ghost_text = { enabled = false },  -- Disable preview text
            list = {
                selection = { auto_insert = false },  -- Don't auto-insert, only on Enter
                max_items = 50,  -- cap rendered items; huge lists were the render lag
            },
            menu = {
                draw = {
                    columns = {
                        { "label", "label_description", gap = 1 },
                        { "kind_icon", "kind", gap = 1 },
                    },
                    components = {
                        kind_icon = {
                            text = function(ctx)
                                return ctx.kind_icon .. ctx.icon_gap
                            end,
                            highlight = function(ctx)
                                return 'BlinkCmpKind' .. ctx.kind
                            end,
                        },
                        label = {
                            text = function(ctx)
                                return ctx.label .. ctx.label_detail
                            end,
                        },
                        kind = {
                            text = function(ctx)
                                return ctx.kind
                            end,
                        },
                    },
                },
            },
        },

        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
            providers = {
                -- rust_analyzer completion can take 300-440ms (esp. while warming up).
                -- async = don't block the menu waiting for it; fill results in when they land.
                lsp = { async = true },
                -- snippets/buffer were building huge lists on the 1st keystroke (the lag).
                -- Gate them behind a couple of chars; LSP still fires immediately.
                snippets = { min_keyword_length = 2 },
                buffer = { min_keyword_length = 3 },
            },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
}
