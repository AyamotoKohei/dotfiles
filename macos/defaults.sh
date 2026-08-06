#!/bin/bash
#
# macOS の設定を defaults コマンドで適用するスクリプト
# 何度実行しても同じ結果になる（冪等）
#
# 使い方:
#   $ ~/dotfiles/macos/defaults.sh
set -euo pipefail

# --- 外観 ---

# システム設定 > 外観 > 外観モード: ダーク
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# --- キーボード ---

# システム設定 > キーボード > テキスト入力 > 入力ソース > 自動的に文を大文字にする: オン
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true

# システム設定 > キーボード > テキスト入力 > 入力ソース > スペースバーを2回押してピリオドを入力: オン
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true

# システム設定 > キーボード > キーボードナビゲーション: オフ（Tab 移動はテキスト入力欄のみ）
defaults write NSGlobalDomain AppleKeyboardUIMode -int 0

# --- トラックパッド ---

# システム設定 > トラックパッド > ポイントとクリック > 軌跡の速さ: 最大
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3.0

# システム設定 > トラックパッド > ポイントとクリック > タップでクリック: オフ
# 内蔵トラックパッドと Bluetooth トラックパッドでドメインが分かれているため両方に書く
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false

# システム設定 > アクセシビリティ > ポインタコントロール > トラックパッドオプション > 3本指でドラッグ: オフ
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false

# --- Dock ---

# システム設定 > デスクトップとDock > Dockを自動的に表示/非表示: オン
defaults write com.apple.dock autohide -bool true

# システム設定 > デスクトップとDock > サイズ
defaults write com.apple.dock tilesize -int 47

# システム設定 > デスクトップとDock > 拡大: オン（拡大時サイズ 114）
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 114

# システム設定 > デスクトップとDock > 最近使用したアプリケーションをDockに表示: オフ
defaults write com.apple.dock show-recents -bool false

# --- Finder ---

# Finder > 表示 > リスト表示をデフォルトにする
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder > 設定 > 一般 > デスクトップに表示する項目
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# --- メニューバー ---

# システム設定 > コントロールセンター > メニューバーのみを表示 > 時計のオプション
# 秒を表示: オン / 曜日を表示: オン / 日付を表示: スペースがあるとき(0) /
# 午前午後を表示: オン / 時刻の区切り記号を点滅: オン
defaults write com.apple.menuextra.clock ShowSeconds -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock FlashDateSeparators -bool true

# システム設定 > コントロールセンター（BentoBox = コントロールセンターのメニューバーアイコン）
defaults write com.apple.controlcenter "NSStatusItem Visible BentoBox" -bool true

# メニューバーに VPN の状態を表示する（menu extra 方式のため配列ごと上書き）
defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/VPN.menu"

# --- 反映 ---

# 設定を読み込ませるため関連プロセスを再起動する（未起動でも失敗させない）
for app in Dock Finder SystemUIServer ControlCenter; do
  killall "${app}" >/dev/null 2>&1 || true
done

echo "macOS の設定を適用しました。一部の設定は再ログイン後に反映されます。"
