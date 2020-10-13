" vimtex settings
	let g:vimtex_view_method='zathura'
	let g:tex_flavor='latex'
	let g:vimtex_quickfix_mode=0
	set conceallevel=1
	let g:tex_conceal='abdmg'
	"let g:vimtex_compiler_progname = 'nvr'

" Specific settings
	au FileType tex set tabstop=4 shiftwidth=4
	au FileType tex map <C-x> <Esc>:!pdflatex --shell-escape %<CR>
	au FileType tex map <C-d> <Esc>:VimtexView<CR>

" vim-easy-align configs
	" Start interactive EasyAlign in visual mode (e.g. vipga)
	xmap ga <Plug>(EasyAlign)
	" Start interactive EasyAlign for a motion/text object (e.g. gaip)
	nmap ga <Plug>(EasyAlign)

" snippets settings
	let g:UltiSnipsExpandTrigger='<Tab>'
	let g:UltiSnipsJumpForwardTrigger='<Ctrl-t>'
	let g:UltiSnipsJumpBackwardTrigger='<Ctrl-Shift-T>'
	let g:UltiSnipsSnippetDirectories=[$XDG_CONFIG_HOME.'/nvim/UltiSnips']

" dunno why
	inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" inkscape figures
	inoremap <C-f> <Esc>: silent exec '.!inkscape-figures create "'.getline('.').'" "'.b:vimtex.root.'/figures/"'<CR><CR>:w<CR>
	nnoremap <C-f> : silent exec '!inkscape-figures edit "'.b:vimtex.root.'/figures/" > /dev/null 2>&1 &'<CR><CR>:redraw!<CR>

	nnoremap ,m j0f<cw
	inoremap ,m <Esc>j0f<cw
	nnoremap ,n gg\<++><CR>ncw
	inoremap ,n <Esc>gg\<++><CR>ncw
