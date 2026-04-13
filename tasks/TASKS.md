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
   Note: 現在地・駅名・郵便番号・店名の4入口と Saved Combos 導線を注文開始ゲートとして整理する。ref: docs/poc-wireframes-s1-store-select-2026-04-12.md
   Detail: tasks/details/3-s1-store-select-gate.md

4. home-screen-poc
   Id: 4-home-screen-poc
   Scope: Next / M1
   Files: CocoichiPoC/Features/HomeView.swift, CocoichiPoC/State/OrderStore.swift
   Note: 受取先カード、期間限定バナー、おすすめ、他タブ導線を実装する。店舗未設定でも閲覧可能にする。ref: docs/poc-wireframes-home-tabs-2026-04-12.md
   Detail: tasks/details/4-home-screen-poc.md

5. menu-discovery-store-aware
   Id: 5-menu-discovery-store-aware
   Scope: Next / M1
   Files: CocoichiPoC/Features/MenuDiscoveryView.swift, CocoichiPoC/State/OrderStore.swift
   Note: 店舗未設定では共通メニュー、設定済みでは店舗限定メニュー混在と store header を出す。ref: docs/poc-wireframes-s2-s3-2026-03-28.md
   Detail: tasks/details/5-menu-discovery-store-aware.md

6. order-and-rewards-placeholders
   Id: 6-order-and-rewards-placeholders
   Scope: Next / M1
   Files: CocoichiPoC/Features/OrderTabView.swift, CocoichiPoC/Features/RewardsView.swift, CocoichiPoC/Features/AppRootView.swift
   Note: Order 空状態と Rewards プレースホルダーをタブ骨格に載せる。ref: docs/poc-wireframes-home-tabs-2026-04-12.md
   Detail: tasks/details/6-order-and-rewards-placeholders.md

7. saved-combos-minimal-flow
   Id: 7-saved-combos-minimal-flow
   Scope: Later / M2
   Files: CocoichiPoC/Features/SavedCombosView.swift, CocoichiPoC/State/OrderStore.swift
   Note: 店舗一致・不一致・Needs Review を持つ Saved Combos 最小導線を整える。ref: docs/poc-wireframes-s4-saved-combos-2026-04-13.md
   Detail: tasks/details/7-saved-combos-minimal-flow.md

8. carry-store-specific-context-through-review
   Id: 8-carry-store-specific-context-through-review
   Scope: Later / M2-M3
   Files: CocoichiPoC/Features/OrderFlowView.swift, CocoichiPoC/Features/OrderReviewView.swift, CocoichiPoC/Features/OrderCompleteView.swift
   Note: 店舗限定文脈は S3/S5 まで保持し、S8 には持ち込まない整合にする。ref: docs/poc-wireframes-s5-s6-2026-03-28.md / docs/poc-wireframes-s8-2026-03-28.md
   Detail: tasks/details/8-carry-store-specific-context-through-review.md

