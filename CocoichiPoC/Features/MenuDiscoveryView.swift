import SwiftUI

struct MenuDiscoveryView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var searchText = ""
    @State private var selectedTag: MenuTag?

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

                SectionHeader("Menu List", subtitle: filteredMenuItems.count == orderStore.menuItems.count ? "人気と定番を混ぜて並べています" : "検索条件に合うメニュー")

                LazyVStack(spacing: POCSpacing.m) {
                    ForEach(filteredMenuItems) { item in
                        Button {
                            orderStore.beginOrder(with: item)
                            navigator.push(.curryDetail)
                        } label: {
                            HStack(spacing: POCSpacing.m) {
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
                let searchSpace = ([item.name, item.subtitle] + item.searchKeywords + item.tags.map(\.rawValue)).joined(separator: " ").lowercased()
                matchesSearch = searchSpace.contains(query)
            }
            return matchesTag && matchesSearch
        }
    }
}
