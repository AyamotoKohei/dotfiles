# bash_historyの設定
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

# エイリアスの設定
if [ "$(uname)" = 'Darwin' ]; then
    alias ls='ls -lG'
else
    # eval `dircolors ~/.colorrc`
    alias ls='ls --color=auto -lG'
fi
alias la='ls -A'
alias nl='nl -b a -s '\'': '\'''
alias re='history -a ~/.bash_history; exec $SHELL -l'

alias gs='git status' # `git status`の確認 
alias gd='git diff' # `git diff`の確認
alias ga='git add' # addする
alias gc='git commit' # commitする
alias gp='git push' # pushする
alias gca='git commit --amend' # 前のコミットの編集
alias glo='git log --oneline' # コミットログを各一行で読む
alias mkpr='hub pull-request' # PRを書く
alias prs='ghi | grep ↑' # 現在のレポジトリのPR取得

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'