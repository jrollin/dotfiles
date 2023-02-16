-- lsp
local lspconfig = require("lspconfig")

local function setup_auto_format(ft, command)
    if not command then
        command = "lua vim.lsp.buf.format()"
    end
    vim.cmd(string.format("autocmd BufWritePre *.%s %s", ft, command))
end

setup_auto_format("lua")
setup_auto_format("rs")
setup_auto_format("js")
setup_auto_format("css")
setup_auto_format("tsx")
setup_auto_format("ts")
setup_auto_format("elm")

-- inject LSP diagnostics, code actions, and more via Lua.
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.elm_format,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.completion.luasnip,
    },
})

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
})

-- vim.lsp.handlers["textDocument/codeAction"] =
--   require("lsputil.codeAction").code_action_handler

-- Setup lspconfig with cmp
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

    -- Keybindings for LSPs
    nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
    nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
    nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

    -- See `:help K` for why this keymap
    nmap("K", vim.lsp.buf.hover, "Hover Documentation")
    nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

    -- Lsp actions
    nmap("<leader>r", vim.lsp.buf.rename, "[R]ename")
    nmap("<leader>a", vim.lsp.buf.code_action, "[A]ction")
    vmap("<leader>a", vim.lsp.buf.range_code_action, "Range [A]ction")

    nmap("<leader>cl", vim.lsp.codelens.run, "[C]ode [L]ens ")
    nmap("<leader>cr", vim.lsp.codelens.refresh, "[C]ode Lens [R]efresh")
    --
    -- Lsp rust actions
    nmap("<leader>rr", "<cmd>RustRunnables<CR>", "[R]ust [R]unnables")
    nmap("<leader>rd", "<cmd>RustDebuggables<CR>", "[R]ust [D]ebuggables")
    nmap("<leader>rh", "<cmd>RustHoverActions<CR>", "[R]ust [H]over Actions")

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        vim.lsp.buf.format()
    end, { desc = "Format current buffer with LSP" })

    if client.server_capabilities.documentFormattingProvider then
        nmap("<leader>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>")
    end
end

-- lsp servers
require("mason").setup()

require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "html", "cssls", "tailwindcss", "rust_analyzer", "elmls" },
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
        local opts = require("jrollin.rust")
        local rt = require("rust-tools")

        opts.server = {
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
        rt.setup(opts)
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
