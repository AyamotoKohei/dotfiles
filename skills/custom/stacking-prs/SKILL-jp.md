---
name: stacking-prs
description: 機能を複数のレビュー可能な PR に分割するとき、「PRを積んで」「スタックPR」と依頼されたとき。巨大な1本や default branch からの独立 PR 並列に走りそうなとき。スタック PR のポリシー層: レビュー単位の判定、統合ブランチの確認、縦スライス、下段のみ ready、追いコミット、merge commit（squash しない）、統合へのマージは1チケット1回（集約ルート）。gh stack コマンドの操作方法は gh-stack スキル側。単発バグ修正では使わない。
---

# gh stack で PR を積む

**スタックはレビュー単位が 2 本以上あるときだけ。1 本の巨大 PR も、default branch から独立 PR を並べるのも避ける。単発修正は通常の単一 PR。**

字面だけ守って趣旨を破るのも違反（集約ルートに直接実装を積む、単発を「念のため」スタックする、など）。

このスキルは**ポリシー層**: レビュー単位の切り方とチーム運用規約を定める。`gh stack` コマンドの機械的な使い方（非対話フラグ、exit code、sync/merge 手順、トラブルシュート）は公式 `gh-stack` スキルを起動して従う。**両スキルの指示が矛盾する場合は本スキルを優先する。**

English version: `SKILL.md` in this directory.

## 用語

| 用語 | 意味 |
|---|---|
| **統合ブランチ** | 直近のマージ済み PR のベース。default branch とは限らない。`gh pr list --state merged --json baseRefName` で確認する。ただし**スタック内部マージは除外する** — ベースがスタックブランチ（`feature/*`、`mvp/*`）になっている行はスライスが自スタックのルートへマージされたもので、チーム共通のベースではない。統合ブランチは「通常の PR がマージされる先」。スタックからは集約ルートの PR 1 本だけが統合ブランチへ向かう。 |
| **集約ルート** | スタックのトランク（ベース）。`feature/<チケット番号>-<slug>` を統合ブランチから切り、**空のまま直接コミットしない**。スライスのマージだけを受け、統合ブランチへ向かう唯一の PR（バージョンを刻む PR）を持つ。 |
| **スライス** | レビュー単位。1 本目も含めすべて `mvp/<機能名を英語>` で集約ルートの上に積む。チケット番号はブランチ名に入れず、コミット/PR タイトル（`feat(<チケット番号>): …`）で紐付ける。 |
| **下段 / 上段** | 今のレビュー対象（ready）とその上（draft）。 |
| **縦スライス** | PR 単体でテストが通り、単体で意味が説明できる切れ目。目安 diff 400 行。 |
| **追いコミット** | 指摘対応を新しいコミットで積むこと。amend + force push ではない。 |

## 判定基準

積む前に問う: **「テストが通り単体で説明できるレビュー単位が 2 本以上あるか」**

この判断が依頼者の明示要求を上書きする場合（例:「スタックPRで」と言われたが単発なので単一 PR にする）は、黙って変えず、実行前に判断と根拠を一言伝える。

- **ある → スタック**: 統合ブランチから集約ルートを切り、レビュー単位はすべて `mvp/*` へ。本数 = レビュー単位数 + 1（集約ルート）。
- **ない → 単一 PR**: `gh stack` しない。本スキルの守備範囲はここまでで、単一 PR の手順は規定しない。プロジェクトの通常の単一 PR フローに従う: PR 作成手順はプロジェクトのスキル一覧・ドキュメント（CLAUDE.md 等）で確認し、PR 作成用のプロジェクトスキルがあればそれを使ってよい（本スキルが強制しないだけで、使用は禁止ではない）。
- **既存スタックへの指摘 / 同期**: 新規 `init` しない。下の運用に従う。

## ❌/✅ 実例

### 1. ベースを default branch と決めない

```
❌ git switch main && gh stack init
✅ gh pr list --state merged --json baseRefName で確認してから
   git switch <統合ブランチ> && git pull
   git switch -c feature/<チケット>-<slug> && git push -u origin HEAD   # 集約ルート（空）
   gh stack init --base feature/<チケット>-<slug> mvp/<slice1>
```

### 2. N 単位は「空の集約ルート + N スライス」

作業が「タブ / 表 / 保存」の 3 単位なら:

```
❌ feature/ABC-123-usage-limit（タブ実装を直接積む）← mvp/limit-table ← mvp/limit-save
✅ feature/ABC-123-usage-limit（空の集約ルート）← mvp/limit-tab ← mvp/limit-table ← mvp/limit-save
```

集約ルートに直接積んだ分はスタック内 PR を持たず、統合 PR がレビュー済みスライスと未レビュー実装の混合 diff になる。1 本目もスライスにする。

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

スタックのトランクは集約ルート。統合ブランチが書き換えられたら、まず集約ルートを `--onto` で乗せ換え、それを `<新トランク>` としてスライスを下から順に乗せ換える（以下の `<最下段>` = 集約ルート）。

**変数のスコープ — `<新>`/`<旧>` は per-branch であり全ブランチ共通ではない。** 上の定義は**最下段**にだけ当てはまる旧トランクのペア。上段の各ブランチでは `<新>` = rebase 済みの親ブランチ、`<旧>` = その親の **rebase 前** tip — 親を rebase する前に `git rev-parse <親>` で記録しておく。下段から順に rebase する。上段にも旧トランク tip を `<旧>` として使い回すと、下段のコミットが新 SHA で重複再生される。

rebase 前に**全**スタックブランチの旧 tip を記録すること: この値は rebase の引数と、sync 前の乖離検査（`origin/<b>` が記録済み旧 tip と一致すること）の両方に使う。旧トランク tip として `origin/<名前>@{1}` を使う前に `git merge-base --is-ancestor <旧> <最下段>` で裏取りする — 自動 fetch で reflog が汚れることがある。

指摘対応と乗せ換えが同時なら **先に乗せ換え、そのあと追いコミット**（指摘は新しいコミットのまま）。

```
❌ すぐ gh stack sync
❌ git rebase --onto <新トランク> <旧トランクtip> <全ブランチ>   # 上段で下段コミットが重複する
✅ git cherry <新トランク> <各スタックブランチ>
   # 期待出力: 自分のスタックのコミットが "+"。"-" は新トランクに patch 同値で取り込み済みで
   # rebase 時に自然に落ちる — 想定外の "-" があれば停止して調査。上段の出力には下段の
   # コミットも "+" で混ざるのが正常。各ブランチ固有分だけを読む。
   old_bottom=$(git rev-parse <最下段>); old_s1=$(git rev-parse <slice1>); …
   # rebase 前に「全」スタックブランチの旧 tip を記録（rebase 引数 + 乖離検査の基準値）
   git rebase --onto <新トランク> <旧トランクtip> <最下段>
   git rebase --onto <最下段> "$old_bottom" <slice1>             # 以降、下から順に各上段へ繰り返す
   git fetch origin +<トランク>:<トランク>  # 書き換え後のローカルトランクは stale。sync/submit は
                                            # ローカル ref から force push する（既知の罠）ため sync 前に更新。
                                            # + が必須: 素の refspec は FF 専用で、書き換え後は rejected になる
   gh stack sync
   # sync は中断時も exit 0（stderr に "Sync aborted"）— 成否は各ブランチの
   # git rev-parse <b> origin/<b> / gh stack view --json で実測確認する（詳細: gh-stack スキル）
   # 追いコミットは「この後」に最下段へ積み、改めて push/sync する
```

`gh-stack` スキルの troubleshooting はトランク自体の履歴書き換えを**扱っていない**（squash マージ追従とスタック管理情報の乖離のみ）。この手順に委譲先は無いため、ここに残す。

### 6. ready は今の下段だけ

下段を次へ進める条件: **今の下段が approve 済み、かつその PR の指摘スレッドを追いコミットで解消したあと**。次の 1 本だけ `gh pr ready`。残りは draft。

```
❌ gh stack submit --open（全 PR を ready）
✅ gh stack submit --auto（全部 draft）→ 下段だけ gh pr ready
```

集約ルート → 統合ブランチの PR は、全スライスがルートへマージされてから作成・ready する。

### 7. スライスを統合ブランチへ向けない（統合へのマージは 1 チケット 1 回）

統合ブランチはマージごとにバージョンを切る運用が一般的（1 PR マージ = 1 バージョン）。スライスごとに統合へマージすると 1 チケットが N バージョンに割れ、間に無関係 PR のバージョンが挟まって後から追えない。細分化済みの単位はスタック内マージでこまめにレビュー・マージする。

```
❌ スライス PR を統合ブランチに向ける / 下段マージで次スライスが統合ブランチへ retarget されるに任せる
✅ スライスは下のレイヤー（最終的に集約ルート）へマージ。全スライスがルートへ入ったら
   feature/<チケット>-<slug> → <統合ブランチ> の PR を 1 本作成してマージ（ここで初めてバージョンが切られる）
```

統合 PR は全スライスのマージ後に作成する（通常の単一 PR フローで可）。中身はレビュー済みスライスの集合なので、レビューは全量の再読ではなく突合で済む。

## ポリシーと結びつくコマンド

ここに載せるのは上のポリシーと不可分なものだけ。それ以外の操作（`add`、`sync`、`view --json`、exit code、復旧）は `gh-stack` スキルに従う。

```bash
git switch <統合ブランチ> && git pull
git switch -c feature/<チケット>-<slug> && git push -u origin HEAD   # 集約ルート。直接コミットしない
gh stack init --base feature/<チケット>-<slug> mvp/<slice1>
# slice1 のレビュー単位をコミットしてから、スライスごとに:
gh stack add mvp/<sliceN>                                            # 現在のレイヤーから分岐
# そのスライスのレビュー単位をコミット、以降繰り返し
gh stack submit --auto
gh pr ready   # 下段スライスだけ
# 全スライスがルートへマージされたら: feature/<チケット>-<slug> → <統合ブランチ> の PR を 1 本
```

- `--base` は必須: 素の `init` は default branch をベースにする。ベースは集約ルート（統合ブランチではない）。
- **レイヤーごとに積み上げる**（init ルート → commit → add → commit → …）。全ブランチ一括 `init` は全部がトランク tip に立つため、実装済みコミットの配分に交互 rebase が必要になり手間。実装済みの作業は、各レイヤーを add した時点でその単位のコミットを cherry-pick して載せればよい。
- ブランチ命名パターンは予約名ではない — 作成前に既存ブランチと照合し（`git branch --list …` / `git ls-remote --heads origin …`）、衝突しない名前を選ぶ。
- `submit`/`sync` の前に**全**スタックブランチで**意図しない乖離**がないか確認する — 目的は stale なローカル ref によるリモート巻き戻しの防止と、第三者 push の検出（下の「既知の罠」参照）。期待される乖離は状態によって異なる:
  - **通常時**: `git rev-parse <b> origin/<b>` の一致が必須。
  - **意図した乗せ換え直後**: ローカルは必ず乖離し、**origin にはまだ乗せ換え前の旧 SHA が載っている**ため、`git log <b>..origin/<b>` のような到達性チェックは正常系で誤検知する — 代わりに `origin/<b>` が **rebase 前に記録した旧 tip と一致する**ことを確認する（`git rev-parse` の同値比較。それ以外の値なら第三者 push）。
  - **自分の追いコミットで意図的に先行している（sync 済み後）**: `origin/<b>` が `<b>` の**祖先**であること（`git merge-base --is-ancestor origin/<b> <b>`）、かつ origin に無いコミットが全て自分のものであることを確認。origin 側だけにあるコミットは第三者 push。
  - origin 未存在の新規ブランチはどの状態でも問題ない。
- マージは merge commit（squash は `gh stack sync` の履歴照合が濁る）。
- レビュー依頼はスタック完成時に 1 通（プロジェクトのレビュー依頼チャネル）。全 PR リンク + 下から読む順序 + 各 PR の一言。

## 拡張の既知の罠（gh-stack 拡張 v0.1.x、2026-09-01 の事故で確認）

公式 `gh-stack` スキルには載っていない、拡張自体の実挙動の罠。拡張側で修正されたら消してよい。

- `gh stack submit` は**全**スタックブランチ（トランク = 集約ルート含む）をローカル ref から無検証で force push する。ローカルが古いと**リモートのトランクを巻き戻す** — 上の local==origin 確認の理由。
- `gh stack unstack` の「stack was left in place」メッセージは信用できない。open PR だけ unstack され、マージ済み PR が残った閉じたスタックが GitHub に残る（部分成功）。復旧: `gh stack unstack --local` → `gh stack init --base <集約ルート> <branch...>` → `gh stack submit`（既存 PR はブランチ名で自動採用）。
- 拡張のメッセージ全般（「re-based onto the trunk」等）は実際の git 操作と一致しないことがある。`git rev-parse` と API の生データ（GraphQL `pullRequest.stack` / REST `repos/{o}/{r}/stacks/{n}`）で確認する。

## 合理化テーブル

| 言い訳 | 現実 |
|---|---|
| 「default が main だから main でいい」 | 統合ブランチはマージ済み PR のベース。確認する。 |
| 「1 本目はルートに直接積めば本数が減る」 | 集約ルートは受け皿。直接積むと統合 PR に未レビュー diff が混ざる。1 本目もスライス。 |
| 「スライスごとに統合へマージすれば早く届く」 | 統合はマージごとにバージョンが切られる。1 チケット N バージョン + 無関係 PR が挟まる。統合へは集約ルートで 1 回。 |
| 「小さくてもスタックの練習になる」 | 単発はオーバーヘッド。単一 PR。 |
| 「amend の方が履歴がきれい」 | reviewer が指摘差分を追えなくなる。 |
| 「名前が同じだからすぐ sync していい」 | tip が書き換わっている。先に `--onto`。 |
| 「全部 ready の方がレビューが速い」 | 上段の誤マージを防ぐ。下段だけ ready。 |
| 「拡張が成功と言った」 | メッセージは嘘をつく。`git rev-parse` / API 生データで確認。 |

## Red Flags — 検出したらやり直す

- ベースを確認せず `main` / default で init
- 既存のローカル/リモートブランチ名と照合せずスタックブランチを作成
- 単発修正で `gh stack init`
- スライス PR のベースが統合ブランチ
- 集約ルートへ直接コミット
- 全スライスのマージ前に集約ルート → 統合 PR をマージ
- 指摘対応を amend + force push
- 統合ブランチ force push 後にすぐ `gh stack sync`
- 全スタックブランチの意図しない乖離（local vs origin）を確認せず `submit`/`sync`
- 上段まで ready / squash マージ

**ひとつでも該当したら: その手順を止めて上の ✅ に戻す。**
