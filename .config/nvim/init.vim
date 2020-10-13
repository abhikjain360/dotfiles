let mapleader =","

call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
	Plug 'tpope/vim-surround'
	Plug 'bling/vim-airline'
	Plug 'dense-analysis/ale'
	Plug 'ap/vim-css-color'
	Plug 'jiangmiao/auto-pairs'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'sonph/onehalf', {'rtp': 'vim/'}
	Plug 'dracula/vim',{ 'as': 'dracula' }
	Plug 'machakann/vim-highlightedyank'
	Plug 'morhetz/gruvbox'
	Plug 'tomasr/molokai', { 'as': 'molokai' }
	Plug 'ayu-theme/ayu-vim'
	Plug 'lervag/vimtex', { 'for': 'tex' }
	Plug 'sirver/ultisnips', { 'for': 'tex' }
	Plug 'octol/vim-cpp-enhanced-highlight', { 'for': 'cpp' }
	Plug 'gabrielelana/vim-markdown', { 'for': 'markdown' }
	Plug 'tpope/vim-abolish'
	Plug 'ziglang/zig.vim', { 'for': 'zig' }
	Plug 'crusoexia/vim-monokai'
	Plug 'rust-lang/rust.vim', { 'for': 'rust' }
	Plug 'tikhomirov/vim-glsl', { 'for': 'glsl' }
	Plug 'mbbill/undotree'
	Plug 'terryma/vim-multiple-cursors'
	Plug 'ollykel/v-vim', { 'for': 'vlang' }
	Plug 'mattn/emmet-vim', { 'for': 'html' }
        Plug 'airblade/vim-gitgutter'
        Plug 'lifepillar/pgsql.vim', { 'for': ['sql','pgsql'] }
        Plug 'junegunn/vim-easy-align'
        Plug 'sakhnik/nvim-gdb' { 'for': ['c','cpp','h','hpp'] }
call plug#end()

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
	autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Spell-check set to <leader>o, 'o' for 'orthography':
	map <leader>o :setlocal spell! spelllang=en_gb<CR>

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
	set splitbelow
	set splitright

" Shortcutting split navigation, saving a keypress:
	map <C-h> <C-w>h
	map <C-j> <C-w>j
	map <C-k> <C-w>k
	map <C-l> <C-w>l

" Save file as sudo on files that require root permission
	cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Automatically deletes all trailing whitespace and newlines at end of file on save.
	autocmd BufWritePre * %s/\s\+$//e
	"autocmd BufWritepre * %s/\n\+\%$//e

" Highlighting the yanked likes
	let g:highlightedyank_highlight_duration = 1000
	hi HighlightedyankRegion cterm=reverse gui=reverse

" Python location
	let g:python3_host_prog='/home/abhik/pymaths/bin/python'

" Mapping terminal exit to <Esc>
	tnoremap <Esc> <C-\><C-n>

" code to save folds
	autocmd BufWinLeave *.* mkview
	autocmd BufWinEnter *.* silent loadview
	set foldnestmax=1       "deepest fold level
	set nofoldenable        "dont fold by default
	set foldmethod=manual

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
	xmap <leader>a  <Plug>(coc-codeaction-selected)
	nmap <leader>a  <Plug>(coc-codeaction-selected)

	" Formatting selected code.
	xmap <leader>f  <Plug>(coc-format-selected)
	nmap <leader>f  <Plug>(coc-format-selected)

	" Remap keys for applying codeAction to the current buffer.
	nmap <leader>ac  <Plug>(coc-codeaction)
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
	nmap <silent> <C-s> <Plug>(coc-range-select)
	xmap <silent> <C-s> <Plug>(coc-range-select)

	" Add `:Format` command to format current buffer.
	command! -nargs=0 Format :call CocAction('format')

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
	nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
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

" split resizing bindings
	nnoremap ,vr :vertical resize
	nnoremap ,hr :resize

" quick spacings
	nnoremap ,l o<Esc>
	nnoremap ,L O<Esc>

" buffer save and quit
	nnoremap QQ :w\|bd<CR>

" Theming
	let ayucolor="dark"
	set termguicolors
	let g:gruvbox_contrast_dark = 'dark'
	let g:airline_theme = 'dracula'
	"let g:airline_powerline_fonts = 1
	colorscheme dracula
	hi Normal guibg=NONE ctermbg=NONE

	function! Tgb()
		colorscheme gruvbox
		let g:airline_theme = 'gruvbox'
	endfunction

	function! Tayu()
		colorscheme ayu
		let g:airline_theme = 'ayu'
	endfunction

	function! Tdra()
		colorscheme dracula
		let g:airline_theme = 'dracula'
	endfunction

	nnoremap ,tgb  :call Tgb()<CR>:call Tgb()<CR>
	nnoremap ,tau  :call Tayu()<CR>:call Tayu()<CR>
	nnoremap ,tdc  :call Tdra()<CR>:call Tdra()<CR>

" quickstart
	nnoremap ,nvi  :edit ~/.config/nvim/init.vim<CR>
	nnoremap ,zsh  :edit ~/.zshrc<CR>
	nnoremap ,st   :edit /home/shared/packages/my_configs/st-0.8.3/config.h<CR>
	nnoremap ,dwm  :edit /home/shared/packages/my_configs/dwm/config.h<CR>
	nnoremap ,dwmb :edit /home/shared/packages/my_configs/dwmblocks/blocks.h<CR>
	nnoremap ,i3   :edit ~/.config/i3/config<CR>
	nnoremap ,i3b  :edit ~/.config/i3blocks/config<CR>
	nnoremap ,vi   :edit ~/.vimrc<CR>
	nnoremap QQ    :w\|bd<CR>
	"nnoremap ,ttet :tabnew|te<CR>
	"nnoremap ,ev :vs|te<CR>
	"nnoremap ,es :sp|te<CR>

" remaps
	" I want to use homekeys only
	nnoremap <Up> 		<Nop>
	nnoremap <Down> 	<Nop>
	nnoremap <Right> 	<Nop>
	nnoremap <Left> 	<Nop>
	" I don't like pressing shift
	nnoremap ; :
	" easy buffer shifts
	nnoremap <Right> 	:bn<CR>
	nnoremap <Left> 	:bp<CR>

" special map find and change
        nnoremap ,m /<++><CR>cf>
        inoremap ,m <Esc>/<++><CR>cf>


if &term =~ '256color'
    " disable Background Color Erase (BCE) so that color schemes
    " render properly when inside 256-color tmux and GNU screen.
    " see also http://sunaku.github.io/vim-256color-bce.html
    set t_ut=
endif

let g:sql_type_default = 'pgsql'

" EasyAlign settings
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
