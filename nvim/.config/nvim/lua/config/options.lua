-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
--
vim.g.snacks_animate = false

vim.g.lazyvim_cmp = "blink.cmp"

vim.opt.relativenumber = false -- Relative line numbers

-- AI : avante
-- views can only be fully collapsed with the global statusline
-- vim.opt.laststatus = 3

vim.opt.cursorline = false -- Enable highlighting of the current line

-- hide codeb rendering (ex: markdown codeblock)
-- vim.opt.conceallevel = 0
--
--

-- spell check
-- vim.opt_local.spell = false
vim.opt.spelllang = { "en", "fr" }
