# 38-selected-store-continue-card

- Number: 38
- Slug: selected-store-continue-card

## Notes

S1 Store Select で既に店舗が選択済みの場合、選択中店舗カードを押下可能にして同じ店舗のまま次へ進める。

## Acceptance Criteria

- 選択中店舗カードの右側に `chevron.right` を表示する
- 選択中店舗カードを押すと、同じ店舗で `commitStoreSelection` 相当の次画面へ進む
- 商品選択後に S1 へ来ている場合は、同じ店舗で S3 へ進める
- 通常の店舗選択導線では、同じ店舗で S2 へ進める
- 別店舗選択時の破棄確認は維持する
- `make build` が成功する
