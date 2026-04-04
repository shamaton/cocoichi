# CoCo壱番屋 新規アプリ PoC ビジュアルトーンボード

- 作成日: 2026-03-28
- 目的: PoCの主要画面に共通する視覚言語を定義し、UI実装前の判断基準を揃える
- 対象画面:
  - `S2 Menu Discovery`
  - `S3 Curry Detail / Customize`
  - `S5 Order Review`
  - `S6 Coupon Suggestion Sheet`
  - `S8 Order Complete`
- 関連資料:
  - `docs/poc-app-direction-2026-03-28.md`
  - `docs/poc-screen-flow-2026-03-28.md`
  - `docs/poc-wireframes-s2-s3-2026-03-28.md`
  - `docs/poc-wireframes-s5-s6-2026-03-28.md`
  - `docs/poc-wireframes-s8-2026-03-28.md`

## デザインステートメント

このPoCの見た目は、`高級レストランの予約UI` でも `クーポン配布アプリ` でもなく、`カレーを選ぶ時間が少し楽しくなる温度感のあるネイティブUI` を目指す。

視覚表現の軸は次の3つです。

1. 食欲をつくる温かさ
2. 注文を迷わせない明快さ
3. 最新のiOSらしい軽さと層の美しさ

## キーワード

- Warm
- Crisp
- Layered
- Playful
- Appetizing
- Native

## 非キーワード

- クールすぎる金属感
- 重すぎる高級感
- Webカードの寄せ集め感
- ポイントアプリの販促感
- 過剰なガラス演出

## ムードの方向性

### 全体ムード

- ベースはやわらかいアイボリーと淡いスパイス色
- 主要アクションは濃いカレー色とクリアなコントラストで見せる
- 写真は食欲が立つ寄りの色温度
- 情報面は軽やかだが、CTAと価格は確実に強く見せる

### 触感のイメージ

- 表面はなめらか
- ガラスは透明度よりも `奥行き整理` のために使う
- カードは浮かせるが、浮きすぎない
- ボタンは押したくなる弾性を持たせる

## カラーパレット

### Core

| Token | Color | 用途 |
| --- | --- | --- |
| `bg.base` | `#F6F1E7` | 全体背景 |
| `bg.elevated` | `#FFF9F0` | カード背景 |
| `bg.glass` | `rgba(255, 248, 235, 0.72)` | 軽いガラス素材 |
| `text.primary` | `#2E221B` | 本文 |
| `text.secondary` | `#6A5648` | 補足文 |
| `text.inverse` | `#FFF8EF` | 暗色面上の文字 |
| `line.soft` | `rgba(84, 58, 39, 0.10)` | 区切り線 |

### Spice

| Token | Color | 用途 |
| --- | --- | --- |
| `accent.curry` | `#8B4A1F` | 主CTA、価格強調 |
| `accent.cheese` | `#E5B94E` | ハイライト、選択済みアクセント |
| `accent.green` | `#5E7D3B` | トッピング系補助表現 |
| `accent.red` | `#B84E2F` | 辛さ、注意、熱量表現 |
| `accent.cream` | `#F2D7A6` | サブ背景ハイライト |

### Status

| Token | Color | 用途 |
| --- | --- | --- |
| `status.success` | `#4E7A45` | 完了、適用済み |
| `status.info` | `#6B7C93` | モック情報、補足 |
| `status.warning` | `#B8752C` | 要確認 |

## タイポグラフィ方針

### 方向性

- iOS標準タイポを活かしつつ、ウェイト差で温度感を作る
- タイトルは丸みよりも `食欲の強さ` が出る太さを選ぶ
- 補足は軽くしすぎず、読みやすさを優先する

### 推奨階層

| Role | Suggested Style | 用途 |
| --- | --- | --- |
| Hero Title | `largeTitle` 相当 / bold | 商品名、完了文言 |
| Section Title | `title3` 相当 / semibold | セクション見出し |
| Card Title | `headline` 相当 / semibold | カード見出し |
| Body | `body` 相当 / regular | 本文 |
| Meta | `subheadline` 相当 / regular | 補足 |
| Micro | `caption` 相当 / medium | ラベル、状態表示 |

### 数字の扱い

- 価格と時間は常に視認優先
- 合計金額は一段太く、周囲から明確に分離する
- 受取時間は数字の塊として読みやすく見せる

## 素材とレイヤー

### 素材方針

- `glass` は上に乗る情報の整理に使う
- 食品写真の上では透明度を上げすぎない
- 完全透明より、少しミルキーなガラスが合う

### レイヤーの基本ルール

1. 背景
2. 写真または大きい面
3. 情報カード
4. CTA
5. 一時的な sheet / toast / feedback

### 影の考え方

- 影は濃くしない
- 広く薄いシャドウで浮遊感を作る
- `影で強調` ではなく `コントラストと余白` で整理する

## コンポーネントトーン

### ボタン

- 主CTA:
  - 濃いカレー色
  - 角丸は十分に大きく
  - 押下時はわずかに沈む
- 副CTA:
  - アイボリー面 + 柔らかい境界線
  - 文字色は主CTAほど強くしない

### カード

- Elevated Card:
  - 明るい背景
  - 軽い影
  - 大きめの角丸
- Glass Card:
  - 確認系や提案系で使用
  - 背景の色味を少し受ける程度に抑える

### チップ

- 定番、人気、辛さ、絞り込みに使用
- 小さいが色味で意味を持てるようにする
- 選択時は塗りつぶし、未選択時は薄い境界線

### シート

- Coupon Suggestion は bottom sheet
- Save Favorite は modal sheet
- どちらも背景ぼかしは軽く、情報面を優先する

## 写真とビジュアル資産

### 写真方針

- 真上からの説明写真ではなく、少し角度のある食欲写真
- ルーの艶、衣の質感、チーズの光、緑トッピングの差し色を重視
- 暗すぎる写真は避ける

### アイコン方針

- SF Symbols を基準
- 塗りつぶしより線ベースを基本にし、成功状態だけ面を使う
- カスタムアイコンを増やしすぎない

## モーション方針

### 基本原則

- `速い、軽い、気持ちいい`
- 装飾のための動きではなく、状態変化の理解を補助する動きにする

### 推奨モーション

| シーン | モーション |
| --- | --- |
| 商品カード選択 | Hero への滑らかな遷移 |
| トッピング追加 | 合計金額と Order Snapshot の同時反応 |
| クーポン適用 | 価格更新と sheet の収束 |
| 完了 | success mark の短いスケールアップ |

### 避けるもの

- 長すぎるフェード
- パーティクル過多
- バウンスしすぎるCTA
- 読み終わる前に消える情報

## 画面別トーン

### S2 Menu Discovery

ムード:

- 期待感
- 食べたい気分を引き出す
- 軽快

ビジュアル要素:

- 写真比率を高めに
- セクション間に呼吸できる余白
- おすすめエリアは少し明るめの面で浮かせる
- `For You` は個人的な提案に見えるやわらかい色面

色の使い方:

- ベースは明るく
- タグやチップでスパイス色を差す
- 商品価格は `accent.curry`

### S3 Curry Detail / Customize

ムード:

- 没入
- 調整の楽しさ
- 手触りの良さ

ビジュアル要素:

- Hero Image を大きく見せる
- Order Snapshot Card は少し浮かせる
- 選択中のトッピングや辛さは、視覚差が明確であること
- CTAエリアは常に安心して押せる重さを持たせる

色の使い方:

- 選択済みは `accent.cheese` と `accent.red` を使い分ける
- 情報面は背景を明るくして読みやすさ優先

### S5 Order Review

ムード:

- 安心
- 整理
- 最後のひと押し

ビジュアル要素:

- 余白を多めに取り、焦らせない
- Pickup Card は安定感重視
- pending draft は編集可能な面、cart line item は read-only の面として視覚差を持たせる
- Price Summary は一段濃い面で分かりやすく
- `Suggested Savings` は少し華やぐが、主役にはしない

色の使い方:

- 主に中立色
- Savings 提案だけアクセントを足す
- `Place Order` は一番強いコントラスト

### S6 Coupon Suggestion Sheet

ムード:

- お得
- 軽い驚き
- 迷わない提案

ビジュアル要素:

- シートはやや明るめ
- Best Match を一番広く、太く見せる
- 金額差分を数字で強く見せる
- 適用不可は存在を薄く見せる

色の使い方:

- `accent.cheese` と `accent.cream` でお得感
- 適用ボタンは主CTA色
- 適用済みは `status.success`

### S8 Order Complete

ムード:

- 解放
- 満足
- 次へ進める安心

ビジュアル要素:

- 成功マークは大きいが短時間
- 情報表示状態では落ち着いた構成へ移る
- CTAは縦積みで迷わせない
- 受取情報はカードで安定表示

色の使い方:

- 背景はやや明るく柔らかい
- success は緑を使うが、医療的な冷たさは避ける
- 主CTAは注文導線と同じ色で一貫させる

## 画面横断の一貫ルール

1. 主CTA色は全画面で固定する
2. 価格強調色は固定する
3. 選択済み状態の見せ方を画面ごとに変えすぎない
4. ガラス素材は `提案` と `補助情報` に限定する
5. 完了画面だけ別世界にしない

## 実装メモ

### SwiftUIで意識する点

- `Material` をそのまま多用せず、背景とのコントラストを見て調整する
- `matchedGeometryEffect` 的なつながりを主要導線で使う
- `contentTransition` や数値変化アニメーションを価格更新に使う
- `sensoryFeedback` を保存、適用、完了に限定して使う

### Reduce Motion / Accessibility

- モーションの意味が消えない範囲で静的代替を持つ
- 色だけで状態を伝えない
- 価格、時間、店舗名の読みやすさを最優先にする

## Do / Don't

### Do

- 温かい背景にクリアな情報カードを重ねる
- CTAを迷わせない
- 食欲写真を活かす
- 選択反応を即時に返す
- 完了時の安心感をしっかり作る

### Don't

- 紫寄りの近未来UIにする
- 透明すぎるガラスで文字を読みにくくする
- クーポンを目立たせすぎて注文の主役を奪う
- 影と装飾で情報を重くする
- 画面ごとに違うアプリのような見た目にする

## 参考

- Apple Developer: Liquid Glass
  - https://developer.apple.com/documentation/technologyoverviews/liquid-glass
- Apple Human Interface Guidelines
  - https://developer.apple.com/design/human-interface-guidelines/
