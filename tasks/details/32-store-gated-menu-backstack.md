# 32-store-gated-menu-backstack

- Number: 32
- Slug: store-gated-menu-backstack

## Notes

店舗未設定でも Home / Menu の閲覧は許可し、商品選択後にだけ S1 Store Select を注文ゲートとして挟む。
店舗確定後は S2 Menu Discovery を NavigationStack の履歴に積み、表示はスキップして選択済み商品の S3 Curry Detail / Customize へ進める。

## Acceptance Criteria

- `Home/Menu -> 商品選択 -> S1 -> S2(stack) -> S3` の履歴が成立する
- `S3 -> 戻る -> S2 -> 戻る -> S1` で店舗選択まで戻れる
- 店舗未設定で選んだ商品は、S1 完了後に同じ商品で S3 を開始する
- S3 から戻った S2 は、選択済み店舗の共通メニュー + 店舗限定メニューを表示する
- 注文作成中の店舗変更は即時自由変更ではなく、戻る履歴または破棄確認付き操作に寄せる
- 店舗変更時に既存の `cartItems / pending draft / applied coupon` がある場合は破棄確認が働く
