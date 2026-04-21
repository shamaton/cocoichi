# 12-s5-order-summary-copy-and-bullets

- Number: 12
- Slug: s5-order-summary-copy-and-bullets

## Notes

- `Your Order` の見出しを `ご注文内容の確認` に変更した。
- 注文カード先頭の `1皿目` などの番号見出しを撤去し、商品名を主見出しにした。
- `ベース` と `トッピング` は `/` 区切りではなく箇条書き表示へ変更した。

## Verification

- `AGENT_NAME=CODEX make build` succeeded.
- `git diff --check` returned no issues.
