---
name: writing-code-comments
description: Use when adding or editing code comments during implementation, fixes, or refactors — when tempted to explain a fix, a regression, or why a change is correct. Enforces Why-not-only comments (one line), test-name-no-duplication, and red-flag removal; move change narrative to commit messages.
---

# Code comment discipline

**Comments are Why-not constraints for the next reader only. Change history and fix justification belong in commit messages.**

Literal compliance without intent is also a violation (e.g. relabeling change narrative as "background explanation").

Japanese version: `SKILL-jp.md` in this directory.

## Terminology

| Term | Meaning |
|---|---|
| **Why not** | One-line note: why the naive/obvious approach was avoided. Without it, someone may "simplify" the code and reintroduce a bug. |
| **Justification** | Explaining *why this change is correct* to a reviewer. Do not put in code. |
| **Change narrative** | Timeline of what changed ("when we switched from X to Y"). Do not put in code. |
| **Fix declaration** | Phrasing like "prevents …", "fixes …", "addresses …". Do not put in code. |

## Decision criteria

Before writing, ask: **"Does a post-merge reader of this code need this, or is it justification for the reviewer?"**

- **Why not (keep · one line)**: Why the straightforward approach was avoided. Only what would cause a regression if removed.
- **Justification (do not write)**: Change narrative, fix declarations, correctness arguments, plans to fix other files.
- **Tests**: The test name states *what* is tested. Do not repeat it in prose comments.

## Anti-pattern → Preferred examples

When refactoring a comment, choose **compress** or **delete**:

- **Compress (pattern 1–3)**: A one-line Why-not constraint remains after removing narrative.
- **Delete (pattern 4)**: Nothing worth keeping for a post-merge reader — only the change story or test-name duplication remains.

### 1. Compress change narrative into a Why-not constraint

```
❌ {/*
     Center the badge with flex. Line-box centering drifts with inherited line-height
     from the parent, and misaligned after we changed the click target from button to anchor
   */}
✅ {/* Line-box centering drifts when parent line-height is inherited; use flex instead */}
```

### 2. Drop symptom dumps; keep only why-not-use-X

Applies when a library flag or API looks usable but is not in some state (e.g. query client `isLoading` stays false until the query key is ready).

```
❌ // isLoading stays false while the query key is null (session unresolved), so using it
   // for loading state flashes the error screen on hard reload before data arrives
✅ // isLoading stays false until the query key is ready, so it cannot represent in-flight fetch
```

Test — delete prose that repeats the test name:

```
❌ # Retry on connection reset because we saw flaky tests last week; this test checks POST is skipped
✅ (no comment — test name carries what)
```

### 3. Keep only why odd-looking code exists

```
❌ // Required by the type, but when version skew sends a response without this field,
   // normalize to an empty slice at the fetch boundary so the page does not throw TypeError
✅ // Required by the type, but omitted by legacy API responses — guard against page crash
```

Go:

```
❌ // We added this nil check after prod incident #4521 when old clients omitted the field
✅ // Legacy clients may omit this field despite the struct tag — avoid panic on nil deref
```

SQL migration — keep why a seemingly redundant constraint exists:

```
❌ -- Added NOT VALID after #892 rollback; we couldn't afford full table scan in prod last Tuesday
✅ -- Legacy rows predate the column; validate in a follow-up migration after backfill
```

### 4. Delete when only the change story remains

```
❌ {/*
     Make the whole card a single anchor. Nested button > a traps focus on the button,
     breaking keyboard navigation and dead click areas on card padding
   */}
✅ Delete — no comment. Rationale belongs in the commit message.
```

Test:

```
❌ def test_retry_excludes_non_idempotent_methods():
       # POST must not be retried because duplicates create records — this test verifies retry skips POST
✅ def test_retry_excludes_non_idempotent_methods():
       (no comment — test name states what)
```

## Rationalization table

| Excuse | Reality |
|---|---|
| "It helps reviewers understand" | That is the PR description and commit log. Post-merge code should not carry review noise. |
| "I want to record why we regressed" | `git blame` and commit history record that permanently. |
| "More detail is kinder" | Post-merge readers have no "before" state. Explanations that assume it are unkind. |
| "This is a Why not" | If it cannot compress to one line, it is not a Why not. |
| "This is background, not history" | Past tense or timeline wording makes it change narrative. Delete it. |

## Red flags — delete before finishing

- References to past state or timeline ("when we changed to …", "fixed because it was …")
- Fix declarations ("prevents …", "fixes …", "addresses …")
- Test prose that repeats the test name
- Block comments of three or more lines (Why-not fits in one line)

**If any flag matches: delete the comment and move needed information to the commit message.**
