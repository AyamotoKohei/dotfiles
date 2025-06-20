# Shell 再起動時にエイリアスを読み込んで欲しいので記述
source ~/.zprofile

# バックグラウンドで ssh-agent を開始
eval "$(ssh-agent -s)"

# Homebrew のパスを通す
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

# zinit を読み込む
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# zsh プラグイン関連の読み込み
zinit ice depth=1;
zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# powerlevel10k の読み込み
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source ~/dotfiles/zsh/p10k/.p10k.zsh

# Gitのタブ補完を有効化する
autoload -Uz compinit && compinit

# GitHub CLIのコマンド補完の設定
eval "$(gh completion -s zsh)"

# asdf の設定
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# postgresql のパスの設定
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/kohei.ayamoto/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
