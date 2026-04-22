import SwiftUI
import UIKit

struct MenuDiscoveryView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var searchText = ""
    @State private var selectedTag: MenuTag?

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = availableContentWidth(in: proxy)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: POCSpacing.l, pinnedViews: [.sectionHeaders]) {
                    if let store = orderStore.selectedStore {
                        StoreContextCard(store: store) {
                            orderStore.resetForNextOrder(keepingStore: false)
                            navigator.presentStoreSelect()
                        }
                    } else {
                        MissingStoreCard {
                            navigator.presentStoreSelect(nextTab: .menu)
                        }
                    }

                    VStack(alignment: .leading, spacing: POCSpacing.s) {
                        Text("今日は何にする？")
                            .font(.largeTitle.weight(.bold))

                        TextField("Search menu, topping, keyword", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .padding(.horizontal, POCSpacing.m)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                                    .fill(POCColor.elevated)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                                    .stroke(POCColor.line, lineWidth: 1)
                            )

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: POCSpacing.xs) {
                                ForEach(MenuTag.allCases, id: \.self) { tag in
                                    FilterChip(title: tag.rawValue, isSelected: selectedTag == tag) {
                                        selectedTag = selectedTag == tag ? nil : tag
                                    }
                                }
                            }
                        }
                    }

                    if searchText.isEmpty, let favorite = orderStore.featuredFavorite {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("For You")

                            Button {
                                orderStore.resumeFavorite(favorite)
                                navigator.push(.curryDetail)
                            } label: {
                                VStack(alignment: .leading, spacing: POCSpacing.s) {
                                    Text("いつものに近い")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(POCColor.textTertiary)
                                    Text(favorite.name)
                                        .font(.headline.weight(.semibold))
                                    Text(favorite.draft.menuItem.name)
                                        .font(.subheadline)
                                        .foregroundStyle(POCColor.textSecondary)
                                    HStack {
                                        Text("from Saved Combos")
                                            .font(.caption)
                                            .foregroundStyle(POCColor.textSecondary)
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                            .foregroundStyle(POCColor.curry)
                                    }
                                }
                                .padding(POCSpacing.m)
                                .pocCard(fill: POCColor.elevatedStrong)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if searchText.isEmpty, !popularItems.isEmpty {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("Popular Today")

                            PopularMenuGrid(items: popularItems, contentWidth: contentWidth) { item in
                                startOrder(for: item)
                            }
                        }
                    }

                    if searchText.isEmpty, let store = orderStore.selectedStore, !storeOnlyItems.isEmpty {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("This Store Only")
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
                            message: "検索語やフィルタを変えると別のグループが見つかります。"
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
                                StickyGroupHeader(
                                    title: section.group.rawValue,
                                    group: section.group
                                )
                                .frame(width: contentWidth, alignment: .leading)
                            }
                        }
                    }
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, POCSpacing.l)
                .padding(.top, POCSpacing.l)
                .padding(.bottom, POCSpacing.l)
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: POCSpacing.s) {
                    SecondaryCTAButton(title: "保存済み", systemImage: "clock") {
                        navigator.push(.savedCombos)
                    }
                    SecondaryCTAButton(title: "気分で探す", systemImage: "sparkles") {
                        selectedTag = .recommended
                    }
                }
                .padding(.horizontal, POCSpacing.l)
                .padding(.top, POCSpacing.s)
                .padding(.bottom, POCSpacing.s)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Menu Discovery")
            .navigationBarTitleDisplayMode(.inline)
            .pocProgressWaveBackground(.menuDiscovery)
        }
    }

    private func startOrder(for item: MenuItem) {
        guard orderStore.selectedStore != nil else {
            navigator.presentStoreSelect(nextTab: .menu)
            return
        }
        orderStore.beginOrder(with: item)
        navigator.push(.curryDetail)
    }

    private func availableContentWidth(in proxy: GeometryProxy) -> CGFloat {
        let horizontalInsets = proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
        return max(0, proxy.size.width - horizontalInsets - (POCSpacing.l * 2))
    }

    private var filteredMenuItems: [MenuItem] {
        orderStore.visibleMenuItems.filter { item in
            let matchesTag = selectedTag.map { item.tags.contains($0) } ?? true
            let matchesSearch: Bool
            if searchText.isEmpty {
                matchesSearch = true
            } else {
                let query = searchText.lowercased()
                let searchSpace = ([item.name, item.subtitle, item.group.rawValue] + item.searchKeywords + item.tags.map(\.rawValue))
                    .joined(separator: " ")
                    .lowercased()
                matchesSearch = searchSpace.contains(query)
            }
            return matchesTag && matchesSearch
        }
    }

    private var groupedSections: [GroupedMenuSection] {
        CurryMenuGroup.allCases.compactMap { group in
            let items = groupedMenuItems.filter { $0.group == group }
            guard !items.isEmpty else { return nil }
            return GroupedMenuSection(group: group, items: items)
        }
    }

    private var groupedMenuItems: [MenuItem] {
        let hiddenStoreOnlyIDs = Set(searchText.isEmpty ? storeOnlyItems.map(\.id) : [])
        return filteredMenuItems.filter { !hiddenStoreOnlyIDs.contains($0.id) }
    }

    private var storeOnlyItems: [MenuItem] {
        filteredMenuItems.filter(\.isStoreLimited)
    }

    private var popularItems: [MenuItem] {
        let curatedIDs = [
            "the-gyu-curry",
            "sakura-shrimp-asari-spring-vegetable-curry",
            "loin-cutlet-curry",
            "cheese-curry",
        ]
        let filteredByID = Dictionary(uniqueKeysWithValues: filteredMenuItems.map { ($0.id, $0) })
        let curatedItems = curatedIDs.compactMap { filteredByID[$0] }
        guard curatedItems.count < 4 else {
            return curatedItems
        }

        let featured = filteredMenuItems.filter { item in
            item.tags.contains(.recommended) || item.tags.contains(.staple)
        }
        let curatedIDSet = Set(curatedIDs)
        let fallbackItems = featured.filter { !curatedIDSet.contains($0.id) }

        return Array((curatedItems + fallbackItems).prefix(4))
    }
}

private struct MissingStoreCard: View {
    let onSelectStore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            Text("受取先を選ぶと店舗限定メニューも見られます")
                .font(.headline.weight(.semibold))
                .foregroundStyle(POCColor.textPrimary)
            Text("まずは共通メニューを見られます。注文に進む前に店舗を選びます。")
                .font(.subheadline)
                .foregroundStyle(POCColor.textSecondary)
            Button("店舗を選ぶ", action: onSelectStore)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(POCColor.curry)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }
}

private struct GroupedMenuSection: Identifiable {
    let group: CurryMenuGroup
    let items: [MenuItem]

    var id: CurryMenuGroup { group }
}

private struct StickyGroupHeader: View {
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

private struct PopularMenuCard: View {
    let item: MenuItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: PopularMenuLayout.contentSpacing) {
                FeaturedMenuArtwork(item: item, height: PopularMenuLayout.imageHeight)

                Text(item.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                    .lineLimit(2, reservesSpace: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(alignment: .center, spacing: POCSpacing.xs) {
                    if item.isStoreLimited {
                        StoreOnlyBadge()
                    }
                    Spacer()
                    PriceLabel(amount: item.basePrice, isDiscount: false)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(PopularMenuLayout.cardPadding)
            .pocCard(fill: item.group.discoveryCardBackground)
            .frame(maxWidth: .infinity, minHeight: PopularMenuLayout.cardHeight, maxHeight: PopularMenuLayout.cardHeight, alignment: .topLeading)
        }
        .buttonStyle(.plain)
    }
}

private enum PopularMenuLayout {
    static let columnSpacing: CGFloat = POCSpacing.l
    static let rowSpacing: CGFloat = POCSpacing.xs
    static let cardPadding: CGFloat = POCSpacing.xs
    static let contentSpacing: CGFloat = POCSpacing.xs
    static let imageHeight: CGFloat = 112
    static let cardHeight: CGFloat = 220
}

private struct PopularMenuGrid: View {
    let items: [MenuItem]
    let contentWidth: CGFloat
    let onSelect: (MenuItem) -> Void

    var body: some View {
        LazyVGrid(columns: columns, spacing: PopularMenuLayout.rowSpacing) {
            ForEach(items) { item in
                PopularMenuCard(item: item) {
                    onSelect(item)
                }
            }
        }
        .frame(width: contentWidth, height: gridHeight, alignment: .leading)
    }

    private var cardWidth: CGFloat {
        floor((contentWidth - PopularMenuLayout.columnSpacing) / 2)
    }

    private var columns: [GridItem] {
        [
            GridItem(.fixed(cardWidth), spacing: PopularMenuLayout.columnSpacing),
            GridItem(.fixed(cardWidth), spacing: PopularMenuLayout.columnSpacing),
        ]
    }

    private var rowCount: Int {
        (items.count + 1) / 2
    }

    private var gridHeight: CGFloat {
        let rows = CGFloat(rowCount)
        let spacing = CGFloat(max(0, rowCount - 1)) * PopularMenuLayout.rowSpacing
        return rows * PopularMenuLayout.cardHeight + spacing
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

private struct StoreOnlyBadge: View {
    var body: some View {
        Text("限定")
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, POCSpacing.xs)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(POCColor.red)
            )
    }
}

private enum CompactMenuLayout {
    static let imageWidth: CGFloat = 108
    static let imageHeight: CGFloat = 74
    static let contentSpacing: CGFloat = POCSpacing.xs
    static let horizontalPadding: CGFloat = POCSpacing.s
    static let verticalPadding: CGFloat = POCSpacing.xs
}

private struct FeaturedMenuArtwork: View {
    let item: MenuItem
    var height: CGFloat = 132

    var body: some View {
        artwork
            .frame(maxWidth: .infinity)
            .frame(height: height)
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
