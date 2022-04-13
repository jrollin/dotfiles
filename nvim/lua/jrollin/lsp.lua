-- lsp 
local lspconfig = require('lspconfig')
local setup_auto_format = require("jrollin.utils").setup_auto_format

setup_auto_format("rs")
setup_auto_format("js")
setup_auto_format("css")
setup_auto_format("tsx")
setup_auto_format("ts")


-- local capabilities = vim.lsp.protocol.make_client_capabilities()
 -- Setup lspconfig with cmp
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- require("null-ls").config({})
-- require("lspconfig")["null-ls"].setup({})

local on_attach = function(client, bufnr)
    local opts = { noremap = true }
    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
        vim.api.nvim_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    end
    if client.resolved_capabilities.document_range_formatting then
        vim.api.nvim_set_keymap("v", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

end


-- -- HTML
-- lspconfig.html.setup{
--   on_attach = on_attach,
-- }

-- -- CSS
-- lspconfig.cssls.setup{
--   on_attach = on_attach,
--   settings = {
--       validate = false
--     },
--     less = {
--       validate = true
--     },
--     scss = {
--       validate = true
--     }
-- }

-- -- tailwind
-- lspconfig.tailwindcss.setup{
--   on_attach = on_attach,
--   settings = {
--       validate = false
--     },
--     less = {
--       validate = true
--     },
--     scss = {
--       validate = true
--     }
-- }

-- -- GO
-- lspconfig.gopls.setup{
--   on_attach = on_attach,
-- }



-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)

vim.lsp.handlers["textDocument/codeAction"] =
  require("lsputil.codeAction").code_action_handler


-- beware twice setup !
-- Lsp install
local lsp_installer = require("nvim-lsp-installer")

-- -- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
-- -- or if the server is already installed).
lsp_installer.on_server_ready(function(server)
    local opts = {
     on_attach = on_attach,   
    }

    -- (optional) Customize the options passed to the server
    -- if server.name == "tsserver" then
    --     opts.root_dir = function() ... end
    -- end

    -- This setup() function will take the provided server configuration and decorate it with the necessary properties
    -- before passing it onwards to lspconfig.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(opts)
end)
