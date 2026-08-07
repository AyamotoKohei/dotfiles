#!/bin/sh
# episodic-memory の better-sqlite3 の ABI 不一致を自動修復する。
# Claude Code はバンドル Node でプラグインを install するが、実行は PATH の Node
# (mise)。メジャーがズレると ERR_DLOPEN_FAILED になる。

set -eu

LOG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/superpowers/logs"
LOG_FILE="$LOG_DIR/episodic-memory.log"
CACHE_ROOT="$HOME/.claude/plugins/cache"

command -v node >/dev/null 2>&1 || exit 0
command -v npm >/dev/null 2>&1 || exit 0

log() {
  mkdir -p "$LOG_DIR" 2>/dev/null || return 0
  printf '%s [abi-guard] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" >>"$LOG_FILE" 2>/dev/null || true
}

for plugin_dir in "$CACHE_ROOT"/*/episodic-memory/*/; do
  [ -d "$plugin_dir/node_modules/better-sqlite3" ] || continue

  # Why not require だけ: lazy binding のため require では dlopen されず、
  # 壊れていても素通りする。Database を生成して初めて検知できる。
  if (cd "$plugin_dir" && node -e "const D=require('better-sqlite3'); new D(':memory:').close()") >/dev/null 2>&1; then
    continue
  fi

  log "ABI mismatch in $plugin_dir (node $(node -v), ABI $(node -p 'process.versions.modules')); rebuilding"

  # Why not バックグラウンド: 同一セッションの sync より先に直す必要がある。
  if (cd "$plugin_dir" && npm rebuild better-sqlite3) >>"$LOG_FILE" 2>&1; then
    log "rebuild succeeded for $plugin_dir"
  else
    log "rebuild FAILED for $plugin_dir; run manually: cd '$plugin_dir' && npm rebuild better-sqlite3"
  fi
done

exit 0
