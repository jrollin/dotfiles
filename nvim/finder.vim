lua require('finder')

" Find files using Telescope command-line sugar.
nnoremap <leader>fs :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
nnoremap <Leader>ff :lua require('telescope.builtin').find_files()<CR>
nnoremap <Leader>fe :lua require('telescope.builtin').file_browser()<CR>

nnoremap <leader>fw :lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>
nnoremap <leader>fb :lua require('telescope.builtin').buffers()<CR>
nnoremap <leader>ft :lua require('telescope.builtin').help_tags()<CR>
