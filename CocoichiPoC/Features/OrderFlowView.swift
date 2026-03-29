import SwiftUI

struct CurryDetailView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    private let riceOptions = [200, 300, 400, 500]
    private let spiceOptions = [1, 2, 3, 4]
    private let toppingColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Group {
            if let draft = orderStore.draftOrder {
                ScrollView {
                    VStack(alignment: .leading, spacing: POCSpacing.l) {
                        HeroBanner(
                            eyebrow: "Customize",
                            title: draft.menuItem.name,
                            subtitle: draft.menuItem.subtitle,
                            accent: draft.menuItem.accentColors
                        )

                        DraftSnapshotCard(draft: draft, showsCoupon: false)

                        SectionHeader("Spice")
                        chipRow(values: spiceOptions, selected: draft.spiceLevel) { level in
                            orderStore.setSpiceLevel(level)
                        }

                        SectionHeader("Rice")
                        chipRow(values: riceOptions, selected: draft.riceGrams, unit: "g") { grams in
                            orderStore.setRiceGrams(grams)
                        }

                        SectionHeader("Toppings", subtitle: "価格とサマリーに即時反映")

                        LazyVGrid(columns: toppingColumns, spacing: POCSpacing.s) {
                            ForEach(orderStore.toppings) { topping in
                                let isSelected = draft.toppings.contains(topping)
                                Button {
                                    orderStore.toggleTopping(topping)
                                } label: {
                                    VStack(alignment: .leading, spacing: POCSpacing.s) {
                                        Text(topping.name)
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(POCColor.textPrimary)
                                        Text("+\(topping.price.yenText)")
                                            .font(.subheadline)
                                            .foregroundStyle(POCColor.textSecondary)
                                        Spacer()
                                        Text(isSelected ? "Added" : "Add")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(isSelected ? Color.white : POCColor.curry)
                                            .padding(.horizontal, POCSpacing.xs)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule().fill(isSelected ? topping.accentColor : POCColor.background)
                                            )
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
                                    .padding(POCSpacing.m)
                                    .background(
                                        RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                                            .fill(isSelected ? topping.accentColor.opacity(0.2) : POCColor.elevated)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                                            .stroke(isSelected ? topping.accentColor : POCColor.line, lineWidth: 1)
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
                        SecondaryCTAButton(title: "Save Combo", systemImage: "star") {
                            navigator.showSheet(.saveFavorite)
                        }
                        PrimaryCTAButton(title: "Review \(draft.total.yenText)", systemImage: "arrow.right") {
                            navigator.push(.orderReview)
                        }
                    }
                    .padding(.horizontal, POCSpacing.l)
                    .padding(.top, POCSpacing.s)
                    .padding(.bottom, POCSpacing.s)
                    .background(.ultraThinMaterial)
                }
            } else {
                EmptyStateCard(title: "選択中の商品がありません", message: "メニュー一覧から商品を選んでください。")
                    .padding(POCSpacing.l)
            }
        }
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func chipRow(values: [Int], selected: Int, unit: String = "", action: @escaping (Int) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: POCSpacing.xs) {
                ForEach(values, id: \.self) { value in
                    FilterChip(title: unit.isEmpty ? "\(value)辛" : "\(value)\(unit)", isSelected: selected == value) {
                        action(value)
                    }
                }
            }
        }
    }
}

struct SavedCombosView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                SectionHeader("Saved Combos", subtitle: "いつもの注文を編集前提で再開します。")

                if orderStore.favoriteCombos.isEmpty {
                    EmptyStateCard(title: "保存済みの組み合わせはまだありません", message: "S3 か S5 の Save Combo から追加できます。")
                } else {
                    ForEach(orderStore.favoriteCombos) { favorite in
                        Button {
                            orderStore.resumeFavorite(favorite)
                            navigator.push(.curryDetail)
                        } label: {
                            VStack(alignment: .leading, spacing: POCSpacing.s) {
                                HStack {
                                    VStack(alignment: .leading, spacing: POCSpacing.xs) {
                                        Text(favorite.name)
                                            .font(.headline.weight(.semibold))
                                        Text(favorite.draft.menuItem.name)
                                            .font(.subheadline)
                                            .foregroundStyle(POCColor.textSecondary)
                                    }
                                    Spacer()
                                    Text(favorite.relativeLabel)
                                        .font(.caption)
                                        .foregroundStyle(POCColor.textTertiary)
                                }

                                Text("\(favorite.draft.spiceLevel)辛 / \(favorite.draft.riceGrams)g / \(favorite.draft.total.yenText)")
                                    .font(.subheadline.weight(.medium))

                                HStack {
                                    Text("この構成で再開")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(POCColor.curry)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .foregroundStyle(POCColor.curry)
                                }
                            }
                            .padding(POCSpacing.m)
                            .pocCard(fill: POCColor.elevated)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(POCSpacing.l)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Menu") {
                    navigator.popToMenuDiscovery()
                }
            }
        }
        .navigationTitle("Saved Combos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct OrderReviewView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        Group {
            if let draft = orderStore.draftOrder {
                ScrollView {
                    VStack(alignment: .leading, spacing: POCSpacing.l) {
                        SectionHeader("Pickup", subtitle: "受取店舗と受取目安を最後に確認します。")

                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SummaryRow(title: draft.store.name, value: draft.pickupWindowText)
                            Button("Change store") {
                                orderStore.resetForNextOrder(keepingStore: false)
                                navigator.resetToStoreSelect()
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(POCColor.curry)
                        }
                        .padding(POCSpacing.m)
                        .pocCard(fill: POCColor.elevated)

                        DraftSnapshotCard(draft: draft, showsCoupon: true)

                        if !orderStore.availableCoupons.isEmpty {
                            VStack(alignment: .leading, spacing: POCSpacing.s) {
                                Text("この注文に使えるクーポンがあります")
                                    .font(.headline.weight(.semibold))
                                Text(orderStore.availableCoupons[0].title)
                                    .font(.subheadline)
                                    .foregroundStyle(POCColor.textSecondary)
                                Button("View Coupon") {
                                    navigator.showSheet(.couponSuggestion)
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(POCColor.curry)
                            }
                            .padding(POCSpacing.m)
                            .pocCard(fill: POCColor.elevatedStrong)
                        }

                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("Price Summary")
                            SummaryRow(title: "Subtotal", value: draft.subtotal.yenText)
                            SummaryRow(title: "Coupon", value: draft.discount == 0 ? "-" : "-\(draft.discount.yenText)")
                            SummaryRow(title: "Total", value: draft.total.yenText)
                        }
                        .padding(POCSpacing.m)
                        .pocCard(fill: POCColor.elevatedStrong)

                        EmptyStateCard(
                            title: "Notes",
                            message: "mock order / native-only PoC"
                        )
                    }
                    .padding(POCSpacing.l)
                }
                .safeAreaInset(edge: .bottom) {
                    HStack(spacing: POCSpacing.s) {
                        SecondaryCTAButton(title: "Save Combo", systemImage: "star") {
                            navigator.showSheet(.saveFavorite)
                        }
                        PrimaryCTAButton(title: "Place Order \(draft.total.yenText)", systemImage: "checkmark") {
                            orderStore.placeOrder()
                            navigator.push(.orderComplete)
                        }
                    }
                    .padding(.horizontal, POCSpacing.l)
                    .padding(.top, POCSpacing.s)
                    .padding(.bottom, POCSpacing.s)
                    .background(.ultraThinMaterial)
                }
                .task {
                    if !orderStore.hasPresentedCouponSuggestion, !orderStore.availableCoupons.isEmpty {
                        orderStore.hasPresentedCouponSuggestion = true
                        navigator.showSheet(.couponSuggestion)
                    }
                }
            } else {
                EmptyStateCard(title: "注文内容がありません", message: "S3 から注文内容を作ってください。")
                    .padding(POCSpacing.l)
            }
        }
        .navigationTitle("Order Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Customize") {
                    navigator.pop()
                }
            }
        }
    }
}

struct OrderCompleteView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                if let completedOrder = orderStore.completedOrder {
                    HeroBanner(
                        eyebrow: "Done",
                        title: "Order Placed",
                        subtitle: "ご注文を受け付けました",
                        accent: [POCColor.success, POCColor.green]
                    )

                    VStack(alignment: .leading, spacing: POCSpacing.s) {
                        SectionHeader("Pickup Info")
                        SummaryRow(title: "Store", value: completedOrder.draft.store.name)
                        SummaryRow(title: "Time", value: completedOrder.pickupWindowText)
                        SummaryRow(title: "Ref", value: completedOrder.referenceID)
                    }
                    .padding(POCSpacing.m)
                    .pocCard(fill: POCColor.elevated)

                    DraftSnapshotCard(draft: completedOrder.draft, showsCoupon: true)

                    EmptyStateCard(
                        title: "Next",
                        message: "受取時間に店舗へお越しください。この PoC では注文番号はモック表示です。"
                    )

                    VStack(spacing: POCSpacing.s) {
                        PrimaryCTAButton(title: "Browse Menu Again", systemImage: "fork.knife") {
                            orderStore.resetForNextOrder(keepingStore: true)
                            navigator.popToMenuDiscovery()
                        }
                        SecondaryCTAButton(title: "View Saved Combos", systemImage: "clock") {
                            orderStore.resetForNextOrder(keepingStore: true)
                            navigator.goToSavedCombosFromCompletion()
                        }
                        SecondaryCTAButton(title: "Change Store", systemImage: "mappin.and.ellipse") {
                            orderStore.resetForNextOrder(keepingStore: false)
                            navigator.resetToStoreSelect()
                        }
                    }
                } else {
                    EmptyStateCard(title: "完了済みの注文がありません", message: "Order Review から注文を確定してください。")
                }
            }
            .padding(POCSpacing.l)
        }
        .navigationTitle("Order Complete")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CouponSuggestionSheet: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: POCSpacing.l) {
                    SectionHeader("Grab a Saving", subtitle: "この注文で使える候補だけを先に出します。")

                    if let draft = orderStore.draftOrder, let best = orderStore.availableCoupons.first {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            Text("Best Match")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(POCColor.textTertiary)
                            Text(best.title)
                                .font(.headline.weight(.semibold))
                            Text(best.summary)
                                .font(.subheadline)
                                .foregroundStyle(POCColor.textSecondary)
                            Text("この注文なら \(draft.subtotal.yenText) -> \(max(draft.subtotal - best.discount(for: draft), 0).yenText)")
                                .font(.subheadline.weight(.semibold))
                            PrimaryCTAButton(title: "Apply This Coupon", systemImage: "tag") {
                                orderStore.applyCoupon(best)
                                navigator.dismissSheet()
                            }
                        }
                        .padding(POCSpacing.m)
                        .pocCard(fill: POCColor.elevatedStrong)
                    }

                    if !orderStore.unavailableCoupons.isEmpty {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("More Options")
                            ForEach(orderStore.unavailableCoupons) { coupon in
                                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                                    Text(coupon.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text("今回は適用外")
                                        .font(.caption)
                                        .foregroundStyle(POCColor.textTertiary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(POCSpacing.m)
                                .pocCard(fill: POCColor.elevated.opacity(0.7))
                                .opacity(0.72)
                            }
                        }
                    }

                    SecondaryCTAButton(title: "Maybe Later", systemImage: "xmark") {
                        navigator.dismissSheet()
                    }
                }
                .padding(POCSpacing.l)
            }
            .navigationTitle("Coupon")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SaveFavoriteSheet: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var name = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                SectionHeader("Save Combo", subtitle: "気に入った構成を名前付きで保存します。")

                TextField("Name", text: $name)
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

                if let draft = orderStore.draftOrder {
                    DraftSnapshotCard(draft: draft, showsCoupon: false)
                } else {
                    EmptyStateCard(title: "保存できる注文がありません", message: "商品を選んでから再度開いてください。")
                }

                Spacer()

                HStack(spacing: POCSpacing.s) {
                    SecondaryCTAButton(title: "Cancel", systemImage: "xmark") {
                        navigator.dismissSheet()
                    }
                    PrimaryCTAButton(title: "Save", systemImage: "star.fill", isDisabled: orderStore.draftOrder == nil) {
                        orderStore.saveCurrentFavorite(named: name)
                        navigator.dismissSheet()
                    }
                }
            }
            .padding(POCSpacing.l)
            .navigationTitle("Save Favorite")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if name.isEmpty, let draft = orderStore.draftOrder {
                    name = draft.suggestedFavoriteName
                }
            }
        }
    }
}

struct DraftSnapshotCard: View {
    let draft: DraftOrder
    let showsCoupon: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Current Order")
            SummaryRow(title: "Base", value: draft.menuItem.name)
            SummaryRow(title: "Spice", value: "\(draft.spiceLevel)辛")
            SummaryRow(title: "Rice", value: "\(draft.riceGrams)g")
            SummaryRow(title: "Topping", value: draft.toppings.isEmpty ? "なし" : draft.toppings.map(\.name).joined(separator: " / "))
            if showsCoupon {
                SummaryRow(title: "Coupon", value: draft.appliedCoupon?.title ?? "-")
            }
            SummaryRow(title: "Total", value: draft.total.yenText)
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }
}
