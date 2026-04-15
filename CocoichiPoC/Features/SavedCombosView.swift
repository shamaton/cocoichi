import SwiftUI

struct SavedCombosView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore
    @State private var selectedFavoriteForReview: FavoriteCombo?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                SectionHeader("Saved Combos")

                SavedCombosStoreContextCard(store: orderStore.selectedStore)

                if orderStore.favoriteCombos.isEmpty {
                    EmptyStateCard(title: "保存済みの組み合わせはまだありません", message: "注文完了後に保存すると、ここからすぐ再開できます。")
                } else {
                    if !readyFavorites.isEmpty {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader(orderStore.selectedStore == nil ? "Saved" : "Ready Here")
                            ForEach(readyFavorites) { favorite in
                                SavedComboCard(
                                    favorite: favorite,
                                    state: orderStore.favoriteResumeState(for: favorite),
                                    actionTitle: "この内容で再開"
                                ) {
                                    resumeFavorite(favorite)
                                }
                            }
                        }
                    }

                    if !needsReviewFavorites.isEmpty {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("Needs Review")
                            ForEach(needsReviewFavorites) { favorite in
                                SavedComboCard(
                                    favorite: favorite,
                                    state: orderStore.favoriteResumeState(for: favorite),
                                    actionTitle: "内容を見る"
                                ) {
                                    selectedFavoriteForReview = favorite
                                }
                            }
                        }
                    }
                }

                VStack(spacing: POCSpacing.s) {
                    SecondaryCTAButton(title: "メニュー一覧へ戻る", systemImage: "fork.knife") {
                        navigator.popToMenuDiscovery()
                    }
                    if orderStore.selectedStore != nil {
                        SecondaryCTAButton(title: "店舗を変更する", systemImage: "mappin.and.ellipse") {
                            navigator.resetToStoreSelect()
                        }
                    }
                }
            }
            .padding(POCSpacing.l)
        }
        .sheet(item: $selectedFavoriteForReview) { favorite in
            SavedComboReviewSheet(
                favorite: favorite,
                message: reviewMessage(for: favorite)
            ) {
                resumeFavorite(favorite)
                selectedFavoriteForReview = nil
            }
        }
        .navigationTitle("Saved Combos")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sortedFavorites: [FavoriteCombo] {
        orderStore.favoriteCombos.sorted { $0.lastUsedAt > $1.lastUsedAt }
    }

    private var readyFavorites: [FavoriteCombo] {
        sortedFavorites.filter {
            switch orderStore.favoriteResumeState(for: $0) {
            case .ready:
                return true
            case .needsReview:
                return false
            }
        }
    }

    private var needsReviewFavorites: [FavoriteCombo] {
        sortedFavorites.filter {
            switch orderStore.favoriteResumeState(for: $0) {
            case .ready:
                return false
            case .needsReview:
                return true
            }
        }
    }

    private func reviewMessage(for favorite: FavoriteCombo) -> String {
        switch orderStore.favoriteResumeState(for: favorite) {
        case let .ready(message), let .needsReview(message):
            return message
        }
    }

    private func resumeFavorite(_ favorite: FavoriteCombo) {
        orderStore.resumeFavorite(favorite)
        navigator.push(.curryDetail)
    }
}

private struct SavedCombosStoreContextCard: View {
    let store: Store?

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            if let store {
                SectionHeader("Store Context")
                SummaryRow(title: "Store", value: store.name)
                SummaryRow(title: "Pickup", value: store.pickupLeadTimeText)
            } else {
                SectionHeader("Store Context")
                Text("店舗未設定のため、保存時の店舗で再開します。")
                    .font(.subheadline)
                    .foregroundStyle(POCColor.textSecondary)
            }
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }
}

private struct SavedComboCard: View {
    let favorite: FavoriteCombo
    let state: FavoriteResumeState
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: POCSpacing.s) {
                HStack(alignment: .top, spacing: POCSpacing.s) {
                    VStack(alignment: .leading, spacing: POCSpacing.xs) {
                        Text(favorite.name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(POCColor.textPrimary)
                        Text(favorite.draft.menuItem.name)
                            .font(.subheadline)
                            .foregroundStyle(POCColor.textSecondary)
                        Text("\(favorite.draft.spiceLevelText) / \(favorite.draft.riceGrams)g / \(favorite.draft.toppingsSummary)")
                            .font(.caption)
                            .foregroundStyle(POCColor.textTertiary)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    Text(favorite.relativeLabel)
                        .font(.caption)
                        .foregroundStyle(POCColor.textTertiary)
                }

                Text("\(favorite.draft.store.name)で保存")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(POCColor.textSecondary)

                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)

                HStack {
                    Text(actionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(POCColor.curry)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(POCColor.curry)
                }
            }
            .padding(POCSpacing.m)
            .pocCard(fill: backgroundFill)
        }
        .buttonStyle(.plain)
    }

    private var statusMessage: String {
        switch state {
        case let .ready(message), let .needsReview(message):
            return message
        }
    }

    private var statusColor: Color {
        switch state {
        case .ready:
            return POCColor.textSecondary
        case .needsReview:
            return POCColor.curry
        }
    }

    private var backgroundFill: Color {
        switch state {
        case .ready:
            return POCColor.elevated
        case .needsReview:
            return POCColor.elevatedStrong
        }
    }
}

private struct SavedComboReviewSheet: View {
    @Environment(\.dismiss) private var dismiss

    let favorite: FavoriteCombo
    let message: String
    let confirm: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                SectionHeader("Saved Combo")

                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                    Text(favorite.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)
                    Text("\(favorite.draft.store.name)で保存")
                        .font(.subheadline)
                        .foregroundStyle(POCColor.textSecondary)
                }

                DraftSnapshotCard(
                    draft: favorite.draft,
                    showsCoupon: false,
                    title: "Summary"
                )

                EmptyStateCard(
                    title: "Note",
                    message: "\(message) 必要な調整は Customize 画面で続けられます。"
                )

                Spacer()

                HStack(spacing: POCSpacing.s) {
                    SecondaryCTAButton(title: "キャンセル", systemImage: "xmark") {
                        dismiss()
                    }
                    PrimaryCTAButton(title: "この内容で再開", systemImage: "arrow.right") {
                        confirm()
                    }
                }
            }
            .padding(POCSpacing.l)
            .navigationTitle("Saved Combo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
