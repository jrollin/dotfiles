" manage plugin with vim-plug 
call plug#begin('~/.vim/plugged')                                               
" vim game 
Plug 'ThePrimeagen/vim-be-good'
" file explorer
Plug 'kyazdani42/nvim-tree.lua'
" color ui
Plug 'gruvbox-community/gruvbox'
Plug 'folke/lsp-colors.nvim'
Plug 'p00f/nvim-ts-rainbow' 
Plug 'norcalli/nvim-colorizer.lua'
" dev icon
Plug 'kyazdani42/nvim-web-devicons'
" status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
" snippets
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'
" format cmp sugestion
Plug 'onsails/lspkind-nvim'

" UI stuff (mainly used for lsp overrides)
Plug 'RishabhRD/popfix'
Plug 'RishabhRD/nvim-lsputils'

"Extensions to built-in LSP, for example, providing type inlay hints
Plug 'nvim-lua/lsp_extensions.nvim'
" lsp diagnostics
Plug 'folke/lsp-trouble.nvim'
" treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
" outline tree structure
Plug 'simrat39/symbols-outline.nvim'
" idk
Plug 'jose-elias-alvarez/null-ls.nvim'
" format code
" Plug 'sbdchd/neoformat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'editorconfig/editorconfig-vim'
Plug 'windwp/nvim-autopairs'
Plug 'windwp/nvim-ts-autotag'
" telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-telescope/telescope-media-files.nvim'
" git
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'
" lang
" rust
Plug 'simrat39/rust-tools.nvim'
" go
Plug 'golang/vscode-go' 
" js
Plug 'xabikos/vscode-javascript'
" config
Plug 'tpope/vim-markdown'
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
Plug 'hashivim/vim-terraform'
" vim-markdown
Plug 'ellisonleao/glow.nvim'
Plug 'iamcco/markdown-preview.nvim'
" Debugging (needs plenary from above as well)
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'theHamsta/nvim-dap-virtual-text'
call plug#end() 





" mapping
" Map the leader key to a space.                                                
let mapleader = ' '                                                             
set termguicolors
" set guifont =JetBrainsMono\ Nerd\ Font:10

lua require('jrollin') 

                                                                              

" Immediately add a closing quotes or braces in insert mode.                    
" inoremap ' ''<esc>i                                                             
" inoremap " ""<esc>i                                                             
" inoremap ( ()<esc>i                                                             
" inoremap { {}<esc>i                                                             
" inoremap [ []<esc>i                                                             


" Use <Tab> and <S-Tab> to navigate through popup menu
" inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"


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
set timeoutlen=400                      " By default timeoutlen is 1000 ms      
                                                                              
set clipboard=unnamedplus               " Copy paste between vim and everything else

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

" Treesitter conf
highlight link TSConstBuiltin Constant
highlight link TSFuncBuiltin FuncBuiltIn


