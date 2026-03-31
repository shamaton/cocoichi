import SwiftUI
import UIKit

struct MenuDiscoveryView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var searchText = ""
    @State private var selectedTag: MenuTag?
    @State private var expandedGroups: Set<CurryMenuGroup> = [.limitedTime, .meat]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
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

                SectionHeader("For You", subtitle: "Saved Combos から今の気分につながる提案")

                if let favorite = orderStore.featuredFavorite {
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

                SectionHeader(
                    "Menu List",
                    subtitle: searchText.isEmpty ? "カレーの種類ごとにたたみながら選べます" : "検索条件に合うメニュー"
                )

                LazyVStack(spacing: POCSpacing.m) {
                    if groupedSections.isEmpty {
                        EmptyStateCard(
                            title: "該当するカレーがありません",
                            message: "検索語やフィルタを変えると別のグループが見つかります。"
                        )
                    } else {
                        ForEach(groupedSections) { section in
                            CurryMenuGroupSection(
                                section: section,
                                isExpanded: isExpanded(section.group),
                                toggle: {
                                    toggle(section.group)
                                },
                                onSelect: { item in
                                    orderStore.beginOrder(with: item)
                                    navigator.push(.curryDetail)
                                }
                            )
                        }
                    }
                }
            }
            .padding(POCSpacing.l)
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

    private func isExpanded(_ group: CurryMenuGroup) -> Bool {
        searchText.isEmpty ? expandedGroups.contains(group) : true
    }

    private func toggle(_ group: CurryMenuGroup) {
        if expandedGroups.contains(group) {
            expandedGroups.remove(group)
        } else {
            expandedGroups.insert(group)
        }
    }
}

private struct GroupedMenuSection: Identifiable {
    let group: CurryMenuGroup
    let items: [MenuItem]

    var id: CurryMenuGroup { group }
}

private struct CurryMenuGroupSection: View {
    let section: GroupedMenuSection
    let isExpanded: Bool
    let toggle: () -> Void
    let onSelect: (MenuItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            Button(action: toggle) {
                HStack(spacing: POCSpacing.s) {
                    VStack(alignment: .leading, spacing: POCSpacing.xs) {
                        Text(section.group.rawValue)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(POCColor.textPrimary)
                        Text("\(section.items.count)品")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(POCColor.textTertiary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.title3)
                        .foregroundStyle(POCColor.curry)
                }
                .padding(POCSpacing.m)
                .background(
                    LinearGradient(
                        colors: [section.groupColor.opacity(0.22), POCColor.elevated],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                        .stroke(POCColor.line, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: POCSpacing.s) {
                    ForEach(section.items) { item in
                        Button {
                            onSelect(item)
                        } label: {
                            HStack(spacing: POCSpacing.m) {
                                MenuItemArtwork(item: item)

                                VStack(alignment: .leading, spacing: POCSpacing.s) {
                                    Text(item.name)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(POCColor.textPrimary)
                                    Text(item.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(POCColor.textSecondary)

                                    HStack(spacing: POCSpacing.xs) {
                                        ForEach(item.tags, id: \.self) { tag in
                                            Text(tag.rawValue)
                                                .font(.caption.weight(.medium))
                                                .padding(.horizontal, POCSpacing.xs)
                                                .padding(.vertical, 6)
                                                .background(POCColor.background, in: Capsule())
                                        }
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: POCSpacing.s) {
                                    PriceLabel(amount: item.basePrice, isDiscount: false)
                                    Image(systemName: "chevron.right")
                                        .font(.footnote.weight(.bold))
                                        .foregroundStyle(POCColor.curry)
                                }
                            }
                            .padding(POCSpacing.m)
                            .background(
                                LinearGradient(
                                    colors: [item.accentColors.first ?? POCColor.elevated, POCColor.elevated],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                                    .stroke(POCColor.line, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, POCSpacing.xs)
            }
        }
    }
}

private struct MenuItemArtwork: View {
    let item: MenuItem

    var body: some View {
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
        .frame(width: 104, height: 88)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.32), lineWidth: 1)
        )
    }

    private var menuImage: UIImage? {
        guard let imagePath = item.imagePath else { return nil }
        let resourcePath = imagePath as NSString
        let resourceName = resourcePath.deletingPathExtension
        let resourceExtension = resourcePath.pathExtension.isEmpty ? nil : resourcePath.pathExtension
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}

private extension GroupedMenuSection {
    var groupColor: Color {
        Color(hex: group.accentHexes.first ?? 0x8B4A1F)
    }
}
