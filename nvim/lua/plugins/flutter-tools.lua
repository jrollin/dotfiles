return   {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select

    },
    config = function () 
        require("flutter-tools").setup({})
        require("telescope").load_extension("flutter")
    end
  }

