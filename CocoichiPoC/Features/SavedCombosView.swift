import SwiftUI

struct SavedCombosView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore
    @State private var selectedFavoriteForReview: FavoriteCombo?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                SectionHeader("お気に入り確認")

                if orderStore.favoriteCombos.isEmpty {
                    EmptyStateCard(title: "保存済みの組み合わせはまだありません", message: "注文完了後に保存すると、ここからすぐ再開できます。")
                } else {
                    if !readyFavorites.isEmpty {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader(orderStore.selectedStore == nil ? "店舗を選んで使うお気に入り" : "すぐ使えるお気に入り")
                            ForEach(readyFavorites) { favorite in
                                SavedComboCard(
                                    favorite: favorite,
                                    state: orderStore.favoriteResumeState(for: favorite)
                                ) {
                                    handleFavoriteSelection(favorite)
                                }
                            }
                        }
                    }

                    if !needsReviewFavorites.isEmpty {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("確認が必要なお気に入り")
                            ForEach(needsReviewFavorites) { favorite in
                                SavedComboCard(
                                    favorite: favorite,
                                    state: orderStore.favoriteResumeState(for: favorite)
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
                                    state: orderStore.favoriteResumeState(for: favorite)
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
                            orderStore.clearPendingMenuSelection()
                            navigator.resetToStoreSelect()
                        }
                    } else if !lockedFavorites.isEmpty {
                        SecondaryCTAButton(title: "店舗を選ぶ", systemImage: "mappin.and.ellipse") {
                            orderStore.clearPendingFavoriteResume()
                            orderStore.clearPendingMenuSelection()
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
        .navigationTitle("お気に入り")
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
        favorite.draft.menuItem.isStoreLimited
            ? "限定メニューを含むため、再開前に内容を確認してください。"
            : "再開前に内容を確認してください。"
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

private struct SavedComboCard: View {
    let favorite: FavoriteCombo
    let state: FavoriteResumeState
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            HStack(alignment: .top, spacing: POCSpacing.s) {
                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                    Text(favorite.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)
                    Text(favorite.draft.menuItem.name)
                        .font(.subheadline)
                        .foregroundStyle(POCColor.textSecondary)
                }

                Spacer(minLength: 0)

                selectButton
            }

            CollapsibleFavoriteDetailGroup(
                baseItems: baseSummaryItems,
                toppingItems: toppingSummaryItems
            )

            if let statusMessage {
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)
            }
        }
        .padding(POCSpacing.m)
        .pocCard(fill: backgroundFill)
    }

    private var selectButton: some View {
        Button(action: action) {
            Text("選択")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(state.isSelectable ? Color.white : POCColor.textTertiary)
                .padding(.horizontal, POCSpacing.m)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(state.isSelectable ? POCColor.curry : POCColor.elevatedStrong)
                )
        }
        .buttonStyle(.plain)
        .disabled(!state.isSelectable)
    }

    private var baseSummaryItems: [String] {
        [
            "カレーソース \(favorite.draft.currySauce.rawValue)",
            "ライス \(favorite.draft.riceGrams)g",
            "辛さ \(favorite.draft.spiceLevelText)",
            "ソース量 \(favorite.draft.sauceAmount.rawValue)"
        ]
    }

    private var toppingSummaryItems: [String] {
        favorite.draft.toppings.isEmpty ? ["なし"] : favorite.draft.toppingsSummary.components(separatedBy: " / ")
    }

    private var statusMessage: String? {
        switch state {
        case .ready, .chooseStore, .storeSelectionRequired:
            return nil
        case .needsReview:
            return "再開前に内容確認が必要です"
        }
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
}

private struct CollapsibleFavoriteDetailGroup: View {
    let baseItems: [String]
    let toppingItems: [String]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            Button {
                withAnimation(.snappy(duration: 0.2, extraBounce: 0)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: POCSpacing.xs) {
                    Image(systemName: isExpanded ? "minus.circle.fill" : "plus.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(POCColor.curry)

                    Text(isExpanded ? "ベース" : "ベース・トッピング")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)

                    Spacer(minLength: 0)

                    Text(isExpanded ? "閉じる" : "表示")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(POCColor.curry)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: POCSpacing.xxs) {
                    bulletList(baseItems)

                    Text("トッピング")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)
                        .padding(.top, POCSpacing.xs)

                    bulletList(toppingItems)
                        .padding(.top, POCSpacing.xxs)
                }
                .transition(.opacity)
            }
        }
        .padding(POCSpacing.s)
        .background(
            RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                .fill(POCColor.elevated.opacity(0.85))
        )
    }

    private func bulletList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: POCSpacing.xxs) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: POCSpacing.xs) {
                    Text("•")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(POCColor.textSecondary)

                    Text(item)
                        .font(.subheadline)
                        .foregroundStyle(POCColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
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
                SectionHeader("お気に入り内容")

                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                    Text(favorite.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)
                }

                SavedComboDetailCard(draft: favorite.draft)

                EmptyStateCard(
                    title: "確認事項",
                    message: "\(message) 再開後はトッピング画面から続けられ、必要ならベース設定へ戻れます。"
                )

                Spacer()

                HStack(spacing: POCSpacing.s) {
                    SecondaryCTAButton(title: "キャンセル", systemImage: "xmark") {
                        dismiss()
                    }
                    PrimaryCTAButton(title: "再開する", systemImage: nil) {
                        confirm()
                    }
                }
            }
            .padding(POCSpacing.l)
            .navigationTitle("お気に入り内容")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct SavedComboDetailCard: View {
    let draft: DraftOrder

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("注文内容")

            Text(draft.menuItem.name)
                .font(.headline.weight(.semibold))
                .foregroundStyle(POCColor.textPrimary)

            OrderDetailBulletGroup(
                title: "ベース設定",
                items: baseSummaryItems
            )

            OrderDetailBulletGroup(
                title: "トッピング",
                items: toppingSummaryItems
            )

            SummaryRow(title: "合計", value: draft.total.yenText)
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }

    private var baseSummaryItems: [String] {
        [
            "カレーソース \(draft.currySauce.rawValue)",
            "ライス \(draft.riceGrams)g",
            "辛さ \(draft.spiceLevelText)",
            "ソース量 \(draft.sauceAmount.rawValue)"
        ]
    }

    private var toppingSummaryItems: [String] {
        draft.toppings.isEmpty ? ["なし"] : draft.toppingsSummary.components(separatedBy: " / ")
    }
}
