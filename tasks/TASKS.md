# Tasks

## Task IDs

1. home-tab-shell-and-launch
   Id: 1-home-tab-shell-and-launch
   Scope: Now / M1
   Files: CocoichiPoC/Features/AppRootView.swift, CocoichiPoC/App/AppNavigator.swift, CocoichiPoC/Features/HomeView.swift
   Note: Home起動のTabView/AppShell実装完了。Home/Menu/Order/Rewards追加、S1を注文開始ゲート化、make build成功
   Detail: tasks/details/1-home-tab-shell-and-launch.md
   Claimed by: CODEX
   Claimed at: 2026-04-13T10:43:09Z
   Done by: CODEX
   Done at: 2026-04-13T10:52:53Z

2. fulfillment-and-store-context
   Id: 2-fulfillment-and-store-context
   Scope: Now / M1
   Files: CocoichiPoC/State/OrderStore.swift, CocoichiPoC/Domain/POCModels.swift, CocoichiPoC/Data/MockCatalog.swift
   Note: selectedFulfillmentMode と availableStoreIDs ベースの表示判定を追加。Home/Menuが店舗状態を参照、make build成功
   Detail: tasks/details/2-fulfillment-and-store-context.md
   Claimed by: CODEX
   Claimed at: 2026-04-13T10:49:02Z
   Done by: CODEX
   Done at: 2026-04-13T10:50:42Z

3. s1-store-select-gate
   Id: 3-s1-store-select-gate
   Scope: Next / M1
   Files: CocoichiPoC/Features/StoreSelectView.swift, CocoichiPoC/App/AppNavigator.swift, CocoichiPoC/State/OrderStore.swift
   Note: S1を4入口+確認状態+デリバリー最小入口+Saved Combos導線に更新。make build成功
   Detail: tasks/details/3-s1-store-select-gate.md
   Claimed by: CODEX
   Claimed at: 2026-04-13T12:14:25Z
   Done by: CODEX
   Done at: 2026-04-13T12:16:56Z

4. home-screen-poc
   Id: 4-home-screen-poc
   Scope: Next / M1
   Files: CocoichiPoC/Features/HomeView.swift, CocoichiPoC/State/OrderStore.swift
   Note: Homeに他タブショートカット、Seasonal CTA、即注文導線を追加。ワイヤーの情報優先度に寄せ、make build成功
   Detail: tasks/details/4-home-screen-poc.md
   Claimed by: CODEX
   Claimed at: 2026-04-13T23:05:25Z
   Done by: CODEX
   Done at: 2026-04-13T23:07:11Z

5. menu-discovery-store-aware
   Id: 5-menu-discovery-store-aware
   Scope: Next / M1
   Files: CocoichiPoC/Features/MenuDiscoveryView.swift, CocoichiPoC/State/OrderStore.swift
   Note: This Store Onlyセクションと限定バッジを追加。渋谷道玄坂店限定のモック商品を投入、make build成功
   Detail: tasks/details/5-menu-discovery-store-aware.md
   Claimed by: CODEX
   Claimed at: 2026-04-13T12:16:56Z
   Done by: CODEX
   Done at: 2026-04-13T12:18:27Z

6. order-and-rewards-placeholders
   Id: 6-order-and-rewards-placeholders
   Scope: Next / M1
   Files: CocoichiPoC/Features/OrderTabView.swift, CocoichiPoC/Features/RewardsView.swift, CocoichiPoC/Features/AppRootView.swift
   Note: Order空状態とRewardsプレースホルダーを強化。メニュー/保存済み導線と将来価値表示を追加、make build成功
   Detail: tasks/details/6-order-and-rewards-placeholders.md
   Claimed by: CODEX
   Claimed at: 2026-04-13T23:05:37Z
   Done by: CODEX
   Done at: 2026-04-13T23:07:11Z

7. saved-combos-minimal-flow
   Id: 7-saved-combos-minimal-flow
   Scope: Later / M2
   Files: CocoichiPoC/Features/SavedCombosView.swift, CocoichiPoC/State/OrderStore.swift
   Note: Saved Combos を店舗コンテキスト付きで再編。Ready Here / Needs Review / 確認シート / 再開導線を追加。make build成功
   Detail: tasks/details/7-saved-combos-minimal-flow.md
   Claimed by: CODEX
   Claimed at: 2026-04-14T08:35:11Z
   Done by: CODEX
   Done at: 2026-04-14T08:39:04Z

8. carry-store-specific-context-through-review
   Id: 8-carry-store-specific-context-through-review
   Scope: Later / M2-M3
   Files: CocoichiPoC/Features/OrderFlowView.swift, CocoichiPoC/Features/OrderReviewView.swift, CocoichiPoC/Features/OrderCompleteView.swift
   Note: S3/S5の保存CTAを撤去し、S8完了後のみ保存提案へ変更。SaveFavoriteSheet は完了注文ベースに切替。make build成功
   Detail: tasks/details/8-carry-store-specific-context-through-review.md
   Claimed by: CODEX
   Claimed at: 2026-04-13T23:24:40Z
   Done by: CODEX
   Done at: 2026-04-13T23:29:42Z

9. order-flow-view-split
   Id: 9-order-flow-view-split
   Scope: Now / M2-M3
   Files: CocoichiPoC/Features/OrderFlowView.swift, CocoichiPoC/Features/OrderFlowCustomizationComponents.swift, CocoichiPoC/Features/SavedCombosView.swift, CocoichiPoC/Features/OrderReviewView.swift, CocoichiPoC/Features/OrderCompleteView.swift, CocoichiPoC/Features/OrderFlowSharedViews.swift, CocoichiPoC.xcodeproj/project.pbxproj
   Note: OrderFlowView を画面別/共通部品別に分割。make build 成功
   Detail: tasks/details/9-order-flow-view-split.md
   Claimed by: CODEX
   Claimed at: 2026-04-15T06:01:59Z
   Done by: CODEX
   Done at: 2026-04-15T06:10:01Z

10. topping-selection-quantity-and-footer-summary
   Id: 10-topping-selection-quantity-and-footer-summary
   Scope: Now / M2-M3
   Files: docs/poc-wireframes-s2-s3-2026-03-28.md, docs/poc-implementation-tasks-2026-03-29.md, CocoichiPoC/Domain/POCModels.swift, CocoichiPoC/State/OrderStore.swift, CocoichiPoC/Features/OrderFlowView.swift, CocoichiPoC/Features/OrderFlowCustomizationComponents.swift, CocoichiPoC/Features/OrderReviewView.swift
   Note: S3トッピングを数量選択対応へ更新。上部チップを下部サマリーへ置換、S5/S8/保存済み表示を x N 表記へ統一。make build成功、make testはschemeにtest action未設定、subagent review ok
   Detail: tasks/details/10-topping-selection-quantity-and-footer-summary.md
   Claimed by: CODEX
   Claimed at: 2026-04-19T23:11:31Z
   Done by: CODEX
   Done at: 2026-04-19T23:26:59Z

11. s5-review-footer-two-cta
   Id: 11-s5-review-footer-two-cta
   Scope: Now / M3
   Files: docs/poc-screen-flow-2026-03-28.md, docs/poc-wireframes-s5-s6-2026-03-28.md, docs/poc-implementation-tasks-2026-03-29.md, DESIGN.md, CocoichiPoC/Features/OrderReviewView.swift
   Note: S5の合計表示付き2CTAフッターを実装。make build成功、git diff --check問題なし
   Detail: tasks/details/11-s5-review-footer-two-cta.md
   Claimed by: CODEX
   Claimed at: 2026-04-21T08:18:33Z
   Done by: CODEX
   Done at: 2026-04-21T08:37:31Z

12. s5-order-summary-copy-and-bullets
   Id: 12-s5-order-summary-copy-and-bullets
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift
   Note: S5の注文確認カード文言と箇条書き表示を更新。make build成功、git diff --check問題なし
   Detail: tasks/details/12-s5-order-summary-copy-and-bullets.md
   Claimed by: CODEX
   Claimed at: 2026-04-21T08:47:35Z
   Done by: CODEX
   Done at: 2026-04-21T08:49:19Z

13. s5-order-summary-base-labels
   Id: 13-s5-order-summary-base-labels
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift
   Note: S5ベース箇条書きのライス/辛さ表記をラベル付きに更新。make build成功、git diff --check問題なし
   Detail: tasks/details/13-s5-order-summary-base-labels.md
   Claimed by: CODEX
   Claimed at: 2026-04-21T08:52:04Z
   Done by: CODEX
   Done at: 2026-04-21T09:03:42Z

14. s3-toppings-base-summary
   Id: 14-s3-toppings-base-summary
   Scope: Now / M2-M3
   Files: CocoichiPoC/Features/OrderFlowView.swift, CocoichiPoC/Features/OrderFlowCustomizationComponents.swift
   Note: S3トッピング画面にベース設定の簡易箇条書きを追加。make build成功、git diff --check問題なし
   Detail: tasks/details/14-s3-toppings-base-summary.md
   Claimed by: CODEX
   Claimed at: 2026-04-21T11:53:43Z
   Done by: CODEX
   Done at: 2026-04-21T11:59:35Z

15. s3-toppings-base-summary-plain-frame
   Id: 15-s3-toppings-base-summary-plain-frame
   Scope: Now / M2-M3
   Files: CocoichiPoC/Features/OrderFlowCustomizationComponents.swift
   Note: S3ベース箇条書きをプレーンな枠で囲う表示に調整。make build成功、git diff --check問題なし
   Detail: tasks/details/15-s3-toppings-base-summary-plain-frame.md
   Claimed by: CODEX
   Claimed at: 2026-04-21T12:00:46Z
   Done by: CODEX
   Done at: 2026-04-21T12:01:20Z

16. s3-decision-lock-flow
   Id: 16-s3-decision-lock-flow
   Scope: Now / M2-M3
   Files: CocoichiPoC/State/OrderStore.swift, CocoichiPoC/Features/OrderFlowView.swift, CocoichiPoC/Features/OrderReviewView.swift
   Note: S3の主CTAを『決定する』へ変更。決定後は draft をレビュー固定状態にして S3/S5 の戻る導線を隠し、変更は注文リスト内の『変更』だけに集約。make build成功、git diff --check問題なし
   Detail: tasks/details/16-s3-decision-lock-flow.md
   Claimed by: CODEX
   Claimed at: 2026-04-21T14:15:54Z
   Done by: CODEX
   Done at: 2026-04-21T14:17:34Z

