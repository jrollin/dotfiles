return {
  "folke/trouble.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  lazy = false,
  keys = {
    -- diagnostics
    { "<leader>sd", "<Cmd>:TroubleToggle<CR>", desc = "[S]earch [D]iagnostics" },
    { "<leader>dp", vim.diagnostic.goto_prev, desc = "[D]iagnostic [P]revious" },
    { "<leader>dn", vim.diagnostic.goto_next, desc = "[D]iagnostic [N]ext" },
  },
}
