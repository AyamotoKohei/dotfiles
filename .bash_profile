source ~/.bashrc
source ~/dotfiles/bin/.git-prompt.sh

PS1='\W \[\e[1;32m\]$(__git_ps1 "(%s)")\[\e[0m\] \$ '

# rbenvの設定
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
if command -v rbenv 1>/dev/null 2>&1
then
  eval "$(rbenv init -)"
fi

# pyenvの設定
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1
then
  eval "$(pyenv init -)"
fi