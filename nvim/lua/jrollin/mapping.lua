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
-- nnoremap <leader>d "_d
-- xnoremap <leader>d "_d
-- xnoremap <leader>p "_dP
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

-- Keybindings for LSPs
nnoremap("gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
nnoremap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
-- nnoremap("gr", "<cmd>lua vim.lsp.buf.references()<CR>")
nnoremap("gr", "<cmd>Telescope lsp_references<CR>")
nnoremap("gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
nnoremap("gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")

nnoremap("<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
nnoremap("<C-h>", "<cmd>lua vim.lsp.buf.hover()<CR>")


-- use telescope for diagnostics on opened buffer files
nnoremap("<Leader>dg", "<cmd>Telescope diagnostics<CR>", true)
-- diagnostics
nnoremap("<leader>dp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", true)
nnoremap("<leader>dn", "<cmd>lua vim.diagnostic.goto_next()<CR>", true)

-- actions
nnoremap("<leader>r", "<cmd>lua vim.lsp.buf.rename()<CR>")
nnoremap("<leader>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", true)
vnoremap("<leader>a", "<cmd>lua vim.lsp.buf.range_code_action()<CR>")

-- rust actions
nnoremap("<leader>t", "<cmd>RustRunnables<CR>")

-- outline code structure
nnoremap("<C-s>", "<cmd>SymbolsOutline<CR>")


nnoremap("<C-space>", "<cmd>lua vim.lsp.buf.hover()<CR>", true)
vnoremap("<C-space>", "<cmd>RustHoverRange<CR>")

nnoremap("gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>")
nnoremap("gs", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")


-- Find files using Telescope command-line sugar.
nnoremap("<leader>fs", "<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input(\"Grep For > \")})<CR>")
nnoremap("<leader>fw", "<cmd>lua require('telescope.builtin').grep_string { search = vim.fn.expand(\"<cword>\") }<CR>")
nnoremap("<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<CR>")
nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>")

-- custom file search
nnoremap("<Leader>fd", "<cmd>lua require('jrollin.telescope').search_dotfiles()<CR>")
nnoremap("<leader>fc", "<cmd>lua require('jrollin.telescope').search_config()<CR>")
nnoremap("<Leader>ff", "<cmd>lua require('jrollin.telescope').search_files()<CR>")
nnoremap("<Leader>fg", "<cmd>lua require('jrollin.telescope').search_git()<CR>")
-- git branches
nnoremap("<Leader>gb", "<cmd>lua require('jrollin.telescope').git_branches()<CR>")
nnoremap("<Leader>gs", "<cmd>lua require('telescope.builtin').git_status()<CR>")

-- dap debug
-- nnoremap("<F4>", "<cmd>lua require'dap'.repl.toggle()<CR>")
nnoremap("<F4>", "<cmd>lua require'dapui'.toggle()<CR>")
nnoremap("<F5>","<cmd>lua require'dap'.continue()<CR>")
nnoremap("<F6>","<cmd>lua require'dap'.step_over()<CR>")
nnoremap("<F7>","<cmd>lua require'dap'.step_into()<CR>")
nnoremap("<F8>","<cmd>lua require'dap'.step_out()<CR>")
nnoremap("<Leader>b", "<cmd>lua require'dap'.toggle_breakpoint()<CR>")
nnoremap("<Leader>B", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR> ")
