-- Resolve ruby-lsp from PATH so the config works on macOS (Homebrew) and Linux alike.
local ruby_lsp_bin = vim.fn.exepath("ruby-lsp")

-- Open the mpls preview for `buf`, starting the server on first use.
local function mpls_preview(name, buf)
  if vim.lsp.get_clients({ bufnr = buf, name = name })[1] then
    vim.cmd.LspMplsOpenPreview()
    return
  end
  -- attach is async, and on_attach has not created :LspMplsOpenPreview yet, so drive the client
  vim.api.nvim_create_autocmd("LspAttach", {
    once = true,
    buffer = buf,
    callback = function(ctx)
      local client = vim.lsp.get_client_by_id(ctx.data.client_id)
      if client and client.name == name then
        client:exec_cmd({ title = "Preview markdown with mpls", command = "open-preview" })
      end
    end,
  })
  vim.lsp.enable(name) -- covers markdown buffers opened from now on
  -- This buffer needs an explicit start. Not :edit, which prompts to save when modified; and
  -- lsp.start() skips root_markers, whose nil root_dir stops mpls marking links as clickable.
  local cfg = vim.lsp.config[name]
  vim.lsp.start(vim.tbl_extend("force", cfg, { root_dir = vim.fs.root(buf, cfg.root_markers) }), { bufnr = buf })
end

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
        -- Markdown preview in the browser: follows links across files, renders mermaid offline.
        -- No --port on purpose: a taken fixed port makes mpls bind nothing while still reporting
        -- a URL, so a second concurrent nvim loses its preview silently.
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
      setup = {
        -- Return true so LazyVim does not enable mpls at startup: every markdown buffer would
        -- otherwise hold a server for the life of the session. <leader>mp starts it instead.
        mpls = function(server, sopts)
          vim.lsp.config(server, sopts) -- LazyVim skips its own config() call once we return true
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            group = vim.api.nvim_create_augroup("mpls.lazy_start", { clear = true }),
            callback = function(args)
              vim.keymap.set("n", "<leader>mp", function()
                mpls_preview(server, args.buf)
              end, { buffer = args.buf, desc = "Markdown Preview" })
            end,
            desc = "mpls: bind lazy-start preview keymap",
          })
          return true
        end,
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
