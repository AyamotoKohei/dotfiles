# Shell 再起動時にエイリアスを読み込んで欲しいので記述
source ~/.zprofile

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

# powerlevel10k の設定ファイルの読み込み先をアプリごとに変更
if [[ $TERM_PROGRAM = "WarpTerminal" ]]; then
  # Warp
  source ~/dotfiles/p10k/warp/.p10k.zsh
else
  # Terminal
  source ~/dotfiles/p10k/terminal/.p10k.zsh
fi

# Gitのタブ補完を有効化する
autoload -Uz compinit && compinit

# rbenv の設定
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
if command -v rbenv 1>/dev/null 2>&1
then
  eval "$(rbenv init -)"
fi

# GitHub CLIのコマンド補完の設定
eval "$(gh completion -s zsh)"

# asdf の設定
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# postgresql のパスの設定
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
