return {
  -- use code companion for mistral / copilot
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- extensions
      "ravitemer/mcphub.nvim",
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          mistral = function()
            return require("codecompanion.adapters").extend("mistral", {
              env = {
                api_key = "cmd:head -n1 ~/.mistral_key | tr -d '\\n'",
                url = "https://api.mistral.ai",
              },
              schema = {
                model = {
                  default = "codestral-latest",
                },
              },
            })
          end,

          codestral = function()
            return require("codecompanion.adapters").extend("mistral", {
              env = {
                api_key = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
                url = "https://codestral.mistral.ai",
              },
              schema = {
                model = {
                  -- default = "codestral-latest",
                  default = "mistral-large-latest",
                },
              },
            })
          end,
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "cmd:head -n1 ~/.claude_api_key | tr -d '\\n'",
              },
            })
          end,
        },
        strategies = {
          chat = {
            adapter = "mistral",
            keymaps = {
              close = {
                -- override to avoid mistyping with default <C-c>
                modes = { n = "<C-q>", i = "<C-q>" },
                opts = {},
              },
            },
          },
          inline = {
            adapter = "mistral",
          },
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              make_vars = true,
              make_slash_commands = true,
              show_result_in_chat = true,
            },
          },
        },
      })
    end,
    keys = {
      {
        "<leader>aa",
        "<cmd>CodeCompanionActions<CR>",
        mode = { "n", "v" },
        desc = "Code companion actions",
      },
      { "<leader>ac", "<cmd>CodeCompanionChat toggle<CR>", mode = { "n", "v" }, desc = "Code companion chat" },
      { "<leader>al", "<cmd>CodeCompanionChat add<CR>", mode = { "v" }, desc = "Code companion addd to chat" },
    },
  },
  -- cleaner diff when using the inline assistant
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
    end,
  },
  -- render markdown in code companion
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "codecompanion" },
  },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    -- For `nvim-treesitter` users.
    priority = 49,
    opts = {
      preview = {
        filetypes = { "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },

  -- alternative ai :
  -- avante plugin

  -- FIX in avante lib : openai.lua
  -- do not match codestral
  -- function M.is_mistral(url) return url:match("^https://(api|codestral)%.mistral%.ai/") end

  --
  -- {
  --   "yetone/avante.nvim",
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   -- ⚠️ must add this setting! ! !
  --   -- build = vim.fn.has("win32") and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
  --   -- or "make",
  --   event = "VeryLazy",
  --   version = false, -- Never set this value to "*"! Never!
  --   opts = {
  --     -- add any opts here
  --     -- for example
  --     provider = "mistral",
  --     -- You might also need to disable streaming entirely
  --     providers = {
  --       claude = {
  --         endpoint = "https://api.anthropic.com",
  --         model = "claude-sonnet-4-20250514",
  --         timeout = 30000, -- Timeout in milliseconds
  --         extra_request_body = {
  --           temperature = 0.75,
  --           max_tokens = 20480,
  --         },
  --       },
  --       mistral = {
  --         __inherited_from = "openai",
  --         -- api_key_name = "MISTRAL_API_KEY",
  --         api_key_name = "cmd:head -n1 ~/.mistral_key | tr -d '\\n'",
  --         endpoint = "https://api.mistral.ai/v1",
  --         model = "mistral-large-latest",
  --         extra_request_body = {
  --           max_tokens = 4096, -- to avoid using max_completion_tokens
  --         },
  --       },
  --       codestral = {
  --         __inherited_from = "openai",
  --         -- api_key_name = "CODESTRAL_API_KEY",
  --         api_key_name = "cmd:head -n1 ~/.mistral_codestral_key | tr -d '\\n'",
  --         -- endpoint = "https://codestral.mistral.ai",
  --         endpoint = "https://codestral.mistral.ai/v1", -- URi is concatened
  --         model = "codestral-latest",
  --         -- disable_tools = true, -- disable tools!
  --         extra_request_body = {
  --           max_tokens = 4096, -- to avoid using max_completion_tokens
  --         },
  --       },
  --       -- ok
  --       --  curl --location 'https://codestral.mistral.ai/v1/fim/completions' \
  --       --     --header 'Content-Type: application/json' \
  --       --     --header 'Accept: application/json' \
  --       --     --header "Authorization: Bearer $CODESTRAL_API_KEY" \
  --       --     --data '{
  --       --     "model": "codestral-latest",
  --       --     "prompt": "def f(",
  --       --     "suffix": "return a + b",
  --       --     "max_tokens": 64,
  --       --     "temperature": 0
  --       -- }' | jq .
  --     },
  --   },
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     --- The below dependencies are optional,
  --     -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
  --     -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
  --     -- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
  --     -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
  --     -- "stevearc/dressing.nvim", -- for input provider dressing
  --     -- "folke/snacks.nvim", -- for input provider snacks
  --     -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  --     -- "zbirenbaum/copilot.lua", -- for providers='copilot'
  --     -- {
  --     --   -- support for image pasting
  --     --   "HakonHarnes/img-clip.nvim",
  --     --   event = "VeryLazy",
  --     --   opts = {
  --     --     -- recommended settings
  --     --     default = {
  --     --       embed_image_as_base64 = false,
  --     --       prompt_for_file_name = false,
  --     --       drag_and_drop = {
  --     --         insert_mode = true,
  --     --       },
  --     --       -- required for Windows users
  --     --       use_absolute_path = true,
  --     --     },
  --     --   },
  --     -- },
  --     {
  --       -- Make sure to set this up properly if you have lazy=true
  --       "MeanderingProgrammer/render-markdown.nvim",
  --       opts = {
  --         file_types = { "Avante" },
  --       },
  --       ft = { "Avante" },
  --     },
  --   },
  -- },
}
