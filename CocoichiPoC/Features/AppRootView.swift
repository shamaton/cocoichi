import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        ZStack {
            POCBackgroundLayer()

            NavigationStack(
                path: Binding(
                    get: { navigator.path },
                    set: { navigator.path = $0 }
                )
            ) {
                AppTabShellView()
                    .navigationDestination(for: AppScreen.self) { screen in
                        destination(for: screen)
                    }
            }
        }
        .sheet(item: Binding(
            get: { navigator.presentedSheet },
            set: { navigator.presentedSheet = $0 }
        )) { sheet in
            sheetView(for: sheet)
                .presentationDetents(sheet == .couponSuggestion ? [.medium, .large] : [.medium])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private func destination(for screen: AppScreen) -> some View {
        switch screen {
        case .storeSelect:
            StoreSelectView()
        case .curryDetail:
            CurryDetailView()
        case .curryToppings:
            CurryToppingsView()
        case .savedCombos:
            SavedCombosView()
        case .orderReview:
            OrderReviewView()
        case .orderComplete:
            OrderCompleteView()
        }
    }

    @ViewBuilder
    private func sheetView(for sheet: AppSheet) -> some View {
        switch sheet {
        case .couponSuggestion:
            CouponSuggestionSheet()
        case .saveFavorite:
            SaveFavoriteSheet()
        }
    }
}

private struct AppTabShellView: View {
    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        ZStack {
            POCBackgroundLayer()

            TabView(selection: $navigator.selectedTab) {
                HomeView()
                    .tag(AppTab.home)
                    .tabItem {
                        Label("ホーム", systemImage: "house.fill")
                    }

                MenuDiscoveryView()
                    .tag(AppTab.menu)
                    .tabItem {
                        Label("メニュー", systemImage: "fork.knife")
                    }

                OrderTabView()
                    .tag(AppTab.order)
                    .tabItem {
                        Label("オーダー", systemImage: "cart.fill")
                    }

                RewardsPlaceholderView()
                    .tag(AppTab.rewards)
                    .tabItem {
                        Label("リワード", systemImage: "seal.fill")
                    }
            }
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.thinMaterial, for: .tabBar)
    }
}

private struct HomeView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                homeHeader
                fulfillmentCard
                seasonalBanner
                if let featuredStoreItem {
                    featuredStoreItemCard(item: featuredStoreItem)
                }
                recommendedSection
                startQuicklySection
                savedCombosSection
                otherTabsSection
            }
            .padding(POCSpacing.l)
            .padding(.bottom, 96)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var homeHeader: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            Text("こんにちは")
                .font(.headline.weight(.semibold))
                .foregroundStyle(POCColor.textSecondary)
            Text(headerTitle)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(POCColor.textPrimary)
        }
    }

    private var headerTitle: String {
        if let store = orderStore.selectedStore {
            return "\(store.name)で受け取り"
        }
        return "今日は何にする？"
    }

    private var fulfillmentCard: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            HStack(alignment: .top, spacing: POCSpacing.s) {
                Image(systemName: orderStore.selectedStore == nil ? "location" : "location.fill")
                    .font(.headline)
                    .foregroundStyle(POCColor.curry)

                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                    if let store = orderStore.selectedStore {
                        Text(store.name)
                            .font(.headline.weight(.semibold))
                        Text("受取目安 \(store.pickupLeadTimeText)")
                            .font(.subheadline)
                            .foregroundStyle(POCColor.textSecondary)
                    } else {
                        Text("受取先を選ぶ")
                            .font(.headline.weight(.semibold))
                        Text("店舗を選ぶと受取時間と限定メニューが分かります")
                            .font(.subheadline)
                            .foregroundStyle(POCColor.textSecondary)
                    }
                }

                Spacer()

                Text(orderStore.selectedStore == nil ? "未設定" : "Change")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(POCColor.curry)
            }

            PrimaryCTAButton(title: orderStore.selectedStore == nil ? "選択する" : "変更する", systemImage: "arrow.right") {
                orderStore.clearPendingFavoriteResume()
                orderStore.clearPendingMenuSelection()
                navigator.presentStoreSelect(nextTab: .menu)
            }
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }

    private var seasonalBanner: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Seasonal")
            Button {
                navigator.showMenuDiscovery()
            } label: {
                VStack(alignment: .leading, spacing: POCSpacing.s) {
                    HeroBanner(
                        eyebrow: "期間限定",
                        title: orderStore.selectedStore == nil ? "スパイスカレー特集" : "春のおすすめトッピング特集",
                        accent: [POCColor.red, POCColor.cheese]
                    )
                    HStack {
                        Text(orderStore.selectedStore == nil ? "今だけのおすすめをチェック" : "この店舗で今食べたいおすすめを探す")
                            .font(.subheadline)
                            .foregroundStyle(POCColor.textSecondary)
                        Spacer()
                        Text(orderStore.selectedStore == nil ? "メニューへ" : "見る")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(POCColor.curry)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader(orderStore.selectedStore == nil ? "Recommended For First Order" : "Recommended For You")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: POCSpacing.s) {
                    ForEach(recommendedItems) { item in
                        Button {
                            startHomeOrder(for: item)
                        } label: {
                            VStack(alignment: .leading, spacing: POCSpacing.s) {
                                MenuArtworkBadge(item: item)
                                Text(item.name)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(POCColor.textPrimary)
                                    .lineLimit(2)
                                Text(item.basePrice.yenText)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(POCColor.curry)
                            }
                            .frame(width: 184, alignment: .leading)
                            .padding(POCSpacing.m)
                            .pocCard(fill: POCColor.elevated)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func featuredStoreItemCard(item: MenuItem) -> some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("This Store Only")
            Button {
                startHomeOrder(for: item)
            } label: {
                HStack(spacing: POCSpacing.m) {
                    MenuArtworkBadge(item: item)
                    VStack(alignment: .leading, spacing: POCSpacing.xs) {
                        Text(item.name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(POCColor.textPrimary)
                        Text("この店舗限定 / 今だけのおすすめ")
                            .font(.subheadline)
                            .foregroundStyle(POCColor.textSecondary)
                        Text(item.basePrice.yenText)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(POCColor.curry)
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(POCColor.curry)
                }
                .padding(POCSpacing.m)
                .pocCard(fill: POCColor.elevatedStrong)
            }
            .buttonStyle(.plain)
        }
    }

    private var savedCombosSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Saved Combos")
            if let favorite = orderStore.featuredFavorite {
                Button {
                    navigator.push(.savedCombos)
                } label: {
                    VStack(alignment: .leading, spacing: POCSpacing.s) {
                        Text("いつものに近い")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(POCColor.textTertiary)
                        Text(favorite.name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(POCColor.textPrimary)
                        Text(favorite.draft.menuItem.name)
                            .font(.subheadline)
                            .foregroundStyle(POCColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(POCSpacing.m)
                    .pocCard(fill: POCColor.elevated)
                }
                .buttonStyle(.plain)
            } else {
                EmptyStateCard(
                    title: "まだ保存された組み合わせはありません",
                    message: "注文後にいつもの組み合わせを残せます。"
                )
            }
        }
    }

    private var startQuicklySection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Start Quickly")
            HStack(spacing: POCSpacing.s) {
                SecondaryCTAButton(title: "メニューを見る", systemImage: "fork.knife") {
                    navigator.showMenuDiscovery()
                }
                PrimaryCTAButton(title: "オーダーを始める", systemImage: "arrow.right") {
                    if orderStore.selectedStore == nil {
                        orderStore.clearPendingFavoriteResume()
                        orderStore.clearPendingMenuSelection()
                        navigator.presentStoreSelect(nextTab: .menu)
                    } else {
                        navigator.showMenuDiscovery()
                    }
                }
            }
        }
    }

    private var otherTabsSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Other Tabs")
            HStack(spacing: POCSpacing.s) {
                HomeShortcutCard(
                    title: "メニュー",
                    subtitle: "一覧から探す",
                    systemImage: "fork.knife"
                ) {
                    navigator.selectedTab = .menu
                }

                HomeShortcutCard(
                    title: "オーダー",
                    subtitle: orderStore.hasReviewItems ? "今の注文へ" : "状態を確認",
                    systemImage: "cart"
                ) {
                    navigator.selectedTab = .order
                }

                HomeShortcutCard(
                    title: "リワード",
                    subtitle: "将来機能",
                    systemImage: "seal"
                ) {
                    navigator.selectedTab = .rewards
                }
            }
        }
    }

    private func startHomeOrder(for item: MenuItem) {
        guard orderStore.selectedStore != nil else {
            orderStore.clearPendingFavoriteResume()
            orderStore.prepareMenuSelectionAfterStoreSelection(item)
            navigator.presentStoreSelect(nextTab: .menu, nextPath: [.curryDetail])
            return
        }
        orderStore.beginOrder(with: item)
        navigator.push(.curryDetail)
    }

    private var recommendedItems: [MenuItem] {
        Array(orderStore.visibleMenuItems.filter { item in
            item.tags.contains(.recommended) || item.tags.contains(.staple)
        }.prefix(4))
    }

    private var featuredStoreItem: MenuItem? {
        orderStore.storeLimitedMenuItems.first
    }
}

private struct OrderTabView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                HeroBanner(
                    eyebrow: "Order",
                    title: orderStore.hasReviewItems ? "今の注文に戻る" : "注文を始める",
                    accent: [POCColor.curry, POCColor.cheese]
                )

                if orderStore.hasReviewItems {
                    currentOrderSummary

                    PrimaryCTAButton(title: "注文内容を確認", systemImage: "cart") {
                        navigator.push(.orderReview)
                    }
                } else if let store = orderStore.selectedStore {
                    StoreContextCard(store: store) {
                        orderStore.resetForNextOrder(keepingStore: false)
                        orderStore.clearPendingFavoriteResume()
                        orderStore.clearPendingMenuSelection()
                        navigator.presentStoreSelect(nextTab: .menu)
                    }

                    EmptyStateCard(
                        title: "まだ注文は始まっていません",
                        message: "メニューから商品を選ぶと、ここに現在の注文が表示されます。"
                    )

                    HStack(spacing: POCSpacing.s) {
                        PrimaryCTAButton(title: "メニューを見る", systemImage: "fork.knife") {
                            navigator.showMenuDiscovery()
                        }
                        SecondaryCTAButton(title: "保存済みを見る", systemImage: "clock") {
                            navigator.push(.savedCombos)
                        }
                    }
                } else {
                    EmptyStateCard(
                        title: "受取先を選んで注文を始める",
                        message: "まずは店舗を選ぶと、受取時間と注文導線が確定します。"
                    )

                    HStack(spacing: POCSpacing.s) {
                        PrimaryCTAButton(title: "受取先を選ぶ", systemImage: "location") {
                            orderStore.clearPendingFavoriteResume()
                            orderStore.clearPendingMenuSelection()
                            navigator.presentStoreSelect(nextTab: .menu)
                        }
                        SecondaryCTAButton(title: "メニューを見る", systemImage: "fork.knife") {
                            navigator.selectedTab = .menu
                        }
                    }
                }
            }
            .padding(POCSpacing.l)
            .padding(.bottom, 96)
        }
        .navigationTitle("Order")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var currentOrderSummary: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Current Order")

            ForEach(Array(orderStore.cartItems.enumerated()), id: \.element.id) { index, item in
                DraftSnapshotCard(
                    draft: item.draft,
                    showsCoupon: false,
                    title: "\(index + 1)皿目",
                    fillColor: POCColor.elevated,
                    showsStore: false,
                    showsPickup: false,
                    emphasizesTotal: false
                )
            }

            if let draft = orderStore.draftOrder {
                DraftSnapshotCard(
                    draft: draft,
                    showsCoupon: false,
                    title: orderStore.cartItems.isEmpty ? "この注文" : "追加中の1皿",
                    fillColor: POCColor.elevatedStrong,
                    showsStore: false,
                    showsPickup: false,
                    emphasizesTotal: true
                )
            }
        }
    }
}

private struct RewardsPlaceholderView: View {
    @EnvironmentObject private var navigator: AppNavigator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                HeroBanner(
                    eyebrow: "Rewards",
                    title: "スタンプと会員価値は今後追加",
                    accent: [POCColor.green, POCColor.cheese]
                )

                EmptyStateCard(
                    title: "PoC ではまだプレースホルダーです",
                    message: "将来はスタンプ、注文履歴、会員特典、ログイン価値の置き場として扱います。"
                )

                VStack(alignment: .leading, spacing: POCSpacing.s) {
                    SectionHeader("Will Live Here")

                    FutureValueCard(
                        title: "スタンプ / リワード",
                        message: "注文後に自然につながる継続利用価値をここに置きます。"
                    )
                    FutureValueCard(
                        title: "注文履歴と保存同期",
                        message: "会員価値が立つ情報は主導線を止めずここに集約します。"
                    )
                }

                VStack(alignment: .leading, spacing: POCSpacing.s) {
                    SectionHeader("Future Work")
                    Text("ログインは注文開始時に促し、起動時には毎回求めない方針を検討します。")
                        .font(.subheadline)
                        .foregroundStyle(POCColor.textSecondary)
                }
                .padding(POCSpacing.m)
                .pocCard(fill: POCColor.elevated)

                SecondaryCTAButton(title: "メニューに戻る", systemImage: "fork.knife") {
                    navigator.selectedTab = .menu
                }
            }
            .padding(POCSpacing.l)
            .padding(.bottom, 96)
        }
        .navigationTitle("Rewards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MenuArtworkBadge: View {
    let item: MenuItem

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: item.accentHexes.map { Color(hex: $0, opacity: 0.88) } + [Color.white.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 104)
            .overlay(alignment: .bottomLeading) {
                Text(item.group.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.92))
                    .padding(POCSpacing.s)
            }
    }
}

private struct HomeShortcutCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: POCSpacing.s) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(POCColor.curry)
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(POCColor.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
            .padding(POCSpacing.m)
            .pocCard(fill: POCColor.elevated)
        }
        .buttonStyle(.plain)
    }
}

private struct FutureValueCard: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(POCColor.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(POCColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }
}
