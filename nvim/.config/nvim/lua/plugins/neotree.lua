return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>o",
        function()
          require("neo-tree.command").execute({ action = "focus", reveal = true, dir = LazyVim.root() })
        end,
        desc = "Reveal current file in NeoTree + focus",
      },
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
          hide_by_name = {},
          never_show = {},
        },
      },
    },
  },
}