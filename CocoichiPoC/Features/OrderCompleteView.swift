import SwiftUI

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
                        accent: [POCColor.success, POCColor.green]
                    )

                    VStack(alignment: .leading, spacing: POCSpacing.s) {
                        SectionHeader("Pickup Info")
                        SummaryRow(title: "Store", value: completedOrder.store.name)
                        SummaryRow(title: "Time", value: completedOrder.pickupWindowText)
                        SummaryRow(title: "Ref", value: completedOrder.referenceID)
                    }
                    .padding(POCSpacing.m)
                    .pocCard(fill: POCColor.elevated)

                    CompletedOrderCard(order: completedOrder)

                    if let savedFavoriteName = orderStore.recentlySavedFavoriteName {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("Saved")
                            Text("「\(savedFavoriteName)」として保存しました。")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(POCColor.textPrimary)
                            Text("保存済みの組み合わせから次回すぐ再開できます。")
                                .font(.subheadline)
                                .foregroundStyle(POCColor.textSecondary)
                        }
                        .padding(POCSpacing.m)
                        .pocCard(fill: POCColor.elevatedStrong)
                    } else if let favoriteCandidate = orderStore.favoriteSaveCandidate {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("Save This Order")
                            Text("今回の1皿をいつもの候補に保存できます。")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(POCColor.textPrimary)
                            Text("\(favoriteCandidate.menuItem.name) / \(favoriteCandidate.spiceLevelText) / \(favoriteCandidate.riceGrams)g")
                                .font(.subheadline)
                                .foregroundStyle(POCColor.textSecondary)
                            SecondaryCTAButton(title: "保存する", systemImage: "star") {
                                navigator.showSheet(.saveFavorite)
                            }
                        }
                        .padding(POCSpacing.m)
                        .pocCard(fill: POCColor.elevated)
                    }

                    EmptyStateCard(
                        title: "Next",
                        message: "受取時間に店舗へお越しください。この PoC では注文番号はモック表示です。"
                    )

                    VStack(spacing: POCSpacing.s) {
                        PrimaryCTAButton(title: "もう一度メニューを見る", systemImage: "fork.knife") {
                            orderStore.resetForNextOrder(keepingStore: true)
                            navigator.popToMenuDiscovery()
                        }
                        SecondaryCTAButton(title: "保存済みを確認", systemImage: "clock") {
                            orderStore.resetForNextOrder(keepingStore: true)
                            navigator.goToSavedCombosFromCompletion()
                        }
                        SecondaryCTAButton(title: "店舗を変更", systemImage: "mappin.and.ellipse") {
                            orderStore.resetForNextOrder(keepingStore: false)
                            orderStore.clearPendingFavoriteResume()
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
                    SectionHeader("使えるクーポン")

                    if let best = orderStore.availableCoupons.first {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            Text("おすすめ")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(POCColor.textTertiary)
                            Text(best.displayTitle)
                                .font(.headline.weight(.semibold))
                            Text(best.displaySummary)
                                .font(.subheadline)
                                .foregroundStyle(POCColor.textSecondary)
                            Text("この注文なら \(orderStore.reviewSubtotal.yenText) -> \(orderStore.previewTotal(afterApplying: best).yenText)")
                                .font(.subheadline.weight(.semibold))
                            PrimaryCTAButton(title: "このクーポンを使う", systemImage: "tag") {
                                orderStore.applyCoupon(best)
                                navigator.dismissSheet()
                            }
                        }
                        .padding(POCSpacing.m)
                        .pocCard(fill: POCColor.elevatedStrong)
                    }

                    if !orderStore.unavailableCoupons.isEmpty {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("その他のクーポン")
                            ForEach(orderStore.unavailableCoupons) { coupon in
                                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                                    Text(coupon.displayTitle)
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

                    SecondaryCTAButton(title: "あとで", systemImage: "xmark") {
                        navigator.dismissSheet()
                    }
                }
                .padding(POCSpacing.l)
            }
            .navigationTitle("クーポン")
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
                SectionHeader("Save This Order")

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

                if let draft = orderStore.favoriteSaveCandidate {
                    DraftSnapshotCard(
                        draft: draft,
                        showsCoupon: false,
                        title: orderStore.completedOrder == nil ? "Current Order" : "今回の1皿"
                    )
                } else {
                    EmptyStateCard(title: "保存できる注文がありません", message: "商品を選んでから再度開いてください。")
                }

                Spacer()

                HStack(spacing: POCSpacing.s) {
                    SecondaryCTAButton(title: "キャンセル", systemImage: "xmark") {
                        navigator.dismissSheet()
                    }
                    PrimaryCTAButton(title: "保存する", systemImage: "star.fill", isDisabled: orderStore.favoriteSaveCandidate == nil) {
                        orderStore.saveFavorite(named: name)
                        navigator.dismissSheet()
                    }
                }
            }
            .padding(POCSpacing.l)
            .navigationTitle("Save Favorite")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if name.isEmpty, let draft = orderStore.favoriteSaveCandidate {
                    name = draft.suggestedFavoriteName
                }
            }
        }
    }
}

struct DraftSnapshotCard: View {
    let draft: DraftOrder
    let showsCoupon: Bool
    var title = "Current Order"
    var fillColor: Color = POCColor.elevated
    var showsStore = false
    var showsPickup = false
    var emphasizesTotal = false

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            HStack(alignment: .firstTextBaseline) {
                SectionHeader(title)
                if showsPickup {
                    Spacer(minLength: 0)
                    Text(draft.pickupWindowText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(POCColor.curry)
                }
            }
            if showsStore {
                SummaryRow(title: "Store", value: draft.store.name)
            }
            SummaryRow(title: "Base", value: draft.menuItem.name)
            SummaryRow(title: "Sauce", value: draft.currySauce.rawValue)
            SummaryRow(title: "Spice", value: draft.spiceLevelText)
            SummaryRow(title: "Rice", value: "\(draft.riceGrams)g")
            SummaryRow(title: "Sauce Amount", value: draft.sauceAmount.rawValue)
            SummaryRow(title: "Topping", value: draft.toppings.isEmpty ? "なし" : draft.toppingsSummary)
            if showsCoupon {
                SummaryRow(title: "Coupon", value: draft.appliedCoupon?.displayTitle ?? "-")
            }
            if emphasizesTotal {
                Divider()
                    .overlay(POCColor.line)

                HStack {
                    Text("Total")
                        .font(.headline.weight(.semibold))
                    Spacer()
                    PriceLabel(amount: draft.total, isDiscount: false)
                }
            } else {
                SummaryRow(title: "Total", value: draft.total.yenText)
            }
        }
        .padding(POCSpacing.m)
        .pocCard(fill: fillColor)
    }
}

private struct CompletedOrderCard: View {
    let order: CompletedOrder

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Your Order")
            ForEach(Array(order.cartItems.enumerated()), id: \.element.id) { index, item in
                SummaryRow(title: "\(index + 1)皿目", value: item.draft.menuItem.name)
                SummaryRow(title: "内容", value: "\(item.draft.spiceLevelText) / \(item.draft.riceGrams)g / \(item.draft.toppingsSummary)")
                SummaryRow(title: "小計", value: item.subtotal.yenText)
            }
            SummaryRow(title: "Coupon", value: order.appliedCoupon?.displayTitle ?? "-")
            SummaryRow(title: "Total", value: order.total.yenText)
            Text("レシートでは税区分の違いが分かる形で表示されますが、PoC では店内飲食とテイクアウトを同額で扱います。")
                .font(.caption)
                .foregroundStyle(POCColor.textTertiary)
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }
}
