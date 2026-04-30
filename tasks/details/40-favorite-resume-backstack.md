# 40-favorite-resume-backstack

- Number: 40
- Slug: favorite-resume-backstack

## Notes

- お気に入り一覧から再開した場合、S4 ではなく `S2 Menu Discovery` を戻り先にして `S3 Curry Detail / Customize` へ進めるようにした。
- 店舗未選択のお気に入り再開では、店舗確定後の stack を `S1 Store Select -> S2 Menu Discovery -> S3 Curry Detail / Customize` にする。
- お気に入りは独立した注文フローではなく、S2 から選び直せるプリセット導線として扱う。
- `make build` 成功。
- `git diff --check` 問題なし。
