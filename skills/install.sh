#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CUSTOM_SKILLS_DIR="$DOTFILES_DIR/skills/custom"

link_custom_skill() {
  local skill_dir="$1"
  local skill_name
  skill_name="$(basename "$skill_dir")"

  for dest_root in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
    mkdir -p "$dest_root"
    local target="$dest_root/$skill_name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "skip $skill_name: $target exists and is not a symlink (remove manually to adopt dotfiles)" >&2
      continue
    fi
    ln -sfn "$skill_dir" "$target"
  done
}

for skill_dir in "$CUSTOM_SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  link_custom_skill "$skill_dir"
done

# 形式: "owner/repo:skill1,skill2,..."
packages=(
  "obra/superpowers:brainstorming,dispatching-parallel-agents,executing-plans,finishing-a-development-branch,receiving-code-review,requesting-code-review,subagent-driven-development,systematic-debugging,test-driven-development,using-git-worktrees,using-superpowers,verification-before-completion,writing-plans,writing-skills"
  "mizchi/skills:empirical-prompt-tuning,extract-glossary,retrospective-codify"
  "mattpocock/skills:grill-me,grilling"
  "GoogleChrome/modern-web-guidance:modern-web-guidance"
  "manaflow-ai/cmux:cmux-workspace"
)

for entry in "${packages[@]}"; do
  repo="${entry%%:*}"
  IFS=',' read -r -a names <<<"${entry#*:}"
  args=()
  for name in "${names[@]}"; do
    args+=(--skill "$name")
  done
  npx -y skills add "$repo" --global --agent '*' "${args[@]}" --yes
done

# agmsg は skills CLI ではなく専用のインストーラで導入する
npx -y agmsg
