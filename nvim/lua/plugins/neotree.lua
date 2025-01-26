return {
  -- override keys
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      { "<C-f>", "<cmd>Neotree reveal left<CR>", desc = "Reveal file in tree" },
    },
  },
}
