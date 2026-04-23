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
                            SectionHeader(orderStore.selectedStore == nil ? "店舗を選んで再開" : "Ready Here")
                            ForEach(readyFavorites) { favorite in
                                SavedComboCard(
                                    favorite: favorite,
                                    state: orderStore.favoriteResumeState(for: favorite),
                                    actionTitle: actionTitle(for: favorite)
                                ) {
                                    handleFavoriteSelection(favorite)
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

                    if !lockedFavorites.isEmpty {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("店舗選択が必要")
                            ForEach(lockedFavorites) { favorite in
                                SavedComboCard(
                                    favorite: favorite,
                                    state: orderStore.favoriteResumeState(for: favorite),
                                    actionTitle: "店舗を選ぶと再開できます"
                                ) {}
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
                            orderStore.clearPendingFavoriteResume()
                            navigator.resetToStoreSelect()
                        }
                    } else if !lockedFavorites.isEmpty {
                        SecondaryCTAButton(title: "店舗を選ぶ", systemImage: "mappin.and.ellipse") {
                            orderStore.clearPendingFavoriteResume()
                            navigator.presentStoreSelect(nextTab: .menu, nextPath: [.savedCombos])
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
            case .ready, .chooseStore:
                return true
            case .needsReview:
                return false
            case .storeSelectionRequired:
                return false
            }
        }
    }

    private var needsReviewFavorites: [FavoriteCombo] {
        sortedFavorites.filter {
            switch orderStore.favoriteResumeState(for: $0) {
            case .ready, .chooseStore:
                return false
            case .needsReview:
                return true
            case .storeSelectionRequired:
                return false
            }
        }
    }

    private var lockedFavorites: [FavoriteCombo] {
        sortedFavorites.filter {
            switch orderStore.favoriteResumeState(for: $0) {
            case .ready, .needsReview, .chooseStore:
                return false
            case .storeSelectionRequired:
                return true
            }
        }
    }

    private func reviewMessage(for favorite: FavoriteCombo) -> String {
        orderStore.favoriteResumeState(for: favorite).message
    }

    private func actionTitle(for favorite: FavoriteCombo) -> String {
        switch orderStore.favoriteResumeState(for: favorite) {
        case .chooseStore:
            return "店舗を選んで再開"
        case .ready:
            return "この内容で再開"
        case .needsReview:
            return "内容を見る"
        case .storeSelectionRequired:
            return "店舗を選ぶと再開できます"
        }
    }

    private func handleFavoriteSelection(_ favorite: FavoriteCombo) {
        switch orderStore.favoriteResumeState(for: favorite) {
        case .chooseStore:
            orderStore.prepareFavoriteResumeAfterStoreSelection(favorite)
            navigator.presentStoreSelect(nextTab: .menu, nextPath: [.curryDetail, .curryToppings])
        case .ready:
            orderStore.resumeFavorite(favorite)
            navigator.showCurryToppings()
        case .needsReview:
            selectedFavoriteForReview = favorite
        case .storeSelectionRequired:
            break
        }
    }

    private func resumeFavorite(_ favorite: FavoriteCombo) {
        guard orderStore.favoriteResumeState(for: favorite).isSelectable else { return }
        orderStore.resumeFavorite(favorite)
        navigator.showCurryToppings()
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
                Text("共通メニューは選択後に店舗を決めて再開します。限定メニューは店舗選択後に有効になります。")
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

                Group {
                    if favorite.draft.menuItem.isStoreLimited {
                        Text("\(favorite.draft.store.name)で保存")
                    } else {
                        Text("共通メニュー")
                    }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(POCColor.textSecondary)

                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)

                HStack {
                    Text(actionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(actionColor)
                    Spacer()
                    Image(systemName: actionSystemImage)
                        .foregroundStyle(actionColor)
                }
            }
            .padding(POCSpacing.m)
            .pocCard(fill: backgroundFill)
        }
        .buttonStyle(.plain)
        .disabled(!state.isSelectable)
    }

    private var statusMessage: String {
        state.message
    }

    private var statusColor: Color {
        switch state {
        case .ready, .chooseStore:
            return POCColor.textSecondary
        case .needsReview:
            return POCColor.curry
        case .storeSelectionRequired:
            return POCColor.red
        }
    }

    private var backgroundFill: Color {
        switch state {
        case .ready, .chooseStore:
            return POCColor.elevated
        case .needsReview:
            return POCColor.elevatedStrong
        case .storeSelectionRequired:
            return POCColor.elevated.opacity(0.72)
        }
    }

    private var actionColor: Color {
        switch state {
        case .storeSelectionRequired:
            return POCColor.textTertiary
        case .ready, .needsReview, .chooseStore:
            return POCColor.curry
        }
    }

    private var actionSystemImage: String {
        switch state {
        case .storeSelectionRequired:
            return "lock.fill"
        case .ready, .needsReview:
            return "arrow.right"
        case .chooseStore:
            return "mappin.and.ellipse"
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
                    Group {
                        if favorite.draft.menuItem.isStoreLimited {
                            Text("\(favorite.draft.store.name)で保存")
                        } else {
                            Text("共通メニュー")
                        }
                    }
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
                    message: "\(message) 再開後はトッピング画面から続けられ、必要ならベース設定へ戻れます。"
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
