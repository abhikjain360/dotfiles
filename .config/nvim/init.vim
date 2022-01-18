set shell=/bin/zsh

" Vim Plug Settings
call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
	" brackets
	Plug 'tpope/vim-surround'
	Plug 'jiangmiao/auto-pairs'

	" themes
	Plug 'morhetz/gruvbox'
	Plug 'dracula/vim'
	Plug 'crusoexia/vim-monokai'

	" better syntax highlighting
	Plug 'ap/vim-css-color'

	" beautify + readability
	Plug 'Yggdroot/indentLine'
	Plug 'luochen1990/rainbow'

	" utility
	Plug 'tpope/vim-abolish'
	Plug 'mbbill/undotree'
	Plug 'terryma/vim-multiple-cursors'
    Plug 'junegunn/vim-easy-align'
	Plug 'tpope/vim-commentary'
	" Plug 'chrisbra/unicode.vim'

	" fzf
	Plug 'airblade/vim-rooter'
	Plug 'junegunn/fzf.vim'

	" autojump
	Plug 'nanotee/zoxide.vim'

	" git
    Plug 'airblade/vim-gitgutter'

	" lightline + bufferline
	Plug 'itchyny/lightline.vim'
	Plug 'mengelbrecht/lightline-bufferline'

	" note taking
	Plug 'vimwiki/vimwiki'
	Plug 'junegunn/goyo.vim'

	" " file browsing
	" Plug 'lambdalisue/fern.vim'
	" Plug 'lambdalisue/fern-renderer-nerdfont.vim'
	" Plug 'lambdalisue/fern-git-status.vim'
	" Plug 'lambdalisue/nerdfont.vim'
	" " this needed for some problem
	" Plug 'antoinemadec/FixCursorHold.nvim'

	" code completion/linting
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'lervag/vimtex', { 'for': 'tex' }
	" Plug 'gabrielelana/vim-markdown', { 'for': 'markdown' }
	Plug 'rust-lang/rust.vim', { 'for': 'rust' }
	Plug 'tikhomirov/vim-glsl', { 'for': 'glsl' }
	Plug 'mattn/emmet-vim', { 'for': 'html' }
	Plug 'cespare/vim-toml', { 'for' : 'toml' }
	Plug 'abhikjain360/wgsl.vim', { 'for': 'wgsl' }
	Plug 'ziglang/zig.vim', { 'for': 'zig' }
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()

" VANILLA VIM SETTINGS

" Some settings I prefer
	" Allowing use of mouse to navigate
	set mouse+=a
	" No highlighting every match when searching
	" set nohlsearch
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
	set autochdir
    set scrolloff=4
	set conceallevel=0

" Enable autocompletion:
	set wildmode=longest,list,full
	set wildmenu
	set showcmd

" " Disables automatic commenting on newline:
" 	autocmd FileType * setlocal formatoptions-=r formatoptions-=o

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
	set splitbelow
	set splitright

" Save file as sudo on files that require root permission
	cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Automatically deletes all trailing whitespace and newlines at end of file on save.
	autocmd BufWritePre * %s/\s\+$//e
	autocmd BufWritepre * %s/\n\+\%$//e

" Python location
	let g:python3_host_prog='/usr/bin/python'

" Spell-check set to <leader>o, 'o' for 'orthography':
	map <leader>o :%GrammarousCheck<CR>
	map <leader>O :setlocal spell! spelllang=en_gb<CR>

" make it so that unfocused split has absolute numbering
	autocmd WinEnter * set rnu
	autocmd WinLeave * set rnu!

" save undo history / persistent history
	set undofile

" " remember all the foldings
" 	augroup remember_folds
" 		autocmd!
" 		autocmd BufWinLeave * mkview
" 		autocmd BufWinEnter * silent! loadview
" 	augroup END

" remove scrolloff in terminal
	au TermEnter * set scrolloff=0
	au TermLeave * set scrolloff=4

" PLUGIN SPECIFIC SETTINGS

" EasyAlign settings
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)


" COC settings
	" Use tab for trigger completion with characters ahead and navigate.
	" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
	" other plugin before putting this into your config.
	inoremap <silent><expr> <TAB>
		  \ pumvisible() ? "\<C-n>" :
		  \ <SID>check_back_space() ? "\<TAB>" :
		  \ coc#refresh()
	inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

	function! s:check_back_space() abort
	  let col = col('.') - 1
	  return !col || getline('.')[col - 1]  =~# '\s'
	endfunction

	" Use <c-space> to trigger completion.
	inoremap <silent><expr> <c-space> coc#refresh()

	" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
	" position. Coc only does snippet and additional edit on confirm.
	" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
	if exists('*complete_info')
	  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
	else
	  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
	endif

	" Use `[g` and `]g` to navigate diagnostics
	" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
	nmap <silent> [g <Plug>(coc-diagnostic-prev)
	nmap <silent> ]g <Plug>(coc-diagnostic-next)

	" GoTo code navigation.
	nmap <silent> gd <Plug>(coc-definition)
	nmap <silent> gy <Plug>(coc-type-definition)
	nmap <silent> gi <Plug>(coc-implementation)
	nmap <silent> gr <Plug>(coc-references)

	" Use K to show documentation in preview window.
	nnoremap <silent> K :call <SID>show_documentation()<CR>

	function! s:show_documentation()
		if (index(['vim','help'], &filetype) >= 0)
			execute 'h '.expand('<cword>')
		else
			call CocAction('doHover')
		endif
	endfunction

	" Highlight the symbol and its references when holding the cursor.
	autocmd CursorHold * silent call CocActionAsync('highlight')

	" Symbol renaming.
	nmap <leader>rn <Plug>(coc-rename)

	augroup mygroup
		autocmd!
		" Setup formatexpr specified filetype(s).
		autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
		" Update signature help on jump placeholder.
		autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
	augroup end

	" Applying codeAction to the selected region.
	" Example: `<leader>aap` for current paragraph
	"xmap <leader>a  <Plug>(coc-codeaction-selected)
	"nmap <leader>a  <Plug>(coc-codeaction-selected)

	" Formatting selected code.
	"xmap <leader>f  <Plug>(coc-format-selected)
	"nmap <leader>f  <Plug>(coc-format-selected)

	" Remap keys for applying codeAction to the current buffer.
	"nmap <leader>ac  <Plug>(coc-codeaction)
	" Apply AutoFix to problem on the current line.
	nmap <leader>qf  <Plug>(coc-fix-current)

	" Map function and class text objects
	" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
	xmap if <Plug>(coc-funcobj-i)
	omap if <Plug>(coc-funcobj-i)
	xmap af <Plug>(coc-funcobj-a)
	omap af <Plug>(coc-funcobj-a)
	xmap ic <Plug>(coc-classobj-i)
	omap ic <Plug>(coc-classobj-i)
	xmap ac <Plug>(coc-classobj-a)
	omap ac <Plug>(coc-classobj-a)

	" Use CTRL-S for selections ranges.
	" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
	"nmap <silent> <C-s> <Plug>(coc-range-select)
	"xmap <silent> <C-s> <Plug>(coc-range-select)

	" Add `:Format` command to format current buffer.
	command! -nargs=0 Format :call CocAction('format')

	nnoremap <space>bf :Format<CR>

	" Add `:Fold` command to fold current buffer.
	command! -nargs=? Fold :call     CocAction('fold', <f-args>)

	" Add `:OR` command for organize imports of the current buffer.
	command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

	" Add (Neo)Vim's native statusline support.
	" NOTE: Please see `:h coc-status` for integrations with external plugins that
	" provide custom statusline: lightline.vim, vim-airline.
	set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

	" Mappings for CoCList
	" Show all diagnostics.
	nnoremap <silent><nowait> <space>za  :<C-u>CocList diagnostics<cr>
	" Manage extensions.
	nnoremap <silent><nowait> <space>ze  :<C-u>CocList extensions<cr>
	" Show commands.
	nnoremap <silent><nowait> <space>zc  :<C-u>CocList commands<cr>
	" Find symbol of current document.
	nnoremap <silent><nowait> <space>zo  :<C-u>CocList outline<cr>
	" Search workspace symbols.
	nnoremap <silent><nowait> <space>zs  :<C-u>CocList -I symbols<cr>
	" Do default action for next item.
	nnoremap <silent><nowait> <space>zj  :<C-u>CocNext<CR>
	" Do default action for previous item.
	nnoremap <silent><nowait> <space>zk  :<C-u>CocPrev<CR>
	" Open coc list
	nnoremap <silent><nowait> <space>zl :<C-u>CocList<CR>
	" Resume latest coc list.
	nnoremap <silent><nowait> <space>zp  :<C-u>CocListResume<CR>

" COC-EXLPLORER SETIINGS
nnoremap <space>te :CocCommand explorer --toggle<CR>

" LIGHTLINE/BUFFERLINE SETTINGS

" defaults copied from README on GitHub
let g:lightline#bufferline#show_number      = 2
let g:lightline#bufferline#shorten_path     = 1
let g:lightline#bufferline#unnamed          = '[No Name]'
let g:lightline                             = {'colorscheme': 'gruvbox'}
let g:lightline.tabline                     = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand            = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type              = {'buffers': 'tabsel'}
let g:lightline#bufferline#unicode_symbols  = 1
let g:lightline#bufferline#enable_nerdfont  = 1
let g:lightline#bufferline#clickable        = 1
let g:lightline.component_raw               = {'buffers': 1}
"g:lightline#bufferline#modified            = ' +'

" mappings
nmap <Leader>1 <Plug>lightline#bufferline#go(1)
nmap <Leader>2 <Plug>lightline#bufferline#go(2)
nmap <Leader>3 <Plug>lightline#bufferline#go(3)
nmap <Leader>4 <Plug>lightline#bufferline#go(4)
nmap <Leader>5 <Plug>lightline#bufferline#go(5)
nmap <Leader>6 <Plug>lightline#bufferline#go(6)
nmap <Leader>7 <Plug>lightline#bufferline#go(7)
nmap <Leader>8 <Plug>lightline#bufferline#go(8)
nmap <Leader>9 <Plug>lightline#bufferline#go(9)

nmap <Leader>c1 <Plug>lightline#bufferline#delete(1)
nmap <Leader>c2 <Plug>lightline#bufferline#delete(2)
nmap <Leader>c3 <Plug>lightline#bufferline#delete(3)
nmap <Leader>c4 <Plug>lightline#bufferline#delete(4)
nmap <Leader>c5 <Plug>lightline#bufferline#delete(5)
nmap <Leader>c6 <Plug>lightline#bufferline#delete(6)
nmap <Leader>c7 <Plug>lightline#bufferline#delete(7)
nmap <Leader>c8 <Plug>lightline#bufferline#delete(8)
nmap <Leader>c9 <Plug>lightline#bufferline#delete(9)

" tabline won't show without this
set showtabline=2

" mode info already in lightline, show cmdline shouldn't show it
set noshowmode

" VIMWIKI settings
let g:vimwiki_key_mappings = { 'table_mappings': 0 }

" GOYO settings
nnoremap <space>g :Goyo<CR>:<CR>
let g:goyo_width = 120
let g:goyo_height = '90%'

" THEME

" fix st coloring issues
	if &term =~ '256color'
		" disable Background Color Erase (BCE) so that color schemes
		" render properly when inside 256-color tmux and GNU screen.
		" see also https://sunaku.github.io/vim-256color-bce.html
		set t_ut=
	endif
	set t_8f=^[[38;2;%lu;%lu;%lum        " set foreground color
	set t_8b=^[[48;2;%lu;%lu;%lum        " set background color
	set t_Co=256                         " Enable 256 colors

" setting colors
	set termguicolors
	set background=dark
	let g:gruvbox_contrast_dark = 'hard'
	" let g:gruvbox_italic = 0
	let g:gruvbox_bold = 1
	let g:gruvbox_underline = 0
	let ayucolor = 'dark'
	colorscheme gruvbox
	hi Normal cterm=bold,reverse,italic,standout
	hi Normal ctermbg=NONE

" UNDOTREE Settings
	nnoremap <space>u :UndotreeToggle<CR>

" INDENTLINE Settings
	" let g:indentLine_char = '¦'
	" let g:indentLine_showFirstIndentLevel = 1
	" let g:indentLine_conceallevel = 0

" RAINBOW settings
	let g:rainbow_active = 1

" FZF settings + bindings
	" this command prevents fzf from searching in useless files
	let $FZF_DEFAULT_COMMAND = "find . -type d \\( -name .git -o -name target -o -name node_modules -o -name vendor \\) -prune -o -type f -printf '%P\n'"
	let g:fzf_command_prefix = 'Fzf'
	" let g:fzf_preview_window = ['right:50%:hidden', 'ctrl-/']

	nnoremap <space>f<CR>
	nnoremap <space>ff :FzfFiles<CR>
	nnoremap <space>fg :FzfGFiles<CR>
	nnoremap <space>fb :FzfBuffers<CR>
	nnoremap <space>fs :FzfRg
	nnoremap <space>fl :FzfLocate
	nnoremap <space>ft :FzfFiletypes<CR>


" KEY BINDINGS
	" I want to use homekeys only ...
	nnoremap <Up>		<Nop>
	nnoremap <Down>		<Nop>
	" ... but map these to change tabs
	nnoremap <Right>	:tabn<CR>
	nnoremap <Left>		:tabp<CR>

	" I don't like pressing shift
	nnoremap ; :

	" special map find and change
    nnoremap ,m /<++><CR>ca<
    inoremap ,m <Esc>/<++><CR>ca<

	" Shortcutting split navigation
	nnoremap <space>wh <C-w>h
	nnoremap <space>wj <C-w>j
	nnoremap <space>wk <C-w>k
	nnoremap <space>wl <C-w>l

	nnoremap <space>wH <C-w>H
	nnoremap <space>wJ <C-w>J
	nnoremap <space>wK <C-w>K
	nnoremap <space>wL <C-w>L

	nnoremap <space>wR <C-w>R

	" Make splits equal
	nnoremap <space>w= <C-w>=

	" easy lines space
	nnoremap [<space> O<Esc>
	nnoremap ]<space> o<Esc>

	" easy resizing
	nnoremap <C-Left>	:vertical resize +5
	nnoremap <C-Right>	:vertical resize -5
	nnoremap <C-Up>		:resize +5
	nnoremap <C-Down>	:resize -5

	" Shortcut close window
	map Q <C-w>c

	" Mapping terminal exit to <Esc>
	tnoremap <Esc> <C-\><C-n>

	" split resizing bindings
	nnoremap ,vr :vertical resize
	nnoremap ,hr :resize

	" quickstart
	nnoremap <space>ec  :edit ~/.config/nvim/init.vim<CR>
	nnoremap <space>es  :edit ~/.local/bin/schedule<CR>
	nnoremap <space>et  :edit ~/vimwiki/TODO list.wiki<CR>
	nnoremap <space>ei  :edit ~/vimwiki/Improvement list.wiki<CR>
	nnoremap ,zsh  :edit ~/.zshrc<CR>
	nnoremap ,i3   :edit ~/.config/i3/config<CR>
	nnoremap ,i3b  :edit ~/.config/i3blocks/config<CR>
	nnoremap ,vi   :edit ~/.vimrc<CR>

	" select all
	nnoremap <M-a> ggvG$
	inoremap <M-a> <Esc>ggvG$

	" terminal
	nnoremap <space>tg :split<CR>:te<CR>
	nnoremap <space>tv :vs<CR>:te<CR>

	" close buffer
	nnoremap <space>bd :bd<CR>

	" remove annoying highlights
	nnoremap <leader>n :noh<CR>

	" seems wrong, Y?
	nnoremap Y y$

	" easier navigation when dealing with text not code
	nnoremap j gj
	nnoremap k gk

" vscode-like terminal
	" Toggle 'default' terminal
	nnoremap <space>" :call ChooseTerm("term-slider", 1)<CR>
	" Start terminal in current pane
	nnoremap <space>' :call ChooseTerm("term-slider", 0)<CR>

	function! ChooseTerm(termname, slider)
		let pane = bufwinnr(a:termname)
		let buf = bufexists(a:termname)
		if pane > 0
			" pane is visible
			if a:slider > 0
				:exe pane . "wincmd c"
			else
				:exe "e #"
			endif
		elseif buf > 0
			" buffer is not in pane
			if a:slider
				:exe "split"
			else
				:exe "vertical split"
			endif
			:exe "buffer " . a:termname
		else
			" buffer is not loaded, create
			if a:slider
				:exe "split"
			else
				:exe "vertical split"
			endif
			:terminal
			:exe "f " a:termname
		endif
	endfunction

" Vim GDB
let g:termdebug_useFloatingHover = 0
let g:nvimgdb_config_override = {
  \ 'key_next': 'n',
  \ 'key_step': 's',
  \ 'key_finish': 'f',
  \ 'key_continue': 'c',
  \ 'key_until': 'u',
  \ 'key_breakpoint': 'b',
  \ 'set_tkeymaps': "NvimGdbNoTKeymaps",
  \ 'key_eval':       'p',
  \ 'key_quit':       'q',
  \ }

" Neovide
let g:neovide_refresh_rate=60
set guifont=FiraCode:h18

" Needed to parse header files as C, comment out when not needed
" autocmd BufNewFile,BufRead,BufEnter *.h setfiletype c

lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "rust", "c", "cpp", "toml", "yaml" },
  highlight = {
    enable = true,
  },
}
EOF
