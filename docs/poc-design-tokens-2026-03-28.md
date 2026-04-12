# CoCo壱番屋 新規アプリ PoC デザイントークン

- 作成日: 2026-03-28
- 目的: ビジュアルトーンボードを実装可能なトークンへ落とし込む
- 対象:
  - 色
  - タイポグラフィ
  - 余白
  - 角丸
  - 影
  - 素材
  - モーション
  - 触覚フィードバック
- 関連資料:
  - `docs/poc-visual-toneboard-2026-03-28.md`
  - `docs/poc-wireframes-s2-s3-2026-03-28.md`
  - `docs/poc-wireframes-s5-s6-2026-03-28.md`
  - `docs/poc-wireframes-s8-2026-03-28.md`

## 方針

このPoCでは、トークンを次の2層で管理する。

1. `foundation tokens`
   - 色、余白、角丸、影、モーションなどの基本値
2. `semantic tokens`
   - `primaryCTA`, `priceText`, `couponCardBackground` のように役割に紐づく値

実装では、可能な限り semantic token を直接参照し、foundation token への依存を画面実装側へ漏らさない。

## 命名ルール

- foundation は `category.role.scale`
  - 例: `color.bg.base`, `space.16`, `radius.card.l`
- semantic は `surface/component/state`
  - 例: `surface.discovery.heroCard`, `cta.primary.background`, `text.price.emphasis`
- 画面固有のものは `screen.component.role`
  - 例: `s6.bestMatch.background`, `s8.successMark.tint`

## Foundation Tokens

### Color

#### Background

| Token | Value | 用途 |
| --- | --- | --- |
| `color.bg.base` | `#F6F1E7` | アプリ全体背景 |
| `color.bg.elevated` | `#FFF9F0` | 基本カード面 |
| `color.bg.elevatedStrong` | `#FFF4E4` | 強めの面 |
| `color.bg.glassTint` | `rgba(255, 248, 235, 0.72)` | 軽いガラス面 |
| `color.bg.cream` | `#F2D7A6` | 提案系の薄い背景 |

#### Text

| Token | Value | 用途 |
| --- | --- | --- |
| `color.text.primary` | `#2E221B` | 主本文 |
| `color.text.secondary` | `#6A5648` | 補足 |
| `color.text.tertiary` | `#8C7869` | さらに薄い補足 |
| `color.text.inverse` | `#FFF8EF` | 暗色面上 |

#### Accent

| Token | Value | 用途 |
| --- | --- | --- |
| `color.accent.curry` | `#8B4A1F` | 主CTA、価格強調 |
| `color.accent.cheese` | `#E5B94E` | 選択済み、提案の温度感 |
| `color.accent.green` | `#5E7D3B` | トッピング補助、成功寄り表現 |
| `color.accent.red` | `#B84E2F` | 辛さ、熱量 |
| `color.accent.cream` | `#F2D7A6` | サブハイライト |

#### Border / Line

| Token | Value | 用途 |
| --- | --- | --- |
| `color.line.soft` | `rgba(84, 58, 39, 0.10)` | 軽い境界線 |
| `color.line.medium` | `rgba(84, 58, 39, 0.18)` | チップ・カード境界 |
| `color.line.strong` | `rgba(84, 58, 39, 0.28)` | 選択強調 |

#### Status

| Token | Value | 用途 |
| --- | --- | --- |
| `color.status.success` | `#4E7A45` | 完了、適用済み |
| `color.status.info` | `#6B7C93` | モック情報、補足 |
| `color.status.warning` | `#B8752C` | 注意 |

### Typography

#### Font Roles

| Token | Suggested Style | Weight | 用途 |
| --- | --- | --- | --- |
| `font.hero` | `largeTitle` | `bold` | 商品名、完了見出し |
| `font.title` | `title3` | `semibold` | セクションタイトル |
| `font.cardTitle` | `headline` | `semibold` | カードタイトル |
| `font.body` | `body` | `regular` | 本文 |
| `font.meta` | `subheadline` | `regular` | 補足 |
| `font.caption` | `caption` | `medium` | ラベル、状態表示 |
| `font.price` | `title3` | `bold` | 合計価格、強調価格 |
| `font.cta` | `headline` | `semibold` | CTAラベル |

#### Numeric Display

| Token | Suggested Style | Weight | 用途 |
| --- | --- | --- | --- |
| `font.numeric.total` | `title2` | `bold` | 合計金額 |
| `font.numeric.price` | `headline` | `semibold` | 商品価格 |
| `font.numeric.time` | `headline` | `semibold` | 受取時間 |

### Space

8pt グリッドを基本に、4pt 刻みを補助に使う。

| Token | Value | 用途 |
| --- | --- | --- |
| `space.4` | `4` | 微調整 |
| `space.8` | `8` | 要素間最小 |
| `space.12` | `12` | チップ・ラベル間 |
| `space.16` | `16` | カード内余白 |
| `space.20` | `20` | セクション内余白 |
| `space.24` | `24` | セクション間 |
| `space.32` | `32` | 大きなブロック間 |

### Radius

| Token | Value | 用途 |
| --- | --- | --- |
| `radius.s` | `10` | 小チップ |
| `radius.m` | `14` | 小カード、入力欄 |
| `radius.l` | `20` | 通常カード |
| `radius.xl` | `28` | 大きな面、hero card |
| `radius.cta` | `22` | ボタン |
| `radius.sheet` | `28` | bottom sheet |

### Shadow

影は濃くせず、広く薄く使う。

| Token | X | Y | Blur | Color | 用途 |
| --- | ---: | ---: | ---: | --- | --- |
| `shadow.card.soft` | `0` | `8` | `24` | `rgba(32, 18, 10, 0.08)` | 通常カード |
| `shadow.card.lifted` | `0` | `12` | `32` | `rgba(32, 18, 10, 0.10)` | 強調カード |
| `shadow.sheet` | `0` | `-8` | `24` | `rgba(32, 18, 10, 0.10)` | bottom sheet |

### Material

| Token | Suggested SwiftUI Material | 用途 |
| --- | --- | --- |
| `material.glass.light` | `.thinMaterial` 相当を調整 | 提案カード |
| `material.glass.sheet` | `.regularMaterial` 相当を調整 | coupon sheet |
| `material.none` | solid fill | 読みやすさ優先面 |

補足:

- Material はそのまま使わず、必要に応じて tint と opacity を追加する

### Motion

| Token | Suggested Value | 用途 |
| --- | --- | --- |
| `motion.fast` | `0.18s` | タップ反応 |
| `motion.base` | `0.28s` | 状態切替 |
| `motion.emphasis` | `0.42s` | Hero 遷移、価格更新 |
| `motion.success` | `0.65s` | 完了演出 |

#### Curve

| Token | Suggested Curve | 用途 |
| --- | --- | --- |
| `curve.standard` | `easeInOut` | 一般遷移 |
| `curve.spring.soft` | soft spring | CTA、カード反応 |
| `curve.spring.hero` | medium spring | Hero 接続 |

### Haptics

| Token | Suggested Feedback | 用途 |
| --- | --- | --- |
| `haptic.selection` | 軽い selection | チップ、辛さ変更 |
| `haptic.impact.soft` | soft impact | トッピング追加 |
| `haptic.success` | success feedback | 保存、適用、完了 |

## Semantic Tokens

### Surface

| Token | Value |
| --- | --- |
| `surface.app.background` | `color.bg.base` |
| `surface.card.default` | `color.bg.elevated` |
| `surface.card.emphasis` | `color.bg.elevatedStrong` |
| `surface.card.glass` | `color.bg.glassTint + material.glass.light` |
| `surface.sheet.coupon` | `material.glass.sheet` |

### Text

| Token | Value |
| --- | --- |
| `text.primary` | `color.text.primary` |
| `text.secondary` | `color.text.secondary` |
| `text.meta` | `color.text.tertiary` |
| `text.price.emphasis` | `color.accent.curry + font.price` |
| `text.success` | `color.status.success` |

### CTA

| Token | Value |
| --- | --- |
| `cta.primary.background` | `color.accent.curry` |
| `cta.primary.foreground` | `color.text.inverse` |
| `cta.primary.radius` | `radius.cta` |
| `cta.secondary.background` | `color.bg.elevated` |
| `cta.secondary.border` | `color.line.medium` |
| `cta.secondary.foreground` | `color.text.primary` |

### Chips

| Token | Value |
| --- | --- |
| `chip.default.background` | `color.bg.elevated` |
| `chip.default.border` | `color.line.medium` |
| `chip.selected.background` | `color.accent.cheese` |
| `chip.selected.foreground` | `color.text.primary` |
| `chip.spicy.selected.background` | `color.accent.red` |
| `chip.spicy.selected.foreground` | `color.text.inverse` |
| `chip.storeOnly.background` | `color.accent.cream` |
| `chip.storeOnly.foreground` | `color.text.primary` |
| `chip.storeOnly.border` | `color.line.medium` |

### Price

| Token | Value |
| --- | --- |
| `price.current.text` | `text.price.emphasis` |
| `price.discount.text` | `color.status.success + font.numeric.price` |
| `price.summary.background` | `color.bg.elevatedStrong` |

### State

| Token | Value |
| --- | --- |
| `state.selected` | `color.accent.cheese` |
| `state.applied` | `color.status.success` |
| `state.unavailable` | `color.text.tertiary` |
| `state.warning` | `color.status.warning` |

## Screen Token Mapping

### S2 Menu Discovery

| Role | Token |
| --- | --- |
| Background | `surface.app.background` |
| Store Context Header | `surface.card.default` |
| This Store Only card | `surface.card.emphasis` |
| Store Only badge | `chip.storeOnly.*` |
| For You card | `surface.card.emphasis` |
| Popular section card | `surface.card.default` |
| Search field | `surface.card.default` + `radius.m` |
| Filter selected | `chip.selected.background` |
| Price | `price.current.text` |

### S3 Curry Detail / Customize

| Role | Token |
| --- | --- |
| Hero overlay card | `surface.card.glass` |
| Order Snapshot card | `surface.card.default` |
| Selected topping | `state.selected` |
| Spice selected | `chip.spicy.selected.background` |
| Review CTA | `cta.primary.*` |
| Save Combo CTA | `cta.secondary.*` |

### S5 Order Review

| Role | Token |
| --- | --- |
| Pickup card | `surface.card.default` |
| Pending draft card | `surface.card.default` |
| Cart line item card | `surface.card.emphasis` |
| Suggested Savings card | `surface.card.emphasis` |
| Price Summary | `price.summary.background` |
| Place Order CTA | `cta.primary.*` |
| Save Combo CTA | `cta.secondary.*` |

### S6 Coupon Suggestion Sheet

| Role | Token |
| --- | --- |
| Sheet background | `surface.sheet.coupon` |
| Best Match card | `surface.card.emphasis` |
| Apply CTA | `cta.primary.*` |
| Maybe Later CTA | `cta.secondary.*` |
| Applied state | `state.applied` |
| Unavailable state | `state.unavailable` |

### S8 Order Complete

| Role | Token |
| --- | --- |
| Background | `surface.app.background` |
| Success mark | `color.status.success` |
| Pickup info card | `surface.card.default` |
| Browse Menu Again CTA | `cta.primary.*` |
| Secondary actions | `cta.secondary.*` |

## SwiftUI Mapping Example

```swift
enum POCColorToken {
    static let bgBase = Color(hex: 0xF6F1E7)
    static let bgElevated = Color(hex: 0xFFF9F0)
    static let textPrimary = Color(hex: 0x2E221B)
    static let accentCurry = Color(hex: 0x8B4A1F)
    static let accentCheese = Color(hex: 0xE5B94E)
    static let statusSuccess = Color(hex: 0x4E7A45)
}

enum POCSpacing {
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
}

enum POCRadius {
    static let chip: CGFloat = 10
    static let field: CGFloat = 14
    static let card: CGFloat = 20
    static let cta: CGFloat = 22
    static let sheet: CGFloat = 28
}
```

## 実装順の提案

1. まず foundation tokens を `Color`, `Spacing`, `Radius`, `Motion` として定義する
2. 次に semantic tokens を `Theme` または `DesignToken` のレイヤーで定義する
3. 画面実装では semantic tokens のみ参照する
4. 商品写真や成功演出など可変要素は token 化しすぎない

## 先に固定すべきトークン

- `cta.primary.*`
- `price.current.text`
- `surface.card.default`
- `surface.card.emphasis`
- `chip.selected.*`
- `motion.base`
- `motion.success`

これらを先に固定すると、主導線の見た目がぶれにくい。

## 後から調整してよいトークン

- ガラス面の透明度
- shadow の強さ
- `accent.cream` の濃さ
- success 演出のモーション時間

## 実装時の注意

- Material と背景色を二重に強くしない
- 価格強調色を画面ごとに変えない
- 完了画面だけ特別な色体系にしない
- Coupon Sheet だけ派手にしすぎない
- チップやトグルの選択状態を複数流儀にしない
