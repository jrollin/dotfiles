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
        oxlint = {
          mason = false, -- use the project/global oxc_language_server, not a Mason copy
        },
        -- Markdown preview in the browser: follows links across files, renders mermaid offline
        mpls = {
          cmd = { "mpls", "--no-auto", "--theme", "dark" },
          root_markers = { ".marksman.toml", ".git" },
          on_attach = function(client, bufnr)
            -- the preview follows the focused buffer, which is what makes cross-file navigation work
            vim.api.nvim_create_autocmd("BufEnter", {
              pattern = { "*.md" },
              -- per-client group: a shared name would let each new buffer's attach clear the previous one
              group = vim.api.nvim_create_augroup("mpls.focus." .. client.id, { clear = true }),
              callback = function(ctx)
                -- mpls resolves the focused doc by URI; ctx.match is a plain path and gets dropped
                if not client:is_stopped() then
                  client:notify("mpls/editorDidChangeFocus", { uri = vim.uri_from_fname(ctx.file) })
                end
              end,
              desc = "mpls: notify buffer focus changed",
            })
            vim.api.nvim_buf_create_user_command(bufnr, "LspMplsOpenPreview", function()
              client:exec_cmd({ title = "Preview markdown with mpls", command = "open-preview" })
            end, { desc = "Preview markdown with mpls" })
            vim.keymap.set("n", "<leader>mp", "<cmd>LspMplsOpenPreview<cr>", {
              buffer = bufnr,
              desc = "Markdown Preview",
            })
          end,
        },
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
      },
    },
  },
  -- Ruby extra wants erb-formatter/erb-lint, but mason installs gems through the
  -- rbenv shim: in EOL-Ruby projects (2.7) the install fails and retries every start
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(p)
        return p ~= "erb-lint" and p ~= "erb-formatter"
      end, opts.ensure_installed or {})
    end,
  },
  -- Use conform for formatting with oxfmt
  {
    "stevearc/conform.nvim",
    opts = {
      -- eslint_d on large files needs more than conform's 3s default
      default_format_opts = {
        timeout_ms = 10000,
      },

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
