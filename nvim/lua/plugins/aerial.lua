return {
    "stevearc/aerial.nvim",
    opts = {
      backends = { "treesitter", "lsp", "markdown", "man" },
    },
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false
}
