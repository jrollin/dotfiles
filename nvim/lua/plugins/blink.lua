return {
  "saghen/blink.cmp",
  lazy = false,
  dependencies = "rafamadriz/friendly-snippets",
  version = "1.*",
  opts = {
    keymap = { preset = "default" },
    sources = {
      default = { "lsp", "path", "snippets", "mistral_codestral", "buffer" },
      providers = {
        mistral_codestral = {
          name = "mistral_codestral",
          module = "mistral-codestral.blink",
          enabled = true,
          async = true,
          timeout_ms = 2000, -- Reduced from 5000ms
          max_items = 1, -- Reduced from 3 to limit dominance
          min_keyword_length = 3, -- Increased to be more selective
          score_offset = -50, -- Negative to lower priority vs LSP
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
    },
    signature = { enabled = true },
  },
  opts_extend = { "sources.default" },
}