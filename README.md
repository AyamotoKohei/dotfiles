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
$ ln -s ~/dotfiles/nvim ~/.config/nvim

# VSCode の設定ファイル
$ rm -rf ~/Library/Application\ Support/Code/User/settings.json
$ ln -s  ~/dotfiles/.vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json

# Warp テーマの有効化
$ ln -s ~/dotfiles/.warp ~/.warp

# Ghostty の設定ファイル
$ rm -rf ~/Library/Application\ Support/com.mitchellh.ghostty/config
$ ln -s ~/dotfiles/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config

# Herdr の設定ファイル
$ mkdir -p ~/.config/herdr
$ ln -s ~/dotfiles/herdr/config.toml ~/.config/herdr/config.toml
$ herdr config check
$ herdr server reload-config
```

Herdr は `config.toml` のみを dotfiles で管理する。`session.json`、`plugins.json`、`plugins/`、ログ、ソケットは端末固有の実行時データのため管理しない。

### Herdr プラグイン

Herdr プラグインは `plugins.json` をコピーせず、CLI から再インストールする。

```bash
$ herdr plugin install edmundmiller/herdr-plugin-hunk --yes
$ herdr plugin install smarzban/herdr-file-viewer --yes
$ herdr plugin list
```

`--ref` を指定せずにインストールコマンドを再実行すると最新版へ更新される。バージョンを固定する場合は `--ref <タグまたはコミット>` を付ける。

7. macOS の設定（Dock・Finder・キーボード・トラックパッドなど）を適用する
```bash
$ ~/dotfiles/macos/defaults.sh
```

設定内容は [macos/defaults.sh](macos/defaults.sh) を参照。設定を変更したら手でこのスクリプトに反映する（自動 dump の仕組みはない）。

以上。

<!--
## 各種アプリケーションの設定
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
