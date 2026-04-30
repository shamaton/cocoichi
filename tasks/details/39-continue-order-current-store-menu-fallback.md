# 39-continue-order-current-store-menu-fallback

- Number: 39
- Slug: continue-order-current-store-menu-fallback

## Notes

S5 の `続けて注文` から `S1 Store Select -> S2 Menu Discovery` の stack を作ったあと、S2 から S1 に戻って選択中店舗カードを押すと、古い `nextPathAfterStoreSelect` が残っている場合に商品未選択のまま S3 へ進めてしまう。

`showStoreMenuBackstack` で S1 再選択後の次画面を S2 に固定し、S1 側でも `draftOrder == nil` のときは S2 へ戻す。

## Acceptance Criteria

- `続けて注文` 後の `S1 -> S2` stack で、S2 からS1へ戻れる
- S1 の選択中店舗カードを押したとき、追加注文の商品未選択なら S2 Menu Discovery へ戻る
- 商品選択後の店舗ゲートやお気に入り再開では、既存の S3 遷移を維持する
- `make build` が成功する
