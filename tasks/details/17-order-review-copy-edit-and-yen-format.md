# 17-order-review-copy-edit-and-yen-format

- Number: 17
- Slug: order-review-copy-edit-and-yen-format

## Notes

- `Order Review` のナビゲーションタイトルを `ご注文内容の確認` に変更した。
- 注文カード内の `カート追加済み` / `決定済み` 表示を撤去し、状態に関係なく `変更` からベース設定/トッピング編集へ戻れるようにした。
- `Order` タブから直接 `S5` を開いた場合でも編集導線が機能するよう、`S3` へ直接遷移するナビゲーション経路を追加した。
- `S5` 画面内の金額表示とクーポン文言の価格表記を `￥XXX` 形式へ揃えた。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
