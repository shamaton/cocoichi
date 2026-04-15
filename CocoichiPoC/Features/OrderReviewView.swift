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
                            SectionHeader("Add More")

                            HStack(spacing: POCSpacing.s) {
                                SecondaryCTAButton(title: "2皿目のカレー", systemImage: "plus.circle") {
                                    orderStore.moveCurrentDraftToCart()
                                    navigator.popToMenuDiscovery()
                                }
                                SecondaryCTAButton(title: "サイドメニュー追加", systemImage: "takeoutbag.and.cup.and.straw") {
                                    orderStore.moveCurrentDraftToCart()
                                    navigator.popToMenuDiscovery()
                                }
                            }
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
                    PrimaryCTAButton(title: "注文する \(orderStore.reviewTotal.yenText)", systemImage: "checkmark", isDisabled: !orderStore.hasReviewItems) {
                        orderStore.placeOrder()
                        navigator.push(.orderComplete)
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

private struct ReviewCartCard: View {
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
                    badgeText: "まだ調整に戻れます"
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

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
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
            Text("\(draft.spiceLevelText) / \(draft.riceGrams)g / \(draft.sauceAmount.rawValue)")
                .font(.subheadline)
                .foregroundStyle(POCColor.textSecondary)
            Text(draft.toppings.isEmpty ? "トッピングなし" : draft.toppings.map(\.name).joined(separator: " / "))
                .font(.subheadline)
                .foregroundStyle(POCColor.textSecondary)
            SummaryRow(title: "Line Total", value: draft.subtotal.yenText)
        }
        .padding(POCSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                .fill(POCColor.elevatedStrong)
        )
    }
}
