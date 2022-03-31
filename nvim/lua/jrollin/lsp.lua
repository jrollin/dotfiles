-- lsp 
local lspconfig = require('lspconfig')
local setup_auto_format = require("jrollin.utils").setup_auto_format

setup_auto_format("rs")
setup_auto_format("js")
setup_auto_format("css")
setup_auto_format("tsx")
setup_auto_format("ts")


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- require("null-ls").config({})
-- require("lspconfig")["null-ls"].setup({})

local on_attach = function(client, bufnr)

    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
        map("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    end
    if client.resolved_capabilities.document_range_formatting then
        map("v", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

    -- vim.cmd("setlocal omnifunc=v:lua.vim.lsp.omnifunc")  
end

-- typescript
lspconfig.tsserver.setup{
    capabilities=capabilities,
    on_attach = on_attach,
}

-- HTML
lspconfig.html.setup{
  on_attach = on_attach,
}

-- CSS
lspconfig.cssls.setup{
  on_attach = on_attach,
  settings = {
      validate = false
    },
    less = {
      validate = true
    },
    scss = {
      validate = true
    }
}

-- GO
lspconfig.gopls.setup{
  on_attach = on_attach,
}



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
