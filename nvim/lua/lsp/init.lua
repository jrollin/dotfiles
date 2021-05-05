local lspconfig = require('lspconfig')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach = function(client, bufnr)
    local function map(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local opts = {noremap = true, silent = true } 
    -- Keybindings for LSPs
    map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    map("n", "<space>gd", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    map("n", "<space>cr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    map("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)


    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
        map("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    end
    if client.resolved_capabilities.document_range_formatting then
        map("v", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

    vim.cmd("setlocal omnifunc=v:lua.vim.lsp.omnifunc")  
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


-- Enable rust_analyzer
lspconfig.rust_analyzer.setup{
    capabilities=capabilities,
    on_attach=on_attach,
}

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = true,
    update_in_insert = true,
  }
)
