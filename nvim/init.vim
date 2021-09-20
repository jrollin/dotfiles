" manage plugin with vim-plug 
call plug#begin('~/.vim/plugged')                                               
Plug 'ThePrimeagen/vim-be-good'
" file explorer
Plug 'preservim/nerdtree'                                                   
" color ui
Plug 'gruvbox-community/gruvbox'
Plug 'folke/lsp-colors.nvim'
Plug 'p00f/nvim-ts-rainbow' 
" status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
Plug 'glepnir/lspsaga.nvim'
"Extensions to built-in LSP, for example, providing type inlay hints
Plug 'nvim-lua/lsp_extensions.nvim'
" lsp diagnostics
Plug 'folke/lsp-trouble.nvim'
" treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
" format code
Plug 'sbdchd/neoformat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'editorconfig/editorconfig-vim'
" snippets
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
" telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
" git
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'
" lang
Plug 'rust-lang/rust.vim'
Plug 'golang/vscode-go' 
Plug 'xabikos/vscode-javascript'
Plug 'hashivim/vim-terraform'
Plug 'tpope/vim-markdown'
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
" Debugging (needs plenary from above as well)
Plug 'mfussenegger/nvim-dap'
call plug#end() 



let mapleader = ' '                                                             

lua require('jrollin') 


" mapping
" Map the leader key to a space.                                                
let mapleader = ' '                                                             
                                                                              
" inoremap : normal mode remap
" inoremap ! insert mode remap

" Use alt + hjkl to resize windows
nnoremap <M-j>    :resize -2<CR>
nnoremap <M-k>    :resize +2<CR>
nnoremap <M-h>    :vertical resize -2<CR>
nnoremap <M-l>    :vertical resize +2<CR>

" Immediately add a closing quotes or braces in insert mode.                    
" inoremap ' ''<esc>i                                                             
" inoremap " ""<esc>i                                                             
" inoremap ( ()<esc>i                                                             
" inoremap { {}<esc>i                                                             
" inoremap [ []<esc>i                                                             
                                                                              
" Save a file with leader-w.                                                    
noremap <leader>w :w<cr>                                                       
                                                                                  
" NERDTree                                                                      
nnoremap <leader>n :NERDTreeFocus<CR>                                           
nnoremap <C-t> :NERDTreeToggle<CR>                                              
nnoremap <C-f> :NERDTreeFind<CR>

" TAB in general mode will move to text buffer
nnoremap <TAB> :bnext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :bprevious<CR>
" close buffer
nnoremap <C-x> :bd!<CR>

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l


" completion
inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"


" lspsaga
" -- code action
nnoremap <silent><leader>ca <cmd>lua require('lspsaga.codeaction').code_action()<CR>
vnoremap <silent><leader>ca :<C-U>lua require('lspsaga.codeaction').range_code_action()<CR>
" -- or use command
" nnoremap <silent><leader>ca :Lspsaga code_action<CR>
" vnoremap <silent><leader>ca :<C-U>Lspsaga range_code_action<CR>


" Find files using Telescope command-line sugar.
nnoremap <C-p> :lua require('telescope.builtin').file_browser()<CR>

nnoremap <leader>fs :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
nnoremap <leader>fw :lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>
nnoremap <Leader>fg :lua require('telescope.builtin').git_files()<CR>
nnoremap <Leader>ff :lua require('telescope.builtin').find_files()<CR>
nnoremap <leader>fb :lua require('telescope.builtin').buffers()<CR>

" search help
nnoremap <leader>fh :lua require('telescope.builtin').help_tags()<CR>

" custom file search
nnoremap <leader>fd :lua require('finder').search_dotfiles()<CR>
nnoremap <leader>fc :lua require('finder').search_config()<CR>
nnoremap <leader>fp :lua require('finder').search_registers()<CR>



" settings
:syntax enable

filetype plugin indent on

" auto change directory to current file
set autochdir

set tabstop=4 softtabstop=4                                                     
set shiftwidth=4                                                                
set expandtab                                                                   
set smartindent                                                                 
set colorcolumn=80                                                              
set signcolumn=yes                                                              
                                                                              
set relativenumber                                                            
set nu                                                                        
                                                                              
set nowrap                                                                      
set smartcase                                                                   
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile

set nohlsearch                                                                  
set incsearch                                                                   
                                                                              
set hidden " Required to keep multiple buffers open multiple buffers            
                                                                              
                                                                              
" Always show statusline.                                                       
set laststatus=2                                                                
" Show last command in the status line.                                         
set showcmd                                                                     
                                                                              
set updatetime=300                      " Faster completion                     
set timeoutlen=500                      " By default timeoutlen is 1000 ms      
                                                                              
set clipboard=unnamedplus               " Copy paste between vim and everything else

set termguicolors
set background=dark
let g:gruvbox_contrast_dark='hard'
let g:gruvbox_contrast_light='soft'
colorscheme gruvbox

" rust format on saveo
let g:rustfmt_autosave = 1

" have a fixed column for the diagnostics to appear in
" this removes the jitter when warnings/errors flow in
set signcolumn=yes

" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set updatetime=300


" completion
" Set completeopt to have a better completion experience
set completeopt=menu,menuone,noselect
" Avoid showing extra messages when using completion
set shortmess+=c


" Treesitter conf
highlight link TSConstBuiltin Constant
highlight link TSFuncBuiltin FuncBuiltIn


