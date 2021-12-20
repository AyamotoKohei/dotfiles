source ~/.bashrc
source ~/dotfiles/bin/.git-prompt.sh

# 表示設定
PS1='\W \[\e[1;32m\]$(__git_ps1 "(%s)")\[\e[0m\] \$ '

# Homebrewのパスを通すための設定
export PATH="/opt/homebrew/bin:$PATH"

# default interactive shell is now zsh...のメッセージを抑制する設定
export BASH_SILENCE_DEPRECATION_WARNING=1

# rbenvの設定
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
if command -v rbenv 1>/dev/null 2>&1
then
  eval "$(rbenv init -)"
fi

# pyenvの設定
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PATH"
if command -v pyenv 1>/dev/null 2>&1
then
  eval "$(pyenv init -)"
fi

# nvmの設定
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
