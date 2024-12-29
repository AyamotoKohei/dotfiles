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

5. Homebrew を bundle コマンドを使用して、アプリケーションのインストールを行う
```bash
$ brew bundle --global
```

6. その他のファイルに関しても、適宜シンボリックリンクを貼る
```bash
# Neovim の設定ファイル
$ ln -s ~/dotfiles/nvim ~/.config

# VSCode の設定ファイル
$ rm -rf ~/Library/Application\ Support/Code/User/settings.json
$ ln -s  ~/dotfiles/.vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json

# Warp テーマの有効化
$ ln -s ~/dotfiles/.warp ~/.warp

# Ghostty の設定ファイル
$ rm -rf ~/Library/Application\ Support/com.mitchellh.ghostty/config
$ ln -s ~/dotfiles/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

以上。

<!--
## 各種アプリケーションの設定
### macOS
### ターミナル
### Warp -->

## 各種アプリケーションの設定

### .Brewfile の更新
```bash
$ brew bundle dump --global --force
```

### GitHub の SSH 接続
下記ドキュメントを参考に GitHub との SSH 接続を行う。
- https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys
