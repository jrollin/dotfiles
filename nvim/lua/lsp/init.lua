local lspconfig = require('lspconfig')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach = function(client, bufnr)
  -- Keybindings for LSPs
  vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "1gD", "<cmd>lua vim.lsp.buf.type_definition()<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "g0", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "gW", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", {noremap = true, silent = true})
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
