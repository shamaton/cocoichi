import SwiftUI

private enum CustomizationStep: Int, CaseIterable, Identifiable {
    case currySauce
    case rice
    case spice
    case sauceAmount
    case toppings
    case review

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .currySauce:
            return "カレーソース"
        case .rice:
            return "ライス量"
        case .spice:
            return "辛さ"
        case .sauceAmount:
            return "ソース量"
        case .toppings:
            return "追加トッピング"
        case .review:
            return "最終確認"
        }
    }

    var shortTitle: String {
        switch self {
        case .currySauce:
            return "ソース"
        case .rice:
            return "ライス"
        case .spice:
            return "辛さ"
        case .sauceAmount:
            return "量"
        case .toppings:
            return "トッピング"
        case .review:
            return "確認"
        }
    }

    var subtitle: String {
        switch self {
        case .currySauce:
            return "ベースの味わいを先に決めて、以後の調整を迷いにくくします。"
        case .rice:
            return "片手で決めやすい定番量を先頭に並べます。"
        case .spice:
            return "変化はすぐ価格とサマリーへ反映されます。"
        case .sauceAmount:
            return "最後の食べ心地を左右するので、ここで微調整します。"
        case .toppings:
            return "おすすめを先に見せつつ、追加はすぐ取り消せます。"
        case .review:
            return "今の構成を確認したら、そのまま Review へ進めます。"
        }
    }

    var actionTitle: String {
        self == .review ? "Review Order" : "Next"
    }

    var next: CustomizationStep? {
        CustomizationStep(rawValue: rawValue + 1)
    }

    var previous: CustomizationStep? {
        CustomizationStep(rawValue: rawValue - 1)
    }
}

struct CurryDetailView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var currentStep: CustomizationStep = .currySauce

    private let riceOptions = [200, 300, 400, 500]
    private let spiceOptions = [1, 2, 3, 4, 5]
    private let toppingColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Group {
            if let draft = orderStore.draftOrder {
                ScrollView {
                    VStack(alignment: .leading, spacing: POCSpacing.l) {
                        HeroBanner(
                            eyebrow: "Step \(currentStep.rawValue + 1) / \(CustomizationStep.allCases.count)",
                            title: draft.menuItem.name,
                            subtitle: "\(currentStep.title)を決める · \(draft.total.yenText)",
                            accent: draft.menuItem.accentColors
                        )

                        DraftSnapshotCard(draft: draft, showsCoupon: false)

                        CustomizationStepper(currentStep: currentStep) { step in
                            withAnimation(.snappy(duration: 0.28)) {
                                currentStep = step
                            }
                        }

                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            HStack(alignment: .center, spacing: POCSpacing.s) {
                                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                                    Text(currentStep.title)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(POCColor.textPrimary)
                                    Text(currentStep.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(POCColor.textSecondary)
                                }
                                if let previousStep = currentStep.previous {
                                    Spacer()
                                    Button("Back") {
                                        withAnimation(.snappy(duration: 0.28)) {
                                            currentStep = previousStep
                                        }
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(POCColor.curry)
                                }
                            }

                            stepContent(for: draft)
                        }
                    }
                    .padding(POCSpacing.l)
                }
                .safeAreaInset(edge: .bottom) {
                    HStack(spacing: POCSpacing.s) {
                        SecondaryCTAButton(title: "Save Combo", systemImage: "star") {
                            navigator.showSheet(.saveFavorite)
                        }
                        PrimaryCTAButton(title: "\(currentStep.actionTitle) \(draft.total.yenText)", systemImage: currentStep == .review ? "cart" : "arrow.right") {
                            if let nextStep = currentStep.next {
                                withAnimation(.snappy(duration: 0.28)) {
                                    currentStep = nextStep
                                }
                            } else {
                                navigator.push(.orderReview)
                            }
                        }
                    }
                    .padding(.horizontal, POCSpacing.l)
                    .padding(.top, POCSpacing.s)
                    .padding(.bottom, POCSpacing.s)
                    .background(.ultraThinMaterial)
                }
                .task(id: draft.id) {
                    currentStep = .currySauce
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

    @ViewBuilder
    private func stepContent(for draft: DraftOrder) -> some View {
        switch currentStep {
        case .currySauce:
            VStack(spacing: POCSpacing.s) {
                ForEach(CurrySauceOption.allCases, id: \.self) { sauce in
                    SelectionCard(
                        title: sauce.rawValue,
                        subtitle: sauce.subtitle,
                        value: sauce.priceDelta == 0 ? "追加料金なし" : "+\(sauce.priceDelta.yenText)",
                        isSelected: draft.currySauce == sauce,
                        accent: sauce.accentColor
                    ) {
                        orderStore.setCurrySauce(sauce)
                    }
                }
            }
        case .rice:
            VStack(alignment: .leading, spacing: POCSpacing.s) {
                chipRow(values: riceOptions, selected: draft.riceGrams, unit: "g") { grams in
                    orderStore.setRiceGrams(grams)
                }
                EmptyStateCard(
                    title: "Rice Hint",
                    message: draft.riceGrams >= 400 ? "がっつり寄りの構成です。最後のトッピング量も見ながら調整できます。" : "標準寄りの量です。後の辛さやトッピングを足しても重くなりすぎません。"
                )
            }
        case .spice:
            VStack(alignment: .leading, spacing: POCSpacing.s) {
                chipRow(values: spiceOptions, selected: draft.spiceLevel) { level in
                    orderStore.setSpiceLevel(level)
                }
                EmptyStateCard(
                    title: "Spice Balance",
                    message: draft.spiceLevel >= 4 ? "辛さを前に出す設定です。ソース量を多めにすると最後まで辛さが残ります。" : "食べやすさを保った設定です。トッピングの味も残りやすくなります。"
                )
            }
        case .sauceAmount:
            VStack(spacing: POCSpacing.s) {
                ForEach(SauceAmountOption.allCases, id: \.self) { amount in
                    SelectionCard(
                        title: amount.rawValue,
                        subtitle: amount.subtitle,
                        value: amount.priceDelta == 0 ? "追加料金なし" : "+\(amount.priceDelta.yenText)",
                        isSelected: draft.sauceAmount == amount,
                        accent: amount.accentColor
                    ) {
                        orderStore.setSauceAmount(amount)
                    }
                }
            }
        case .toppings:
            VStack(alignment: .leading, spacing: POCSpacing.m) {
                if !draft.toppings.isEmpty {
                    VStack(alignment: .leading, spacing: POCSpacing.s) {
                        Text("Selected Toppings")
                            .font(.headline.weight(.semibold))
                        FlexibleChipGroup(items: draft.toppings) { topping in
                            orderStore.toggleTopping(topping)
                        }
                    }
                }

                if !recommendedToppings(for: draft).isEmpty {
                    VStack(alignment: .leading, spacing: POCSpacing.s) {
                        Text("Recommended")
                            .font(.headline.weight(.semibold))
                        toppingGrid(recommendedToppings(for: draft), draft: draft)
                    }
                }

                VStack(alignment: .leading, spacing: POCSpacing.s) {
                    Text("More Toppings")
                        .font(.headline.weight(.semibold))
                    toppingGrid(otherToppings(for: draft), draft: draft)
                }
            }
        case .review:
            VStack(alignment: .leading, spacing: POCSpacing.m) {
                EmptyStateCard(
                    title: "Ready To Review",
                    message: "店舗、構成、価格がそろいました。必要なら stepper から前の工程へ戻って微調整できます。"
                )

                VStack(alignment: .leading, spacing: POCSpacing.s) {
                    Text("Review Highlights")
                        .font(.headline.weight(.semibold))
                    SummaryRow(title: "Store", value: draft.store.name)
                    SummaryRow(title: "Pickup", value: draft.pickupWindowText)
                    SummaryRow(title: "Sauce", value: draft.currySauce.rawValue)
                    SummaryRow(title: "Rice", value: "\(draft.riceGrams)g")
                    SummaryRow(title: "Spice", value: "\(draft.spiceLevel)辛")
                    SummaryRow(title: "Sauce Amount", value: draft.sauceAmount.rawValue)
                    SummaryRow(title: "Toppings", value: draft.toppings.isEmpty ? "なし" : draft.toppings.map(\.name).joined(separator: " / "))
                    SummaryRow(title: "Subtotal", value: draft.subtotal.yenText)
                }
                .padding(POCSpacing.m)
                .pocCard(fill: POCColor.elevatedStrong)
            }
        }
    }

    @ViewBuilder
    private func toppingGrid(_ toppings: [Topping], draft: DraftOrder) -> some View {
        LazyVGrid(columns: toppingColumns, spacing: POCSpacing.s) {
            ForEach(toppings) { topping in
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

    private func recommendedToppings(for draft: DraftOrder) -> [Topping] {
        let recommendedIDs = Set(draft.menuItem.recommendedToppingIDs)
        return orderStore.toppings.filter { recommendedIDs.contains($0.id) }
    }

    private func otherToppings(for draft: DraftOrder) -> [Topping] {
        let recommendedIDs = Set(draft.menuItem.recommendedToppingIDs)
        return orderStore.toppings.filter { !recommendedIDs.contains($0.id) }
    }
}

private struct CustomizationStepper: View {
    let currentStep: CustomizationStep
    let onSelect: (CustomizationStep) -> Void

    var body: some View {
        HStack(spacing: POCSpacing.xs) {
            ForEach(CustomizationStep.allCases) { step in
                Button {
                    onSelect(step)
                } label: {
                    VStack(spacing: POCSpacing.xs) {
                        Text("\(step.rawValue + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(step == currentStep ? Color.white : POCColor.textPrimary)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(step == currentStep ? POCColor.curry : POCColor.elevatedStrong)
                            )
                        Text(step.shortTitle)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(step == currentStep ? POCColor.curry : POCColor.textTertiary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, POCSpacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                            .fill(step == currentStep ? POCColor.elevatedStrong : POCColor.elevated.opacity(0.75))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct SelectionCard: View {
    let title: String
    let subtitle: String
    let value: String
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: POCSpacing.m) {
                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(POCColor.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: POCSpacing.xs) {
                    Text(value)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? accent : POCColor.textSecondary)
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? accent : POCColor.textTertiary)
                }
            }
            .padding(POCSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .fill(isSelected ? accent.opacity(0.14) : POCColor.elevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .stroke(isSelected ? accent : POCColor.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct FlexibleChipGroup: View {
    let items: [Topping]
    let onRemove: (Topping) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            ForEach(chunked(items, size: 2), id: \.self) { row in
                HStack(spacing: POCSpacing.xs) {
                    ForEach(row) { topping in
                        Button {
                            onRemove(topping)
                        } label: {
                            HStack(spacing: POCSpacing.xs) {
                                Text(topping.name)
                                Image(systemName: "xmark")
                                    .font(.caption.weight(.bold))
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(POCColor.textPrimary)
                            .padding(.horizontal, POCSpacing.s)
                            .padding(.vertical, POCSpacing.xs)
                            .background(
                                Capsule()
                                    .fill(topping.accentColor.opacity(0.18))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(topping.accentColor.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func chunked(_ toppings: [Topping], size: Int) -> [[Topping]] {
        stride(from: 0, to: toppings.count, by: size).map { index in
            Array(toppings[index..<min(index + size, toppings.count)])
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
            if orderStore.hasReviewItems {
                ScrollView {
                    VStack(alignment: .leading, spacing: POCSpacing.l) {
                        SectionHeader("Pickup", subtitle: "受取店舗と受取目安を最後に確認します。")

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
                            SectionHeader("Add More", subtitle: "1皿目を保ったまま、2皿目や追加メニューを探しに戻れます。")

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
                    HStack(spacing: POCSpacing.s) {
                        SecondaryCTAButton(title: "Save Combo", systemImage: "star") {
                            navigator.showSheet(.saveFavorite)
                        }
                        PrimaryCTAButton(title: "Place Order \(orderStore.reviewTotal.yenText)", systemImage: "checkmark", isDisabled: !orderStore.hasReviewItems) {
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
                        SummaryRow(title: "Store", value: completedOrder.store.name)
                        SummaryRow(title: "Time", value: completedOrder.pickupWindowText)
                        SummaryRow(title: "Ref", value: completedOrder.referenceID)
                    }
                    .padding(POCSpacing.m)
                    .pocCard(fill: POCColor.elevated)

                    CompletedOrderCard(order: completedOrder)

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

                    if let best = orderStore.availableCoupons.first {
                        VStack(alignment: .leading, spacing: POCSpacing.s) {
                            Text("Best Match")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(POCColor.textTertiary)
                            Text(best.displayTitle)
                                .font(.headline.weight(.semibold))
                            Text(best.displaySummary)
                                .font(.subheadline)
                                .foregroundStyle(POCColor.textSecondary)
                            Text("この注文なら \(orderStore.reviewSubtotal.yenText) -> \(orderStore.previewTotal(afterApplying: best).yenText)")
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
            SummaryRow(title: "Sauce", value: draft.currySauce.rawValue)
            SummaryRow(title: "Spice", value: "\(draft.spiceLevel)辛")
            SummaryRow(title: "Rice", value: "\(draft.riceGrams)g")
            SummaryRow(title: "Sauce Amount", value: draft.sauceAmount.rawValue)
            SummaryRow(title: "Topping", value: draft.toppings.isEmpty ? "なし" : draft.toppings.map(\.name).joined(separator: " / "))
            if showsCoupon {
                SummaryRow(title: "Coupon", value: draft.appliedCoupon?.displayTitle ?? "-")
            }
            SummaryRow(title: "Total", value: draft.total.yenText)
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
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
            Text("\(draft.spiceLevel)辛 / \(draft.riceGrams)g / \(draft.sauceAmount.rawValue)")
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

private struct CompletedOrderCard: View {
    let order: CompletedOrder

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Your Order")
            ForEach(Array(order.cartItems.enumerated()), id: \.element.id) { index, item in
                SummaryRow(title: "\(index + 1)皿目", value: item.draft.menuItem.name)
                SummaryRow(title: "内容", value: "\(item.draft.spiceLevel)辛 / \(item.draft.riceGrams)g / \(item.draft.toppings.isEmpty ? "トッピングなし" : item.draft.toppings.map(\.name).joined(separator: " / "))")
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
