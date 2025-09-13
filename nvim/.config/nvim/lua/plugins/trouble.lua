-- override
return {
  "folke/trouble.nvim",
  keys = {
    -- diagnostics
    {
      "<leader>dp",
      function()
        vim.diagnostic.jump({ count = -1, float = true })
      end,
      desc = "[D]iagnostic [P]revious",
    },
    {
      "<leader>dn",
      function()
        vim.diagnostic.jump({ count = 1, float = true })
      end,
      desc = "[D]iagnostic [N]ext",
    },
  },
}
