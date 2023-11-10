local config = function()
  local custom_gruvbox = require("lualine.themes.gruvbox_dark")
  -- Change the background of lualine_c section for normal mode
  -- custom_gruvbox.normal.c.bg = '#112233'
  require("lualine").setup({
    options = { theme = custom_gruvbox },
    extensions = { "man", "nvim-tree", "fugitive", "nvim-dap-ui", "trouble", "fzf", "lazy" },
    sections = {
      lualine_a = {
        {
          "mode",
          fmt = function(str)
            return str:sub(1, 1)
          end,
        },
        "buffers",
      },
      -- add progress status extension to left
      lualine_c = {
        "filename",
        "lsp_progress",
      },
    },
  })
  -- colorscheme gruvbox
  vim.o.background = "dark" -- or "light" for light mode
  vim.cmd([[colorscheme gruvbox]])
  vim.g.gruvbox_contrast_dark = "hard"
  vim.g.gruvbox_contrast_light = "soft"
end

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "gruvbox-community/gruvbox",
  },
  lazy = false,
  config = config,
}
