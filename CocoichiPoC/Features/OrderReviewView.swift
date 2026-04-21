import SwiftUI

struct OrderReviewView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        Group {
            if orderStore.hasReviewItems {
                ScrollView {
                    VStack(alignment: .leading, spacing: POCSpacing.l) {
                        SectionHeader("Pickup")

                        if let store = orderStore.reviewStore {
                            VStack(alignment: .leading, spacing: POCSpacing.s) {
                                SummaryRow(title: store.name, value: store.pickupLeadTimeText)
                                Button("Change store") {
                                    orderStore.resetForNextOrder(keepingStore: false)
                                    navigator.resetToStoreSelect()
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(POCColor.curry)
                            }
                            .padding(POCSpacing.m)
                            .pocCard(fill: POCColor.elevated)
                        }

                        ReviewCartCard(
                            cartItems: orderStore.cartItems,
                            pendingItem: orderStore.pendingReviewLineItem
                        )

                        if let appliedCoupon = orderStore.appliedCoupon {
                            VStack(alignment: .leading, spacing: POCSpacing.s) {
                                SectionHeader("Applied Coupon")
                                Text(appliedCoupon.displayTitle)
                                    .font(.headline.weight(.semibold))
                                Text(appliedCoupon.displaySummary)
                                    .font(.subheadline)
                                    .foregroundStyle(POCColor.textSecondary)
                                Button("Remove") {
                                    orderStore.removeCoupon()
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(POCColor.curry)
                            }
                            .padding(POCSpacing.m)
                            .pocCard(fill: POCColor.elevatedStrong)
                        } else if let suggestedCoupon = orderStore.availableCoupons.first {
                            VStack(alignment: .leading, spacing: POCSpacing.s) {
                                Text("この注文に使えるクーポンがあります")
                                    .font(.headline.weight(.semibold))
                                Text(suggestedCoupon.displayTitle)
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
                            SummaryRow(title: "Subtotal", value: orderStore.reviewSubtotal.yenText)
                            SummaryRow(title: "Coupon", value: orderStore.reviewDiscount == 0 ? "-" : "-\(orderStore.reviewDiscount.yenText)")
                            SummaryRow(title: "Total", value: orderStore.reviewTotal.yenText)
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
                    ReviewFooterBar(
                        total: orderStore.reviewTotal,
                        isDisabled: !orderStore.hasReviewItems,
                        continueAction: continueOrdering,
                        confirmAction: confirmOrder
                    )
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
                Button("基本設定") {
                    navigator.popToCurryDetail()
                }
            }
        }
    }

    private func continueOrdering() {
        orderStore.moveCurrentDraftToCart()
        navigator.popToMenuDiscovery()
    }

    private func confirmOrder() {
        orderStore.placeOrder()
        navigator.push(.orderComplete)
    }
}

private struct ReviewCartCard: View {
    @EnvironmentObject private var navigator: AppNavigator

    let cartItems: [CartLineItem]
    let pendingItem: CartLineItem?

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Your Order")

            ForEach(Array(cartItems.enumerated()), id: \.element.id) { index, item in
                CartLineSummaryCard(
                    title: "\(index + 1)皿目",
                    draft: item.draft,
                    badgeText: "カート追加済み"
                )
            }

            if let pendingItem {
                CartLineSummaryCard(
                    title: cartItems.isEmpty ? "この注文" : "追加中の1皿",
                    draft: pendingItem.draft,
                    badgeText: "まだ調整に戻れます",
                    onChangeBasics: {
                        navigator.popToCurryDetail()
                    },
                    onChangeToppings: {
                        navigator.popToCurryToppings()
                    }
                )
            }
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }
}

private struct CartLineSummaryCard: View {
    let title: String
    let draft: DraftOrder
    let badgeText: String
    var onChangeBasics: (() -> Void)? = nil
    var onChangeToppings: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(badgeText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(POCColor.curry)
            }

            Text(draft.menuItem.name)
                .font(.headline.weight(.semibold))

            OrderDetailGroupRow(
                title: "ベース",
                value: baseSummary,
                action: onChangeBasics
            )

            OrderDetailGroupRow(
                title: "トッピング",
                value: toppingSummary,
                action: onChangeToppings
            )

            SummaryRow(title: "Line Total", value: draft.subtotal.yenText)
        }
        .padding(POCSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                .fill(POCColor.elevatedStrong)
        )
    }

    private var baseSummary: String {
        "\(draft.currySauce.rawValue) / \(draft.riceGrams)g / \(draft.spiceLevelText)"
    }

    private var toppingSummary: String {
        draft.toppings.isEmpty ? "なし" : draft.toppingsSummary
    }
}

private struct OrderDetailGroupRow: View {
    let title: String
    let value: String
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: POCSpacing.s) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)

                Spacer()

                if let action {
                    Button("変更") {
                        action()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(POCColor.curry)
                }
            }

            Text(value)
                .font(.subheadline)
                .foregroundStyle(POCColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(POCSpacing.s)
        .background(
            RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                .fill(POCColor.elevated.opacity(0.85))
        )
    }
}

private struct ReviewFooterBar: View {
    let total: Int
    let isDisabled: Bool
    let continueAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            VStack(alignment: .leading, spacing: POCSpacing.xxs) {
                Text("合計")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(POCColor.textSecondary)

                Text(total.yenText)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(POCColor.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(total)))
                    .animation(.snappy(duration: 0.28, extraBounce: 0), value: total)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            HStack(spacing: POCSpacing.s) {
                SecondaryCTAButton(title: "続けて注文", systemImage: "plus.circle", isDisabled: isDisabled) {
                    continueAction()
                }

                PrimaryCTAButton(title: "注文を確定", systemImage: "checkmark", isDisabled: isDisabled) {
                    confirmAction()
                }
            }
        }
        .padding(.horizontal, POCSpacing.l)
        .padding(.top, POCSpacing.xs)
        .padding(.bottom, POCSpacing.xs)
        .background(.ultraThinMaterial)
    }
}
