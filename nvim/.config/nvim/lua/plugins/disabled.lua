return {
  -- unused colorschemes shipped by LazyVim core (dracula is the active one)
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
  -- markview.nvim renders markdown instead
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false,
  },
  -- no markdown linting (markdownlint-cli2 runs via nvim-lint, not as a plugin)
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      if opts.linters_by_ft then
        opts.linters_by_ft.markdown = nil
      end
    end,
  },
}
