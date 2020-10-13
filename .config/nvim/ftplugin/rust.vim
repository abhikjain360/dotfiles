" Rust format on save
"let g:rustfmt_autosave = 1

nnoremap ,f :RustFmt<CR>

nnoremap <C-x> :RustRun<CR>
inoremap <C-x> <Esc>:RustRun<CR>

" Bracket manupulation
     	nnoremap ,sb ddkA {<Return>}<Esc>P
		nnoremap ,db k0f{ma%dd`ax
