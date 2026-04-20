# 10-topping-selection-quantity-and-footer-summary

- Number: 10
- Slug: topping-selection-quantity-and-footer-summary

## Notes

- S3 トッピング phase の選択済みチップ表示を撤去し、下部フッター内の summary 表示へ移した。
- 同一トッピングの複数選択を `DraftOrder.toppings` の重複保持で表現し、集計表示は `x N` 表記へ統一した。
- トッピングカードは未選択時 `追加`、選択後 `- / +` で個数調整する挙動へ変更した。

## Verification

- `AGENT_NAME=CODEX AUTO_RUN_ON_BOOTED_SIM=0 make build` succeeded.
- `AGENT_NAME=CODEX make test` failed because scheme `CocoichiPoC` is not configured for the test action.

## Subagent review result

- size: medium
- reviewers: 2
- iterations: 2/5
- status: ok

### Fixed

- `CocoichiPoC/Domain/POCModels.swift`: 減算時に `lastIndex(where:)` を使うようにし、数量サマリーの並び順が揺れないようにした。
- `CocoichiPoC/Features/OrderFlowCustomizationComponents.swift`: 数量調整ボタンのヒット領域を 44x44pt に拡張した。

### Advisory

- test action が未設定のため、数量集計まわりの自動テストは未整備。

### Unreviewed

- none
