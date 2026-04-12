# CoCo壱番屋 新規アプリ PoC 実装タスク分解

- 作成日: 2026-03-29
- 目的: PoC 指示書を、着手順と依存関係が明確な実装タスクへ分解する
- 補完対象:
  - `docs/poc-app-direction-2026-03-28.md`
  - `docs/poc-screen-flow-2026-03-28.md`
  - `docs/poc-home-tab-architecture-2026-04-12.md`
  - `docs/poc-wireframes-s1-store-select-2026-04-12.md`
  - `docs/poc-wireframes-home-tabs-2026-04-12.md`
  - `docs/poc-wireframes-s2-s3-2026-03-28.md`
  - `docs/poc-wireframes-s5-s6-2026-03-28.md`
  - `docs/poc-wireframes-s8-2026-03-28.md`
  - `docs/poc-visual-toneboard-2026-03-28.md`
  - `docs/poc-design-tokens-2026-03-28.md`

## このドキュメントの位置づけ

この文書は、PoC の仕様書そのものではなく、既存の PoC 指示書を `実装順に並べ替えた作業計画` です。
仕様が競合した場合は、必ず以下を優先します。

1. `docs/poc-app-direction-2026-03-28.md`
2. `docs/poc-screen-flow-2026-03-28.md`
3. `docs/poc-home-tab-architecture-2026-04-12.md`
4. 各ワイヤー / トーン / トークン資料
5. 本ドキュメント

## 実装前提

- iOS-first のネイティブ PoC として進める
- ネットワーク通信は必須にしない
- ローカルデータとモック状態で注文完了まで通す
- アプリ起動直後は `Home` タブを初期表示にしてよく、注文開始時に `S1 Store Select` を開く構成を許容する
- 主導線は `S1 -> S2 -> S3(基本設定 -> トッピング) -> S5(cart/review) -> S6 -> S8`
- 補助導線として `S4 Saved Combos` と `S7 Save Favorite Sheet` を入れる
- ログイン、決済実連携、バックエンド実装、WebView は扱わない
- 価格は `実値` と `PoC用の仮想表示価格` を分け、アプリ内では仮想表示価格を支払額として一貫使用する
- 仮想表示価格は `実値に 8% を上乗せし、10円単位で切り上げた価格` を基準にする
- 店内飲食とテイクアウトの税区分差はアプリ内価格に反映せず、レシート表現側でのみ差分を扱える前提にする

## 実装方針

- 画面単体ではなく、`一連の注文フローが操作できること` を優先する
- 共通基盤を先に固め、画面実装は主導線順に積む
- 価格、店舗、受取時間、保存済み構成、クーポン適用、カート内容はローカル状態で一貫管理する
- メニュー YAML では `price` を実値、`virtualPrice` を PoC用の仮想表示価格として保持する
- `Home` と `Menu` は店舗未設定でも閲覧可能にし、店舗設定済み時だけ店舗限定メニューを表示できる構造にする
- `S2` でベースのカレーを選び、`S3` では `基本設定 phase -> トッピング phase` の 2段階で進める
- `S5` は最終確認だけでなく、`pending draft を review し、必要なら cart line item に昇格させて 2皿目やサイドを追加するか判断する地点` として扱う
- クーポンは `読ませる` のではなく `この注文で使える` を返すローカルルールで扱う
- 主要CTA、価格強調、選択状態、phase 進捗表示、成功演出の見せ方は全画面で統一する

## 注文手順の整理

具体的な表示要素は後続で詰めるが、PoC 実装では次の順番を基準にする。

1. `S2 Menu Discovery` でカレーメニューを選ぶ
2. `S3 Curry Detail / Customize` の基本設定 phase で `カレーソース` `ライス量` `辛さ` を一画面で選ぶ
3. `S3 Curry Detail / Customize` の基本設定 phase で `ソース量` を必要時だけ折りたたみで調整する
4. `S3 Curry Detail / Customize` のトッピング phase で `追加トッピング` を選ぶ
5. `S5 Order Review` で `2皿目のカレー / サイドメニュー追加` または `注文確定` に進む

実装メモ:

- `S3` は `基本設定` と `トッピング` の 2 phase を持ち、基本設定 phase の中では主要調整を一画面で決められるようにする
- `S5` は `最終確認画面` 兼 `カート確認画面` として扱う
- phase ごとの具体UIは後続で詰めるため、今は進行順と状態管理の整合を優先する

## マイルストーン

### M0. PoC 基盤

注文フローを載せるアプリ骨格を作る。

### M1. 注文開始から商品発見まで

`Home` タブ、`Order` 空状態、`Rewards` プレースホルダー、`S1 Store Select`、`S2 Menu Discovery` を実装し、商品詳細へ進める状態にする。

### M2. カスタマイズと保存

`S3 Curry Detail / Customize` の 2 phase 進行と `S7 Save Favorite Sheet` を実装し、`Review Order` から S5 へ渡せる状態にする。

### M3. 最終確認とクーポン提案

`S5 Order Review` と `S6 Coupon Suggestion Sheet` を実装し、追加注文と注文確定直前までつなぐ。

### M4. 完了演出と仕上げ

`S8 Order Complete`、再訪導線、アクセシビリティ、動きの整合を仕上げる。

## 単位実装タスク

| ID | タスク | 内容 | 依存 | 完了条件 |
| --- | --- | --- | --- | --- |
| T01 | App Shell / Navigation | PoC 用の app entry、`TabView`、`NavigationStack`、sheet 制御、画面遷移のルートを作る | - | Home / Menu / Order / Rewards のタブ骨格と S1 から S8 までの遷移骨格がある |
| T02 | Theme / Design Tokens | color, spacing, radius, typography, motion, haptics の foundation と semantic token を定義する | T01 | 画面実装が token 経由で色と CTA を参照できる |
| T03 | Mock Domain Models | Store, MenuItem, CurrySauceOption, RicePortion, SpiceLevel, SauceAmountOption, Topping, CartLineItem, FavoriteCombo, Coupon, DraftOrder, CompletedOrder のモデルを作る | T01 | 主要画面に必要なローカルデータ構造が揃う |
| T04 | Seed Data / Mock Rules | 店舗一覧、商品一覧、店舗限定メニュー可否、カレーソース候補、ライス量、辛さ、ソース量、トッピング、サイドメニュー、クーポン候補、モック受取時間算出を用意する | T03 | 画面間をまたいで同じデータで表示でき、店舗設定時だけ限定メニューを返せる |
| T05 | Order State Store | 選択店舗、受取モード、商品、カレーソース、ライス量、辛さ、ソース量、トッピング、価格、pending draft、カート、適用クーポン、保存状態を持つ状態管理を作る | T03,T04 | 画面をまたいでも注文状態が崩れず、S3 から S5 に pending draft を渡せる。pending draft は常に1件だけ保持され、トッピングは一意管理され、重複タップは no-op になる。店舗変更時は store-scoped state をまとめて破棄できる |
| T06 | Shared UI Components | Primary/Secondary CTA、chip、card、price row、store header、sheet header を共通化する | T02,T05 | S2-S8 で共通UIを使い回せる |
| T07 | S1 Store Select | 注文開始や店舗変更時に呼び出せる店舗選択ゲート、`現在地 / 駅名 / 郵便番号 / 店名` の検索入口、受取目安表示、`保存済みから始める` 導線を実装する | T04,T05,T06 | 店舗選択後に S2 へ進める。GPS 失敗時も手入力検索で継続できる |
| T08 | Home / S2 MenuDiscovery Layout | Home の受取先カード、期間限定バナー、おすすめ、他タブ導線と、S2 の店舗ヘッダー、検索欄、quick filters、For You、Popular、Menu List、下部導線を実装する。S2 では店舗限定メニューをヘッダー直下または一覧バッジで自然に混ぜる | T04,T05,T06,T07 | Home から受取先設定やメニュー閲覧へ進め、S2 では商品カードから S3 へ遷移できる。店舗設定済み時だけ限定メニューを表示できる。限定商品が 0 件の店舗では無理にセクションを出さない。S3 から戻って別メニューを選んだ時は pending draft が新しい選択で置き換わる |
| T09 | Order / Rewards Placeholder | `Order` タブの空状態と `Rewards` タブの将来機能プレースホルダーを実装する | T01,T05,T06 | 店舗未設定時の `Order` では開始方法が分かり、Rewards は主導線を邪魔しない最低限の受け皿になる |
| T10 | S2 Search / Filter Interaction | 検索アクティブ状態、候補キーワード、検索結果、Saved Combos 該当表示を入れる | T08 | 検索入力で一覧が切り替わる |
| T11 | S4 Saved Combos Minimal Screen | 保存済み構成一覧、再開、メニューへ戻る、店舗変更の最低限 UI を作る | T05,T06,T07 | S1/S2/S8 から S4 に入り S3 へ進める |
| T12 | S3 Two-Phase Base Layout | Hero image、商品情報、Order Snapshot card、phase switcher、基本設定 area、トッピング area、下部 CTA を実装する。店舗限定商品では `この店舗限定` の補助表示も持つ | T05,T06,T08 | 初期状態の S3 が 2 phase 前提で表示される。店舗限定商品から入った時も限定文脈を落とさない |
| T13 | S3 Basics To Toppings Flow | `基本設定 -> トッピング` の進行、戻る/進む、進捗表示、`Review Order` CTA から pending draft のまま S5 に渡す遷移を実装する | T05,T12 | 現在地と残り工程が崩れず進行できる |
| T14 | S3 Customization Logic | 基本設定 phase の選択、ソース量折りたたみ、トッピング追加削除、価格再計算、Order Snapshot 更新、軽い反応を実装する | T05,T12,T13 | 変更が即時に価格とサマリーへ反映され、S5 では pending draft を review 用に受け取れる。選択済みトッピングは Added または非表示で扱い、重複追加できない |
| T15 | S7 Save Favorite Sheet | 名前入力、注文サマリー、保存/キャンセルを持つ modal sheet を実装する | T05,T06,T14 | S3 と S5 から同じ保存 sheet を呼べる |
| T16 | Favorite Persistence / Resume | 保存済み構成のローカル保存、再編集前提の復元、For You 反映を実装する | T05,T11,T15 | 保存後に S4 と S2 の再利用導線へ反映される |
| T17 | S5 Order Review Layout | Pickup card、pending draft を含む cart summary、Suggested Savings、Save This Combo、Price Summary、下部 CTA を実装する。店舗限定商品では order card に短い補助ラベルを残す | T05,T06,T14 | pending draft と cart line item の見せ分けができ、`内容を修正` は pending draft のみに対して表示される。初版 PoC では cart line item は read-only として扱い、クーポン適用後でも Add More を残す。店舗限定文脈を落とさない |
| T18 | Coupon Matching Engine | 現在注文に対して適用可能クーポンだけを返すローカル判定を作る | T03,T04,T05 | S5 で提案対象を算出できる |
| T19 | S5 Continue Shopping Loop | `2皿目のカレー` と `サイドメニュー追加` の導線で `pending draft` を cart に昇格させてから S2 に戻り、カート保持のまま再度 S5 に戻れるようにする | T05,T08,T14,T17 | 追加注文ループ時に pending draft と cart の境界が崩れない |
| T20 | S6 Coupon Suggestion Sheet | best match、適用後状態、Maybe Later、価格差分更新を持つ bottom sheet を実装する | T17,T18 | 適用/非適用で S5 の金額が更新される |
| T21 | S5 First-Arrival Behavior | 初回到達時のみ S6 をハーフオープンし、以後は CTA 起点に戻す制御を入れる | T17,T20 | 強制感なく `自然に提案される` を再現できる |
| T22 | Mock Place Order Flow | `Place Order` 押下、`cartItems + pending draft` の統合確定、短い処理演出、モック注文確定、参照番号生成を実装する | T05,T17,T19,T20 | S5 から S8 へ注文確定として遷移できる。確定後は active order state が初期化される |
| T23 | S8 Complete Screen | 成功演出、受取情報、注文サマリー、次アクション CTA を実装する | T22,T06 | 完了状態が一画面で明確に分かる |
| T24 | Post-Complete Navigation | `Browse Menu Again`、`View Saved Combos`、`Change Store` の再訪導線を整理する | T23,T11 | 完了後の再利用導線が破綻しない。`Change Store` では cartItems / pending draft / applied coupon を全て破棄して S1 に戻る |
| T25 | Motion / Haptics Pass | phase 遷移、トッピング追加、クーポン適用、保存、完了の反応を最小限の気持ちよさに整える | T14,T20,T23 | 動きが長すぎず、主要反応が揃う |
| T26 | Accessibility / Reduce Motion | VoiceOver 順序、色依存回避、Reduce Motion 代替、Dynamic Type 崩れ確認を行う | T08,T13,T17,T23 | 主導線がアクセシビリティ要件を満たす |
| T27 | Demo QA / Content Sweep | 文言、価格一貫性、CTA優先度、phase 進捗、店舗名/受取時間/次アクション表示を通しで確認する | T07,T08,T09,T10,T11,T12,T13,T14,T15,T16,T17,T18,T19,T20,T21,T22,T23,T24,T25,T26 | PoC デモで詰まらない最低品質に達する |

## 推奨実装順

1. `T01-T06`
2. `T07-T10`
3. `T11-T15`
4. `T16-T21`
5. `T22-T27`

## 並行で進めやすいタスク

- `T02 Theme / Design Tokens` と `T03-T04 Mock Data`
- `T08 S2 Menu Discovery Layout` と `T11 S4 Saved Combos Minimal Screen`
- `T15 S7 Save Favorite Sheet` と `T17 S5 Order Review Layout`
- `T24 Motion / Haptics Pass` と `T25 Accessibility / Reduce Motion`

前提:

- 2つ目の並行実装は `T07` 完了後
- 3つ目の並行実装は `T12` 完了後

## 初版 PoC で削らないもの

- 店舗選択が注文文脈として常に見えること
- S3 で phase により進捗が常に見えること
- S3 での価格即時更新
- S5 でのクーポン提案
- S5/S3 からのお気に入り保存
- S5 から追加注文へ戻ってもカート内容が保たれること
- S8 での明確な完了表示

## 初版 PoC で後回しにしてよいもの

- 高度な検索アルゴリズム
- カート内商品の並び替えや高度な編集
- 認証、決済、注文API連携
- 完了画面上での追加保存導線
- 通知、共有、カレンダー追加

## タスク分解上の注意点

- `S4 Saved Combos` は専用ワイヤー未整備のため、初版は `再開の速さ` を優先した最小UIでよい
- `S3 Curry Detail / Customize` の具体的な phase UI は後続で詰めるが、`基本設定 -> トッピング` の順番と `Review Order` CTA から S5 に抜ける状態管理は先に固定する
- `S6 Coupon Suggestion` は販促画面ではなく `注文の補助UI` として実装する
- `S8 Order Complete` は `Done` ではなく `注文できた` と `どう受け取るか` を明示する
- 画面ごとの装飾差より、主CTA・価格・選択済み状態の統一を優先する

## マイルストーンごとの受け入れ条件

### M0 完了条件

- アプリ起動後に注文フローのルートへ入れる
- theme、model、mock data、order state が分離されている

### M1 完了条件

- 店舗を選んで商品詳細へ進める
- Saved Combos 入口が S1 または S2 から到達できる
- `Order` の空状態と `Rewards` のプレースホルダーがタブとして破綻なく表示される

### M2 完了条件

- S3 で 2 phase に沿って pending draft を作り、Review Order から S5 に渡せる
- 保存済み構成を再開して再編集できる

### M3 完了条件

- S5 で注文内容、店舗、価格、クーポン提案を確認できる
- S5 で `pending draft` を review し、必要なら S3 に戻して再編集できる
- S5 では `内容を修正` が pending draft のみに対して表示され、cart line item は初版 PoC では read-only である
- S5 から 2皿目のカレーまたはサイド追加へ戻れる
- クーポン適用の有無に関わらず注文確定へ進める

### M4 完了条件

- 完了演出と情報表示が 1.2 秒以内で切り替わる
- 完了後の次アクションが迷わない
- 主導線で `今どこまで進んだか / 何を注文したか / いくらか / 次に何をするか` が常に分かる
