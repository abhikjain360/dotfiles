" VIM PLUG SETTINGS

call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
	" brackets
	Plug 'tpope/vim-surround'
	Plug 'jiangmiao/auto-pairs'

	" themes
	Plug 'dracula/vim',{ 'as': 'dracula' }
	Plug 'morhetz/gruvbox'

	" better syntax highlighting
	Plug 'ap/vim-css-color'
	Plug 'octol/vim-cpp-enhanced-highlight', { 'for': 'cpp' }

	" utility
	Plug 'tpope/vim-abolish'
	Plug 'mbbill/undotree'
	Plug 'terryma/vim-multiple-cursors'
    Plug 'junegunn/vim-easy-align'
	Plug 'preservim/nerdcommenter'

	" notes management
	Plug 'vimwiki/vimwiki'

	" git
    Plug 'airblade/vim-gitgutter'

	" lightline + bufferline
	Plug 'itchyny/lightline.vim'
	Plug 'mengelbrecht/lightline-bufferline'

	" file browsing
	Plug 'lambdalisue/fern.vim'
	Plug 'lambdalisue/fern-renderer-nerdfont.vim'
	Plug 'lambdalisue/fern-git-status.vim'
	Plug 'lambdalisue/nerdfont.vim'
	" this needed for some problem
	Plug 'antoinemadec/FixCursorHold.nvim'

	" code completion/linting
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'lervag/vimtex', { 'for': 'tex' }
	Plug 'gabrielelana/vim-markdown', { 'for': 'markdown' }
	Plug 'rust-lang/rust.vim', { 'for': 'rust' }
	Plug 'tikhomirov/vim-glsl', { 'for': 'glsl' }
	Plug 'mattn/emmet-vim', { 'for': 'html' }
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
	" start scrolling with 8 lines gap
	"set scrolloff=8
	set shell=/usr/bin/zsh
	set modeline
	set modelines=2
	set hidden
	set cmdheight=2
	set updatetime=100
	set signcolumn=yes
	" don't redraw screen so often
	set lazyredraw
	set encoding=utf-8
	set autochdir
    set scrolloff=8

" Enable autocompletion:
	set wildmode=longest,list,full
	set wildmenu
	set showcmd

" Disables automatic commenting on newline:
	autocmd FileType * setlocal formatoptions-=r formatoptions-=o

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
	set splitbelow
	set splitright

" Save file as sudo on files that require root permission
	cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Automatically deletes all trailing whitespace and newlines at end of file on save.
	autocmd BufWritePre * %s/\s\+$//e
	"autocmd BufWritepre * %s/\n\+\%$//e

" Python location
	let g:python3_host_prog='/usr/bin/python'

" Spell-check set to <leader>o, 'o' for 'orthography':
	map <leader>o :setlocal spell! spelllang=en_gb<CR>

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
	nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
	" Manage extensions.
	"nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
	" Show commands.
	nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
	" Find symbol of current document.
	nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
	" Search workspace symbols.
	nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
	" Do default action for next item.
	nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
	" Do default action for previous item.
	nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
	" Resume latest coc list.
	nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" lightline/bufferline Settings

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
"g:lightline#bufferline#modified             = ' +'

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

" Fern Settings

" needed for some problem
let g:cursorhold_updatetime = 100
" icons
let g:fern#renderer = "nerdfont"

" configs
let g:fern#drawer_width = 30
let g:fern#default_hidden = 1
let g:fern#disable_drawer_smart_quit = 1

" mapping
nnoremap <space>ft :Fern . -drawer -toggle <CR>
function! s:init_fern() abort
  nmap <buffer> H <Plug>(fern-action-open:split)
  nmap <buffer> V <Plug>(fern-action-open:vsplit)
  nmap <buffer> o <Plug>(fern-action-open:select)
  nmap <buffer> R <Plug>(fern-action-rename)
  nmap <buffer> M <Plug>(fern-action-move)
  nmap <buffer> C <Plug>(fern-action-copy)
  nmap <buffer> N <Plug>(fern-action-new-file)
  nmap <buffer> D <Plug>(fern-action-new-dir)
  nmap <buffer> dD <Plug>(fern-action-remove)
  nmap <buffer> s <Plug>(fern-action-hidden-toggle)
  nmap <buffer> m <Plug>(fern-action-mark)
  nmap <buffer> / <Plug>(fern-action-grep)
  nmap <buffer> yp <Plug>(fern-action-yank:path)
  nmap <buffer> t <Plug>(fern-action-terminal:select)
endfunction

augroup fern-custom
  autocmd! *
  autocmd FileType fern call s:init_fern()
augroup END

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
	let g:gruvbox_contrast_dark = 'hard'
	let g:gruvbox_italic = 0
	let g:gruvbox_bold = 1
	colorscheme gruvbox
	set background=dark
	hi Normal guibg=NONE ctermbg=NONE


" KEY BINDINGS
	" I want to use homekeys only
	nnoremap <Up>		<Nop>
	nnoremap <Down>		<Nop>
	nnoremap <Right>	<Nop>
	nnoremap <Left>		<Nop>

	" I don't like pressing shift
	nnoremap ; :

	" special map find and change
    nnoremap ,m /<++><CR>cf>
    inoremap ,m <Esc>/<++><CR>cf>

	" Shortcutting split navigation
	nnoremap <space>wh <C-w>h
	nnoremap <space>wj <C-w>j
	nnoremap <space>wk <C-w>k
	nnoremap <space>wl <C-w>l

	" Shortcutting split navigation
	nnoremap <space>wH <C-w>H
	nnoremap <space>wJ <C-w>J
	nnoremap <space>wK <C-w>K
	nnoremap <space>wL <C-w>L

	" easy lines space
	nnoremap [<space> O<Esc>
	nnoremap ]<space> o<Esc>

	" Shortcut close window
	map Q <C-w>c

	" Mapping terminal exit to <Esc>
	tnoremap <Esc> <C-\><C-n>

	" split resizing bindings
	nnoremap ,vr :vertical resize
	nnoremap ,hr :resize

	" quickstart
	nnoremap <space>ec  :edit ~/.config/nvim/init.vim<CR>
	nnoremap ,zsh  :edit ~/.zshrc<CR>
	nnoremap ,i3   :edit ~/.config/i3/config<CR>
	nnoremap ,i3b  :edit ~/.config/i3blocks/config<CR>
	nnoremap ,vi   :edit ~/.vimrc<CR>

	" terminal
	nnoremap <space>tg :split<CR>:te<CR>
	nnoremap <space>tv :vs<CR>:te<CR>

	" close buffer
	nnoremap <space>bd :bd<CR>
