return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
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
          },
        },
      },
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
}
