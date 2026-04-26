import SwiftUI
import UIKit

enum PopularMenuCurator {
    static func popularItems(from items: [MenuItem]) -> [MenuItem] {
        let curatedIDs = [
            "handmade-chicken-tender-cutlet-curry",
            "stewed-beef-tendon-curry",
            "loin-cutlet-curry",
            "cheese-curry",
        ]
        let filteredByID = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        let curatedItems = curatedIDs.compactMap { filteredByID[$0] }
        guard curatedItems.count < 4 else {
            return curatedItems
        }

        let featured = items.filter { item in
            item.tags.contains(.recommended) || item.tags.contains(.staple)
        }
        let curatedIDSet = Set(curatedIDs)
        let fallbackItems = featured.filter { !curatedIDSet.contains($0.id) }

        return Array((curatedItems + fallbackItems).prefix(4))
    }
}

struct PopularMenuGrid: View {
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

struct StoreOnlyBadge: View {
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
