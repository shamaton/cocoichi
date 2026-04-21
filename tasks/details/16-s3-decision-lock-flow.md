# 16-s3-decision-lock-flow

- Number: 16
- Slug: s3-decision-lock-flow

## Notes

- `S3` ベース設定/トッピング画面の主CTAを `注文確認` から `決定する` に変更した。
- `決定する` 押下時に draft をレビュー固定状態へ切り替え、`S3` と `S5` の通常の戻るボタンを隠すようにした。
- 注文内容の再編集は `S5` の注文リスト内 `変更` 導線だけに集約し、pending draft の状態表示は `決定済み` に更新した。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
