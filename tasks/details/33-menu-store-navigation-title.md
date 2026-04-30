# 33-menu-store-navigation-title

- Number: 33
- Slug: menu-store-navigation-title

## Notes

Menu 本文内の店舗情報 UI は削除し、店舗設定済み時だけ navigation 領域に店舗名を表示する。
店舗名は S1 Store Select へ戻る操作として扱い、ジャンル選択 UI より上で店舗文脈を示す。

## Acceptance Criteria

- Menu 本文先頭に `StoreContextCard` / 店舗未設定カードを表示しない
- 店舗設定済みの Menu では navigation title に店舗名を表示する
- 店舗名タップで履歴上の `S1 Store Select` へ戻れる
- 店舗未設定時は Menu から直接店舗選択カードを出さず、Home / Order または商品タップ後の S1 ゲートで店舗選択する
- `make build` が成功する
