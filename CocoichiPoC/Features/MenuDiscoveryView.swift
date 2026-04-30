import SwiftUI
import UIKit

struct MenuDiscoveryView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var selectedGenre: MenuDiscoveryGenre = .curry

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = availableContentWidth(in: proxy)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: POCSpacing.l) {
                    genreContent(contentWidth: contentWidth)
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, POCSpacing.l)
                .padding(.top, POCSpacing.l)
                .padding(.bottom, POCSpacing.l)
            }
            .navigationTitle(orderStore.selectedStore?.name ?? "メニューを選ぶ")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top, spacing: 0) {
                pinnedNavigationHeader(contentWidth: contentWidth)
            }
            .pocProgressWaveBackground(.menuDiscovery)
        }
    }

    @ViewBuilder
    private func genreContent(contentWidth: CGFloat) -> some View {
        switch selectedGenre {
        case .curry:
            curryContent(contentWidth: contentWidth)
        case .salad, .drink, .other:
            placeholderContent(for: selectedGenre)
        }
    }

    @ViewBuilder
    private func curryContent(contentWidth: CGFloat) -> some View {
        favoriteEntrySection

        if !popularItems.isEmpty {
            VStack(alignment: .leading, spacing: POCSpacing.s) {
                SectionHeader("今日のおすすめ")

                PopularMenuGrid(items: popularItems, contentWidth: contentWidth) { item in
                    startOrder(for: item)
                }
            }
        }

        if let store = orderStore.selectedStore, !storeOnlyItems.isEmpty {
            VStack(alignment: .leading, spacing: POCSpacing.s) {
                SectionHeader("この店舗限定")
                Text("\(store.name)で選べる限定メニュー")
                    .font(.subheadline)
                    .foregroundStyle(POCColor.textSecondary)

                ForEach(storeOnlyItems) { item in
                    CompactMenuRow(item: item) {
                        startOrder(for: item)
                    }
                }
            }
        }

        if groupedSections.isEmpty {
            EmptyStateCard(
                title: "該当するカレーがありません",
                message: "表示条件を見直すと、別のメニューが表示される場合があります。"
            )
        } else {
            ForEach(groupedSections) { section in
                Section {
                    VStack(spacing: POCSpacing.s) {
                        ForEach(section.items) { item in
                            CompactMenuRow(item: item) {
                                startOrder(for: item)
                            }
                        }
                    }
                } header: {
                    MenuGroupHeader(
                        title: section.group.rawValue,
                        group: section.group
                    )
                    .frame(width: contentWidth, alignment: .leading)
                }
            }
        }
    }

    private func pinnedNavigationHeader(contentWidth: CGFloat) -> some View {
        genreHeader
        .frame(width: contentWidth, alignment: .leading)
        .padding(.horizontal, POCSpacing.l)
        .padding(.top, POCSpacing.s)
        .padding(.bottom, POCSpacing.s)
        .background(POCColor.background.opacity(0.96))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(POCColor.line)
                .frame(height: 1)
        }
    }

    private var genreHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: POCSpacing.s) {
                    ForEach(MenuDiscoveryGenre.allCases) { genre in
                        MenuGenreChip(
                            genre: genre,
                            isSelected: selectedGenre == genre
                        ) {
                            selectedGenre = genre
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func placeholderContent(for genre: MenuDiscoveryGenre) -> some View {
        VStack(alignment: .leading, spacing: POCSpacing.m) {
            SectionHeader(genre.sectionTitle)

            VStack(alignment: .leading, spacing: POCSpacing.s) {
                Text("\(genre.rawValue)メニューはPoCで準備中です")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                Text(genre.placeholderMessage)
                    .font(.subheadline)
                    .foregroundStyle(POCColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("まずはカレーから注文フローを確認できます。")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(POCColor.curry)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(POCSpacing.m)
            .pocCard(fill: POCColor.elevatedStrong)
        }
    }

    private func startOrder(for item: MenuItem) {
        guard orderStore.selectedStore != nil else {
            orderStore.clearPendingFavoriteResume()
            orderStore.prepareMenuSelectionAfterStoreSelection(item)
            navigator.pushStoreSelectForMenuSelection()
            return
        }
        orderStore.beginOrder(with: item)
        navigator.push(.curryDetail)
    }

    private func availableContentWidth(in proxy: GeometryProxy) -> CGFloat {
        let horizontalInsets = proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
        return max(0, proxy.size.width - horizontalInsets - (POCSpacing.l * 2))
    }

    private var favoriteEntrySection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("お気に入りから選ぶ")

            Button {
                navigator.push(.savedCombos)
            } label: {
                HStack(spacing: POCSpacing.m) {
                    VStack(alignment: .leading, spacing: POCSpacing.xs) {
                        Text(favoriteEntryTitle)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(POCColor.textPrimary)
                        Text(favoriteEntryMessage)
                            .font(.subheadline)
                            .foregroundStyle(POCColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(POCColor.curry)
                }
                .padding(POCSpacing.m)
                .pocCard(fill: POCColor.elevatedStrong)
            }
            .buttonStyle(.plain)
        }
    }

    private var favoriteEntryTitle: String {
        if let favorite = orderStore.featuredFavorite {
            return favorite.name
        }
        return "保存済みのお気に入りを見る"
    }

    private var favoriteEntryMessage: String {
        if let favorite = orderStore.featuredFavorite {
            switch orderStore.favoriteResumeState(for: favorite) {
            case .chooseStore:
                return "店舗を選んでからお気に入りを再開できます"
            case .storeSelectionRequired:
                return "限定メニューを含むため、店舗を選ぶと再開できます"
            case .ready, .needsReview:
                break
            }
            return "\(favorite.draft.menuItem.name) からすぐ再開できます"
        }
        return "注文後に保存した組み合わせを、ここからすぐ呼び出せます。"
    }

    private var groupedSections: [GroupedMenuSection] {
        CurryMenuGroup.allCases.compactMap { group in
            let items = groupedMenuItems.filter { $0.group == group }
            guard !items.isEmpty else { return nil }
            return GroupedMenuSection(group: group, items: items)
        }
    }

    private var groupedMenuItems: [MenuItem] {
        let hiddenStoreOnlyIDs = Set(storeOnlyItems.map(\.id))
        return orderStore.visibleMenuItems.filter { !hiddenStoreOnlyIDs.contains($0.id) }
    }

    private var storeOnlyItems: [MenuItem] {
        orderStore.visibleMenuItems.filter(\.isStoreLimited)
    }

    private var popularItems: [MenuItem] {
        PopularMenuCurator.popularItems(from: orderStore.visibleMenuItems)
    }
}

private enum MenuDiscoveryGenre: String, CaseIterable, Identifiable {
    case curry = "カレー"
    case salad = "サラダ"
    case drink = "ドリンク"
    case other = "その他"

    var id: Self { self }

    var sectionTitle: String {
        switch self {
        case .curry:
            return "カレー"
        case .salad:
            return "サラダ"
        case .drink:
            return "ドリンク"
        case .other:
            return "その他"
        }
    }

    var placeholderMessage: String {
        switch self {
        case .curry:
            return ""
        case .salad:
            return "季節のサラダやセット候補をここに追加できる想定です。"
        case .drink:
            return "ラッシーやソフトドリンクなどの一覧をここに載せる想定です。"
        case .other:
            return "スープやサイドなど、カレー以外の補助メニューをここに載せる想定です。"
        }
    }
}

private struct MenuGenreChip: View {
    let genre: MenuDiscoveryGenre
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(genre.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? POCColor.textPrimary : POCColor.textSecondary)
                .padding(.horizontal, POCSpacing.m)
                .padding(.vertical, POCSpacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? POCColor.cheese : POCColor.elevated)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? POCColor.cheese : POCColor.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct GroupedMenuSection: Identifiable {
    let group: CurryMenuGroup
    let items: [MenuItem]

    var id: CurryMenuGroup { group }
}

private struct MenuGroupHeader: View {
    let title: String
    let group: CurryMenuGroup

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                .fill(group.discoveryCardBackground)
            HStack(spacing: POCSpacing.s) {
                if let uiImage = genreImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.28))
                        .overlay {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.92))
                        }
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.28), lineWidth: 1)
                        )
                }

                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, POCSpacing.m)
            .padding(.vertical, POCSpacing.xs)
        }
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                .stroke(POCColor.line, lineWidth: 1)
        )
    }

    private var genreImage: UIImage? {
        let resourcePath = group.genreImagePath as NSString
        let resourceName = resourcePath.deletingPathExtension
        let resourceExtension = resourcePath.pathExtension.isEmpty ? nil : resourcePath.pathExtension
        if let bundledImage = UIImage(named: resourceName) {
            return bundledImage
        }
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}

private struct CompactMenuRow: View {
    let item: MenuItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: POCSpacing.m) {
                MenuItemArtwork(
                    item: item,
                    width: CompactMenuLayout.imageWidth,
                    height: CompactMenuLayout.imageHeight
                )

                VStack(alignment: .leading, spacing: CompactMenuLayout.contentSpacing) {
                    VStack(alignment: .leading, spacing: POCSpacing.xxs) {
                        if item.isStoreLimited {
                            StoreOnlyBadge()
                        }
                        Text(item.name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(POCColor.textPrimary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer(minLength: 0)

                    HStack {
                        Spacer()
                        PriceLabel(amount: item.basePrice, isDiscount: false)
                            .fixedSize()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: CompactMenuLayout.imageHeight, alignment: .topLeading)
            }
            .padding(.horizontal, CompactMenuLayout.horizontalPadding)
            .padding(.vertical, CompactMenuLayout.verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .fill(item.group.discoveryCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .stroke(POCColor.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private enum CompactMenuLayout {
    static let imageWidth: CGFloat = 108
    static let imageHeight: CGFloat = 74
    static let contentSpacing: CGFloat = POCSpacing.xs
    static let horizontalPadding: CGFloat = POCSpacing.s
    static let verticalPadding: CGFloat = POCSpacing.xs
}

private struct MenuItemArtwork: View {
    let item: MenuItem
    var width: CGFloat = 118
    var height: CGFloat = 88

    var body: some View {
        artwork
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.32), lineWidth: 1)
            )
    }

    private var artwork: some View {
        Group {
            if let uiImage = menuImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [item.accentColors.first ?? POCColor.cheese, POCColor.elevatedStrong],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(alignment: .bottomLeading) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.92))
                        .padding(POCSpacing.s)
                }
            }
        }
    }

    private var menuImage: UIImage? {
        loadMenuImage()
    }

    private func loadMenuImage() -> UIImage? {
        guard let imagePath = item.imagePath else { return nil }
        let resourcePath = imagePath as NSString
        let resourceName = resourcePath.deletingPathExtension
        let resourceExtension = resourcePath.pathExtension.isEmpty ? nil : resourcePath.pathExtension
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}
