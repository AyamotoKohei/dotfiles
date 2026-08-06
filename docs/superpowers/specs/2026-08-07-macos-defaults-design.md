# macOS 設定適用スクリプト 設計

日付: 2026-08-07
ステータス: 承認済み

## 目的

現在の macOS（26.5.2）でカスタマイズしている設定を、新しいマシンでも `defaults` コマンドで再適用できるようにする。

## 方針

- 単一スクリプト `macos/defaults.sh` にセクションコメント区切りで `defaults write` を並べる（案A）
- 現在のマシンで明示的に値が設定されているキーのみ対象とする。未設定（OS デフォルトのまま）のキーは書かない
- 適用スクリプトのみ。以後の設定変更は手でスクリプトを編集して取り込む（dump 機構は作らない）

## ファイル構成

- `macos/defaults.sh` — 新規。実行権限付きの適用スクリプト
- `README.md` — macOS 設定の適用手順を追記

## 対象設定（2026-08-07 時点の実機値）

| セクション | ドメイン / キー | 値 | 意味 |
|---|---|---|---|
| 外観 | `NSGlobalDomain AppleInterfaceStyle` | `Dark` | ダークモード |
| キーボード | `NSGlobalDomain NSAutomaticCapitalizationEnabled` | `true` | 自動大文字化オン |
| キーボード | `NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled` | `true` | ダブルスペースでピリオドオン |
| キーボード | `NSGlobalDomain AppleKeyboardUIMode` | `0` | Tab 移動はテキスト入力欄のみ |
| トラックパッド | `NSGlobalDomain com.apple.trackpad.scaling` | `3.0` | 軌跡の速さ最大 |
| トラックパッド | `com.apple.AppleMultitouchTrackpad Clicking` | `false` | タップでクリック無効（内蔵） |
| トラックパッド | `com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking` | `false` | タップでクリック無効（Bluetooth） |
| トラックパッド | `com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag` | `false` | 3 本指ドラッグ無効 |
| Dock | `com.apple.dock autohide` | `true` | 自動的に隠す |
| Dock | `com.apple.dock tilesize` | `47` | アイコンサイズ |
| Dock | `com.apple.dock magnification` | `true` | 拡大オン |
| Dock | `com.apple.dock largesize` | `114` | 拡大時サイズ |
| Dock | `com.apple.dock show-recents` | `false` | 最近使った App を表示しない |
| Finder | `com.apple.finder FXPreferredViewStyle` | `Nlsv` | リスト表示 |
| Finder | `com.apple.finder ShowExternalHardDrivesOnDesktop` | `true` | 外部ディスクをデスクトップに表示 |
| Finder | `com.apple.finder ShowHardDrivesOnDesktop` | `false` | 内蔵ディスクは表示しない |
| Finder | `com.apple.finder ShowRemovableMediaOnDesktop` | `true` | リムーバブルメディアを表示 |
| Finder | `com.apple.finder NewWindowTarget` | `PfHm` | 新規ウインドウでホームフォルダを開く（「最近の項目」を開かない） |
| Finder | `com.apple.finder NewWindowTargetPath` | `file://$HOME/` | 実行ユーザーのホームから生成 |
| メニューバー | `com.apple.menuextra.clock ShowSeconds` | `true` | 時計に秒を表示 |
| メニューバー | `com.apple.menuextra.clock ShowDayOfWeek` | `true` | 時計に曜日を表示 |
| メニューバー | `com.apple.menuextra.clock ShowDate` | `0` | 日付は「スペースがあるとき」に表示 |
| メニューバー | `com.apple.menuextra.clock ShowAMPM` | `true` | 午前/午後を表示 |
| メニューバー | `com.apple.menuextra.clock FlashDateSeparators` | `true` | 時刻の区切り記号を点滅 |
| メニューバー | `com.apple.controlcenter "NSStatusItem Visible BentoBox"` | `true` | コントロールセンターのアイコンを表示 |
| メニューバー | `com.apple.systemuiserver menuExtras` | `VPN.menu` | VPN 状態アイコンを表示 |

## スクリプトの作り

- `#!/bin/bash` + `set -euo pipefail`
- `defaults write` は型フラグ（`-bool` / `-int` / `-float` / `-string`）を明示する
- 各設定に「システム設定のどの画面のどの項目か」を日本語コメントで併記する
- 末尾で `killall Dock Finder SystemUIServer`（未起動でも失敗しないよう `|| true`）で即時反映する
- 冪等: 何度実行しても同じ結果になる

## 検証

- `shellcheck` を通す
- 実行後に `defaults read` で全キーが期待値になっていることを確認する（現在値と同じ値を書くため、実機で安全に検証できる）

## スコープ外

- `sudo` が必要なシステム全体設定（`nvram`、`pmset` 等）
- dump / 再生成の仕組み
- macOS 以外の OS
