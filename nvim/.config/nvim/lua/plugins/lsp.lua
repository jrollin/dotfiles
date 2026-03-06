-- Enable the following language servers
vim.lsp.enable("oxlint")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
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
