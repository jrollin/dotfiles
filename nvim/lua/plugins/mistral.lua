return {
  dir = vim.fn.stdpath("config") .. "/lua/mistral-codestral",
  name = "mistral-codestral.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Choose ONE completion engine:
    -- "hrsh7th/nvim-cmp", -- Traditional & mature
    -- OR
    "saghen/blink.cmp", -- Fast & modern
  },
  lazy = false,
  priority = 1000,
  config = function()
    local ok, mistral = pcall(require, "mistral-codestral")
    if not ok then
      vim.notify("Failed to load mistral-codestral", vim.log.levels.ERROR)
      return
    end

    local setup_ok, err = pcall(mistral.setup, {
      api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
      model = "codestral-latest",
      max_tokens = 256,
      enable_cmp_source = true,
      completion_engine = "blink.cmp",
      -- Virtual text configuration for inline AI suggestions
      virtual_text = {
        enabled = true,
        manual = false,
        idle_delay = 200,
        key_bindings = {
          accept = "<Tab>",
          accept_word = "<C-Right>",
          accept_line = "<C-Down>",
          clear = "<C-c>",
        },
      },
    })

    if not setup_ok then
      vim.notify("Mistral setup failed: " .. tostring(err), vim.log.levels.ERROR)
    else
      vim.notify("Mistral Codestral loaded successfully", vim.log.levels.INFO)
    end
  end,

  keys = {
    { "<leader>mc", "<cmd>MistralCodestralComplete<cr>", desc = "Mistral Complete" },
    { "<leader>ma", "<cmd>MistralCodestralAuth status<cr>", desc = "Auth Status" },
  },
}
