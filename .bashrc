# bash_historyの設定
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

# エイリアスの設定
alias ls='ls --color=auto -lG'
alias la='ls --color=auto -A'
alias nl='nl -b a -s '\'': '\'''
alias re='history -a ~/.bash_history; exec $SHELL -l'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'