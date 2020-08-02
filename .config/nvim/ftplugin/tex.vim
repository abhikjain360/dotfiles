" vimtex settings
	let g:vimtex_view_method = 'zathura'
	"let g:vimtex_compiler_progname = 'nvr'
	au FileType tex set tabstop=4
	au FileType tex map <C-x> <Esc>:VimtexCompile<CR>
	au FileType tex map <C-d> <Esc>:VimtexView<CR>

" vim-easy-align configs
	" Start interactive EasyAlign in visual mode (e.g. vipga)
	xmap ga <Plug>(EasyAlign)
	" Start interactive EasyAlign for a motion/text object (e.g. gaip)
	nmap ga <Plug>(EasyAlign)
