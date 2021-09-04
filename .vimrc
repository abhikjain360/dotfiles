
" vim: set foldmethod=indent

" Basic settings
    let mapleader=","
    set nu
    set rnu
    set showcmd
    syntax on
    filetype on
    set autoindent
    set tabstop=4
    set shiftwidth=4
    set clipboard+=unnamedplus
    set shell=/bin/zsh
    set encoding=utf-8
    set mouse=av
    set term=xterm
    set hidden
    set scrolloff=4


" make the arrows work
    inoremap OC <right>
    inoremap OD <left>

" I can comment myself
    set formatoptions-=c
    set formatoptions-=r
    set formatoptions-=o

" remove extra whitespaces and empty lines
    " autocmd BufWritePre * %s/\s\+$//e
    " autocmd BufWritepre * %s/\n\+\%$//e

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
    set bg=dark
    autocmd vimenter * ++nested colorscheme gruvbox

" Clang completion
    let g:clang_library_path='/usr/lib/libclang.so'

" remaps
    " I want to use homekeys only
    nnoremap <Up>       <Nop>
    nnoremap <Down>     <Nop>
    nnoremap <Right>    <Nop>
    nnoremap <Left>     <Nop>
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
    nnoremap <Up>       <Nop>
    nnoremap <Down>     <Nop>
    nnoremap <Right>    <Nop>
    nnoremap <Left>     <Nop>
    " Save key
    nnoremap <C-s> :w<CR>
    inoremap <C-s> <Esc>:w<CR>i
    " I don't like pressing shift
    nnoremap ; :
    " easy buffer shifts
    nnoremap <Right>    :bn<CR>
    nnoremap <Left>     :bp<CR>
