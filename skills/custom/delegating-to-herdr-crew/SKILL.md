---
name: delegating-to-herdr-crew
description: Use when asked to have the herdr「workerタブ」implement and the「reviewerタブ」review — a review-comment fix PR or a new feature/ticket. The calling session stays the foreman: investigate, brief, triage review findings, loop until clean. herdr CLI mechanics live in the herdr skill.
---

# Herdr crew への委任

呼び出したセッションは **foreman** として振る舞う。調べて、brief を書き、レビュー結果を仕分ける。コードを書くのは worker、レビューするのは reviewer と subagent。foreman は製品リポジトリを編集しない。

CLI の構文は `herdr` スキルと `herdr <group>` の出力に従う。始める前に `test "${HERDR_ENV:-}" = 1` を確認する。

## 1. crew を見つける

- `herdr tab list --workspace "$HERDR_WORKSPACE_ID"` を実行し、ラベルが `worker` と `reviewer` のタブを探す。続けて `herdr pane list` で、それぞれの pane ID とエージェントの種類を調べる。
- crew のエージェントには名前が付いていないことが多い。その場合は pane ID（例: `w1:p7`）を宛先にする。
- 対象リポジトリのメインのチェックアウトが、ユーザーの別作業のブランチにあることがある。`git status -sb` と `git worktree list` で確認する。

完了条件: 両方の pane ID が分かり、どちらのエージェントも `idle` か `done` になっている。タブがない、または `working` のときは、ユーザーに確認する。

## 2. 調べる（foreman）

worker に調査をやり直させないように、根拠は foreman が集める。独立した調査（フロント・バックエンド・infra など）は subagent に並列で投げ、要約だけを受け取る。

- **レビュー指摘への対応**: 指摘が妥当かを判断する。既存コードの前例、ほかのリポジトリでの扱い、環境ごとの違いを調べる。指摘以外に見つかった問題（古くなったコメント、仕様のずれなど）も拾う。
- **新規実装**: チケットや仕様の受け入れ条件、真似できる既存のパターン、積み先のブランチを調べる。仕様が曖昧なときは、委任する前にユーザーに確認する。
- **共通（機能フラグ）**: 変更が触る機能のうち、環境変数などの機能フラグで無効にできるものを一覧にする。フラグ名・既存の判定箇所（`file:line`）・その機能が表示される箇所（フォーム、一覧、詳細など）を並べる。同じグループの兄弟項目（隣のスイッチなど）も含める（理由: 1 項目だけ出し分け、隣は常に表示、という食い違いはその項目だけを見ても気づけない）。

ユーザーに結論と対応案を報告し、委任の了承を得てから 3 に進む。了承済みの依頼なら、そのまま進む。

完了条件: brief の「調査済みの事実」に入れる項目が、すべて `file:line` で示せる。

## 3. worker に brief を渡す

brief は scratchpad にファイルとして書く。送るときは `herdr agent prompt <pane> "$(cat <file>)" --wait --timeout <ms>` を `run_in_background` で実行する（理由: Bash の前面実行は 10 分で打ち切られる）。brief には次の節を入れる。

- **作業場所**: リポジトリ、base ブランチ、作るブランチ名、チケット番号、`git worktree add` を使うかどうか。メインのチェックアウトがユーザーの作業中なら、必ず worktree を使わせる。
- **調査済みの事実**: 2 で集めた `file:line` 付きの事実。
- **やること**: 番号付きで書く。TDD で進めること（先に失敗するテストを書く）、lint・型チェック・テストを通すこと、draft PR の作成まで含める。コメントと JSDoc は `writing-code-comments` スキルに従い、守りたい挙動はテストで固定すること、とも書く。触ってはいけない範囲も書く。
- **判断を任せる点**: worker に決めさせることと、その理由を PR 本文に書くこと。
- **報告**: PR の URL と、判断した点を短く報告させる。

外に出る操作（ready for review への変更、マージ、レビューコメントへの返信）はユーザーの了承を得てからにする。brief でも、これらはまだしないと明記する。

完了条件: worker が `idle` か `done` に戻り、PR の URL が分かっている。結果は `herdr agent read <pane> --source recent-unwrapped --lines 200` で読む。wait が返っても、`herdr agent get <pane>` で状態をもう一度確かめる（理由: crew が承認待ちになると `--wait` はその時点で返り、承認したあとの `agent wait` も作業中のうちに返ることがある）。`blocked` のときは画面を読んでユーザーに選択肢を示し、返ってきた答えを `agent send-keys` で入力する。

## 4. reviewer と subagent にレビューを依頼する

reviewer と新規の subagent（`general-purpose`）に、同じ依頼を同じタイミングで並列に出す。reviewer への `herdr agent prompt` は `run_in_background` で実行し、同じメッセージで Agent tool を呼ぶ（理由: エージェントの種類と文脈が違うと、拾える指摘が変わる）。

依頼には PR の URL、変更の意図（元の指摘やチケット）、受け入れ条件、2 で作った機能フラグの一覧を入れる。そのうえで、次の 4 点を指示する。

- 直すべき指摘だけを、`file:line` と理由を添えて返す。
- 一覧の各フラグを無効にした環境で、表示箇所ごとの見え方（隠す・注記付きで見せる・常に表示）と保存される値を確かめる。兄弟項目と扱いが食い違うものは、そろえる理由がコミットや PR 本文に書かれていなければ指摘として返す。
- 追加したコメントと JSDoc を `writing-code-comments` スキルの書き方の規則と Red Flags に照らして確かめる。違反は「削除」として返す。
- ファイルの編集・commit・push はしない。

完了条件: reviewer と subagent の両方の報告を読み終わっている。

## 5. 仕分けて差し戻す

指摘はそのまま worker に転送しない。reviewer と subagent の指摘のうち同じものは 1 件にまとめ、1 件ずつ、次の 3 つに仕分ける。

- **妥当**: 直す。
- **見送り**: 範囲外、または根拠が弱い。理由を記録する。
- **ユーザー判断**: 仕様や範囲に関わる。

妥当なものだけを worker に差し戻し、push が済んだら、変更点を示して、4 と同じく reviewer と新規の subagent に並列で再レビューを依頼する。妥当な指摘がなくなったら終える。3 往復しても終わらないときは、ユーザーに判断を仰ぐ。

## 6. ユーザーに報告する

次の内容を報告する。

- PR の URL
- 変更の要点
- 見送った指摘とその理由
- ユーザーの判断が必要な点
- 残っている外向きの操作（ready への変更、元のコメントへの返信など）

crew が作った worktree の後片付けは、PR がマージされてから行う。
