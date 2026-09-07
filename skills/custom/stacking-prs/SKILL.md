---
name: stacking-prs
description: Use when splitting a feature into multiple reviewable PRs or asked to 「PRを積んで」「スタックPR」 — including when tempted to open one giant PR or N independent PRs from the default branch. Policy layer for stacked PRs; enforces review-unit decision, integration-base discovery, vertical slices, ready-only-bottom, follow-up commits, merge-commit not squash, one integration merge per ticket (aggregate root). gh stack command mechanics live in the gh-stack skill. Not for a single-PR bugfix.
---

# Stack PRs with gh stack

**Stack only when there are two or more review units. Avoid one giant PR and N independent PRs from the default branch. A one-off fix is a normal single PR.**

Literal compliance without intent is also a violation (implementing directly on the aggregate root, stacking a one-off "for practice", and so on).

This skill is the **policy layer**: how to cut review units and the team rules around them. For `gh stack` command mechanics (non-interactive flags, exit codes, sync/merge procedures, troubleshooting), invoke the official `gh-stack` skill. **If the two skills conflict, this skill wins.**

Japanese version: `SKILL-jp.md` in this directory.

## Terminology

| Term | Meaning |
|---|---|
| **Integration branch** | Base of recently merged PRs. Not necessarily the default branch. Confirm with `gh pr list --state merged --json baseRefName`, **excluding stack-internal merges** — rows whose base is itself a stack branch (`feature/*`, `mvp/*`) are slices merging into their own root, not the team's shared base. The integration branch is what ordinary PRs merge into. From a stack, only the aggregate root's PR targets it. |
| **Aggregate root** | The stack's trunk (base). Cut `feature/<ticket>-<slug>` from the integration branch and **keep it empty — never commit to it directly**. It only receives slice merges, and carries the single PR into the integration branch (the version-bearing PR). |
| **Slice** | A review unit. Every unit — including the first — is `mvp/<feature-name-in-english>` stacked on the aggregate root. Keep the ticket out of the branch name; put it in the commit/PR title (`feat(<ticket>): …`). |
| **Bottom / upper** | The current review target (ready) and everything above it (draft). |
| **Vertical slice** | A cut where the PR passes tests on its own and makes sense on its own. Rough guide: ~400 lines of diff. |
| **Follow-up commit** | Address review comments with a new commit. Not amend + force-push. |

## Decision criteria

Before stacking, ask: **"Are there two or more review units that pass tests and make sense on their own?"**

When this decision overrides the requester's explicit ask (e.g. they said "stack it" but it's a one-off → single PR), tell them the decision and the reason in one line before proceeding — don't silently deviate.

- **Yes → stack**: Cut the aggregate root from the integration branch; every review unit goes to `mvp/*`. Branch count = review-unit count + 1 (the aggregate root).
- **No → single PR**: Do not use `gh stack`. This skill stops here — it does not govern the single-PR procedure. Follow the project's normal single-PR flow: check the project's skill list and docs (CLAUDE.md etc.) for its PR-creation procedure, and use a project PR-creation skill if one exists (allowed; just not mandated by this skill).
- **Review comments / sync on an existing stack**: Do not `init` again. Follow the rules below.

## Anti-pattern → Preferred examples

### 1. Do not assume the default branch is the base

```
❌ git switch main && gh stack init
✅ Confirm with gh pr list --state merged --json baseRefName, then
   git switch <integration-branch> && git pull
   git switch -c feature/<ticket>-<slug> && git push -u origin HEAD   # aggregate root (empty)
   gh stack init --base feature/<ticket>-<slug> mvp/<slice1>
```

### 2. N units are "empty aggregate root + N slices"

If the work is three units "tab / table / save":

```
❌ feature/ABC-123-usage-limit (tab implemented directly) ← mvp/limit-table ← mvp/limit-save
✅ feature/ABC-123-usage-limit (empty aggregate root) ← mvp/limit-tab ← mvp/limit-table ← mvp/limit-save
```

Work committed directly on the aggregate root has no stack-internal PR of its own, so the integration PR becomes a mixed diff of reviewed slices and unreviewed implementation. The first unit is a slice too.

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

The stack's trunk is the aggregate root. When the integration branch was rewritten, replant the aggregate root with `--onto` first, then use it as `<new-trunk>` and replant the slices bottom-up (`<bottom>` below = the aggregate root).

**Variable scope — `<new>`/`<old>` are per-branch, not global.** They name the old-trunk pair only for the **bottom** branch. For each upper branch, `<new>` = its parent after that parent was rebased, and `<old>` = the parent's **pre-rebase** tip — record it with `git rev-parse <parent>` before rebasing the parent. Rebase bottom-up. Reusing the old trunk tip as `<old>` for uppers replays the lower branches' commits as duplicate new SHAs.

Record the old tip of **every** stack branch before rebasing: the values serve double duty as rebase arguments and as the pre-`sync` divergence check (`origin/<b>` must still equal the recorded old tip). Before trusting `origin/<name>@{1}` as the old trunk tip, verify it with `git merge-base --is-ancestor <old> <bottom>` — auto-fetches can pollute the reflog.

If review comments and replant happen together: **replant first, then follow-up commits** (the review fix stays a new commit).

```
❌ gh stack sync immediately
❌ git rebase --onto <new-trunk> <old-trunk-tip> <every-branch>   # duplicates lower commits in uppers
✅ git cherry <new-trunk> <each-stack-branch>
   # expected output: your stack's commits as "+". A "-" is already patch-equivalent upstream and will
   # drop in the rebase — stop and investigate any UNEXPECTED "-". On upper branches, lower branches'
   # commits also show as "+" — that is normal; read each branch's own commits only.
   old_bottom=$(git rev-parse <bottom>); old_s1=$(git rev-parse <slice1>); …
   # record the old tip of EVERY stack branch BEFORE any rebase (rebase args + divergence-check baseline)
   git rebase --onto <new-trunk> <old-trunk-tip> <bottom>
   git rebase --onto <bottom> "$old_bottom" <slice1>              # repeat bottom-up per upper branch
   git fetch origin +<trunk>:<trunk>  # local trunk is stale after the rewrite; sync/submit force-push it
                                      # from local refs (see pitfalls). The + is required: a plain refspec
                                      # is FF-only and gets rejected after a rewrite
   gh stack sync
   # sync exits 0 even when it aborts ("Sync aborted" on stderr) — verify the result with
   # git rev-parse <b> origin/<b> per branch / gh stack view --json (details: gh-stack skill)
   # ONLY THEN add the follow-up commits on the bottom and push/sync again
```

The `gh-stack` skill's troubleshooting reference does **not** cover a rewritten trunk (only squash-merge follow-up and stack-metadata divergence), so this procedure has no upstream equivalent — keep it here.

### 6. Ready only the current bottom

Promote the next bottom only when **the current bottom is approved and its comment threads are resolved with follow-up commits**. Then `gh pr ready` on the next one only. The rest stay draft.

```
❌ gh stack submit --open (readies every PR)
✅ gh stack submit --auto (all draft) → gh pr ready on the bottom only
```

Create and ready the aggregate-root → integration-branch PR only after every slice has merged into the root.

### 7. Do not point slices at the integration branch (one integration merge per ticket)

Teams commonly cut a version per merge into the integration branch (1 PR merge = 1 version). Merging each slice into it splits one ticket across N versions, with unrelated PRs' versions interleaved — untraceable afterwards. Units that are already subdivided get their frequent review/merge cadence from stack-internal merges instead.

```
❌ Slice PRs based on the integration branch / letting the next slice retarget it after a bottom merge
✅ Slices merge into the layer below (ultimately the aggregate root). Once every slice is in,
   open ONE PR feature/<ticket>-<slug> → <integration-branch> and merge it (the only version-bearing merge)
```

Create the integration PR after all slices have merged (the project's normal single-PR flow is fine). Its content is the set of already-reviewed slices, so its review is a cross-check, not a full re-read.

## Policy-bound commands

Only commands tied to a policy above are listed here. Everything else (`add`, `sync`, `view --json`, exit codes, recovery) — follow the `gh-stack` skill.

```bash
git switch <integration-branch> && git pull
git switch -c feature/<ticket>-<slug> && git push -u origin HEAD   # aggregate root; never commit to it directly
gh stack init --base feature/<ticket>-<slug> mvp/<slice1>
# commit slice1's review unit, then for each slice:
gh stack add mvp/<sliceN>                                           # branches off the current layer
# commit that slice's review unit, repeat
gh stack submit --auto
gh pr ready   # bottom slice only
# once every slice has merged into the root: ONE PR feature/<ticket>-<slug> → <integration-branch>
```

- `--base` is mandatory: bare `init` bases the stack on the default branch. The base is the aggregate root (not the integration branch).
- **Build layer by layer** (init root → commit → add → commit → …). A bulk `init` of all branches leaves every branch at the trunk tip, so distributing pre-existing commits afterwards needs interleaved rebases. Pre-existing work is fine: cherry-pick each unit's commits into its layer as you add it.
- Branch name patterns are patterns, not reserved names — before creating, check against existing branches (`git branch --list …` / `git ls-remote --heads origin …`) and pick non-colliding names.
- Before `submit`/`sync`, check **every** stack branch for **unintended divergence** — the goal is to avoid rewinding the remote from a stale local ref and to catch third-party pushes (see pitfalls below). Normally: `git rev-parse <b> origin/<b>` must match. The expected divergence depends on the state you are in:
  - **Normal:** `git rev-parse <b> origin/<b>` must match.
  - **Right after a deliberate replant:** local necessarily differs **and origin still holds the pre-replant SHAs**, so reachability checks like `git log <b>..origin/<b>` misfire on the normal path — instead confirm `origin/<b>` still **equals the old tip recorded before the rebase** (`git rev-parse` equality; anything else = a third-party push).
  - **Local intentionally ahead by your own follow-up commits (already synced once):** `origin/<b>` must be an **ancestor** of `<b>` (`git merge-base --is-ancestor origin/<b> <b>`) and every commit in `<b>` not on origin must be yours; any origin-only commit = a third-party push.
  - Branches not yet on origin are fine in every state.
- Merge with a merge commit (squash muddies `gh stack sync` history matching).
- Send one review-request when the stack is complete (the project's review channel). Include every PR link, bottom-up read order, and a one-line summary per PR.

## Known extension pitfalls (gh-stack extension v0.1.x, observed 2026-09-01)

Real-world traps in the extension itself, not covered by the official `gh-stack` skill. Retire these once the extension fixes them.

- `gh stack submit` force-pushes **every** stack branch (trunk = aggregate root included) from local refs, unverified. A stale local ref **rewinds the remote trunk** — hence the local==origin check above.
- `gh stack unstack`'s "stack was left in place" message is unreliable: open PRs get unstacked while merged PRs remain in a closed stack on GitHub (partial success). Recovery: `gh stack unstack --local` → `gh stack init --base <aggregate-root> <branch...>` → `gh stack submit` (existing PRs are re-adopted by branch name).
- Extension messages in general ("re-based onto the trunk" etc.) may not match the actual git operations. Verify with `git rev-parse` and raw API data (GraphQL `pullRequest.stack` / REST `repos/{o}/{r}/stacks/{n}`).

## Rationalization table

| Excuse | Reality |
|---|---|
| "Default is main, so main is fine" | The integration branch is the base of merged PRs. Confirm it. |
| "Implementing the first unit on the root saves a branch" | The aggregate root only receives merges. Committing to it mixes unreviewed diff into the integration PR. The first unit is a slice. |
| "Merging each slice into the integration branch ships sooner" | The integration branch cuts a version per merge. One ticket becomes N versions with unrelated PRs interleaved. Integration merge = once, via the aggregate root. |
| "Stacking a small change is good practice" | A one-off is overhead. Single PR. |
| "Amend keeps history cleaner" | The reviewer can no longer follow the review delta. |
| "Same name, so sync is fine" | The tip was rewritten. `--onto` first. |
| "Ready everything so review is faster" | Prevents accidental merge of uppers. Ready the bottom only. |
| "The extension said it succeeded" | Its messages can lie. Verify with `git rev-parse` / raw API. |

## Red flags — stop and redo

- `init` on `main` / default without checking the base
- Creating stack branches without checking existing local/remote branch names for collisions
- `gh stack init` for a one-off fix
- A slice PR based on the integration branch
- Committing directly to the aggregate root
- Merging the aggregate-root → integration PR before every slice has merged
- Amend + force-push for review comments
- `gh stack sync` immediately after the integration branch was force-pushed
- `submit`/`sync` without checking every stack branch for unintended divergence (local vs origin)
- Ready uppers / squash merge

**If any flag matches: stop that procedure and return to the ✅ above.**
