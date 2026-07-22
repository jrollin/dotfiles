return {

  -- add more treesitter parsers without replaceing existing
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        -- common
        "lua",
        "markdown",
        "markdown_inline",
        "yaml",
        "diff",
        --  lang
        "rust",
      })
    end,
  },
}
