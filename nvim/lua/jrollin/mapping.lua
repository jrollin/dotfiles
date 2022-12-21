local nnoremap = function(lhs, rhs, silent)
  vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = silent })
end

local inoremap = function(lhs, rhs)
  vim.api.nvim_set_keymap("i", lhs, rhs, { noremap = true })
end

local vnoremap = function(lhs, rhs)
  vim.api.nvim_set_keymap("v", lhs, rhs, { noremap = true })
end

local xnoremap = function(lhs, rhs)
  vim.api.nvim_set_keymap("x", lhs, rhs, { noremap = true })
end



-- Save a file with leader-w.
nnoremap("<leader>w", ":w<CR>")

-- surround plugin reminder
-- surround (ys), delete (ds) change (cs) change tag aroung (cst)
-- ex: surround sentence with " :  yss"
-- ex: change " by ' around work  :  csw"'


-- real delete not cut with register trick
nnoremap("<leader>d", "\"_d")
xnoremap("<leader>d", "\"_d")
xnoremap("<leader>p", "\"_dP")


-- Nvim tree
nnoremap("<C-n>", ":NvimTreeToggle<CR>")
nnoremap("<C-f>", ":NvimTreeFindFile<CR>")

-- Use alt + hjkl to resize windows
nnoremap("<M-j>", ":resize -2<CR>")
nnoremap("<M-k>", ":resize +2<CR>")
nnoremap("<M-h>", ":vertical resize -2<CR>")
nnoremap("<M-l>", ":vertical resize +2<CR>")

-- Escape redraws the screen and removes any search highlighting.
nnoremap("<esc>", ":noh<return><esc>")

inoremap("jk", "<esc>")

-- TAB in normal mode will move to text buffer
nnoremap("<Tab>", ":bnext<CR>")
-- SHIFT-TAB will go back
nnoremap("<S-Tab>", ":bprevious<CR>")
-- close buffer
nnoremap("<C-x>", ":bd!<CR>")

-- Better tabbing
vnoremap("<", "<gv")
vnoremap(">", ">gv")

-- Better window navigation
nnoremap("<C-h>", "<C-w>h")
nnoremap("<C-j>", "<C-w>j")
nnoremap("<C-k>", "<C-w>k")
nnoremap("<C-l>", "<C-w>l")

-- remap because azerty mapping
-- [m - move to the start of a method.
-- ]m - move to the end of a method.
nnoremap("m", "[m")
nnoremap("M", "]m")


-- custom file search
vim.keymap.set('n', '<Leader>sd', require('jrollin.telescope').search_dotfiles, { desc = '[S]earch [D]otfiles' })
vim.keymap.set('n', '<leader>sc', require('jrollin.telescope').search_config, { desc = '[S]earch [C]onfig' })
vim.keymap.set('n', '<Leader>sg', require('jrollin.telescope').search_git, {desc = '[S]earch [G]it'})
vim.keymap.set('n', '<Leader>sf', require('jrollin.telescope').search_files, { desc = '[S]earch [F]iles' })

-- vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').live_grep, { desc = '[S]earch by G[r]ep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch [B]uffers' })

-- diagnostics
vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev, { desc = '[D]iagnostic [P]revious'})
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next, { desc = '[D]iagnostic [N]ext'})

-- git 
vim.keymap.set('n', '<Leader>gb', require('jrollin.telescope').git_branches, { desc = '[G]it [B]ranches' })
vim.keymap.set('n', '<Leader>gs', require('telescope.builtin').git_status, { desc = '[G]it [S]tatus' })


-- dap debug
vim.keymap.set("n", "<leader><leader>dc", "<Cmd>lua require('dap').continue()<CR>", { desc = "start debugging" })
vim.keymap.set("n", "<leader><leader>do", "<Cmd>lua require('dap').step_over()<CR>", { desc = "step over" })
vim.keymap.set("n", "<leader><leader>di", "<Cmd>lua require('dap').step_into()<CR>", { desc = "step into" })
vim.keymap.set("n", "<leader><leader>dt", "<Cmd>lua require('dap').step_out()<CR>", { desc = "step out" })
vim.keymap.set("n", "<leader><leader>db", "<Cmd>lua require('dap').toggle_breakpoint()<CR>", { desc = "toggle breakpoint" })
vim.keymap.set("n", "<leader><leader>dB", "<Cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", { desc = "toggle breakpoint" })
vim.keymap.set("n", "<leader><leader>dr", "<Cmd>lua require('dap').repl.toggle()<CR>", { desc = "toggle repl" })
vim.keymap.set("n", "<leader><leader>du", "<Cmd>lua require('dapui').toggle()<CR>", { desc = "toggle dap ui" })
---- intellij shortkeys
-- Resume program (F9)
-- Step Over (F8): executing a program one line at a time
-- Step into (F7) : inside the method to demonstrate what gets executed 
-- -- Smart step into (Shift + F7)
-- Step out (Shift + F8):  take you to the call method and back up the hierarchy branch of your code
-- -- Run to cursor (Alt + F9)
-- -- Evaluate expression (Alt + F8)
-- Toggle (Ctrl + F8)
-- -- view breakpoints (Ctrl + Shift + F8)
vim.keymap.set("n", "<F9>", "<Cmd>lua require('dap').continue()<CR>", { desc = "start debugging" })
vim.keymap.set("n", "<F8>", "<Cmd>lua require('dap').step_over()<CR>", { desc = "step over" })
vim.keymap.set("n", "<F7>", "<Cmd>lua require('dap').step_into()<CR>", { desc = "step into" })
vim.keymap.set("n", "<S-F8>", "<Cmd>lua require('dap').step_out()<CR>", { desc = "step out" })
vim.keymap.set("n", "<C-F8>", "<Cmd>lua require('dap').toggle_breakpoint()<CR>", { desc = "toggle breakpoint" })
