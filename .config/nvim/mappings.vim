" window closing
" -> doesn't closes buffers, only windows, unless it is the last window
map Q <C-w>c

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

" window resizing
nnoremap <space>w=  C-w>=
nnoremap <C-Left>	<cmd>vertical resize +5<cr>
nnoremap <C-Right>	<cmd>vertical resize -5<cr>
nnoremap <C-Up>		<cmd>resize +5<cr>
nnoremap <C-Down>	<cmd>resize -5<cr>

nnoremap <left>  <cmd>tabn<cr>
nnoremap <right> <cmd>tabp<cr>

" buffer
nnoremap <space>bD <cmd>bd<cr>

" misc
nnoremap ; :
nnoremap <leader>n :noh<CR>

" mapping terminal exit to <Esc>
tnoremap <Esc> <C-\><C-n>

" terminal
nnoremap <space>tg :sp<CR>:te<CR>
nnoremap <space>tv :vs<CR>:te<CR>
