# 33-menu-store-navigation-title

- Number: 33
- Slug: menu-store-navigation-title

## Notes

Menu 本文内の店舗情報 UI は削除し、店舗設定済み時だけ navigation 領域に店舗名を表示する。
後続 task 37 で、店舗名は表示専用の navigation title に変更した。

## Acceptance Criteria

- Menu 本文先頭に `StoreContextCard` / 店舗未設定カードを表示しない
- 店舗設定済みの Menu では navigation title に店舗名を表示する
- 後続 task 37 により、店舗名はタップ操作を持たない
- 店舗未設定時は Menu から直接店舗選択カードを出さず、Home / Order または商品タップ後の S1 ゲートで店舗選択する
- `make build` が成功する
