vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.g.mapleader = " "

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- enable highlight groups
vim.opt.termguicolors = true

-- auto change directory to current file
vim.opt.autochdir = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.colorcolumn = "80"
vim.opt.signcolumn = "yes"

vim.opt.relativenumber = false
vim.opt.nu = true

vim.opt.wrap = false
vim.opt.smartcase = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.hidden = true -- Required to keep multiple buffers open multiple buffers

-- " Always show statusline.
vim.opt.laststatus = 2
-- Show last command in the status line.
vim.opt.showcmd = true

vim.opt.updatetime = 600 --Faster completion
vim.opt.timeoutlen = 600 --By default timeoutlen is 1000 ms

vim.opt.clipboard = "unnamedplus" --Copy paste between vim and everything else

vim.opt.scrolloff = 8

-- rust format on saveo
vim.g.rustfmt_autosave = 1

--  have a fixed column for the diagnostics to appear in
--  this removes the jitter when warnings/errors flow in
vim.opt.signcolumn = "yes"

-- Set updatetime for CursorHold
-- 300ms of no cursor movement to trigger CursorHold
vim.opt.updatetime = 300

-- show more hidden characters
-- also, show tabs nicer
vim.opt.listchars = "tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•"

--  Treesitter conf
-- highlight link TSConstBuiltin Constant
-- highlight link TSFuncBuiltin FuncBuiltIn

-- Don't pass messages to |ins-completion-menu|.
vim.opt.shortmess:append("c")
