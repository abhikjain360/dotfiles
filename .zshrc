# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ $- != *i* ]]; then
	return
fi

# completion cache path setup
typeset -g comppath="$HOME/.cache"
typeset -g compfile="$comppath/.zcompdump"

if [[ -d "$comppath" ]]; then
	[[ -w "$compfile" ]] || rm -rf "$compfile" >/dev/null 2>&1
else
	mkdir -p "$comppath"
fi

# zsh internal stuff
SHELL=/bin/zsh
KEYTIMEOUT=0
SAVEHIST=10000
HISTSIZE=10000
HISTFILE="$HOME/.cache/.zsh_history"

# completion
setopt CORRECT
setopt NO_NOMATCH
setopt LIST_PACKED
setopt ALWAYS_TO_END
setopt NOCASEGLOB
setopt NUMERICGLOBSORT
setopt GLOB_COMPLETE
setopt COMPLETE_ALIASES
setopt COMPLETE_IN_WORD

# builtin command behaviour
setopt AUTO_CD

# job control
setopt AUTO_CONTINUE
setopt LONG_LIST_JOBS

# history control
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS

# misc
setopt EXTENDED_GLOB
setopt TRANSIENT_RPROMPT
setopt INTERACTIVE_COMMENTS


autoload -U compinit     # completion
autoload -U terminfo     # terminfo keys
zmodload -i zsh/complist # menu completion
autoload -U promptinit   # prompt

first_tab() # on first tab without any text it will list the current directory
{ # empty line tab lists
	if [[ $#BUFFER == 0 ]]; then
		BUFFER="cd " CURSOR=3
		zle list-choices
		BUFFER="" CURSOR=1
	else
		zle expand-or-complete
	fi
}; zle -N first_tab

exp_alias() # expand aliases to the left (if any) before inserting the key pressed
{ # expand aliases
	zle _expand_alias
	zle self-insert
}; zle -N exp_alias

# bind keys not in terminfo
bindkey -- '^P'   up-history
bindkey -- '^N'   down-history
bindkey -- '^E'   end-of-line
bindkey -- '^A'   beginning-of-line

# vi bindings
bindkey -v

# default shell behaviour using terminfo keys
[[ -n ${terminfo[kdch1]} ]] && bindkey -- "${terminfo[kdch1]}" delete-char                   # delete
[[ -n ${terminfo[kend]}  ]] && bindkey -- "${terminfo[kend]}"  end-of-line                   # end
[[ -n ${terminfo[kcuf1]} ]] && bindkey -- "${terminfo[kcuf1]}" forward-char                  # right arrow
[[ -n ${terminfo[kcub1]} ]] && bindkey -- "${terminfo[kcub1]}" backward-char                 # left arrow
[[ -n ${terminfo[kich1]} ]] && bindkey -- "${terminfo[kich1]}" overwrite-mode                # insert
[[ -n ${terminfo[khome]} ]] && bindkey -- "${terminfo[khome]}" beginning-of-line             # home
[[ -n ${terminfo[kbs]}   ]] && bindkey -- "${terminfo[kbs]}"   backward-delete-char          # backspace
[[ -n ${terminfo[kcbt]}  ]] && bindkey -- "${terminfo[kcbt]}"  reverse-menu-complete         # shift-tab
[[ -n ${terminfo[kcuu1]} ]] && bindkey -- "${terminfo[kcuu1]}" up-line-or-search   # up arrow
[[ -n ${terminfo[kcud1]} ]] && bindkey -- "${terminfo[kcud1]}" down-line-or-search # down arrow

# correction
zstyle ':completion:*:correct:*' original true
zstyle ':completion:*:correct:*' insert-unambiguous true
zstyle ':completion:*:approximate:*' max-errors 'reply=($(( ($#PREFIX + $#SUFFIX) / 3 )) numeric)'

# completion
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$comppath"
zstyle ':completion:*' rehash true
zstyle ':completion:*' verbose true
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:-command-:*:' verbose false
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*:manuals.*' insert-sections true
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*' completer _complete _match _approximate _ignored
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# labels and categories
zstyle ':completion:*' group-name ''
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{green}->%F{yellow} %d%f'
zstyle ':completion:*:messages' format ' %F{green}->%F{purple} %d%f'
zstyle ':completion:*:descriptions' format ' %F{green}->%F{yellow} %d%f'
zstyle ':completion:*:warnings' format ' %F{green}->%F{red} no matches%f'
zstyle ':completion:*:corrections' format ' %F{green}->%F{green} %d: %e%f'

# menu colours
eval "$(dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=36=0=01'

# command parameters
zstyle ':completion:*:functions' ignored-patterns '(prompt*|_*|*precmd*|*preexec*)'
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'
zstyle ':completion:*:(vim|nvim|vi|nano):*' ignored-patterns '*.(wav|mp3|flac|ogg|mp4|avi|mkv|iso|so|o|7z|zip|tar|gz|bz2|rar|deb|pkg|gzip|pdf|png|jpeg|jpg|gif)'

# hostnames and addresses
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'
zstyle -e ':completion:*:hosts' hosts 'reply=( ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ } ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*} ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}})'
ttyctl -f

# exapnd aliases
zstyle ':completion:*' completer _expand_alias _complete _ignored

# initialize completion
compinit -u -d "$compfile"


# Print some greetings
#echo -e "\e[36;1m$USER\e[39;1m@\e[34;1m$HOST"$'\n'"\e[0m$(uname -srm)"$'\n'"$(date +"%y/%m/%d (%a) %H:%M:%S")"$'\n\n'

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-r

#PROMPT=$'\n'"%F{11}%n%f@%F{13}%m%f:%F{10}%~%f"$'\n'"$%B%F{26}$%f%b%B%F{14}$%f%b "

source $HOME/.local/share/zsh/powerlevel10k/powerlevel10k.zsh-theme

## for git prompt https://joshdick.net/2012/12/30/my_git_prompt_for_zsh.html
#setopt prompt_subst
#autoload -U colors && colors # Enable colors in prompt
#
## Modify the colors and symbols in these variables as desired.
#GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"
#GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
#GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
#GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
#GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
#GIT_PROMPT_MERGING="%{$fg[magenta]%}⚡︎%{$reset_color%}"
#GIT_PROMPT_UNTRACKED="%{$fg[red]%}U%{$reset_color%}"
#GIT_PROMPT_MODIFIED="%{$fg[yellow]%}M%{$reset_color%}"
#GIT_PROMPT_STAGED="%{$fg[green]%}S%{$reset_color%}"
#
## Show Git branch/tag, or name-rev if on detached head
#parse_git_branch() {
#  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
#}
#
## Show different symbols as appropriate for various Git repository states
#parse_git_state() {
#
#  # Compose this value via multiple conditional appends.
#  local GIT_STATE=""
#
#  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
#  if [ "$NUM_AHEAD" -gt 0 ]; then
#    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
#  fi
#
#  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
#  if [ "$NUM_BEHIND" -gt 0 ]; then
#    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
#  fi
#
#  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
#  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
#    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
#  fi
#
#  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
#    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
#  fi
#
#  if ! git diff --quiet 2> /dev/null; then
#    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
#  fi
#
#  if ! git diff --cached --quiet 2> /dev/null; then
#    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
#  fi
#
#  if [[ -n $GIT_STATE ]]; then
#    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
#  fi
#
#}
#
## If inside a Git repository, print its branch and state
#git_prompt_string() {
#  local git_where="$(parse_git_branch)"
#  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
#}
#
## Set the right-hand prompt
#RPS1='$(git_prompt_string)'

#### Load plugins

# zsh-completions
#fpath=(~/.local/share/zsh/zsh-completions/src $fpath)

# zsh-autosuggestions
source ~/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-history-substring-search
source ~/.local/share/zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# fast-syntax-highlighting
source ~/.local/share/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh


#### Prettier view
alias la='exa -al --color=always --group-directories-first'
alias lag='exa -al --color=always --group-directories-first | less -r'
alias mv='mv -v'
alias mkdir='mkdir -vp'
alias rm='rm -vr'
alias cp='cp -rv'

#### Docker aliases
alias sdk='sudo systemctl start docker.service'
alias qdk='sudo systemctl stop docker.service'
alias dks='docker start'
alias dkq='docker stop'
alias dkx='docker exec -ti'
alias dkd='docker rm'
alias dkp='docker ps -a'
alias dki='docker images'
alias dkr='docker run'

#### Systemd aliases
alias sys='sudo systemctl start'
alias syq='sudo systemctl stop'
alias syr='sudo systemctl restart'
alias syt='sudo systemctl status'

#### Auto open neovim
alias -s {cpp,hpp,c,h,py}='nvim'
alias -s {yaml,js,json,sql}='nvim'
alias -s {txt,markdown,md}='nvim'
alias -s {README,LICENSE}='nvim'
alias -s {conf,config,vim}='nvim'
alias -s {toml,lock,rs}='nvim'

#### Auto open zathura
alias setz='setsid zathura'

#### nvim always
alias v='nvim'

#### YouTube songs download
alias ysd='youtube-dl -f bestaudio'

#### Discord MPD
alias mpd_discord_richpresence='mpd_discord_richpresence -h=192.168.29.118 -p=6600 --fork -h=192.168.29.118 -p=6600 --fork'

#### Quick study book find
#alias stub="setsid zathura \"\$(find $HOME/study | fzf)\""

#### tlmgr package manager for TeX
alias tlmgr='/usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode'

#### Required by some packages
export EDITOR='/usr/bin/nvim'
export TERMINAL='/usr/bin/st'
export VISUAL='/usr/bin/nvim'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# zoxide eval for fast folder movement
eval "$(zoxide init zsh)"
export _ZO_DATA_DIR="$HOME/.cache/zoxide/"
