source ~/.bashrc
source ~/dotfiles/bin/.git-prompt.sh

PS1='\W \[\e[1;32m\]$(__git_ps1 "(%s)")\[\e[0m\] \$ '

export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
if command -v rbenv 1>/dev/null 2>&1
then
  eval "$(rbenv init -)"
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1
then
  eval "$(pyenv init -)"
fi

# Ubunts 20.04
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

export NVM_DIR="$HOME/.nvm"
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && . "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"
