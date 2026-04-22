# 22-remove-store-change-from-order-review

- Number: 22
- Slug: remove-store-change-from-order-review

## Notes

- `S5 Order Review` の受取情報カードから `店舗を変更` ボタンを削除した。
- 店舗限定メニューを含む注文でも、確認画面上で店舗変更できてしまう矛盾をなくした。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
