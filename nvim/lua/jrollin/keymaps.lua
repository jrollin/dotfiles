-- Save a file with leader-w.
vim.keymap.set("n", "<leader>w", ":w<CR>")

-- real delete, not cut, paste to void register
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("x", "<leader>d", '"_d')
vim.keymap.set("x", "<leader>p", '"_dP')

-- copy to system clipboard (thx to + register)
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- always center when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- disable annoying pageDown/pageUp tiny key on laptop
vim.keymap.set("n", "<PageUp>", "<nop>")
vim.keymap.set("n", "<PageDown>", "<nop>")
vim.keymap.set("v", "<PageUp>", "<nop>")
vim.keymap.set("v", "<PageUp>", "<nop>")
vim.keymap.set("i", "<PageDown>", "<nop>")
vim.keymap.set("i", "<PageDown>", "<nop>")

-- Nvim tree
-- vim.keymap.set("n", "<C-t>", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "T", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<C-f>", ":NvimTreeFindFile<CR>")

-- Use alt + hjkl to resize windows
vim.keymap.set("n", "<M-j>", ":resize -2<CR>")
vim.keymap.set("n", "<M-k>", ":resize +2<CR>")
vim.keymap.set("n", "<M-h>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<M-l>", ":vertical resize +2<CR>")

-- Escape redraws the screen and removes any search highlighting.
vim.keymap.set("n", "<esc>", ":noh<return><esc>")

vim.keymap.set("i", "jk", "<esc>")

-- TAB in normal mode will move to text buffer
vim.keymap.set("n", "<S-Tab>", "<cmd>bprev<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
-- quick list
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz")
-- location list
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz")

-- close buffer
vim.keymap.set("n", "<C-x>", ":bd!<CR>")

-- Better tabbing :  indent and reselect selection
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Better window navigation()
-- vim.keymap.set("n", "<C-h>", "<C-w>h")
-- vim.keymap.set("n", "<C-j>", "<C-w>j")
-- vim.keymap.set("n", "<C-k>", "<C-w>k")
-- vim.keymap.set("n", "<C-l>", "<C-w>l")

-- remap because azerty mapping
-- [m - move to the start of a method.
-- ]m - move to the end of a method.
-- vim.keymap.set("n", "m", "[m")
-- vim.keymap.set("n", "M", "]m")

-- aerial structure
vim.keymap.set("n", "<leader>s", "<cmd>Telescope aerial<CR>")

-- call custom script to scrap url
vim.keymap.set(
  "n",
  "<leader>S",
  "<CMD>execute 'r! scrapr  -u '.shellescape(@+, 1) <CR>",
  { desc = "Retrieve url infos" }
)
vim.keymap.set(
  "v",
  "<leader>S",
  "<CMD>execute 'r! scrapr  -u '.shellescape(@+, 1) <CR>",
  { desc = "Retrieve url infos" }
)

vim.keymap.set("n", "CV", "<CMD>execute 'r! scrapr  -u '.shellescape(@+, 1) <CR>", { desc = "Retrieve url infos" })
vim.keymap.set("v", "CV", "<CMD>execute 'r! scrapr  -u '.shellescape(@+, 1) <CR>", { desc = "Retrieve url infos" })
