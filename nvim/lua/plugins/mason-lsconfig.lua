local config = function()
  local lspconfig = require("lspconfig")
  local function setup_auto_format(ft, command)
    if not command then
      command = "lua vim.lsp.buf.format()"
    end
    vim.cmd(string.format("autocmd BufWritePre *.%s %s", ft, command))
  end

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
    -- lsp keymap
    require("jrollin.utils").lsp_keymap(bufnr)
    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
      vim.lsp.buf.format()
    end, { desc = "Format current buffer with LSP" })

    if client.server_capabilities.documentFormattingProvider then
      vim.keymap.set("n", "<leader>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>")
    end
  end

  require("mason").setup()
  require("mason-lspconfig").setup({
    -- list of servers for mason to install
    ensure_installed = {
      "ts_ls",
      "html",
      "cssls",
      "tailwindcss",
      "lua_ls",
      -- python
      "pyright",
      -- "rust_analyzer", -- managed by plugin rustaceannvim
    },
    -- auto-install configured servers (with lspconfig)
    automatic_installation = true, -- not the same as ensure_installed
  })

  require("mason-tool-installer").setup({
    ensure_installed = {
      -- formatter
      "prettier",
      -- javascript linter
      "eslint_d",
      -- lua
      -- lua formatter
      "stylua",
      -- python
      -- python formatter
      "isort",
      "black",
      -- python linter
      "pylint",
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

  --[[ vim.g.rustaceanvim = {
    server = {
      cmd = function()
        local mason_registry = require("mason-registry")
        local ra_binary = mason_registry.is_installed("rust-analyzer")
            -- This may need to be tweaked, depending on the operating system.
            and mason_registry.get_package("rust-analyzer"):get_install_path() .. "/rust-analyzer"
          or "rust-analyzer"
        return { ra_binary } -- You can add args to the list, such as '--log-file'
      end,

      on_attach = on_attach,
      capabilities = capabilities,
    },
  } ]]
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
