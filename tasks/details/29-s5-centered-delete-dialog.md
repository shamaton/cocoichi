# 29-s5-centered-delete-dialog

- Number: 29
- Slug: s5-centered-delete-dialog

## Notes

- `S5` の削除確認を `confirmationDialog` から、画面全体を黒 scrim で覆う中央ダイアログへ変更した。
- 削除対象の状態を `OrderReviewView` 側で持ち、カード位置に依存しない固定位置の確認 UI に揃えた。
- 最後の1件を削除する場合だけ、メニュー選択画面へ戻ることを補足表示するようにした。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
