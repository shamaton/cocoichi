import SwiftUI
import UIKit

struct MenuDiscoveryView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var searchText = ""
    @State private var selectedTag: MenuTag?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: POCSpacing.l, pinnedViews: [.sectionHeaders]) {
                if let store = orderStore.selectedStore {
                    StoreContextCard(store: store) {
                        orderStore.resetForNextOrder(keepingStore: false)
                        navigator.resetToStoreSelect()
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
                        SectionHeader("For You", subtitle: "Saved Combos から今の気分につながる提案")

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
                        SectionHeader("Popular Today", subtitle: "写真から気分で選べるおすすめ")

                        LazyVGrid(columns: popularColumns, spacing: POCSpacing.s) {
                            ForEach(popularItems) { item in
                                PopularMenuCard(item: item) {
                                    orderStore.beginOrder(with: item)
                                    navigator.push(.curryDetail)
                                }
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
                                        orderStore.beginOrder(with: item)
                                        navigator.push(.curryDetail)
                                    }
                                }
                            }
                        } header: {
                            StickyGroupHeader(
                                title: section.group.rawValue,
                                itemCount: section.items.count
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, POCSpacing.l)
            .padding(.top, POCSpacing.l)
            .padding(.bottom, POCSpacing.l)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: POCSpacing.s) {
                SecondaryCTAButton(title: "Saved Combos", systemImage: "clock") {
                    navigator.push(.savedCombos)
                }
                SecondaryCTAButton(title: "Browse by Mood", systemImage: "sparkles") {
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
    }

    private var filteredMenuItems: [MenuItem] {
        orderStore.menuItems.filter { item in
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
            let items = filteredMenuItems.filter { $0.group == group }
            guard !items.isEmpty else { return nil }
            return GroupedMenuSection(group: group, items: items)
        }
    }

    private var popularItems: [MenuItem] {
        let featured = filteredMenuItems.filter { item in
            item.tags.contains(.recommended) || item.tags.contains(.staple)
        }
        return Array(featured.prefix(4))
    }

    private var popularColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: POCSpacing.s),
            GridItem(.flexible(), spacing: POCSpacing.s),
        ]
    }
}

private struct GroupedMenuSection: Identifiable {
    let group: CurryMenuGroup
    let items: [MenuItem]

    var id: CurryMenuGroup { group }
}

private struct StickyGroupHeader: View {
    let title: String
    let itemCount: Int

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(POCColor.textPrimary)

            Spacer()

            Text("\(itemCount)品")
                .font(.caption.weight(.medium))
                .foregroundStyle(POCColor.textTertiary)
        }
        .padding(.horizontal, POCSpacing.m)
        .padding(.vertical, POCSpacing.s)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                .fill(POCColor.background.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                .stroke(POCColor.line, lineWidth: 1)
        )
    }
}

private struct PopularMenuCard: View {
    let item: MenuItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: POCSpacing.s) {
                FeaturedMenuArtwork(item: item)

                Text(item.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                PriceLabel(amount: item.basePrice, isDiscount: false)
            }
            .padding(POCSpacing.s)
            .pocCard(fill: POCColor.elevated)
        }
        .buttonStyle(.plain)
    }
}

private struct CompactMenuRow: View {
    let item: MenuItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: POCSpacing.m) {
                MenuItemArtwork(item: item)

                Text(item.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                PriceLabel(amount: item.basePrice, isDiscount: false)
                    .fixedSize()
            }
            .padding(POCSpacing.s)
            .background(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .fill(POCColor.elevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .stroke(POCColor.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct FeaturedMenuArtwork: View {
    let item: MenuItem

    var body: some View {
        artwork
            .frame(maxWidth: .infinity)
            .frame(height: 132)
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

    var body: some View {
        artwork
            .frame(width: 118, height: 88)
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
