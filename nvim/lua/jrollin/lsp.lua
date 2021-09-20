require("trouble").setup {
    icons = false,
    fold_open = "v", -- icon used for open folds
    fold_closed = ">", -- icon used for closed folds
    indent_lines = false, -- add an indent guide below the fold icons
    signs = {
        -- icons / text used for a diagnostic
        error = "error",
        warning = "warn",
        hint = "hint",
        information = "info"
    },
    use_lsp_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
}
local options =  {silent = true, noremap = true};
vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>LspTroubleToggle<cr>",options)
vim.api.nvim_set_keymap("n", "<leader>xw", "<cmd>LspTroubleToggle lsp_workspace_diagnostics<cr>", options)
vim.api.nvim_set_keymap("n", "<leader>xd", "<cmd>LspTroubleToggle lsp_document_diagnostics<cr>", options)
vim.api.nvim_set_keymap("n", "<leader>xl", "<cmd>LspTroubleToggle loclist<cr>", options)
vim.api.nvim_set_keymap("n", "<leader>xq", "<cmd>LspTroubleToggle quickfix<cr>", options)
vim.api.nvim_set_keymap("n", "<leader>xr", "<cmd>LspTroubleRefresh<cr>", options)
-- override 
vim.api.nvim_set_keymap("n", "gd", "<cmd>LspTrouble lsp_definitions<cr>", options)
vim.api.nvim_set_keymap("n", "gr", "<cmd>LspTrouble lsp_references<cr>", options)

-- Enable type inlay hints
vim.cmd [[
    autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost * lua require'lsp_extensions'.inlay_hints{ prefix = '>', highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }
]]

-- git changes annotations
require('gitsigns').setup()




local lspconfig = require('lspconfig')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Code actions
capabilities.textDocument.codeAction = {
    dynamicRegistration = true,
    codeActionLiteralSupport = {
        codeActionKind = {
            valueSet = (function()
                local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
                table.sort(res)
                return res
            end)()
        }
    }
}

-- enable auto-import

capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }
}

local on_attach = function(client, bufnr)
    local function map(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local opts = {noremap = true, silent = true } 
    -- Keybindings for LSPs
    map("n", "<space>gd", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    -- overriden by lsp trouble plugin
    --map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    --map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    map("n", "<space>r", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    map("n", "<space>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)

    map("n", "gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
    map("n", "gs", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)


    -- rust : TODO only map on rust 
    map("n", "<space>cb", "<cmd>:Cbuild<CR>", opts)
    map("n", "<space>ct", "<cmd>:Ctest<CR>", opts)
    map("n", "<space>cr", "<cmd>:Crun<CR>", opts)
    map("n", "<space>rr", "<cmd>:RustRun<CR>", opts)
    map("n", "<space>rt", "<cmd>:RustTest<CR>", opts)


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
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
