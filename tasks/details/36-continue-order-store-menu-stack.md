# 36-continue-order-store-menu-stack

- Number: 36
- Slug: continue-order-store-menu-stack

## Notes

S5 の `続けて注文` 後は S5 を戻り履歴に残さず、`S1 Store Select -> S2 Menu Discovery` の stack を作って S2 を表示する。

## Acceptance Criteria

- `続けて注文` は pending draft を cart line item に昇格する
- その後の navigation path は `S1 Store Select -> S2 Menu Discovery` になる
- `続けて注文` 後の S2 で戻ると S1 に戻る
- S1 から戻る時は既存の注文リセット確認が働く
- S2 では navigation title に店舗名が表示される
- `make build` が成功する
