import SwiftUI

struct OrderReviewView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        Group {
            if orderStore.hasReviewItems {
                ScrollView {
                    VStack(alignment: .leading, spacing: POCSpacing.l) {
                        SectionHeader("受取情報")

                        if let store = orderStore.reviewStore {
                            VStack(alignment: .leading, spacing: POCSpacing.s) {
                                SummaryRow(title: store.name, value: store.pickupLeadTimeText)
                            }
                            .padding(POCSpacing.m)
                            .pocCard(fill: POCColor.elevated)
                        }

                        ReviewCartCard(
                            lineItems: orderStore.reviewLineItems
                        )

                        if let appliedCoupon = orderStore.appliedCoupon {
                            VStack(alignment: .leading, spacing: POCSpacing.s) {
                                SectionHeader("適用中のクーポン")
                                Text(appliedCoupon.displayTitle.reviewCurrencyText)
                                    .font(.headline.weight(.semibold))
                                Text(appliedCoupon.displaySummary.reviewCurrencyText)
                                    .font(.subheadline)
                                    .foregroundStyle(POCColor.textSecondary)
                                Button("外す") {
                                    orderStore.removeCoupon()
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(POCColor.curry)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(POCSpacing.m)
                            .pocCard(fill: POCColor.elevatedStrong)
                        } else if let suggestedCoupon = orderStore.availableCoupons.first {
                            VStack(alignment: .leading, spacing: POCSpacing.s) {
                                Text("この注文に使えるクーポンがあります")
                                    .font(.headline.weight(.semibold))
                                Text(suggestedCoupon.displayTitle.reviewCurrencyText)
                                    .font(.subheadline)
                                    .foregroundStyle(POCColor.textSecondary)
                                Button("クーポンを見る") {
                                    navigator.showSheet(.couponSuggestion)
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(POCColor.curry)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(POCSpacing.m)
                            .pocCard(fill: POCColor.elevatedStrong)
                        }

                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("料金確認")
                            SummaryRow(title: "小計", value: orderStore.reviewSubtotal.reviewYenText)
                            SummaryRow(title: "クーポン", value: orderStore.reviewDiscount == 0 ? "-" : "-\(orderStore.reviewDiscount.reviewYenText)")
                            SummaryRow(title: "合計", value: orderStore.reviewTotal.reviewYenText)
                        }
                        .padding(POCSpacing.m)
                        .pocCard(fill: POCColor.elevatedStrong)
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
        .navigationTitle("ご注文内容の確認")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(orderStore.isDraftConfirmedForReview)
        .pocProgressWaveBackground(.review)
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
    @EnvironmentObject private var orderStore: OrderStore

    let lineItems: [ReviewLineItem]

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("ご注文内容の確認")

            ForEach(Array(lineItems.enumerated()), id: \.element.id) { index, item in
                CartLineSummaryCard(
                    draft: item.draft,
                    onChangeBasics: {
                        beginEditing(item, reviewIndex: index)
                        navigator.showCurryDetail()
                    },
                    onChangeToppings: {
                        beginEditing(item, reviewIndex: index)
                        navigator.showCurryToppings()
                    }
                )
            }
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }

    private func beginEditing(_ item: ReviewLineItem, reviewIndex: Int) {
        switch item.source {
        case let .cart(lineItemID):
            orderStore.beginEditingCartItem(lineItemID, reviewIndex: reviewIndex)
        case .pendingDraft:
            break
        }
    }
}

private struct CartLineSummaryCard: View {
    let draft: DraftOrder
    var onChangeBasics: (() -> Void)? = nil
    var onChangeToppings: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            HStack {
                Text(draft.menuItem.name)
                    .font(.headline.weight(.semibold))
                Spacer()
            }

            OrderDetailBulletGroup(
                title: "ベース",
                items: baseSummaryItems,
                action: onChangeBasics
            )

            OrderDetailBulletGroup(
                title: "トッピング",
                items: toppingSummaryItems,
                action: onChangeToppings
            )

            HStack {
                Spacer()

                Text(draft.subtotal.reviewYenText)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                    .monospacedDigit()
            }
        }
        .padding(POCSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                .fill(POCColor.elevatedStrong)
        )
    }

    private var baseSummaryItems: [String] {
        [
            draft.currySauce.rawValue,
            "ライス \(draft.riceGrams)g",
            "辛さ \(draft.spiceLevelText)"
        ]
    }

    private var toppingSummaryItems: [String] {
        draft.toppings.isEmpty ? ["なし"] : draft.toppingsSummary.components(separatedBy: " / ")
    }
}

private struct OrderDetailBulletGroup: View {
    let title: String
    let items: [String]
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

                Text(total.reviewYenText)
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

private extension Int {
    var reviewYenText: String {
        "￥\(formatted(.number.grouping(.automatic)))"
    }
}

private extension String {
    var reviewCurrencyText: String {
        guard let regex = try? NSRegularExpression(pattern: #"([0-9,]+)円"#) else { return self }
        let range = NSRange(startIndex..<endIndex, in: self)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "￥$1")
    }
}
