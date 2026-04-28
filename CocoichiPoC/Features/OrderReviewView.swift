import SwiftUI

struct OrderReviewView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore
    @State private var pendingDeletion: PendingDeletion?

    var body: some View {
        ZStack {
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
                                lineItems: orderStore.reviewLineItems,
                                onDelete: { item, reviewIndex in
                                    pendingDeletion = PendingDeletion(item: item, reviewIndex: reviewIndex)
                                }
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
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .allowsHitTesting(pendingDeletion == nil)

            if let pendingDeletion {
                ReviewDeleteConfirmationOverlay(
                    pendingDeletion: pendingDeletion,
                    isDeletingLastItem: orderStore.reviewLineItems.count == 1,
                    cancelAction: { self.pendingDeletion = nil },
                    confirmAction: { confirmDeletion(pendingDeletion) }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .zIndex(1)
            }
        }
        .animation(.snappy(duration: 0.22, extraBounce: 0), value: pendingDeletion != nil)
        .task(id: orderStore.hasReviewItems) {
            guard !orderStore.hasReviewItems else { return }
            navigator.dismissSheet()
            navigator.popToMenuDiscovery()
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

    private func confirmDeletion(_ pendingDeletion: PendingDeletion) {
        orderStore.removeReviewItem(pendingDeletion.item, reviewIndex: pendingDeletion.reviewIndex)
        self.pendingDeletion = nil
    }
}

private struct ReviewCartCard: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    let lineItems: [ReviewLineItem]
    let onDelete: (ReviewLineItem, Int) -> Void

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
                    },
                    onDelete: {
                        onDelete(item, index)
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

private struct PendingDeletion {
    let item: ReviewLineItem
    let reviewIndex: Int
}

private struct ReviewDeleteConfirmationOverlay: View {
    let pendingDeletion: PendingDeletion
    let isDeletingLastItem: Bool
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.42)
                .ignoresSafeArea()
                .onTapGesture {
                    cancelAction()
                }

            VStack(alignment: .leading, spacing: POCSpacing.m) {
                Text("この商品を削除しますか？")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)

                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                    Text(pendingDeletion.item.draft.menuItem.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)

                    Text("ご注文内容から外します。")
                        .font(.subheadline)
                        .foregroundStyle(POCColor.textSecondary)
                }

                if isDeletingLastItem {
                    Label("最後の1件を削除すると、メニュー選択に戻ります。", systemImage: "info.circle")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(POCColor.textSecondary)
                        .padding(POCSpacing.s)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                                .fill(POCColor.elevatedStrong)
                        )
                }

                HStack(spacing: POCSpacing.s) {
                    SecondaryCTAButton(title: "キャンセル", systemImage: nil) {
                        cancelAction()
                    }

                    DestructiveCTAButton(title: "削除する", systemImage: "trash") {
                        confirmAction()
                    }
                }
            }
            .padding(POCSpacing.l)
            .frame(maxWidth: 360, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .fill(POCColor.elevated)
                    .shadow(color: Color.black.opacity(0.12), radius: 24, y: 12)
            )
            .padding(.horizontal, POCSpacing.l)
        }
    }
}

private struct DestructiveCTAButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: POCSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.headline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(Color.white)
            .background(
                RoundedRectangle(cornerRadius: POCRadius.cta, style: .continuous)
                    .fill(POCColor.red)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct CartLineSummaryCard: View {
    let draft: DraftOrder
    var onChangeBasics: (() -> Void)? = nil
    var onChangeToppings: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

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
                if let onDelete {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("削除", systemImage: "trash")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(POCColor.red)
                }

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

struct OrderDetailBulletGroup: View {
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
