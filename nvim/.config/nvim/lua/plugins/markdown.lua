-- markdown-preview.nvim is unmaintained since 2023 and vendored mermaid 10.2.3, which needed a
-- build hook to overwrite. Replaced by mpls (see plugins/lsp.lua): it renders mermaid offline and
-- follows links across files, so the vendored-mermaid workaround is no longer needed.
return {

  { "iamcco/markdown-preview.nvim", enabled = false },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    -- For `nvim-treesitter` users.
    priority = 49,
    opts = {},
    config = function()
      local presets = require("markview.presets")
      local glow = presets.headings.glow
      -- override
      glow.shift_width = 0

      require("markview").setup({
        preview = {
          filetypes = { "markdown", "codecompanion", "avante" },
          ignore_buftypes = {},
        },
        markdown = {
          headings = glow,
          code_blocks = {
            enable = false,
          },
        },
      })
    end,
  },
}
