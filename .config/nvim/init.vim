set shell=/bin/zsh

lua require('plugins')

" VANILLA VIM SETTINGS

" Some settings I prefer
	" Allowing use of mouse to navigate
	set mouse+=a
	" Using system clipboard
	set clipboard+=unnamedplus
	set nocompatible
	filetype plugin on
	" Syntax Highlighting
	syntax on
	set encoding=utf-8
	" Show line numbes
	set nu
	set rnu
	" Tab spacing
	set tabstop=4
	set shiftwidth=4
	filetype on
	" indent newline to match previous line
	set autoindent
	set modeline
	set modelines=2
	set hidden
	set cmdheight=1
	set updatetime=100
	set signcolumn=yes
	" don't redraw screen so often
	set lazyredraw
	set encoding=utf-8
	set scrolloff=4
	set conceallevel=0

	" project specific configuration
	set exrc
	set secure

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
	set splitbelow
	set splitright

" Automatically deletes all trailing whitespace and newlines at end of file on save.
	autocmd BufWritePre * %s/\s\+$//e
	autocmd BufWritepre * %s/\n\+\%$//e

" Python location
	let g:python3_host_prog='/usr/bin/python'

" Spell-check set to <leader>o, 'o' for 'orthography':
	map <leader>o :setlocal spell! spelllang=en_gb<CR>

" make it so that unfocused split has absolute numbering
	autocmd WinEnter * set rnu
	autocmd WinLeave * set rnu!

" save undo history / persistent history
	set undofile

" remove scrolloff in terminal
	au TermEnter * set scrolloff=0
	au TermLeave * set scrolloff=4

" markdown for somereason doesn't detect by file extensions
	autocmd BufNewFile,BufRead *.MD set syntax=markdown

" theme settings
	source ~/.config/nvim/theme.vim
" keybindings
	source ~/.config/nvim/mappings.vim
" undotree (mundo) settings
	source ~/.config/nvim/undotree.vim
