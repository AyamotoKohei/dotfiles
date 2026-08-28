---
name: stacking-prs
description: Use when splitting a feature into multiple reviewable PRs, stacking with gh stack, or asked to 「PRを積んで」「スタックPR」 — including when tempted to open one giant PR or N independent PRs from the default branch. Not for a single-PR bugfix. Enforces integration-base discovery, vertical slices, ready-only-bottom, follow-up commits, merge-commit not squash.
---

# Stack PRs with gh stack

**Stack only when there are two or more review units. Avoid one giant PR and N independent PRs from the default branch. A one-off fix is a normal single PR.**

Literal compliance without intent is also a violation (empty root so the branch count is review-units+1, stacking a one-off "for practice", and so on).

Japanese version: `SKILL-jp.md` in this directory.

## Terminology

| Term | Meaning |
|---|---|
| **Integration branch** | Base of recently merged PRs. Not necessarily the default branch. Confirm with `gh pr list --state merged --json baseRefName`. |
| **Root** | Bottom of the stack. `feature/<ticket>-<slug>`. This is the first review unit (not an empty stub). |
| **Slice** | Additional review unit stacked on the root. `mvp/<feature-name-in-english>`. Keep the ticket out of the branch name; put it in the commit/PR title (`feat(<ticket>): …`). |
| **Bottom / upper** | The current review target (ready) and everything above it (draft). |
| **Vertical slice** | A cut where the PR passes tests on its own and makes sense on its own. Rough guide: ~400 lines of diff. |
| **Follow-up commit** | Address review comments with a new commit. Not amend + force-push. |

## Decision criteria

Before stacking, ask: **"Are there two or more review units that pass tests and make sense on their own?"**

- **Yes → stack**: Bottom becomes the root; the rest go to `mvp/*`. Branch count = review-unit count.
- **No → single PR**: Do not use `gh stack`. Use the project's normal single-PR flow (this skill does not delegate to another skill).
- **Review comments / sync on an existing stack**: Do not `init` again. Follow the rules below.

## Anti-pattern → Preferred examples

### 1. Do not assume the default branch is the base

```
❌ git switch main && gh stack init
✅ Confirm with gh pr list --state merged --json baseRefName, then
   git switch <integration-branch> && git pull
   gh stack init --base <integration-branch> feature/<ticket>-<slug> mvp/<first-slice>
```

### 2. N existing units are root + (N-1) branches

If the work is three units "tab / table / save":

```
❌ feature/ABC-123-usage-limit (empty) ← mvp/limit-tab ← mvp/limit-table ← mvp/limit-save
✅ feature/ABC-123-usage-limit (tab) ← mvp/limit-table ← mvp/limit-save
```

### 3. Do not stack a one-off fix

```
❌ gh stack init for an 8-line null-guard
✅ Normal single PR (one feature/<ticket>-<slug>)
```

### 4. Review comments are follow-up commits

```
❌ git commit --amend && git push --force to hide the review delta
✅ New commit on the bottom. Upper rebase/force-push is allowed when it comes from gh stack sync
```

### 5. If the integration branch was force-pushed, replant first

The tip is new even when the branch name is unchanged. `<new>` = `origin/<name>` after fetch; `<old>` = pre-rewrite tip (`origin/<name>@{1}` or a recorded merge-base).

If review comments and replant happen together: **replant first, then follow-up commits** (the review fix stays a new commit).

```
❌ gh stack sync immediately
✅ git cherry <new> <each-stack-branch>
   git rebase --onto <new> <old> <each-stack-branch>
   then gh stack sync
```

### 6. Ready only the current bottom

Promote the next bottom only when **the current bottom is approved and its comment threads are resolved with follow-up commits**. Then `gh pr ready` on the next one only. The rest stay draft.

```
❌ gh stack submit --open (readies every PR)
✅ gh stack submit --auto (all draft) → gh pr ready on the bottom only
```

## Commands

```bash
git switch <integration-branch>
git pull
gh stack init --base <integration-branch> feature/<ticket>-<slug> mvp/<first-slice>
gh stack add mvp/<slice>
gh stack submit --auto
gh pr ready   # bottom only
```

Merge with a merge commit (squash muddies `gh stack sync` history matching). Send one review-request when the stack is complete (the project's review channel). Include every PR link, bottom-up read order, and a one-line summary per PR.

## Rationalization table

| Excuse | Reality |
|---|---|
| "Default is main, so main is fine" | The integration branch is the base of merged PRs. Confirm it. |
| "Three slices, so an empty root is fine" | The root is the first unit. Do not add an empty stub. |
| "Stacking a small change is good practice" | A one-off is overhead. Single PR. |
| "Amend keeps history cleaner" | The reviewer can no longer follow the review delta. |
| "Same name, so sync is fine" | The tip was rewritten. `--onto` first. |
| "Ready everything so review is faster" | Prevents accidental merge of uppers. Ready the bottom only. |

## Red flags — stop and redo

- `init` on `main` / default without checking the base
- `gh stack init` for a one-off fix
- Empty root so the branch count is review-units+1
- Amend + force-push for review comments
- `gh stack sync` immediately after the integration branch was force-pushed
- Ready uppers / squash merge

**If any flag matches: stop that procedure and return to the ✅ above.**
