return {
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = {
      "rafamadriz/friendly-snippets",
      "nvim-tree/nvim-web-devicons",
    },
    version = "1.*",
    opts = {
      keymap = {
        preset = "default",
        -- Add Tab acceptance to the default preset
        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          mistral_codestral = {
            name = "mistral_codestral",
            module = "mistral-codestral.blink",
            enabled = true,
            async = true,
            timeout_ms = 2000,
            max_items = 1,
            min_keyword_length = 3,
            score_offset = -50,
          },
        },
      },
      completion = {
        accept = {
          auto_brackets = { enabled = true },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = vim.g.ai_cmp,
        },
        menu = {
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  if ctx.source_name == "mistral_codestral" then
                    return "󰭶"
                  end
                  return ctx.kind_icon .. ctx.icon_gap
                end,
                highlight = "BlinkCmpKindIcon",
              },
            },
          },
        },
      },
      -- fuzzy = { implementation = "lua" },
      --fuzzy = { implementation = "prefer_rust_with_warning" },

      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
}
