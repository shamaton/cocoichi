# CoCo壱番屋 新規アプリ PoC 画面遷移図

- 作成日: 2026-03-28
- 目的: PoCで実装する注文体験の画面遷移を定義する
- 関連資料:
  - `docs/poc-app-direction-2026-03-28.md`
  - `docs/app-renewal-planning-611124786-jp-2026-03-28.md`

## 画面遷移の考え方

このPoCでは、`最短で注文を完了する主導線` を最優先に置きます。
その上で、注文体験を豊かにする `お気に入り保存` `クーポン提案` `完了後の再利用導線` をサブ導線として追加します。

遷移の基本方針は次の通りです。

- 画面の主遷移は `NavigationStack` を前提とした push 中心
- 補助操作は `sheet` または `bottom sheet` で見せる
- 完了後は戻るのではなく、明確な完了画面を経由する
- ログイン前提の分岐は持たない

## 画面一覧

| ID | 画面名 | 役割 |
| --- | --- | --- |
| S1 | Welcome / Store Select | 注文の起点。店舗を決める |
| S2 | Menu Discovery | 商品を探し、選ぶ |
| S3 | Curry Detail / Customize | カレー詳細とカスタマイズ |
| S4 | Saved Combos | 保存済みのお気に入り構成を選ぶ |
| S5 | Order Review | 注文内容の最終確認 |
| S6 | Coupon Suggestion Sheet | 適用可能クーポンの提案 |
| S7 | Save Favorite Sheet | 現在の組み合わせ保存 |
| S8 | Order Complete | 注文完了演出と次行動提示 |

## 全体遷移図

```mermaid
flowchart TD
    A[S1 Welcome / Store Select] --> B[S2 Menu Discovery]
    A --> D[S4 Saved Combos]

    B --> C[S3 Curry Detail / Customize]
    B --> D

    D --> C
    D --> B

    C --> E[S5 Order Review]
    C --> G[S7 Save Favorite Sheet]
    G --> C

    E --> F[S6 Coupon Suggestion Sheet]
    F --> E
    E --> H[S8 Order Complete]
    E --> G
    G --> E

    H --> B
    H --> D
    H --> A
```

## 主導線

### 1. 最短注文フロー

最も重要な導線です。

```text
S1 Store Select
  -> S2 Menu Discovery
  -> S3 Curry Detail / Customize
  -> S5 Order Review
  -> S6 Coupon Suggestion Sheet
  -> S8 Order Complete
```

狙い:

- 店舗決定後、余計な登録導線なしで注文検討に入れる
- 商品選択から確認までを一筆書きで進める
- クーポンは最後に提案し、文脈に合うものだけを見せる
- 完了時に不安を残さない

### 2. お気に入り経由フロー

常連利用に向けた時短導線です。

```text
S1 Store Select
  -> S4 Saved Combos
  -> S3 Curry Detail / Customize
  -> S5 Order Review
  -> S6 Coupon Suggestion Sheet
  -> S8 Order Complete
```

狙い:

- いつもの注文をベースに小さく調整する
- Saved Combos を独立画面にしつつ、注文主導線から浮かせない

## 画面ごとの遷移定義

### S1. Welcome / Store Select

目的:

- 注文開始の心理的ハードルを下げる
- 店舗が決まったらすぐ食事検討に移す

遷移:

- `店舗を選択` -> `S2 Menu Discovery`
- `保存済みから始める` -> `S4 Saved Combos`

UIメモ:

- 店舗選択はフルスクリーンの初期画面
- 店舗確定時に軽い成功演出を返す

### S2. Menu Discovery

目的:

- メニュー一覧から迷わず商品を選ばせる
- 探す行為自体を楽しくする

遷移:

- `商品カードを選択` -> `S3 Curry Detail / Customize`
- `保存済み構成を見る` -> `S4 Saved Combos`
- `店舗変更` -> `S1 Welcome / Store Select`

UIメモ:

- おすすめ、定番、最近見た構成などの区切りを試す
- 検索や絞り込みはネイティブの検索UIを使う

### S3. Curry Detail / Customize

目的:

- PoCの中心画面
- カスタマイズの楽しさと分かりやすさを両立する

遷移:

- `確認へ進む` -> `S5 Order Review`
- `お気に入り保存` -> `S7 Save Favorite Sheet`
- `戻る` -> `S2 Menu Discovery` または `S4 Saved Combos`

UIメモ:

- トッピング、辛さ、量の変更は即時反映
- 価格とビジュアルの変化を遅延なく見せる
- 保存操作は別画面遷移ではなく sheet が適切

### S4. Saved Combos

目的:

- 保存した構成の再利用を速くする
- 再注文文化を作る

遷移:

- `保存済み構成を選択` -> `S3 Curry Detail / Customize`
- `メニュー一覧へ` -> `S2 Menu Discovery`
- `店舗変更` -> `S1 Welcome / Store Select`

UIメモ:

- 完全固定ではなく、再開後に編集できる前提
- `いつものやつ` を一番気持ちよく始められる画面にする

### S5. Order Review

目的:

- 注文の不安をなくし、最後の確認を短く済ませる

遷移:

- `クーポンを見る` -> `S6 Coupon Suggestion Sheet`
- `お気に入りとして保存` -> `S7 Save Favorite Sheet`
- `注文する` -> `S8 Order Complete`
- `内容を修正` -> `S3 Curry Detail / Customize`

UIメモ:

- 合計、内容、受取店舗が一画面で確認できる
- クーポンは独立画面へ飛ばさず sheet で補助表示する
- 注文ボタンは強い主要CTAとして固定配置する

### S6. Coupon Suggestion Sheet

目的:

- `使えるか分からない` 状態をなくす
- 最後に自然に得を提示する

遷移:

- `クーポンを適用` -> `S5 Order Review`
- `適用せず閉じる` -> `S5 Order Review`

UIメモ:

- bottom sheet 想定
- 適用可能な候補だけを上位に出す
- 説明よりも `この注文ならこれが使える` を優先する

### S7. Save Favorite Sheet

目的:

- 気に入った構成をその場で保存する

遷移:

- `保存する` -> 呼び出し元へ戻る
- `キャンセル` -> 呼び出し元へ戻る

呼び出し元:

- `S3 Curry Detail / Customize`
- `S5 Order Review`

UIメモ:

- modal sheet 想定
- 名前編集を最短で終えられるようにする

### S8. Order Complete

目的:

- 注文成功を曖昧にしない
- 次の行動を明確にする

遷移:

- `もう一度メニューを見る` -> `S2 Menu Discovery`
- `保存済みを見る` -> `S4 Saved Combos`
- `店舗選択に戻る` -> `S1 Welcome / Store Select`

UIメモ:

- 注文確定、受取店舗、受取目安を明示する
- 成功演出は出すが、長すぎない
- 触覚フィードバックを組み合わせる

## 状態変化とモーダル方針

### Pushで遷移する画面

- S1 Welcome / Store Select
- S2 Menu Discovery
- S3 Curry Detail / Customize
- S4 Saved Combos
- S5 Order Review
- S8 Order Complete

理由:

- 注文の進行感と現在地を明確にするため

### Sheetで開く画面

- S6 Coupon Suggestion Sheet
- S7 Save Favorite Sheet

理由:

- 主導線を切らず、補助判断として扱いたいため

## 遷移上の重要ルール

1. ログイン要求で主導線を止めない
2. WebViewへは遷移しない
3. クーポンは専用タブに逃がさず、確認画面の文脈で提案する
4. 完了画面を必ず通す
5. 保存済み構成は一覧閲覧だけで終わらせず、注文再開へ直結させる

## 実装優先度

### P0

- S1 Welcome / Store Select
- S2 Menu Discovery
- S3 Curry Detail / Customize
- S5 Order Review
- S6 Coupon Suggestion Sheet
- S8 Order Complete

### P1

- S4 Saved Combos
- S7 Save Favorite Sheet

PoCとして最初に成立させるべきなのは、`最短注文フローが気持ちよく完走できること` です。
お気に入り保存は重要ですが、主導線が成立してから載せてもよいです。

## 次に詰める論点

1. S2 Menu Discovery の情報構造をどう切るか
2. S3 Curry Detail / Customize のレイアウトを1画面完結にするか、セクション分割するか
3. S5 Order Review でクーポン提案を自動表示にするか、CTA表示にするか
4. S8 Order Complete の成功演出をどの程度強くするか
5. Saved Combos をタブにしない場合、どこから最も自然に再訪できるか
