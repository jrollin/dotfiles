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

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l



