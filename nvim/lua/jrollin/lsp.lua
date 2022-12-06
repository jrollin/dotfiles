-- lsp 
local lspconfig = require('lspconfig')
local setup_auto_format = require("jrollin.utils").setup_auto_format

setup_auto_format("rs")
setup_auto_format("js")
setup_auto_format("css")
setup_auto_format("tsx")
setup_auto_format("ts")


-- inject LSP diagnostics, code actions, and more via Lua.
require("null-ls").setup({
    sources = {
        require("null-ls").builtins.formatting.stylua,
        require("null-ls").builtins.diagnostics.eslint,
        require("null-ls").builtins.completion.spell,
    },
})


-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)

-- vim.lsp.handlers["textDocument/codeAction"] =
--   require("lsputil.codeAction").code_action_handler

 -- Setup lspconfig with cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities();

local on_attach = function(client, bufnr)
    local opts = { noremap = true }
    -- Set some keybinds conditional on server capabilities
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
    end
end


-- lsp servers
require("mason").setup()

require("mason-lspconfig").setup({
    ensure_installed = { "sumneko_lua", "html", "cssls","tailwindcss"  }
})

require("mason-lspconfig").setup_handlers({
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function (server_name) -- default handler (optional)
        require("lspconfig")[server_name].setup {
            on_attach = on_attach,
            capabilities = capabilities,
        }
    end,
    -- Next, you can provide targeted overrides for specific servers.
    ["rust_analyzer"] = function ()
        local opts = require("jrollin.rust");
        local rt = require("rust-tools")

        local on_attach_rust =  function(client, bufnr)
            -- Set some keybinds conditional on server capabilities
            if client.server_capabilities.documentFormattingProvider then
                vim.api.nvim_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", {noremap = true})
            end
            -- Hover actions
            -- vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            -- vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
        end

        opts.server = {
            on_attach = on_attach_rust,
            capabilities = capabilities,
            settings = {
                ["rust-analyzer"] = {
                    assist = {
                        importEnforceGranularity = true,
                        importPrefix = "crate"
                    },
                    checkOnSave = {
                        -- default: `cargo check`
                        command = "clippy"
                    },
                    inlayHints = {
                        lifetimeElisionHints = {
                            enable = true,
                            useParameterNames = true
                        },
                    },
                }
            }
        }
        rt.setup(opts)
    end,
    ["sumneko_lua"] = function ()
        lspconfig.sumneko_lua.setup {
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = {'vim'},
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = {
                        enable = false,
                    },
                }
            }
        }
    end,
})

