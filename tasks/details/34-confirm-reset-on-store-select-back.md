# 34-confirm-reset-on-store-select-back

- Number: 34
- Slug: confirm-reset-on-store-select-back

## Notes

店舗選択済みかつ注文中の状態で S1 Store Select から戻る時は、注文状態の破棄確認を出す。
承諾時は店舗と注文状態をリセットし、Home root へ戻す。

## Acceptance Criteria

- S1 は標準 back ではなくカスタム back で戻る操作を処理する
- `selectedStore != nil` かつ `hasReviewItems == true` の時、戻る操作で確認ダイアログを出す
- キャンセル時は S1 に留まる
- 承諾時は `resetForNextOrder(keepingStore: false)` を実行し、Home root に戻る
- 注文中でない時は確認なしで通常の戻る操作を行う
- `make build` が成功する
