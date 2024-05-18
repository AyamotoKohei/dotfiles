# dotfiles
macOSとUbuntu 20.04(WSL2)用のdotfilesです<br>
他のLinux OSはサポートしていません<br>

## インストール手順
<!-- ここにインストール手順を記載する -->
.Brewfile のシンボリックリンクを貼る
```script
ln -s ~/dotfiles/.Brewfile ~/.Brewfile
```

zsh の設定ファイルのシンボリックリンクを貼る
```script
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -s ~/dotfiles/zsh/.zprofile ~/.zprofile
```
neovim の設定ファイルのシンボリックリンクを貼る
```script
ln -s ~/dotfiles/nvim ~/.config
```

## 参考文献
<!-- https://kisqragi.hatenablog.com/entry/2020/02/17/224129<br> -->
