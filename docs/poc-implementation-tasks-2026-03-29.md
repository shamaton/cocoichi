# CoCo壱番屋 新規アプリ PoC 実装タスク分解

- 作成日: 2026-03-29
- 目的: PoC 指示書を、着手順と依存関係が明確な実装タスクへ分解する
- 補完対象:
  - `docs/poc-app-direction-2026-03-28.md`
  - `docs/poc-screen-flow-2026-03-28.md`
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
3. 各ワイヤー / トーン / トークン資料
4. 本ドキュメント

## 実装前提

- iOS-first のネイティブ PoC として進める
- ネットワーク通信は必須にしない
- ローカルデータとモック状態で注文完了まで通す
- 主導線は `S1 -> S2 -> S3(stepper) -> S5(cart/review) -> S6 -> S8`
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
- `S2` でベースのカレーを選び、`S3` では公式手順に近い stepper で `カレーソース -> ライス量 -> 辛さ -> ソース量 -> トッピング -> 最終確認` を進める
- `S5` は最終確認だけでなく、`1皿目をカートに入れた後に 2皿目のカレーやサイドを追加するか判断する地点` として扱う
- クーポンは `読ませる` のではなく `この注文で使える` を返すローカルルールで扱う
- 主要CTA、価格強調、選択状態、stepper の進捗表示、成功演出の見せ方は全画面で統一する

## 注文手順の整理

具体的な表示要素は後続で詰めるが、PoC 実装では次の順番を基準にする。

1. `S2 Menu Discovery` でカレーメニューを選ぶ
2. `S3 Curry Detail / Customize` で `カレーソース` を選ぶ
3. `S3 Curry Detail / Customize` で `ライス量` を選ぶ
4. `S3 Curry Detail / Customize` で `辛さ` を選ぶ
5. `S3 Curry Detail / Customize` で `ソース量` を選ぶ
6. `S3 Curry Detail / Customize` で `追加トッピング` を選ぶ
7. `S3 Curry Detail / Customize` で最終確認し、`カートに入れる`
8. `S5 Order Review` で `2皿目のカレー / サイドメニュー追加` または `注文確定` に進む

実装メモ:

- `S3` は 1画面内で全選択肢を並べるより、stepper に沿って段階表示する
- `S5` は `最終確認画面` 兼 `カート確認画面` として扱う
- step ごとの具体UIは後続で詰めるため、今は進行順と状態管理の整合を優先する

## マイルストーン

### M0. PoC 基盤

注文フローを載せるアプリ骨格を作る。

### M1. 注文開始から商品発見まで

`S1 Store Select` と `S2 Menu Discovery` を実装し、商品詳細へ進める状態にする。

### M2. カスタマイズと保存

`S3 Curry Detail / Customize` の stepper 進行と `S7 Save Favorite Sheet` を実装し、カート投入まで進める状態にする。

### M3. 最終確認とクーポン提案

`S5 Order Review` と `S6 Coupon Suggestion Sheet` を実装し、追加注文と注文確定直前までつなぐ。

### M4. 完了演出と仕上げ

`S8 Order Complete`、再訪導線、アクセシビリティ、動きの整合を仕上げる。

## 単位実装タスク

| ID | タスク | 内容 | 依存 | 完了条件 |
| --- | --- | --- | --- | --- |
| T01 | App Shell / Navigation | PoC 用の app entry、`NavigationStack`、sheet 制御、画面遷移のルートを作る | - | S1 から S8 まで遷移の骨格がある |
| T02 | Theme / Design Tokens | color, spacing, radius, typography, motion, haptics の foundation と semantic token を定義する | T01 | 画面実装が token 経由で色と CTA を参照できる |
| T03 | Mock Domain Models | Store, MenuItem, CurrySauceOption, RicePortion, SpiceLevel, SauceAmountOption, Topping, CartLineItem, FavoriteCombo, Coupon, DraftOrder, CompletedOrder のモデルを作る | T01 | 主要画面に必要なローカルデータ構造が揃う |
| T04 | Seed Data / Mock Rules | 店舗一覧、商品一覧、カレーソース候補、ライス量、辛さ、ソース量、トッピング、サイドメニュー、クーポン候補、モック受取時間算出を用意する | T03 | 画面間をまたいで同じデータで表示できる |
| T05 | Order State Store | 選択店舗、商品、カレーソース、ライス量、辛さ、ソース量、トッピング、価格、カート、適用クーポン、保存状態を持つ状態管理を作る | T03,T04 | 画面をまたいでも注文状態が崩れない |
| T06 | Shared UI Components | Primary/Secondary CTA、chip、card、price row、store header、sheet header を共通化する | T02,T05 | S2-S8 で共通UIを使い回せる |
| T07 | S1 Store Select | 店舗選択の初期画面、受取目安表示、`保存済みから始める` 導線を実装する | T04,T05,T06 | 店舗選択後に S2 へ進める |
| T08 | S2 Menu Discovery Layout | 店舗ヘッダー、検索欄、quick filters、For You、Popular、Menu List、下部導線を実装する | T04,T05,T06,T07 | 商品カードから S3 へ遷移できる |
| T09 | S2 Search / Filter Interaction | 検索アクティブ状態、候補キーワード、検索結果、Saved Combos 該当表示を入れる | T08 | 検索入力で一覧が切り替わる |
| T10 | S4 Saved Combos Minimal Screen | 保存済み構成一覧、再開、メニューへ戻る、店舗変更の最低限 UI を作る | T05,T06,T07 | S1/S2/S8 から S4 に入り S3 へ進める |
| T11 | S3 Stepper Base Layout | Hero image、商品情報、Current Order card、stepper、step content area、下部 CTA を実装する | T05,T06,T08 | 初期状態の S3 が stepper 前提で表示される |
| T12 | S3 Stepper Flow | `カレーソース -> ライス量 -> 辛さ -> ソース量 -> トッピング -> 最終確認` の進行、戻る/進む、進捗表示を実装する | T05,T11 | 現在地と残り工程が崩れず進行できる |
| T13 | S3 Customization Logic | 各 step の選択、トッピング追加削除、価格再計算、Current Order 更新、軽い反応を実装する | T05,T11,T12 | 変更が即時に価格とサマリーへ反映される |
| T14 | S7 Save Favorite Sheet | 名前入力、注文サマリー、保存/キャンセルを持つ modal sheet を実装する | T05,T06,T13 | S3 と S5 から同じ保存 sheet を呼べる |
| T15 | Favorite Persistence / Resume | 保存済み構成のローカル保存、再編集前提の復元、For You 反映を実装する | T05,T10,T14 | 保存後に S4 と S2 の再利用導線へ反映される |
| T16 | S5 Order Review Layout | Pickup card、cart summary、Suggested Savings、Save This Combo、Price Summary、下部 CTA を実装する | T05,T06,T13 | カート確認、内容確認、注文確定導線が成立する |
| T17 | Coupon Matching Engine | 現在注文に対して適用可能クーポンだけを返すローカル判定を作る | T03,T04,T05 | S5 で提案対象を算出できる |
| T18 | S5 Continue Shopping Loop | `2皿目のカレー` と `サイドメニュー追加` の導線で S2 に戻り、カート保持のまま再度 S5 に戻れるようにする | T05,T08,T13,T16 | 1皿目投入後に追加注文してもカート内容が崩れない |
| T19 | S6 Coupon Suggestion Sheet | best match、適用後状態、Maybe Later、価格差分更新を持つ bottom sheet を実装する | T16,T17 | 適用/非適用で S5 の金額が更新される |
| T20 | S5 First-Arrival Behavior | 初回到達時のみ S6 をハーフオープンし、以後は CTA 起点に戻す制御を入れる | T16,T19 | 強制感なく `自然に提案される` を再現できる |
| T21 | Mock Place Order Flow | `Place Order` 押下、短い処理演出、モック注文確定、参照番号生成を実装する | T05,T16,T19 | S5 から S8 へ注文確定として遷移できる |
| T22 | S8 Complete Screen | 成功演出、受取情報、注文サマリー、次アクション CTA を実装する | T21,T06 | 完了状態が一画面で明確に分かる |
| T23 | Post-Complete Navigation | `Browse Menu Again`、`View Saved Combos`、`Change Store` の再訪導線を整理する | T22,T10 | 完了後の再利用導線が破綻しない |
| T24 | Motion / Haptics Pass | stepper 遷移、トッピング追加、クーポン適用、保存、完了の反応を最小限の気持ちよさに整える | T13,T19,T22 | 動きが長すぎず、主要反応が揃う |
| T25 | Accessibility / Reduce Motion | VoiceOver 順序、色依存回避、Reduce Motion 代替、Dynamic Type 崩れ確認を行う | T08,T12,T16,T22 | 主導線がアクセシビリティ要件を満たす |
| T26 | Demo QA / Content Sweep | 文言、価格一貫性、CTA優先度、stepper進捗、店舗名/受取時間/次アクション表示を通しで確認する | T07,T08,T09,T10,T11,T12,T13,T14,T15,T16,T17,T18,T19,T20,T21,T22,T23,T24,T25 | PoC デモで詰まらない最低品質に達する |

## 推奨実装順

1. `T01-T06`
2. `T07-T10`
3. `T11-T15`
4. `T16-T21`
5. `T22-T26`

## 並行で進めやすいタスク

- `T02 Theme / Design Tokens` と `T03-T04 Mock Data`
- `T08 S2 Menu Discovery Layout` と `T10 S4 Saved Combos Minimal Screen`
- `T14 S7 Save Favorite Sheet` と `T16 S5 Order Review Layout`
- `T24 Motion / Haptics Pass` と `T25 Accessibility / Reduce Motion`

前提:

- 2つ目の並行実装は `T07` 完了後
- 3つ目の並行実装は `T12` 完了後

## 初版 PoC で削らないもの

- 店舗選択が注文文脈として常に見えること
- S3 で stepper により進捗が常に見えること
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
- `S3 Curry Detail / Customize` の具体的な step UI は後続で詰めるが、stepper の順番と状態管理は先に固定する
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

### M2 完了条件

- S3 で stepper に沿って注文内容を作り、カートに入れられる
- 保存済み構成を再開して再編集できる

### M3 完了条件

- S5 で注文内容、店舗、価格、クーポン提案を確認できる
- S5 から 2皿目のカレーまたはサイド追加へ戻れる
- クーポン適用の有無に関わらず注文確定へ進める

### M4 完了条件

- 完了演出と情報表示が 1.2 秒以内で切り替わる
- 完了後の次アクションが迷わない
- 主導線で `今どこまで進んだか / 何を注文したか / いくらか / 次に何をするか` が常に分かる
