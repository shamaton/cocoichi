# 28-s5-auto-return-on-empty

- Number: 28
- Slug: s5-auto-return-on-empty

## Notes

- `S5` で注文内容が空になった場合、空状態カードは出さずに `Menu Discovery` へ自動で戻るようにした。
- 自動復帰時は開いている sheet も閉じ、注文確認画面に UI が取り残されないようにした。

## Verification

- `make build` succeeded.
- `git diff --check` returned no issues.
