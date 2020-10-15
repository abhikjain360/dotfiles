
" vim: set foldmethod=indent

" Basic settings
	let mapleader=","
	set nu
	set rnu
	set showcmd
	syntax on
	filetype on
	set autoindent
	set tabstop=8
	set shiftwidth=8
	set clipboard+=unnamedplus
	set shell=/bin/zsh
	set encoding=utf-8
	set mouse=v
	set term=xterm
	set hidden

" Vim Plug
call plug#begin('~/.vim/plugged')
	Plug 'Shougo/deoplete.nvim'
	Plug 'roxma/nvim-yarp'
	Plug 'roxma/vim-hug-neovim-rpc'
	Plug 'Shougo/deoplete-clangx'
	Plug 'morhetz/gruvbox'
	Plug 'octol/vim-cpp-enhanced-highlight'
	Plug 'dense-analysis/ale'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'jiangmiao/auto-pairs'
call plug#end()

" make the arrows work
	inoremap OC <right>
	inoremap OD <left>

" I can comment myself
	set formatoptions-=c
	set formatoptions-=r
	set formatoptions-=o

" remove extra whitespaces and empty lines
	autocmd BufWritePre * %s/\s\+$//e
	"autocmd BufWritepre * %s/\n\+\%$//e

" Each file is unique
	set modeline
	set modelines=2
	set t_Co=256

" help me type
	set wildmode=longest,list,full
	set wildmenu

" non-retarded splitiing
	set splitbelow splitright

" Let me though splits faster
	map <C-h> <C-w>h
	map <C-j> <C-w>j
	map <C-k> <C-w>k
	map <C-l> <C-w>l

" terminal won't let me leave
	tnoremap <Esc> <C-\><C-n>

" save the folds
	autocmd BufWinLeave *.* mkview
	autocmd BufWinEnter *.* silent loadview
	set foldnestmax=1
	set foldmethod=manual

" resize quickly
	nnoremap ,vr :vertical resize
	nnoremap ,hr :resize

" add line quickly
	nnoremap nl o<Esc>
	nnoremap nL O<Esc>

" files shortcut
	nnoremap ,vi :edit ~/.vimrc<CR>GG
	nnoremap ,zsh :edit ~/.zshrc<CR>GG
	nnoremap ,nvi :edit ~/.config/nvim/init.vim<CR>GG

" use the tab for completion
	function! InsertTabWrapper()
		let col = col('.') - 1
		if !col || getline('.')[col - 1] !~ '\k'
			return "\<tab>"
		else
			return "\<c-p>"
		endif
	endfunction

	inoremap <expr> <tab> InsertTabWrapper()
	inoremap <s-tab> <c-n>

" Let me theme
	"set termguicolors
	set bg=dark
	"colorscheme gruvbox

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

" Clang completion
	let g:clang_library_path='/usr/lib/libclang.so'

" remaps
	" I want to use homekeys only
	nnoremap <Up> 		<Nop>
	nnoremap <Down> 	<Nop>
	nnoremap <Right> 	<Nop>
	nnoremap <Left> 	<Nop>
	" Save key
	nnoremap <C-s> :w<CR>
	inoremap <C-s> <Esc>:w<CR>i
	" I don't like pressing shift
	nnoremap ; :
	" easy buffer shifts
	nnoremap <C-Tab> :bn<CR>
	inoremap <C-Tab> <Esc>:bn<CR>i

" remaps
	" I want to use homekeys only
	nnoremap <Up> 		<Nop>
	nnoremap <Down> 	<Nop>
	nnoremap <Right> 	<Nop>
	nnoremap <Left> 	<Nop>
	" Save key
	nnoremap <C-s> :w<CR>
	inoremap <C-s> <Esc>:w<CR>i
	" I don't like pressing shift
	nnoremap ; :
	" easy buffer shifts
	nnoremap <Right> 	:bn<CR>
	nnoremap <Left> 	:bp<CR>
