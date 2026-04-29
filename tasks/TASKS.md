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

17. order-review-copy-edit-and-yen-format
   Id: 17-order-review-copy-edit-and-yen-format
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift, CocoichiPoC/App/AppNavigator.swift, CocoichiPoC/State/OrderStore.swift
   Note: S5のタイトルを『ご注文内容の確認』へ変更。ステータス表示を撤去し、cart/pending を問わず変更可能に更新。価格表記をOrder Review内で ￥ 形式へ統一。make build成功、git diff --check問題なし
   Detail: tasks/details/17-order-review-copy-edit-and-yen-format.md
   Claimed by: CODEX
   Claimed at: 2026-04-21T23:14:10Z
   Done by: CODEX
   Done at: 2026-04-21T23:17:18Z

18. preserve-order-when-editing-review-items
   Id: 18-preserve-order-when-editing-review-items
   Scope: Now / M3
   Files: CocoichiPoC/State/OrderStore.swift, CocoichiPoC/Features/OrderReviewView.swift
   Note: S5編集後も注文リストの順番を維持するよう修正。review用の挿入位置を保持し、続けて注文/注文確定でも同順序を反映。make build成功、git diff --check問題なし
   Detail: tasks/details/18-preserve-order-when-editing-review-items.md
   Claimed by: CODEX
   Claimed at: 2026-04-21T23:26:40Z
   Done by: CODEX
   Done at: 2026-04-21T23:27:44Z

19. remove-order-review-notes-card
   Id: 19-remove-order-review-notes-card
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift
   Note: S5最下部のNotesカードを削除。make build成功、git diff --check問題なし
   Detail: tasks/details/19-remove-order-review-notes-card.md
   Claimed by: CODEX
   Claimed at: 2026-04-22T13:28:29Z
   Done by: CODEX
   Done at: 2026-04-22T13:28:58Z

20. remove-line-total-label-from-order-review
   Id: 20-remove-line-total-label-from-order-review
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift
   Note: S5注文カードのLine Totalラベルを削除し、金額のみの右寄せ表示へ変更。make build成功、git diff --check問題なし
   Detail: tasks/details/20-remove-line-total-label-from-order-review.md
   Claimed by: CODEX
   Claimed at: 2026-04-22T13:32:24Z
   Done by: CODEX
   Done at: 2026-04-22T13:32:51Z

21. localize-order-review-copy-to-japanese
   Id: 21-localize-order-review-copy-to-japanese
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift
   Note: S5注文確認ページの英語文言を日本語へ統一。make build成功、git diff --check問題なし
   Detail: tasks/details/21-localize-order-review-copy-to-japanese.md
   Claimed by: CODEX
   Claimed at: 2026-04-22T13:35:04Z
   Done by: CODEX
   Done at: 2026-04-22T13:35:34Z

22. remove-store-change-from-order-review
   Id: 22-remove-store-change-from-order-review
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift
   Note: S5注文確認ページの店舗変更導線を削除。make build成功、git diff --check問題なし
   Detail: tasks/details/22-remove-store-change-from-order-review.md
   Claimed by: CODEX
   Claimed at: 2026-04-22T13:40:59Z
   Done by: CODEX
   Done at: 2026-04-22T13:41:35Z

23. widen-order-review-coupon-card
   Id: 23-widen-order-review-coupon-card
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift
   Note: S5クーポンカードの幅を他カードと揃えるよう修正。make build成功、git diff --check問題なし
   Detail: tasks/details/23-widen-order-review-coupon-card.md
   Claimed by: CODEX
   Claimed at: 2026-04-22T13:47:55Z
   Done by: CODEX
   Done at: 2026-04-22T13:48:31Z

24. localize-coupon-list-ui-to-japanese
   Id: 24-localize-coupon-list-ui-to-japanese
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderCompleteView.swift
   Note: クーポンリストUIの英語文言を日本語へ統一。make build成功、git diff --check問題なし
   Detail: tasks/details/24-localize-coupon-list-ui-to-japanese.md
   Claimed by: CODEX
   Claimed at: 2026-04-22T13:53:37Z
   Done by: CODEX
   Done at: 2026-04-22T13:54:08Z

25. skip-store-confirmation-on-select
   Id: 25-skip-store-confirmation-on-select
   Scope: Now / M1-M2
   Files: docs/poc-wireframes-s1-store-select-2026-04-12.md, CocoichiPoC/Features/StoreSelectView.swift, CocoichiPoC/App/AppNavigator.swift, CocoichiPoC/State/OrderStore.swift, CocoichiPoC/Features/MenuDiscoveryView.swift, CocoichiPoC/Features/AppRootView.swift
   Note: S1確認画面を撤去し、店舗変更時のみ確認ダイアログを追加。未選択店舗で押した商品は店舗確定後にS3へ復帰。make build成功、git diff --check問題なし
   Detail: tasks/details/25-skip-store-confirmation-on-select.md
   Claimed by: CODEX
   Claimed at: 2026-04-23T22:56:25Z
   Done by: CODEX
   Done at: 2026-04-23T23:00:54Z

26. home-banner-images
   Id: 26-home-banner-images
   Scope: Now / M1
   Files: CocoichiPoC/Features/AppRootView.swift, CocoichiPoC.xcodeproj/project.pbxproj
   Note: Home に BannerImages を静的表示で追加。project.pbxproj に BannerImages folder resource を登録、make build 成功、Simulator screenshot で表示確認。
   Detail: tasks/details/26-home-banner-images.md
   Claimed by: CODEX
   Claimed at: 2026-04-24T09:45:22Z
   Done by: CODEX
   Done at: 2026-04-24T09:47:57Z

27. s5-review-item-delete
   Id: 27-s5-review-item-delete
   Scope: Now / M3
   Files: CocoichiPoC/State/OrderStore.swift, CocoichiPoC/Features/OrderReviewView.swift
   Note: S5注文確認で商品削除を追加。make build成功、git diff --check問題なし
   Detail: tasks/details/27-s5-review-item-delete.md
   Claimed by: CODEX
   Claimed at: 2026-04-26T05:27:22Z
   Done by: CODEX
   Done at: 2026-04-26T05:29:33Z

28. s5-auto-return-on-empty
   Id: 28-s5-auto-return-on-empty
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift
   Note: S5空状態でメニューへ自動復帰。make build成功、git diff --check問題なし
   Detail: tasks/details/28-s5-auto-return-on-empty.md
   Claimed by: CODEX
   Claimed at: 2026-04-26T05:33:52Z
   Done by: CODEX
   Done at: 2026-04-26T05:34:15Z

29. s5-centered-delete-dialog
   Id: 29-s5-centered-delete-dialog
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift
   Note: S5削除確認を中央ダイアログ化。make build成功、git diff --check問題なし
   Detail: tasks/details/29-s5-centered-delete-dialog.md
   Claimed by: CODEX
   Claimed at: 2026-04-26T05:41:06Z
   Done by: CODEX
   Done at: 2026-04-26T05:42:41Z

30. s5-delete-dialog-info-icon
   Id: 30-s5-delete-dialog-info-icon
   Scope: Now / M3
   Files: CocoichiPoC/Features/OrderReviewView.swift
   Note: S5削除ダイアログ補足アイコンを info.circle へ変更。make build成功、git diff --check問題なし
   Detail: tasks/details/30-s5-delete-dialog-info-icon.md
   Claimed by: CODEX
   Claimed at: 2026-04-26T05:44:08Z
   Done by: CODEX
   Done at: 2026-04-26T05:44:29Z

31. s8-order-content-favorite-action
   Id: 31-s8-order-content-favorite-action
   Scope: Now / M3
   Files: docs/poc-wireframes-s8-2026-03-28.md, docs/poc-screen-flow-2026-03-28.md, CocoichiPoC/Features/OrderCompleteView.swift
   Note: S8完了画面の保存UIを各注文内容の価格行へ移動。お気に入り由来で未編集の明細は保存済み表示。S8/flow docs更新、make build成功、git diff --check問題なし
   Detail: tasks/details/31-s8-order-content-favorite-action.md
   Claimed by: CODEX
   Claimed at: 2026-04-28T13:32:46Z
   Done by: CODEX
   Done at: 2026-04-28T13:40:33Z

32. store-gated-menu-backstack
   Id: 32-store-gated-menu-backstack
   Scope: Next / M1-M2
   Files: docs/poc-screen-flow-2026-03-28.md, docs/poc-home-tab-architecture-2026-04-12.md, docs/poc-wireframes-s1-store-select-2026-04-12.md, docs/poc-wireframes-home-tabs-2026-04-12.md, docs/poc-wireframes-s2-s3-2026-03-28.md, docs/poc-implementation-tasks-2026-03-29.md, CocoichiPoC/App/AppNavigator.swift, CocoichiPoC/Features/AppRootView.swift, CocoichiPoC/Features/StoreSelectView.swift, CocoichiPoC/Features/MenuDiscoveryView.swift, CocoichiPoC/State/OrderStore.swift
   Note: S1/S2をNavigationStack履歴へ積む商品選択後の店舗ゲートを実装。make build成功、make testはscheme test action未設定で失敗
   Detail: tasks/details/32-store-gated-menu-backstack.md
   Claimed by: CODEX
   Claimed at: 2026-04-29T23:50:06Z
   Done by: CODEX
   Done at: 2026-04-29T23:52:13Z

