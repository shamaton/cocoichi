# 20-remove-line-total-label-from-order-review

- Number: 20
- Slug: remove-line-total-label-from-order-review

## Notes

- `S5 Order Review` の各注文カードに表示していた `Line Total` ラベルを削除した。
- 金額はラベルなしの右寄せ表示に変更し、カード内の情報量を減らした。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
