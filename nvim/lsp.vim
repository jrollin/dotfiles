" LSP config, in lua
lua require("lsp")

" diagnostics
lua << EOF
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
--
vim.api.nvim_set_keymap("n", "gR", "<cmd>LspTrouble lsp_references<cr>", options)
EOF


" Show diagnostic popup on cursor hover
autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

" Enable type inlay hints
autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
\ lua require'lsp_extensions'.inlay_hints{ prefix = '>', highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }

