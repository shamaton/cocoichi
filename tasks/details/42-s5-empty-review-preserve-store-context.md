# 42-s5-empty-review-preserve-store-context

- Number: 42
- Slug: s5-empty-review-preserve-store-context

## Notes

- S5で最後の注文内容を削除する時、削除対象の店舗を `selectedStore` として保持してから明細を破棄するようにした。
- 空のS5から自動復帰する時、既存の `S1 Store Select -> S2 Menu Discovery` stack があれば S2 まで pop し、注文文脈内の Menu に戻すようにした。
