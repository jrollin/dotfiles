-- override
return {
  "folke/trouble.nvim",
  keys = {
    -- diagnostics
    { "<leader>dp", vim.diagnostic.goto_prev, desc = "[D]iagnostic [P]revious" },
    { "<leader>dn", vim.diagnostic.goto_next, desc = "[D]iagnostic [N]ext" },
  },
}
