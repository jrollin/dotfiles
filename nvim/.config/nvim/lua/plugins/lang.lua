return {

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = "lazyvim.plugins.extras.lang.json" },

  -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  { import = "lazyvim.plugins.extras.lang.typescript" },

  -- ruby_lsp, rubocop formatter, treesitter and neotest-rspec
  { import = "lazyvim.plugins.extras.lang.ruby" },

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
