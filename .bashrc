export EDITOR='nvim'
export VISUAL='nvim'

### Readable prompt
export PS1=$'\n'"\[\e[33;1m\]\u\[\e[m\]@\[\e[34m\]\h\[\e[m\] \[\e[32m\]\W\[\e[m\]"$'\n'"\$ "

export PATH="/home/kaka/.config/nvm/versions/node/v15.0.0/bin:/home/kaka/.gem/ruby/2.7.0/bin:/home/kaka/.cargo/bin:/home/kaka/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/opt/android-sdk/platform-tools"

#### This loads nvm
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

### Better output from common commands
alias la="ls -Al --color -X --group-directories-first"
alias lag="ls -Al --color -X --group-directories-first | less -r"
alias greppy="grep -i --color=auto"
alias mv="mv -v"
alias mkdir="mkdir -vp"
alias cp="cp -v -ir"
alias rm="rm -v -ir"

### get Rusty goodness
# source "$HOME/.cargo/env"
