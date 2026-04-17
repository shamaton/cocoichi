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
                        CurryDetailHeroCard(draft: draft, phase: .basics)
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
                    .padding(POCSpacing.l)
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
                        secondaryTitle: "トッピング",
                        secondarySystemImage: "arrow.right",
                        secondaryAction: showToppings,
                        primaryTitle: "注文確認",
                        primarySystemImage: "cart",
                        primaryAction: showOrderReview
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
        .navigationTitle("ソース・ライス・辛さ")
        .navigationBarTitleDisplayMode(.inline)
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
                        CurryDetailHeroCard(draft: draft, phase: .toppings)
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
                    .padding(POCSpacing.l)
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
                        secondaryTitle: "ベース設定",
                        secondarySystemImage: "arrow.uturn.backward",
                        secondaryAction: showBasics,
                        primaryTitle: "注文確認",
                        primarySystemImage: "cart",
                        primaryAction: showOrderReview
                    )
                }
            } else {
                EmptyStateCard(title: "選択中の商品がありません", message: "メニュー一覧から商品を選んでください。")
                    .padding(POCSpacing.l)
            }
        }
        .navigationTitle("トッピング")
        .navigationBarTitleDisplayMode(.inline)
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
}

private struct OrderFlowFooterBar: View {
    let total: Int
    let secondaryTitle: String
    let secondarySystemImage: String?
    let secondaryAction: () -> Void
    let primaryTitle: String
    let primarySystemImage: String?
    let primaryAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            Text(footerPriceText)
                .font(.title3.weight(.bold))
                .foregroundStyle(POCColor.textPrimary)
                .monospacedDigit()
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
        .padding(.top, POCSpacing.s)
        .padding(.bottom, POCSpacing.s)
        .background(.ultraThinMaterial)
    }

    private var footerPriceText: String {
        "￥\(total.formatted(.number.grouping(.automatic)))"
    }
}
