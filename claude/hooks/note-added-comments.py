#!/usr/bin/env python3
"""PostToolUse hook: 今回の編集で追加されたコードコメント行を、止めずに Claude の文脈へ添える。"""
import json
import os
import re
import subprocess
import sys

MAX_LINES = 10
SLASH_EXTS = {".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".mts", ".cts", ".go"}
HASH_EXTS = {".py", ".rb", ".sh", ".bash", ".zsh"}
SLASH_COMMENT = re.compile(r"(^|\s)(//|/\*)|^\s*\*(\s|/|$)|\{/\*")
HASH_COMMENT = re.compile(r"(^|\s)#(?!!)")
DIRECTIVE = re.compile(
    r"eslint-|oxlint-|@ts-|prettier-ignore|istanbul ignore|biome-ignore|noqa|type:\s*ignore|pragma|nolint|https?://|^\s*#!"
)
COMMENT_MARKER = re.compile(r"^.*?(\{/\*|/\*\*?|//|#|^\s*\*)\s?|\s*\*/\}?\s*$")
WHY_NOT_LABEL = re.compile(r"\bwhy\s+not\b[^:：]*[:：]", re.IGNORECASE)
HOME = os.path.expanduser("~")
TEXTLINT = os.path.join(HOME, "Library/pnpm/bin/textlint")
TEXTLINT_CONFIG = os.path.join(HOME, ".textlintrc.json")


def textlint_findings(texts):
    if not (os.path.exists(TEXTLINT) and os.path.exists(TEXTLINT_CONFIG)):
        return []
    try:
        result = subprocess.run(
            [TEXTLINT, "-c", TEXTLINT_CONFIG, "--stdin", "--stdin-filename", "comment.md", "--format", "json"],
            input="\n".join(texts) + "\n", capture_output=True, text=True, timeout=8,
            env={**os.environ, "NODE_PATH": os.path.join(HOME, ".textlint/node_modules")},
        )
        reports = json.loads(result.stdout or "[]")
    except (OSError, subprocess.TimeoutExpired, json.JSONDecodeError):
        return []
    return [
        f"{texts[m['line'] - 1]} → {m['message']}"
        for report in reports
        for m in report.get("messages", [])
        if 0 < m.get("line", 0) <= len(texts)
    ]


def added_lines(tool_name, tool_input, file_path):
    if tool_name == "Edit":
        pairs = [(tool_input.get("old_string", ""), tool_input.get("new_string", ""))]
    elif tool_name == "MultiEdit":
        pairs = [(e.get("old_string", ""), e.get("new_string", "")) for e in tool_input.get("edits", [])]
    else:
        return added_lines_from_git(file_path, tool_input.get("content", ""))
    lines = []
    for old, new in pairs:
        before = set(old.splitlines())
        lines += [line for line in new.splitlines() if line not in before]
    return lines


def added_lines_from_git(file_path, content):
    directory = os.path.dirname(file_path) or "."
    try:
        tracked = subprocess.run(
            ["git", "-C", directory, "ls-files", "--error-unmatch", file_path],
            capture_output=True, timeout=5,
        ).returncode == 0
        if not tracked:
            return content.splitlines()
        diff = subprocess.run(
            ["git", "-C", directory, "diff", "-U0", "HEAD", "--", file_path],
            capture_output=True, text=True, timeout=5,
        ).stdout
    except (OSError, subprocess.TimeoutExpired):
        return content.splitlines()
    return [line[1:] for line in diff.splitlines() if line.startswith("+") and not line.startswith("+++")]


def main():
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        return
    tool_input = payload.get("tool_input") or {}
    file_path = tool_input.get("file_path") or ""
    ext = os.path.splitext(file_path)[1].lower()
    if ext in SLASH_EXTS:
        pattern = SLASH_COMMENT
    elif ext in HASH_EXTS:
        pattern = HASH_COMMENT
    else:
        return

    comments = [
        line.strip()
        for line in added_lines(payload.get("tool_name", ""), tool_input, file_path)
        if pattern.search(line) and not DIRECTIVE.search(line)
    ]
    if not comments:
        return

    shown = "\n".join(f"- {line}" for line in comments[:MAX_LINES])
    more = f"\n- ほか {len(comments) - MAX_LINES} 行" if len(comments) > MAX_LINES else ""
    texts = [t for t in (COMMENT_MARKER.sub("", line).strip() for line in comments) if t]
    findings = [f"{t} → `Why not X:` のラベル形式" for t in texts if WHY_NOT_LABEL.search(t)]
    findings += textlint_findings(texts)
    lint = ""
    if findings:
        lint = "\n文言の指摘（言い換えより先に、削除できないかを考える）:\n" + "\n".join(
            f"- {f}" for f in findings[:MAX_LINES]
        )
    context = (
        f"追加したコメント（{file_path}）:\n{shown}{more}{lint}\n"
        "writing-code-comments に照らし、Why not の 1 行だけを残して、それ以外は削除する。"
        "迷ったら削除し、文面は書き直さない。ユーザーが確定した文言はそのままにする。"
    )
    print(json.dumps(
        {"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": context}},
        ensure_ascii=False,
    ))


if __name__ == "__main__":
    main()
