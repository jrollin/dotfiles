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
        {
          "buffers",
          show_filename_only = true, -- Shows shortened relative path when set to false.
          hide_filename_extension = false, -- Hide filename extension when set to true.
          show_modified_status = true, -- Shows indicator when the buffer is modified.

          mode = 0, -- 0: Shows buffer name
          -- 1: Shows buffer index
          -- 2: Shows buffer name + buffer index
          -- 3: Shows buffer number
          -- 4: Shows buffer name + buffer number

          max_length = vim.o.columns * 2 / 3, -- Maximum width of buffers component,
          -- it can also be a function that returns
          -- the value of `max_length` dynamically.
        },
      },
      -- add progress status extension to left
      lualine_c = {
        { "filename", path = 4 },
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
