# dotfiles
macOSとUbuntu 20.04(WSL2)用のdotfilesです<br>
他のLinux OSはサポートしていません<br>

## インストール手順
<!-- ここにインストール手順を記載する -->
1. zsh の設定ファイルのシンボリックリンクを貼る
```bash
$ ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
$ ln -s ~/dotfiles/zsh/.zprofile ~/.zprofile
```

2. .zshrc の再読み込みを行う
```bash
$ source ~/.zshrc
```

3. [Homebrew](https://brew.sh/ja/) 公式ドキュメントからインストールスクリプトをコピーして、ターミナルに貼り付けて実行する
```bash
# 2024年5月20日現在のインストールコマンド
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

4. .Brewfile のシンボリックリンクを貼る
```bash
$ ln -s ~/dotfiles/.Brewfile ~/.Brewfile
```

5. neovim の設定ファイルのシンボリックリンクを貼る
```bash
$ ln -s ~/dotfiles/nvim ~/.config
```
<!--
## 各種アプリケーションの設定
### macOS
### ターミナル
### Warp -->

## .Brewfile の更新
```bash
$ brew bundle dump --global --force
```
