lua require('finder')

" Find files using Telescope command-line sugar.
nnoremap <C-p> :lua require('telescope.builtin').file_browser()<CR>

nnoremap <leader>fs :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
nnoremap <leader>fw :lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>
nnoremap <Leader>fg :lua require('telescope.builtin').git_files()<CR>
nnoremap <Leader>ff :lua require('telescope.builtin').find_files()<CR>
nnoremap <leader>fb :lua require('telescope.builtin').buffers()<CR>

" search help
nnoremap <leader>ft :lua require('telescope.builtin').help_tags()<CR>

" custom file search
nnoremap <leader>fd :lua require('finder').search_dotfiles()<CR>
