export EDITOR='nvim'
export VISUAL='nvim'

### Readable prompt
export PS1=$'\n'"\[\e[33;1m\]\u\[\e[m\]@\[\e[34m\]\h\[\e[m\] \[\e[32m\]\W\[\e[m\]"$'\n'"\e[1;95mλ \e[0m"

#### This loads nvm
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

### Better output from common commands
alias la="ls -Al --color -X --group-directories-first"
alias lag="ls -Al --color -X --group-directories-first | less -r"
alias greppy="grep -i --color=auto"
alias mv="mv -v"
alias mkdir="mkdir -vp"
alias cp="cp -v -r"
alias rm="rm -v -r"
. "$HOME/.cargo/env"
