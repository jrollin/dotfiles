return {
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
      ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
    },
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
      menu = {
        draw = {
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(ctx)
                -- Use custom nerd font icon for mistral_codestral source
                if ctx.source_name == "mistral_codestral" then
                  return "󰭶" -- nerd font robot/AI icon
                end
                return ctx.kind_icon .. ctx.icon_gap
              end,
              highlight = "BlinkCmpKindIcon",
            },
          },
        },
      },
    },
    signature = { enabled = true },
  },
  opts_extend = { "sources.default" },
}