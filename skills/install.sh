#!/bin/bash
set -euo pipefail

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
