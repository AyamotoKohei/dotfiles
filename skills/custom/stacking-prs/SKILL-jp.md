---
name: stacking-prs
description: 機能を複数のレビュー可能な PR に分割するとき、gh stack で積むとき、「PRを積んで」「スタックPR」と依頼されたとき。巨大な1本や default branch からの独立 PR 並列に走りそうなとき。単発バグ修正では使わない。統合ブランチの確認、縦スライス、下段のみ ready、追いコミット、merge commit（squash しない）。
---

# gh stack で PR を積む

**スタックはレビュー単位が 2 本以上あるときだけ。1 本の巨大 PR も、default branch から独立 PR を並べるのも避ける。単発修正は通常の単一 PR。**

字面だけ守って趣旨を破るのも違反（空のルートを足して本数をレビュー単位+1 にする、単発を「念のため」スタックする、など）。

English version: `SKILL.md` in this directory.

## 用語

| 用語 | 意味 |
|---|---|
| **統合ブランチ** | 直近のマージ済み PR のベース。default branch とは限らない。`gh pr list --state merged --json baseRefName` で確認する。 |
| **ルート** | スタック最下段。`feature/<チケット番号>-<slug>`。これ自体が 1 本目のレビュー単位（空スタブにしない）。 |
| **スライス** | ルートの上に積む追加レビュー単位。`mvp/<機能名を英語>`。チケット番号はブランチ名に入れず、コミット/PR タイトル（`feat(<チケット番号>): …`）で紐付ける。 |
| **下段 / 上段** | 今のレビュー対象（ready）とその上（draft）。 |
| **縦スライス** | PR 単体でテストが通り、単体で意味が説明できる切れ目。目安 diff 400 行。 |
| **追いコミット** | 指摘対応を新しいコミットで積むこと。amend + force push ではない。 |

## 判定基準

積む前に問う: **「テストが通り単体で説明できるレビュー単位が 2 本以上あるか」**

- **ある → スタック**: 下段をルートに、残りを `mvp/*` へ。本数 = レビュー単位数。
- **ない → 単一 PR**: `gh stack` しない。プロジェクトの通常の単一 PR 手順を使う（このスキルは他スキルへ委譲しない）。
- **既存スタックへの指摘 / 同期**: 新規 `init` しない。下の運用に従う。

## ❌/✅ 実例

### 1. ベースを default branch と決めない

```
❌ git switch main && gh stack init
✅ gh pr list --state merged --json baseRefName で確認してから
   git switch <統合ブランチ> && git pull
   gh stack init --base <統合ブランチ> feature/<チケット>-<slug> mvp/<最初のslice>
```

### 2. 既存の N 単位はルート + (N-1) 本

作業が「タブ / 表 / 保存」の 3 単位なら:

```
❌ feature/ABC-123-usage-limit（空）← mvp/limit-tab ← mvp/limit-table ← mvp/limit-save
✅ feature/ABC-123-usage-limit（タブ）← mvp/limit-table ← mvp/limit-save
```

### 3. 単発修正は積まない

```
❌ 8 行の null-guard に gh stack init
✅ 通常の単一 PR（feature/<チケット>-<slug> 1 本）
```

### 4. 指摘は追いコミット

```
❌ git commit --amend && git push --force で指摘差分を消す
✅ 新しいコミットを下段に積む。上段の rebase/force push は gh stack sync 起因なら許容
```

### 5. 統合ブランチが force push されたら先に乗せ換える

ブランチ名が同じでも tip は新しい。`<新>` = fetch 後の `origin/<名前>`、`<旧>` = 書き換え前 tip（`origin/<名前>@{1}` または記録済み merge-base）。

指摘対応と乗せ換えが同時なら **先に乗せ換え、そのあと追いコミット**（指摘は新しいコミットのまま）。

```
❌ すぐ gh stack sync
✅ git cherry <新> <各スタックブランチ>
   git rebase --onto <新> <旧> <各スタックブランチ>
   その後 gh stack sync
```

### 6. ready は今の下段だけ

下段を次へ進める条件: **今の下段が approve 済み、かつその PR の指摘スレッドを追いコミットで解消したあと**。次の 1 本だけ `gh pr ready`。残りは draft。

```
❌ gh stack submit --open（全 PR を ready）
✅ gh stack submit --auto（全部 draft）→ 下段だけ gh pr ready
```

## コマンド

```bash
git switch <統合ブランチ>
git pull
gh stack init --base <統合ブランチ> feature/<チケット>-<slug> mvp/<最初のslice>
gh stack add mvp/<slice>
gh stack submit --auto
gh pr ready   # 下段だけ
```

マージは merge commit（squash は `gh stack sync` の履歴照合が濁る）。レビュー依頼はスタック完成時に 1 通（プロジェクトのレビュー依頼チャネル）。全 PR リンク + 下から読む順序 + 各 PR の一言。

## 合理化テーブル

| 言い訳 | 現実 |
|---|---|
| 「default が main だから main でいい」 | 統合ブランチはマージ済み PR のベース。確認する。 |
| 「スライスが 3 つあるからルートは空でいい」 | ルートが 1 本目。空スタブを足すな。 |
| 「小さくてもスタックの練習になる」 | 単発はオーバーヘッド。単一 PR。 |
| 「amend の方が履歴がきれい」 | reviewer が指摘差分を追えなくなる。 |
| 「名前が同じだからすぐ sync していい」 | tip が書き換わっている。先に `--onto`。 |
| 「全部 ready の方がレビューが速い」 | 上段の誤マージを防ぐ。下段だけ ready。 |

## Red Flags — 検出したらやり直す

- ベースを確認せず `main` / default で init
- 単発修正で `gh stack init`
- ルートが空スタブで本数がレビュー単位+1
- 指摘対応を amend + force push
- 統合ブランチ force push 後にすぐ `gh stack sync`
- 上段まで ready / squash マージ

**ひとつでも該当したら: その手順を止めて上の ✅ に戻す。**
