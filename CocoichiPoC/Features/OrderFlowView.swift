import SwiftUI

enum CustomizationPhase: Int, CaseIterable, Identifiable {
    case basics
    case toppings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .basics:
            return "ソース・ライス・辛さ"
        case .toppings:
            return "トッピング"
        }
    }

    var subtitle: String {
        switch self {
        case .basics:
            return "ソース、ライス、辛さを一画面で決めてから先へ進みます。"
        case .toppings:
            return "おすすめを先に見せつつ、追加はすぐ取り消せる状態で選びます。"
        }
    }

    var actionTitle: String {
        switch self {
        case .basics:
            return "トッピングへ進む"
        case .toppings:
            return "注文内容を確認"
        }
    }

    var eyebrow: String {
        switch self {
        case .basics:
            return "Phase 1 / 2"
        case .toppings:
            return "Phase 2 / 2"
        }
    }
}

struct CurryDetailView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var isSauceAmountExpanded = false
    @State private var heroMinY: CGFloat = 0
    @State private var riceArtworkTransitionDirection: RiceArtworkTransitionDirection = .increase
    @State private var spiceArtworkTransitionDirection: SpiceArtworkTransitionDirection = .increase

    var body: some View {
        Group {
            if let draft = orderStore.draftOrder {
                ScrollView {
                    VStack(alignment: .leading, spacing: POCSpacing.m) {
                        CurryDetailHeroCard(draft: draft)
                            .padding(.horizontal, -POCSpacing.l)
                            .background {
                                GeometryReader { proxy in
                                    Color.clear.preference(
                                        key: CurryDetailHeroMinYPreferenceKey.self,
                                        value: proxy.frame(in: .named("curryDetailScroll")).minY
                                    )
                                }
                            }

                        VStack(alignment: .leading, spacing: POCSpacing.m) {
                            CurryBasicsContent(
                                draft: draft,
                                isSauceAmountExpanded: $isSauceAmountExpanded,
                                riceArtworkTransitionDirection: $riceArtworkTransitionDirection,
                                spiceArtworkTransitionDirection: $spiceArtworkTransitionDirection
                            )
                        }
                    }
                    .padding(.horizontal, POCSpacing.l)
                    .padding(.top, 0)
                    .padding(.bottom, POCSpacing.xl)
                }
                .coordinateSpace(name: "curryDetailScroll")
                .onPreferenceChange(CurryDetailHeroMinYPreferenceKey.self) { value in
                    heroMinY = value
                }
                .overlay(alignment: .top) {
                    CompactCurryDetailHeader(draft: draft, phase: .basics)
                        .padding(.horizontal, POCSpacing.l)
                        .padding(.top, POCSpacing.xs)
                        .opacity(showsCompactHeader ? 1 : 0)
                        .offset(y: showsCompactHeader ? 0 : -12)
                        .allowsHitTesting(false)
                }
                .animation(.snappy(duration: 0.24), value: showsCompactHeader)
                .safeAreaInset(edge: .bottom) {
                    OrderFlowFooterBar(
                        total: draft.total,
                        summaryItems: [],
                        secondaryTitle: "トッピング",
                        secondarySystemImage: "arrow.right",
                        secondaryAction: showToppings,
                        primaryTitle: "決定する",
                        primarySystemImage: "checkmark.circle.fill",
                        primaryAction: confirmDraft
                    )
                }
                .task(id: draft.id) {
                    isSauceAmountExpanded = false
                }
            } else {
                EmptyStateCard(title: "選択中の商品がありません", message: "メニュー一覧から商品を選んでください。")
                    .padding(POCSpacing.l)
            }
        }
        .navigationTitle(orderStore.draftOrder?.menuItem.name ?? "カレー")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(orderStore.isDraftConfirmedForReview)
    }

    private var showsCompactHeader: Bool {
        heroMinY < -96
    }

    private func showToppings() {
        guard navigator.path.last != .curryToppings else { return }
        navigator.push(.curryToppings)
    }

    private func showOrderReview() {
        guard navigator.path.last != .orderReview else { return }
        navigator.push(.orderReview)
    }

    private func confirmDraft() {
        orderStore.confirmCurrentDraftForReview()
        showOrderReview()
    }
}

struct CurryToppingsView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var heroMinY: CGFloat = 0

    var body: some View {
        Group {
            if let draft = orderStore.draftOrder {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: POCSpacing.m, pinnedViews: [.sectionHeaders]) {
                        CurryDetailHeroCard(draft: draft)
                            .padding(.horizontal, -POCSpacing.l)
                            .background {
                                GeometryReader { proxy in
                                    Color.clear.preference(
                                        key: CurryDetailHeroMinYPreferenceKey.self,
                                        value: proxy.frame(in: .named("curryToppingsScroll")).minY
                                    )
                                }
                            }

                        VStack(alignment: .leading, spacing: POCSpacing.m) {
                            CurryToppingsContent(draft: draft)
                        }

                        CurryToppingSectionList(draft: draft)
                    }
                    .padding(.horizontal, POCSpacing.l)
                    .padding(.top, 0)
                    .padding(.bottom, POCSpacing.xl)
                }
                .coordinateSpace(name: "curryToppingsScroll")
                .onPreferenceChange(CurryDetailHeroMinYPreferenceKey.self) { value in
                    heroMinY = value
                }
                .overlay(alignment: .top) {
                    CompactCurryDetailHeader(draft: draft, phase: .toppings)
                        .padding(.horizontal, POCSpacing.l)
                        .padding(.top, POCSpacing.xs)
                        .opacity(showsCompactHeader ? 1 : 0)
                        .offset(y: showsCompactHeader ? 0 : -12)
                        .allowsHitTesting(false)
                }
                .animation(.snappy(duration: 0.24), value: showsCompactHeader)
                .safeAreaInset(edge: .bottom) {
                    OrderFlowFooterBar(
                        total: draft.total,
                        summaryItems: draft.toppingSelections,
                        secondaryTitle: "ベース設定",
                        secondarySystemImage: "arrow.uturn.backward",
                        secondaryAction: showBasics,
                        primaryTitle: "決定する",
                        primarySystemImage: "checkmark.circle.fill",
                        primaryAction: confirmDraft
                    )
                }
            } else {
                EmptyStateCard(title: "選択中の商品がありません", message: "メニュー一覧から商品を選んでください。")
                    .padding(POCSpacing.l)
            }
        }
        .navigationTitle(orderStore.draftOrder?.menuItem.name ?? "カレー")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(orderStore.isDraftConfirmedForReview)
    }

    private var showsCompactHeader: Bool {
        heroMinY < -96
    }

    private func showBasics() {
        navigator.popToCurryDetail()
    }

    private func showOrderReview() {
        guard navigator.path.last != .orderReview else { return }
        navigator.push(.orderReview)
    }

    private func confirmDraft() {
        orderStore.confirmCurrentDraftForReview()
        showOrderReview()
    }
}

private struct OrderFlowFooterBar: View {
    let total: Int
    let summaryItems: [DraftToppingSelection]
    let secondaryTitle: String
    let secondarySystemImage: String?
    let secondaryAction: () -> Void
    let primaryTitle: String
    let primarySystemImage: String?
    let primaryAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            if !summaryItems.isEmpty {
                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                    Text("選択中のトッピング")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(POCColor.textSecondary)

                    if usesScrollableSummary {
                        ScrollView(.vertical, showsIndicators: true) {
                            summaryItemList
                        }
                        .frame(height: summaryContentHeight)
                    } else {
                        summaryItemList
                    }
                }
                .padding(.horizontal, POCSpacing.m)
                .padding(.vertical, POCSpacing.xs)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                        .fill(Color.white.opacity(0.58))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                        .stroke(POCColor.line, lineWidth: 1)
                )
            }

            Text(footerPriceText)
                .font(.title3.weight(.bold))
                .foregroundStyle(POCColor.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(total)))
                .animation(.snappy(duration: 0.28, extraBounce: 0), value: total)
                .padding(.trailing, POCSpacing.xs)
                .frame(maxWidth: .infinity, alignment: .trailing)

            HStack(spacing: POCSpacing.s) {
                SecondaryCTAButton(title: secondaryTitle, systemImage: secondarySystemImage) {
                    secondaryAction()
                }

                PrimaryCTAButton(title: primaryTitle, systemImage: primarySystemImage) {
                    primaryAction()
                }
            }
        }
        .padding(.horizontal, POCSpacing.l)
        .padding(.top, POCSpacing.xs)
        .padding(.bottom, POCSpacing.xs)
        .background(.ultraThinMaterial)
    }

    private var footerPriceText: String {
        "￥\(total.formatted(.number.grouping(.automatic)))"
    }

    private var usesScrollableSummary: Bool {
        summaryItems.count >= FooterLayout.scrollActivationCount
    }

    private var summaryContentHeight: CGFloat {
        let visibleRowCount = min(summaryItems.count, FooterLayout.maxVisibleRows)
        let rowCount = CGFloat(visibleRowCount)
        let spacingCount = CGFloat(max(visibleRowCount - 1, 0))
        let baseHeight = rowCount * FooterLayout.summaryRowHeight + spacingCount * POCSpacing.xs
        if usesScrollableSummary {
            return baseHeight + FooterLayout.summaryPeekHeight
        }
        return baseHeight
    }

    private var summaryItemList: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            ForEach(summaryItems) { item in
                HStack(alignment: .firstTextBaseline, spacing: POCSpacing.s) {
                    Text(item.summaryLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text(summaryPriceText(for: item.subtotal))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(POCColor.textSecondary)
                        .monospacedDigit()
                }
            }
        }
    }

    private func summaryPriceText(for amount: Int) -> String {
        "+￥\(amount.formatted(.number.grouping(.automatic)))"
    }
}

private enum FooterLayout {
    static let summaryRowHeight: CGFloat = 20
    static let maxVisibleRows = 3
    static let scrollActivationCount = 4
    static let summaryPeekHeight: CGFloat = 12
}
