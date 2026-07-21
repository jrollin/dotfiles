-- Enable the following language servers
vim.lsp.enable("oxlint")

-- Resolve ruby-lsp from PATH so the config works on macOS (Homebrew) and Linux alike.
local ruby_lsp_bin = vim.fn.exepath("ruby-lsp")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Some projects pin an EOL Ruby (e.g. 2.7) that modern ruby-lsp cannot install
        -- into. Run a global ruby-lsp on modern Ruby, and point BUNDLE_GEMFILE at a stub
        -- so it never bundles the project's Ruby (which crashes on version mismatch).
        -- See README "Ruby LSP" for per-machine setup.
        ruby_lsp = {
          enabled = ruby_lsp_bin ~= "", -- skip if no ruby-lsp on PATH (e.g. fresh machine)
          cmd = { ruby_lsp_bin }, -- global ruby-lsp on modern Ruby, not the project's 2.7.8
          cmd_env = {
            BUNDLE_GEMFILE = vim.fn.expand("~/.config/ruby-lsp/Gemfile"), -- stub gemfile: skip project bundle
            RUBY_LSP_BYPASS_TYPECHECKER = "1", -- no sorbet in the stub bundle
          },
          mason = false, -- use the system binary, not a Mason-managed copy
        },
        eslint = {},
        vtsls = {
          settings = {
            typescript = {
              tsserver = {
                -- Increase memory for large files (e.g. serverless.ts with big objects)
                maxTsServerMemory = 4096,
              },
            },
          },
        },
        tsserver = {
          keys = {
            { "<leader>co", "<cmd>TypescriptOrganizeImports<CR>", desc = "Organize Imports" },
            { "<leader>cr", "<cmd>TypescriptRenameFile<CR>", desc = "Rename File" },
          },
        },
      },
    },
    setup = {
      eslint = function()
        require("lazyvim.util").lsp.on_attach(function(client)
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
          elseif client.name == "tsserver" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,
    },
  },
  -- Use conform for formatting with oxfmt
  {
    "stevearc/conform.nvim",
    opts = {
      timeout_ms = 10000,

      -- install npm i -g eslint_d
      formatters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      },
      -- formatters_by_ft = {
      --   javascript = { "oxfmt" },
      --   javascriptreact = { "oxfmt" },
      --   typescript = { "oxfmt" },
      --   typescriptreact = { "oxfmt" },
      --   json = { "oxfmt" },
      --   vue = { "oxfmt" },
      -- },
    },
  },
}
