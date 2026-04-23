# 25-skip-store-confirmation-on-select

- Number: 25
- Slug: skip-store-confirmation-on-select

## Notes

- `S1 Store Select` の店舗選択後確認画面を撤去し、店舗タップで即遷移する流れに変更した。
- 店舗変更で既存の注文状態がある場合のみ、`店舗を変更しますか？` ダイアログを表示して確認するようにした。
- 店舗未選択のまま商品カードを押した文脈を保持し、店舗確定後は `S3` のベース設定へ戻れるようにした。
- 保存済み再開文脈と商品選択文脈が混線しないよう、`OrderStore` 側で pending state を分離した。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
