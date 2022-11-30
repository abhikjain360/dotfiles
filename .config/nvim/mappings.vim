" window closing
" -> doesn't closes buffers, only windows, unless it is the last window
nnoremap Q <cmd>q<cr>

" window splitting
nnoremap <space>vs <cmd>vs<cr>
nnoremap <space>sp <cmd>sp<cr>

" window movements
nnoremap <space>wh <C-w>h
nnoremap <space>wj <C-w>j
nnoremap <space>wk <C-w>k
nnoremap <space>wl <C-w>l

" window shiftings
nnoremap <space>wH <C-w>H
nnoremap <space>wJ <C-w>J
nnoremap <space>wK <C-w>K
nnoremap <space>wL <C-w>L

" buffer
nnoremap <space>bd <cmd>bd<cr>

" misc
nnoremap ; :
nnoremap <leader>n :noh<CR>
