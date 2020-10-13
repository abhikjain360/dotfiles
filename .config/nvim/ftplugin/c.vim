" C++ settings
set path=.,/usr/include/,/usr/local/include/
set tabstop=4
set shiftwidth=4
set scrolloff=10

" formatting command (astyle must be installed, only works for c/c++)
	" -A2 attached brackets
	" -s4 indent 4 spaces
	" -xc attached braces to class declarations
	" -xj remove braces for single statement ifs and elses
	" -c convert tabs to spaces in the non-indentation part of the line
	"  styles available : google,ansi
	"map <C-S-i> :%!astyle -A2 -t -s4 --style=google<CR>
	nnoremap <leader>f :%!clang-format<CR>

" Bracket manupulation
     	nnoremap ,sb ddkA {<Return>}<Esc>P
     	nnoremap ,db k0f{ma%dd`ax
