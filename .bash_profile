source ~/.bashrc
source ~/.git-prompt.sh

PS1='\W \[\e[1;32m\]$(__git_ps1 "(%s)")\[\e[0m\] \$ '

eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

export NVM_DIR="$HOME/.nvm"
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && . "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"


