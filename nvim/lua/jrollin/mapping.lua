local nnoremap = function(lhs, rhs, silent)
  vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = silent })
end

local inoremap = function(lhs, rhs)
  vim.api.nvim_set_keymap("i", lhs, rhs, { noremap = true })
end

local vnoremap = function(lhs, rhs)
  vim.api.nvim_set_keymap("v", lhs, rhs, { noremap = true })
end

-- Save a file with leader-w.                                                    
nnoremap("<leader>w", ":w<CR>")
                                                                                  
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


-- lsp trouble
nnoremap("<leader>xx", "<cmd>LspTroubleToggle<cr>")
nnoremap("<leader>xw", "<cmd>LspTroubleToggle lsp_workspace_diagnostics<cr>")
nnoremap("<leader>xd", "<cmd>LspTroubleToggle lsp_document_diagnostics<cr>")
nnoremap("<leader>xl", "<cmd>LspTroubleToggle loclist<cr>")
nnoremap("<leader>xq", "<cmd>LspTroubleToggle quickfix<cr>")
nnoremap("<leader>xr", "<cmd>LspTroubleRefresh<cr>")
-- override 
nnoremap("gd", "<cmd>LspTrouble lsp_definitions<cr>")
nnoremap("gr", "<cmd>LspTrouble lsp_references<cr>")


-- " lspsaga
-- " -- code action
-- " nnoremap <silent><leader>ca <cmd>lua require('lspsaga.codeaction').code_action()<CR>
-- " vnoremap <silent><leader>ca :<C-U>lua require('lspsaga.codeaction').range_code_action()<CR>


                                                                         
-- Keybindings for LSPs                                                     
nnoremap("gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")              
-- nnoremap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")             
-- nnoremap("gr", "<cmd>lua vim.lsp.buf.references()<CR>")             
nnoremap("<leader>gd", "<cmd>lua vim.lsp.buf.type_definition()<CR>")   
nnoremap("gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")           
nnoremap("<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")        
nnoremap("<leader>r", "<cmd>lua vim.lsp.buf.rename()<CR>")             
nnoremap("<leader>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", true)
vnoremap("<leader>a", "<cmd>lua vim.lsp.buf.range_code_action()<CR>")

nnoremap("<leader>t", "<cmd>RustRunnables<CR>")


nnoremap("<C-space>", "<cmd>lua vim.lsp.buf.hover()<CR>", true)
vnoremap("<C-space>", "<cmd>RustHoverRange<CR>")

nnoremap("gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>")         
nnoremap("gs", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")  


-- Find files using Telescope command-line sugar.
nnoremap("<C-p>", "<cmd>lua require('telescope.builtin').file_browser()<CR>")

-- nnoremap("<leader>fs", "<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>")
-- nnoremap("<leader>fw", "<cmd>lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>")
nnoremap("<Leader>fg", "<cmd>lua require('telescope.builtin').git_files()<CR>")
nnoremap("<Leader>ff", "<cmd>lua require('telescope.builtin').find_files()<CR>")
nnoremap("<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<CR>")

-- search help
nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>")

-- custom file search
nnoremap("<Leader>fd", "<Esc> :lua require('jrollin.finder').search_dotfiles()<CR>")
nnoremap("<leader>fc", "<cmd>lua require('jrollin.finder').search_config()<CR>")
nnoremap("<leader>fp", "<cmd>lua require('jrollin.finder').search_registers()<CR>")

