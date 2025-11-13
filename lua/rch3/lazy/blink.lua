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
            accept = { auto_insert = false },  -- Don't auto-insert, only on Enter
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
        },

        fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
}
