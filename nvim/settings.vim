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

" rust format on save
let g:rustfmt_autosave = 1
