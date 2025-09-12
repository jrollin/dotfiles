return {
  dir = vim.fn.stdpath("config") .. "/lua/mistral-codestral",
  name = "mistral-codestral.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
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
      debug = false, -- Set to true to enable debug logging
      -- Virtual text configuration for inline AI suggestions
      virtual_text = {
        enabled = true,
        manual = false,
        idle_delay = 800, -- Increased from 200ms to 800ms for less intrusive suggestions
        min_chars = 3, -- Require at least 3 characters before showing suggestions
        key_bindings = {
          accept = "<Tab>",
          accept_word = "<C-Right>",
          accept_line = "<C-Down>",
          clear = "<C-c>",
        },
      },
      -- Buffer and filetype exclusions
      exclusions = {
        -- Additional filetypes to disable (neo-tree and other common plugins)
        filetypes = {
          "neo-tree",
          "neo-tree-popup", 
          "help",
          "alpha",
          "dashboard",
          "nvim-tree",
          "trouble",
          "lspinfo",
          "mason",
          "lazy",
          "TelescopePrompt",
          "TelescopeResults",
        },
        -- Buffer patterns to exclude
        buffer_patterns = {
          "^neo%-tree",
          "^NvimTree",
          "^%[Scratch%]",
        },
        -- Buffer types to exclude
        buftypes = {
          "help",
          "nofile",
          "quickfix", 
          "terminal",
          "prompt",
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
