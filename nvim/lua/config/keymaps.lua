-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- use `vim.keymap.set` instead
--

local lazymap = LazyVim.safe_keymap_set

lazymap("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
lazymap("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })

local map = vim.keymap.set

map("n", "<C-x>", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
