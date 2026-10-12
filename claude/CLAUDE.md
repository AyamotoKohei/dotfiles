# 開発スタイル

TDD で開発する（探索 → Red → Green）。リファクタリングは Red → Green のループに含めず、レビュー段階（code-review）で行う。
KPI やカバレッジ目標が与えられたら、達成するまで試行する。
不明瞭な指示は質問して明確にする。
コードには How、テストコードには What、コミットログには Why、コードコメントには Why not を残すこと。

# コード設計

- 関心の分離を保つ
- 状態とロジックを分離する
- 同じ意味の状態を複数の state に保持せず、単一の状態から派生させる
- 可読性と保守性を重視する
- コントラクト層（API/型）を厳密に定義し、実装層は再生成可能に保つ
- コンポーネントには表示文言ではなく mode などの意味的な状態を渡し、文言の選択や i18n は表示責務を持つ内部で行う
- API hook を実装する前に既存の共通 hook・utility を確認し、ローディング・エラー・キャッシュ管理を重複実装しない
- エラーコードや文言の責務がバックエンドまたは共通層にある場合は、機能側へ同じ定義を追加せず既存のレスポンスを利用する
- 静的に判定できるルールはプロンプトではなく、その環境の linter か ast-grep で記述する
- 近くのコードでは有効にしているのに、ここでは意図して無効にしている設定（例: SWR の `keepPreviousData`）は、`false` と明示し、有効にすると失敗するテストで固定する。理由は明示した行に 1 行で添える（理由: コメントだけではコピーされた有効化を止められず、既定値に頼ると意図が読み取れない）

# UI 実装

- ローディング・エラー・空状態を実装する前に類似画面を確認し、プロジェクトで確立された見せ方を踏襲する
- 見た目が同じという理由だけで他画面へ共通化を広げない。共通化は変更範囲が合意されている場合に行う

# テスト

- API の fixture・モック値は TypeScript の型だけでなく、日時形式・null・enum など型コメントやAPI仕様に記載された契約にも合わせる
- テストの警告・stderr を確認・検証するときは vitest に `--reporter=default` を付ける（理由: エージェント環境では既定の reporter が通過したテストの console 出力を省き、警告が出ていないように見える）
- React の act 警告は、`--printConsoleTrace` で更新元のコンポーネントとハンドラを特定してから直す。`act` に渡すコールバックが Promise を返さないと、`await` しても同期の act になる（理由: 同じ警告文でも描画待ちとフォーカス残りなど原因が別で、`await act`・`findBy` では後者の警告が消えない）

# 並列化と subagent

タスクを受けたら最初に「**並列化できる subtask は何か**」「**subagent に投げて main context を空けられるか**」を洗い出してから動く。default は subagent 優先 / 並列優先。

判断:

- **互いに独立な 2+ task** → Agent tool で 1 message 内に並列 dispatch (independent search、 multi-scenario eval、 multi-model 比較など)
- **大量探索・grep・解析 (3+ query 規模)** → `general-purpose` / `Explore` subagent に投げ、 main は要約だけ受け取る
- **bias-free 評価** (skill / prompt / 自分の生成物の検証) → 新規 subagent。 「自分で再読」 は禁じ手 (`empirical-prompt-tuning` の caveat 通り)
- **Long-running batch** (Bash の 10 分上限を超える / `apm install` を多 repo に回す等) → subagent dispatch か `run_in_background` + `Monitor`

避けるべき:

- 直列依存 (前 task の結果が次 task 入力) を無理に並列化する
- 1-step / short lookup を subagent に投げる (overhead がコストに見合わない)
- subagent と main で同じ作業を二重に実行する

# スキルの使い分け

- エージェント向け文書（スキル・CLAUDE.md・AGENTS.md）: 文面や構成を書く・直す → `writing-for-agents`。評価・ベンチマーク・description の起動精度の最適化 → `skill-creator`。frontmatter のキーや設定・フックなど Claude Code の仕様の事実確認 → `working-with-claude-code`

# コマンド実行

- コマンド実行前に `package.json` の `packageManager` を確認し、それに従う。
- 変更ファイルだけ lint したい場合は `package.json` の lint スクリプトで linter を確認し、そのバイナリにファイルを直接渡す（例: `pnpm exec oxlint <files> --max-warnings=0`、`pnpm exec eslint <files>`）。`next lint` にはファイル引数を渡さない（理由: pages/app ディレクトリ検出エラーで失敗することがある）
- zsh で変数に入れた複数のパスをコマンドに渡すときは `xargs` か `${=VAR}` を使う（理由: zsh は引用符なしの変数を単語分割せず、一覧全体が 1 引数になる）

# Git

- プルリクを出すとき、レビュー単位が複数 PR に割れる機能開発は `stacking-prs` スキル（スタック PR の運用ポリシー）に従う。gh stack コマンドの操作方法は公式 `gh-stack` スキル、矛盾時は `stacking-prs` 優先。単発修正は単一 PR
- 対話 rebase は `GIT_SEQUENCE_EDITOR` に todo 書き換えスクリプトを渡して非対話で実行する
- 統合ブランチが履歴書き換えされる運用で base..HEAD に他人のコミットが大量に見えたら、`git cherry` で patch 同値を確認してから `rebase --onto` 現 base で乗せ換える
