# cocoichi

App Store のレビューを取得する Go CLI を追加しています。

## 使い方

1 ページだけ取得する場合:

```bash
go run ./cmd/appstore-reviews --id 611124786 --page 1
```

連続した複数ページを取得する場合:

```bash
go run ./cmd/appstore-reviews --id 611124786 --page 1 --pages 3
```

`country` と `sort` も変更できます。

```bash
go run ./cmd/appstore-reviews --id 611124786 --page 1 --country jp --sort mostrecent
```

出力はレビューだけを抜き出した JSON です。各レビューには取得元ページ番号と元 URL も含まれます。
