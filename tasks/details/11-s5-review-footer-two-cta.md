# 11-s5-review-footer-two-cta

- Number: 11
- Slug: s5-review-footer-two-cta

## Notes

- `OrderReviewView` の `Add More` セクションを撤去し、下部固定 footer に `合計` と `続けて注文` / `注文を確定` の 2CTA を実装した。
- `続けて注文` は既存仕様どおり `pending draft` を cart に昇格させてメニューへ戻す。
- `注文を確定` は既存の注文確定処理を維持したまま文言だけを新仕様へ揃えた。

## Verification

- `AGENT_NAME=CODEX make build` succeeded.
- `git diff --check` returned no issues.
