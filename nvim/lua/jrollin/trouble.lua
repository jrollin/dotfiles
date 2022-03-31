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


-- Enable type inlay hints
-- vim.cmd [[
--     autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost * lua require'lsp_extensions'.inlay_hints{ prefix = '>', highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }
-- ]]
