export EDITOR='vim'

### Readable prompt
export PS1=$'\n'"\[\e[33;1m\]\u\[\e[m\]@\[\e[34m\]\h\[\e[m\] \[\e[32m\]\W\[\e[m\]"$'\n'"\$ "

### Better output from common commands
alias la="ls -Al --color -X --group-directories-first"
alias lag="ls -Al --color -X --group-directories-first | less -r"
alias greppy="grep -i --color=auto"
alias mv="mv -v"
alias mkdir="mkdir -vp"
alias cp="cp -v -ir"
alias rm="rm -v -ir"
alias -p v="nvim"
