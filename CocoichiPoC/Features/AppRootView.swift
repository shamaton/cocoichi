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
        .fullScreenCover(item: Binding(
            get: { navigator.presentedCover },
            set: { navigator.presentedCover = $0 }
        )) { cover in
            coverView(for: cover)
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
    private func coverView(for cover: AppCover) -> some View {
        switch cover {
        case .storeSelect:
            NavigationStack {
                ZStack {
                    POCBackgroundLayer()
                    StoreSelectView()
                }
            }
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
        GeometryReader { proxy in
            let contentWidth = availableContentWidth(in: proxy)

            ScrollView {
                VStack(alignment: .leading, spacing: POCSpacing.l) {
                    homeHeader
                    primaryTabsSection
                    seasonalBanner
                    if let featuredStoreItem {
                        featuredStoreItemCard(item: featuredStoreItem)
                    }
                    if !popularItems.isEmpty {
                        recommendedSection(contentWidth: contentWidth)
                    }
                    recommendedBannersSection
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, POCSpacing.l)
                .padding(.top, POCSpacing.l)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("ホーム")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeStickyHeader()
        }
    }

    private var homeHeader: some View {
        Group {
            if let store = orderStore.selectedStore {
                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                    Text("\(store.name)で受け取り")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(POCColor.textPrimary)
                }
            }
        }
    }

    private var seasonalBanner: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("今だけのオススメ")

            ForEach(homeBanners) { banner in
                HomeImageBannerCard(banner: banner)
            }
        }
    }

    private func recommendedSection(contentWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("今日のおすすめ")

            PopularMenuGrid(items: popularItems, contentWidth: contentWidth) { item in
                startHomeOrder(for: item)
            }
        }
    }

    private var recommendedBannersSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            ForEach(recommendedBanners) { banner in
                HomeImageBannerCard(banner: banner)
            }
        }
    }

    @ViewBuilder
    private func featuredStoreItemCard(item: MenuItem) -> some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("この店舗限定")
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

    private var primaryTabsSection: some View {
        HStack(spacing: POCSpacing.s) {
                HomeShortcutCard(
                    title: "メニュー",
                    systemImage: "fork.knife"
                ) {
                    navigator.selectedTab = .menu
                }

                HomeShortcutCard(
                    title: "オーダー",
                    systemImage: "cart"
                ) {
                    navigator.selectedTab = .order
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

    private func availableContentWidth(in proxy: GeometryProxy) -> CGFloat {
        let horizontalInsets = proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
        return max(0, proxy.size.width - horizontalInsets - (POCSpacing.l * 2))
    }

    private var popularItems: [MenuItem] {
        PopularMenuCurator.popularItems(from: orderStore.visibleMenuItems)
    }

    private var featuredStoreItem: MenuItem? {
        orderStore.storeLimitedMenuItems.first
    }

    private var homeBanners: [HomeBanner] {
        [
            HomeBanner(imagePath: "the-gyu-curry.png"),
            HomeBanner(imagePath: "oyster_curry.png"),
        ]
    }

    private var recommendedBanners: [HomeBanner] {
        [
            HomeBanner(imagePath: "collaboration.png"),
            HomeBanner(imagePath: "philosophy.png"),
        ]
    }
}

private struct OrderTabView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                HeroBanner(
                    eyebrow: "オーダー",
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
        .navigationTitle("オーダー")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var currentOrderSummary: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("現在の注文")

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
                    eyebrow: "リワード",
                    title: "スタンプと会員価値は今後追加",
                    accent: [POCColor.green, POCColor.cheese]
                )

                EmptyStateCard(
                    title: "この PoC ではまだ仮表示です",
                    message: "将来はスタンプ、注文履歴、会員特典、ログイン価値の置き場として扱います。"
                )

                VStack(alignment: .leading, spacing: POCSpacing.s) {
                    SectionHeader("今後ここに追加")

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
                    SectionHeader("今後の検討")
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
        .navigationTitle("リワード")
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
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: POCSpacing.s) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(POCColor.curry)
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 76)
            .padding(.horizontal, POCSpacing.s)
            .padding(.vertical, POCSpacing.xs)
            .pocCard(fill: POCColor.elevated)
        }
        .buttonStyle(.plain)
    }
}

private struct HomeStickyHeader: View {
    private let sideControlSize: CGFloat = 40

    var body: some View {
        HStack(spacing: POCSpacing.s) {
            HomeAccountMockIcon(size: sideControlSize)
            Spacer()
            HomeBrandHeader(iconSize: 66, fallbackSize: 36)
            Spacer()
            Color.clear
                .frame(width: sideControlSize, height: sideControlSize)
        }
        .padding(.horizontal, POCSpacing.m)
            .padding(.top, POCSpacing.xxs)
            .padding(.bottom, POCSpacing.xs)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(POCColor.line)
                .frame(height: 1)
        }
    }
}

private struct HomeBrandHeader: View {
    let iconSize: CGFloat
    let fallbackSize: CGFloat

    var body: some View {
        Group {
            if let iconImage {
                Image(uiImage: iconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            } else {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: fallbackSize))
                    .foregroundStyle(POCColor.curry)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("CoCo壱番屋ホームヘッダ")
    }

    private var iconImage: UIImage? {
        if let bundledImage = UIImage(named: "shop_icon") {
            return bundledImage
        }

        guard let url = Bundle.main.url(forResource: "shop_icon", withExtension: "png") else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}

private struct HomeAccountMockIcon: View {
    let size: CGFloat

    var body: some View {
        Button {
        } label: {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: size * 0.7))
                .foregroundStyle(POCColor.textPrimary, POCColor.elevatedStrong)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(POCColor.elevated.opacity(0.92))
                )
                .overlay {
                    Circle()
                        .stroke(POCColor.line, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("アカウント")
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

private struct HomeBanner: Identifiable {
    let imagePath: String

    var id: String { imagePath }
}

private struct HomeImageBannerCard: View {
    let banner: HomeBanner

    var body: some View {
        bannerArtwork
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: POCRadius.hero, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: POCRadius.hero, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }

    @ViewBuilder
    private var bannerArtwork: some View {
        if let bannerImage {
            Image(uiImage: bannerImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(POCColor.elevated)
        } else {
            LinearGradient(
                colors: [POCColor.red, POCColor.cheese, POCColor.elevatedStrong],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(maxWidth: .infinity)
            .frame(height: 176)
            .overlay {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.92))
            }
        }
    }

    private var bannerImage: UIImage? {
        let resourcePath = banner.imagePath as NSString
        let resourceName = resourcePath.deletingPathExtension
        let resourceExtension = resourcePath.pathExtension.isEmpty ? nil : resourcePath.pathExtension

        if let bannerURL = Bundle.main.url(
            forResource: resourceName,
            withExtension: resourceExtension,
            subdirectory: "BannerImages"
        ) {
            return UIImage(contentsOfFile: bannerURL.path)
        }

        if let bundledImage = UIImage(named: resourceName) {
            return bundledImage
        }

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}
