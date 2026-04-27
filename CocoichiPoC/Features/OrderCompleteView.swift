import SwiftUI

struct OrderCompleteView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                if let completedOrder = orderStore.completedOrder {
                    HeroBanner(
                        eyebrow: "注文完了",
                        title: "ご注文を受け付けました",
                        accent: [POCColor.success, POCColor.green]
                    )

                    VStack(alignment: .leading, spacing: POCSpacing.s) {
                        SectionHeader("受取情報")
                        SummaryRow(title: "店舗", value: completedOrder.store.name)
                        SummaryRow(title: "受取時間", value: completedOrder.pickupWindowText)
                        SummaryRow(title: "受付番号", value: completedOrder.referenceID)
                    }
                    .padding(POCSpacing.m)
                    .pocCard(fill: POCColor.elevated)

                    CompletedOrderCard(order: completedOrder)

                    if let savedFavoriteName = orderStore.recentlySavedFavoriteName {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            SectionHeader("保存しました")
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
                            SectionHeader("いつもの候補に保存")
                            Text("今回の1皿をいつもの候補に保存できます。")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(POCColor.textPrimary)
                            Text("\(favoriteCandidate.menuItem.name)・\(favoriteCandidate.spiceLevelText)・ライス \(favoriteCandidate.riceGrams)g")
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
                        title: "次にすること",
                        message: "受取時間に店舗へお越しください。この試作版では受付番号を仮表示しています。"
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
                    EmptyStateCard(title: "完了済みの注文がありません", message: "注文確認から注文を確定してください。")
                }
            }
            .padding(POCSpacing.l)
        }
        .navigationTitle("注文完了")
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
                            Text("この注文なら \(orderStore.reviewSubtotal.yenText) → \(orderStore.previewTotal(afterApplying: best).yenText)")
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
                SectionHeader("お気に入りに保存")

                TextField("名前", text: $name)
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
                        title: orderStore.completedOrder == nil ? "現在の注文" : "今回の1皿"
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
            .navigationTitle("お気に入り保存")
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
    var title = "この注文"
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
                SummaryRow(title: "店舗", value: draft.store.name)
            }
            SummaryRow(title: "商品", value: draft.menuItem.name)
            SummaryRow(title: "カレーソース", value: draft.currySauce.rawValue)
            SummaryRow(title: "辛さ", value: draft.spiceLevelText)
            SummaryRow(title: "ライス", value: "\(draft.riceGrams)g")
            SummaryRow(title: "ソース量", value: draft.sauceAmount.rawValue)
            SummaryRow(title: "トッピング", value: draft.toppings.isEmpty ? "なし" : draft.toppingsSummary)
            if showsCoupon {
                SummaryRow(title: "クーポン", value: draft.appliedCoupon?.displayTitle ?? "-")
            }
            if emphasizesTotal {
                Divider()
                    .overlay(POCColor.line)

                HStack {
                    Text("合計")
                        .font(.headline.weight(.semibold))
                    Spacer()
                    PriceLabel(amount: draft.total, isDiscount: false)
                }
            } else {
                SummaryRow(title: "合計", value: draft.total.yenText)
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
            SectionHeader("ご注文内容の確認")
            ForEach(Array(order.cartItems.enumerated()), id: \.element.id) { index, item in
                CompletedOrderLineCard(index: index, item: item)
            }

            VStack(alignment: .leading, spacing: POCSpacing.s) {
                SectionHeader("料金確認")
                SummaryRow(title: "小計", value: order.subtotal.completeYenText)
                SummaryRow(title: "クーポン", value: order.discount == 0 ? "-" : "-\(order.discount.completeYenText)")
                SummaryRow(title: "合計", value: order.total.completeYenText)
            }
            .padding(.top, POCSpacing.xs)

            if let appliedCoupon = order.appliedCoupon {
                Text("適用中のクーポン：\(appliedCoupon.displayTitle.completeCurrencyText)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(POCColor.textSecondary)
            }

            Text("レシートでは税区分の違いが分かる形で表示されますが、この試作版では店内飲食とテイクアウトを同額で扱います。")
                .font(.caption)
                .foregroundStyle(POCColor.textTertiary)
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }
}

private struct CompletedOrderLineCard: View {
    let index: Int
    let item: CartLineItem

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(index + 1)皿目")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(POCColor.textTertiary)

                Spacer()

                Text(item.subtotal.completeYenText)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                    .monospacedDigit()
            }

            Text(item.draft.menuItem.name)
                .font(.headline.weight(.semibold))
                .foregroundStyle(POCColor.textPrimary)

            CompletedOrderDetailGroup(
                title: "ベース",
                items: [
                    item.draft.currySauce.rawValue,
                    "ライス \(item.draft.riceGrams)g",
                    "辛さ \(item.draft.spiceLevelText)"
                ]
            )

            CompletedOrderDetailGroup(
                title: "トッピング",
                items: item.draft.toppings.isEmpty ? ["なし"] : item.draft.toppingsSummary.components(separatedBy: " / ")
            )
        }
        .padding(POCSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                .fill(POCColor.elevatedStrong)
        )
    }
}

private struct CompletedOrderDetailGroup: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(POCColor.textPrimary)

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

private extension Int {
    var completeYenText: String {
        "￥\(formatted(.number.grouping(.automatic)))"
    }
}

private extension String {
    var completeCurrencyText: String {
        guard let regex = try? NSRegularExpression(pattern: #"([0-9,]+)円"#) else { return self }
        let range = NSRange(startIndex..<endIndex, in: self)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "￥$1")
    }
}
