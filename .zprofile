# エイリアスの設定
alias ls='ls -lG'
alias tree='tree -a'
alias brew="PATH=/opt/homebrew/bin brew"
alias la='ls -A'
alias nl='nl -b a -s '\'': '\'''
alias re='exec $SHELL -l'
alias net='networkQuality'
alias vim='nvim'

alias gs='git status' # git statusの確認
alias gd='git diff' # git diffの確認
alias ga='git add' # addする
alias gb='git branch' # branchを行う
alias gc='git commit' # commitする
alias gcm='git commit -m' # commitをmオプション付きでする
alias gco='git checkout' #checkoutする
alias gp='git push' # pushする
alias gca='git commit --amend' # 前のコミットの編集
alias glo='git log --oneline' # コミットログを各一行で読む
alias mkpr='hub pull-request' # PRを書く
alias prs='ghi | grep ↑' # 現在のレポジトリのPR取得
alias gbm='git branch --merged | grep -v main' # main を除くマージ済みのブランチを取得
