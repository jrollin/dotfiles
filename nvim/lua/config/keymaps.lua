-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- use `vim.keymap.set` instead
--

local lazymap = LazyVim.safe_keymap_set

lazymap("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
lazymap("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- azerty workaround
-- lazymap("n", "<A-h>", "[", { desc = "Prev alias [" })
-- lazymap("n", "<A-m>", "]", { desc = "Next alias ]" })

local map = vim.keymap.set

map("n", "<C-x>", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })

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
