# 37-menu-store-title-static

- Number: 37
- Slug: menu-store-title-static

## Notes

Menu の店舗名は navigation title として表示し、タップ可能な店舗選択導線にはしない。
ジャンル選択 UI の上に出していた店舗名ボタンを削除する。

## Acceptance Criteria

- 店舗設定済みの Menu は navigation title に店舗名を表示する
- 店舗名は表示専用で、タップ操作を持たない
- ジャンル選択 UI の上に店舗名ボタンを表示しない
- `続けて注文` 後の S2 でも navigation title に店舗名を表示する
- `make build` が成功する
