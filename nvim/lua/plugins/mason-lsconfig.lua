local config = function()
  local lspconfig = require("lspconfig")
  local function setup_auto_format(ft, command)
    if not command then
      command = "lua vim.lsp.buf.format()"
    end
    vim.cmd(string.format("autocmd BufWritePre *.%s %s", ft, command))
  end

  setup_auto_format("rs")
  setup_auto_format("js")
  setup_auto_format("css")
  setup_auto_format("tsx")
  setup_auto_format("ts")

  -- Enable diagnostics
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  })

  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  local on_attach = function(client, bufnr)
    local nmap = function(keys, func, desc)
      if desc then
        desc = "LSP: " .. desc
      end
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end

    local vmap = function(keys, func, desc)
      if desc then
        desc = "LSP: " .. desc
      end
      vim.keymap.set("v", keys, func, { buffer = bufnr, desc = desc })
    end

    local imap = function(keys, func, desc)
      if desc then
        desc = "LSP: " .. desc
      end
      vim.keymap.set("i", keys, func, { buffer = bufnr, desc = desc })
    end

    -- Keybindings for LSPs
    nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
    nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    nmap("<leader>td", vim.lsp.buf.type_definition, "[T]ype [D]efinition")
    -- nmap("<leader>s", require("telescope.builtin").lsp_document_symbols, "Document [S]ymbols")
    nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

    -- See `:help K` for why this keymap
    nmap("K", vim.lsp.buf.hover, "Hover Documentation")
    nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
    imap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

    -- Lsp actions
    nmap("<leader>r", vim.lsp.buf.rename, "[R]ename")
    nmap("<leader>a", vim.lsp.buf.code_action, "[A]ction")
    vmap("<leader>a", vim.lsp.buf.range_code_action, "Range [A]ction")

    nmap("<leader>ll", vim.lsp.codelens.run, "Code [L]ens ")
    nmap("<leader>lr", vim.lsp.codelens.refresh, "Code [L]ens [R]efresh")

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
      vim.lsp.buf.format()
    end, { desc = "Format current buffer with LSP" })

    if client.server_capabilities.documentFormattingProvider then
      nmap("<leader>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>")
    end
  end

  require("mason").setup()
  require("mason-lspconfig").setup({
    -- list of servers for mason to install
    ensure_installed = {
      "tsserver",
      "html",
      "cssls",
      "tailwindcss",
      "lua_ls",
      "pyright",
      "rust_analyzer",
    },
    -- auto-install configured servers (with lspconfig)
    automatic_installation = true, -- not the same as ensure_installed
  })

  require("mason-tool-installer").setup({
    ensure_installed = {
      -- formatter
      "prettier", -- prettier formatter
      "stylua", -- lua formatter
      "isort", -- python formatter
      "black", -- python formatter
      -- linter
      "pylint", -- python linter
      "eslint_d", -- js linter
    },
  })

  require("mason-lspconfig").setup_handlers({
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function(server_name) -- default handler (optional)
      require("lspconfig")[server_name].setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end,
    -- Next, you can provide targeted overrides for specific servers.
    ["rust_analyzer"] = function()
      local rt = require("rust-tools")
      local rustopts = require("jrollin.lsp.rust")
      -- override
      rustopts.server = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            assist = {
              importEnforceGranularity = true,
              importPrefix = "crate",
            },
            checkOnSave = {
              -- default: `cargo check`
              command = "clippy",
            },
            inlayHints = {
              lifetimeElisionHints = {
                enable = true,
                useParameterNames = true,
              },
            },
          },
        },
      }
      rt.setup(rustopts)
    end,
    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = "LuaJIT",
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { "vim" },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
          },
        },
      })
    end,
  })
end

return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "simrat39/rust-tools.nvim",
  },
  config = config,
  lazy = false,
}
