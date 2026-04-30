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

## Implementation Notes

- `AppScreen.storeSelect` と `AppScreen.menuDiscovery` を追加し、S1/S2 を NavigationStack 上の履歴として扱う
- 店舗未設定で商品を選んだ時は `pushStoreSelectForMenuSelection()` で `Menu` タブへ移り、`path = [.storeSelect]` にする
- S1 で店舗確定後、保留していた商品で draft を開始できた場合は `path = [.storeSelect, .menuDiscovery, .curryDetail]` にする
- draft を開始できない場合は `path = [.storeSelect, .menuDiscovery]` にし、店舗文脈つきメニューへ戻す
- 通常の店舗選択も full-screen S1 を出さず、stack 上の S1 へ遷移する
- stack 内の S2 で店舗カードを押した場合は、履歴上の S1 へ戻す
