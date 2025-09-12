return {

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
