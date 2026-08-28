#!/bin/bash
# Stop hook: 追加されたコードコメントを検出したら writing-code-comments スキルの検査を強制する
set -u
input=$(cat)
# 検査後の再停止では発火させない（無限ループ防止）
case "$input" in *'"stop_hook_active":true'* | *'"stop_hook_active": true'*) exit 0 ;; esac

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

CODE_PATHS=('*.ts' '*.tsx' '*.js' '*.jsx' '*.py' '*.go' '*.rb' '*.sh')
diff_output=$(git diff HEAD -- "${CODE_PATHS[@]}" 2>/dev/null)
# 直近30分以内のコミットも対象（作業完了直前にコミット済みのケース）
if [ -n "$(git log -1 --since='30 minutes ago' --format=%H 2>/dev/null)" ] && git rev-parse -q --verify HEAD~1 >/dev/null 2>&1; then
  diff_output="${diff_output}
$(git diff HEAD~1..HEAD -- "${CODE_PATHS[@]}" 2>/dev/null)"
fi

comments=$(printf '%s\n' "$diff_output" |
  grep -E '^\+' | grep -v '^+++' |
  grep -E '//|/\*|^\+\s*\*|^\+\s*#' |
  grep -viE 'eslint-disable|@ts-|prettier-ignore|istanbul ignore|https?://|^\+\s*#!' |
  head -15)
[ -z "$comments" ] && exit 0

COMMENTS="$comments" python3 - <<'PY'
import json, os
reason = (
    "作業完了前のコメント検査: ~/.claude/skills/writing-code-comments/SKILL.md を読み、"
    "以下の追加コメントがそれぞれ Why not か検査せよ。"
    "変更経緯・修正宣言・テスト名と重複する説明は削除してから完了すること。\n"
    + os.environ["COMMENTS"]
)
print(json.dumps({"decision": "block", "reason": reason}, ensure_ascii=False))
PY
