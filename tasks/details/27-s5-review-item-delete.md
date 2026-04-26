# 27-s5-review-item-delete

- Number: 27
- Slug: s5-review-item-delete

## Notes

- `S5` の注文カードに `削除` 導線を追加し、`変更` と並んで商品の除外ができるようにした。
- 削除前に確認ダイアログを挟み、確定済みの商品でも誤操作なしで外せるようにした。
- `OrderStore` に review item 削除処理を追加し、`pending draft` を含む表示順が崩れないよう `pendingReviewInsertionIndex` を調整するようにした。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
