# 35-continue-order-menu-context-back

- Number: 35
- Slug: continue-order-menu-context-back

## Notes

S5 の `続けて注文` 後に表示される S2 Menu Discovery で、店舗名と戻り導線が失われないようにする。
このタスクでは一度 S2 を S5 の上に stack したが、後続の task 36 で `S1 -> S2` stack に変更した。
店舗名はジャンル選択 UI の上に表示する。

## Acceptance Criteria

- 後続 task 36 により、`続けて注文` は pending draft を cart line item に昇格した後、`S1 -> S2` stack を作る
- 後続 task 36 により、`続けて注文` 後の S2 で戻ると S1 に戻れる
- 店舗設定済みの S2 では、root / pushed のどちらでもジャンル選択 UI の上に店舗名を表示する
- 店舗名タップで S1 Store Select に戻れる
- cart item がある S2 では注文確認へ戻る footer が表示される
- `make build` が成功する
