# cocoichi

App Store のレビューを取得する Go CLI を追加しています。

## iOS PoC のローカル実行

Xcode プロジェクトの確認は、基本的にルートの `Makefile` を使います。

```bash
make diagnose
make build
make run
make test
make agent-verify
```

`make build` はビルド成功後、すでに `Booted` の iPhone Simulator があればその端末へ `.app` を再インストールして再起動します。自動反映を止めたい場合は `AUTO_RUN_ON_BOOTED_SIM=0 make build` を使ってください。

ビルド成果物とログは `build/` 配下に出力されます。必要なら `AGENT_NAME=foo make build` のように agent 名を分けて実行できます。

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
