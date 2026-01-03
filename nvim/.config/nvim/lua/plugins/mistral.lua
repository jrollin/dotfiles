return {
  "jrollin/mistral-codestral.nvim",
  lazy = false,
  priority = 1000,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    require("mistral-codestral").setup({
      api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
    })
  end,

  keys = {
    { "<leader>mc", "<cmd>MistralCodestralComplete<cr>", desc = "Mistral Complete" },
    { "<leader>ma", "<cmd>MistralCodestralAuth status<cr>", desc = "Auth Status" },
  },
}
