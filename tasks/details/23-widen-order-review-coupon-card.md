# 23-widen-order-review-coupon-card

- Number: 23
- Slug: widen-order-review-coupon-card

## Notes

- `S5 Order Review` のクーポン表示カードに `maxWidth` を付け、他カードと同じ横幅で広がるようにした。
- 適用中クーポン表示とクーポン提案表示の両方に同じ幅揃えを入れた。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
