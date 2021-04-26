" manage plugin with vim-plug 
call plug#begin('~/.vim/plugged')                                               
Plug 'ThePrimeagen/vim-be-good'
" file explorer
Plug 'preservim/nerdtree'                                                   
" color ui
Plug 'gruvbox-community/gruvbox'
" Plug 'dracula/vim', { 'as': 'dracula' }
" status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'nathunsmitty/nvim-ale-diagnostic'
Plug 'hrsh7th/nvim-compe'
" Extensions to built-in LSP, for example, providing type inlay hints
Plug 'nvim-lua/lsp_extensions.nvim'
" treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
" snippets
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
" telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
" rust
Plug 'rust-lang/rust.vim'
Plug 'golang/vscode-go' 
Plug 'xabikos/vscode-javascript'
Plug 'hashivim/vim-terraform'
call plug#end() 



source $HOME/.config/nvim/settings.vim
source $HOME/.config/nvim/mappings.vim
source $HOME/.config/nvim/completion.vim
source $HOME/.config/nvim/lsp.vim
source $HOME/.config/nvim/treesitter.vim
source $HOME/.config/nvim/finder.vim


" have a fixed column for the diagnostics to appear in
" this removes the jitter when warnings/errors flow in
set signcolumn=yes

" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set updatetime=300
" Show diagnostic popup on cursor hover
autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

" Enable type inlay hints
autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
\ lua require'lsp_extensions'.inlay_hints{ prefix = '', highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }

