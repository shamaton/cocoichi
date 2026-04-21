# 14-s3-toppings-base-summary

- Number: 14
- Slug: s3-toppings-base-summary

## Notes

- `S3` トッピング画面のヒーロー画像直下に、ベース設定の簡易箇条書きを追加した。
- 箇条書きは `カレーソース` `ライス NNNg` `辛さ N辛` を常時表示し、`ソース増し` は通常以外のときだけ表示する。
- 既存の `タップでトッピングが追加できます` テキストは箇条書きの下へ残した。

## Verification

- `AGENT_NAME=CODEX make build` succeeded.
- `git diff --check` returned no issues.
