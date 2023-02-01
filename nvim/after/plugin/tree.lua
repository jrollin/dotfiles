require("nvim-tree").setup({})

local function open_nvim_tree()
    -- open the tree
    require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
