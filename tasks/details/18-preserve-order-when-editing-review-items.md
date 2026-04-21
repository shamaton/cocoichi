# 18-preserve-order-when-editing-review-items

- Number: 18
- Slug: preserve-order-when-editing-review-items

## Notes

- `S5` の注文リストを `cartItems + pending draft` の固定末尾表示ではなく、review 用の表示順を持つ構造に変更した。
- cart item の `変更` を押した時は、その行の review 上の index を保持したまま編集対象へ切り替え、元の pending draft は同じ相対位置へ戻すようにした。
- `続けて注文` と `注文を確定` でも、review 上で見えていた順番のまま cart / completed order に反映するように揃えた。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
