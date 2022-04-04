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

-- NERDTree                                                                      
nnoremap("<C-t>", ":NERDTreeToggle<CR>")
nnoremap("<C-f>", ":NERDTreeFind<CR>")

-- Use alt + hjkl to resize windows
nnoremap("<M-j>", ":resize -2<CR>")
nnoremap("<M-k>", ":resize +2<CR>")
nnoremap("<M-h>", ":vertical resize -2<CR>")
nnoremap("<M-l>", ":vertical resize +2<CR>")

-- Escape redraws the screen and removes any search highlighting.
nnoremap("<esc>", ":noh<return><esc>")


-- TAB in normal mode will move to text buffer
nnoremap("<TAB>", ":bnext<CR>")
-- SHIFT-TAB will go back
nnoremap("<S-TAB>", ":bprevious<CR>")
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

                                                                         
-- Keybindings for LSPs                                                     
nnoremap("gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")              
nnoremap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")             
-- nnoremap("gr", "<cmd>lua vim.lsp.buf.references()<CR>")             
nnoremap("gr", "<cmd>Telescope lsp_references<CR>")             
nnoremap("gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")           
nnoremap("gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")   

nnoremap("<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")        

-- diagnostics
nnoremap("<leader>dp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", true)
nnoremap("<leader>dn", "<cmd>lua vim.diagnostic.goto_next()<CR>", true)

-- nnoremap("<Leader>dd", "<cmd>Trouble document_diagnostics<CR>", true)
-- use telescope for diagnostics on opened buffer files 
nnoremap("<Leader>dd", "<cmd>Telescope diagnostics<CR>", true)
nnoremap("<Leader>dw", "<cmd>Trouble workspace_diagnostics<CR>", true)
nnoremap("<Leader>dt", "<cmd>TroubleToggle<CR>", true)

-- actions
nnoremap("<leader>r", "<cmd>lua vim.lsp.buf.rename()<CR>")             
-- nnoremap("<leader>a", "<cmd>hua vim.lsp.buf.code_action()<CR>", true)
-- vnoremap("<leader>a", "<cmd>lua vim.lsp.buf.range_code_action()<CR>")
-- use telescope for code actions
nnoremap("<leader>a", "<cmd>Telescope lsp_code_actions<CR>", true)
vnoremap("<leader>a", "<cmd>Telescope lsp_range_code_actions<CR>")

-- rust actions
nnoremap("<leader>t", "<cmd>RustRunnables<CR>")

-- outline code structure
nnoremap("<C-s>", "<cmd>SymbolsOutline<CR>")


nnoremap("<C-space>", "<cmd>lua vim.lsp.buf.hover()<CR>", true)
vnoremap("<C-space>", "<cmd>RustHoverRange<CR>")

nnoremap("gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>")         
nnoremap("gs", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")  


-- Find files using Telescope command-line sugar.
nnoremap("<C-p>", "<cmd>:Telescope file_browser<CR>")

nnoremap("<leader>fs", "<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input(\"Grep For > \")})<CR>")
nnoremap("<leader>fw", "<cmd>lua require('telescope.builtin').grep_string { search = vim.fn.expand(\"<cword>\") }<CR>")
nnoremap("<Leader>fg", "<cmd>lua require('telescope.builtin').git_files()<CR>")
nnoremap("<Leader>ff", "<cmd>lua require('telescope.builtin').find_files()<CR>")
nnoremap("<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<CR>")
nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>")


-- custom file search
nnoremap("<Leader>fd", "<Esc> :lua require('jrollin.telescope').search_dotfiles()<CR>")
nnoremap("<leader>fc", "<cmd>lua require('jrollin.telescope').search_config()<CR>")
-- git branches
nnoremap("<Leader>gg", "<cmd>lua require('jrollin.telescope').git_branches()<CR>")

