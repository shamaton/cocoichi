# 24-localize-coupon-list-ui-to-japanese

- Number: 24
- Slug: localize-coupon-list-ui-to-japanese

## Notes

- `CouponSuggestionSheet` 内の英語文言を日本語へ置き換えた。
- `Grab a Saving / Best Match / Apply This Coupon / More Options / Coupon` を、それぞれ `使えるクーポン / おすすめ / このクーポンを使う / その他のクーポン / クーポン` に変更した。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
