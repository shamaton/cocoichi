import SwiftUI
import UIKit

private enum CustomizationPhase: Int, CaseIterable, Identifiable {
    case basics
    case toppings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .basics:
            return "基本設定"
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
            return "Review Order"
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

    @State private var currentPhase: CustomizationPhase = .basics
    @State private var isSauceAmountExpanded = false
    @State private var heroMinY: CGFloat = 0
    @State private var riceArtworkTransitionDirection: RiceArtworkTransitionDirection = .increase

    private let riceOptions = RiceSelectionOption.all
    private let spiceOptions = [1, 2, 3, 4, 5]
    private let toppingColumns = [GridItem(.flexible(), spacing: POCSpacing.s), GridItem(.flexible(), spacing: POCSpacing.s)]

    var body: some View {
        Group {
            if let draft = orderStore.draftOrder {
                ScrollView {
                    VStack(alignment: .leading, spacing: POCSpacing.m) {
                        CurryDetailHeroCard(draft: draft, phase: currentPhase)
                            .background {
                                GeometryReader { proxy in
                                    Color.clear.preference(
                                        key: CurryDetailHeroMinYPreferenceKey.self,
                                        value: proxy.frame(in: .named("curryDetailScroll")).minY
                                    )
                                }
                            }

                        CustomizationPhaseSwitcher(currentPhase: currentPhase) { phase in
                            withAnimation(.snappy(duration: 0.28)) {
                                currentPhase = phase
                            }
                        }

                        VStack(alignment: .leading, spacing: POCSpacing.m) {
                            HStack(alignment: .top, spacing: POCSpacing.s) {
                                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                                    Text(currentPhase.title)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(POCColor.textPrimary)
                                    Text(currentPhase.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(POCColor.textSecondary)
                                }

                                Spacer(minLength: 0)

                                if currentPhase == .toppings {
                                    Button("基本設定へ戻る") {
                                        withAnimation(.snappy(duration: 0.28)) {
                                            currentPhase = .basics
                                        }
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(POCColor.curry)
                                }
                            }

                            phaseContent(for: draft)
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
                    CompactCurryDetailHeader(draft: draft, phase: currentPhase)
                        .padding(.horizontal, POCSpacing.l)
                        .padding(.top, POCSpacing.xs)
                        .opacity(showsCompactHeader ? 1 : 0)
                        .offset(y: showsCompactHeader ? 0 : -12)
                        .allowsHitTesting(false)
                }
                .animation(.snappy(duration: 0.24), value: showsCompactHeader)
                .safeAreaInset(edge: .bottom) {
                    HStack(spacing: POCSpacing.s) {
                        SecondaryCTAButton(title: "Save Combo", systemImage: "star") {
                            navigator.showSheet(.saveFavorite)
                        }
                        PrimaryCTAButton(
                            title: "\(currentPhase.actionTitle) \(draft.total.yenText)",
                            systemImage: currentPhase == .basics ? "arrow.right" : "cart"
                        ) {
                            if currentPhase == .basics {
                                withAnimation(.snappy(duration: 0.28)) {
                                    currentPhase = .toppings
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
                    currentPhase = .basics
                    isSauceAmountExpanded = false
                }
            } else {
                EmptyStateCard(title: "選択中の商品がありません", message: "メニュー一覧から商品を選んでください。")
                    .padding(POCSpacing.l)
            }
        }
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var showsCompactHeader: Bool {
        heroMinY < -96
    }

    @ViewBuilder
    private func phaseContent(for draft: DraftOrder) -> some View {
        switch currentPhase {
        case .basics:
            basicsContent(for: draft)
        case .toppings:
            toppingsContent(for: draft)
        }
    }

    @ViewBuilder
    private func basicsContent(for draft: DraftOrder) -> some View {
        VStack(alignment: .leading, spacing: POCSpacing.l) {
            VStack(alignment: .leading, spacing: POCSpacing.s) {
                SectionHeader("ソースを選ぶ", subtitle: "最初に味の軸を決めると、後の調整が迷いにくくなります。")
                VStack(spacing: POCSpacing.s) {
                    ForEach(CurrySauceOption.allCases, id: \.self) { sauce in
                        SauceFlavorCard(
                            sauce: sauce,
                            isSelected: draft.currySauce == sauce
                        ) {
                            orderStore.setCurrySauce(sauce)
                        }
                    }
                }
            }

            RicePortionCard(
                selectedOption: riceSelection(for: draft.riceGrams),
                options: riceOptions,
                currySauce: draft.currySauce,
                artworkTransitionDirection: riceArtworkTransitionDirection,
                onDecrease: { changeRiceSelection(by: -1, selected: draft.riceGrams) },
                onIncrease: { changeRiceSelection(by: 1, selected: draft.riceGrams) },
                onSelect: { option in
                    riceArtworkTransitionDirection = option.grams >= draft.riceGrams ? .increase : .decrease
                    orderStore.setRiceGrams(option.grams)
                }
            )

            SpiceLevelCard(
                selectedLevel: draft.spiceLevel,
                options: spiceOptions,
                onSelect: { level in
                    orderStore.setSpiceLevel(level)
                }
            )

            SauceAmountDisclosureCard(
                isExpanded: $isSauceAmountExpanded,
                selectedAmount: draft.sauceAmount
            ) { amount in
                orderStore.setSauceAmount(amount)
            }
        }
    }

    @ViewBuilder
    private func toppingsContent(for draft: DraftOrder) -> some View {
        VStack(alignment: .leading, spacing: POCSpacing.l) {
            if draft.toppings.isEmpty {
                EmptyStateCard(
                    title: "トッピングなしでも進めます",
                    message: "まずはベースの構成を保ったまま Review に進み、必要ならこの画面で追加してください。"
                )
            } else {
                VStack(alignment: .leading, spacing: POCSpacing.s) {
                    SectionHeader("Selected Toppings", subtitle: "外したい時はチップをタップします。")
                    FlexibleChipGroup(items: draft.toppings) { topping in
                        orderStore.toggleTopping(topping)
                    }
                }
            }

            if !recommendedToppings(for: draft).isEmpty {
                VStack(alignment: .leading, spacing: POCSpacing.s) {
                    SectionHeader("Recommended Toppings", subtitle: "このカレーと相性の良い候補を先に並べます。")
                    toppingGrid(recommendedToppings(for: draft), draft: draft)
                }
            }

            VStack(alignment: .leading, spacing: POCSpacing.s) {
                SectionHeader("More Toppings", subtitle: "定番の追加候補から広げられます。")
                toppingGrid(otherToppings(for: draft), draft: draft)
            }
        }
    }

    private func changeRiceSelection(by delta: Int, selected: Int) {
        let currentIndex = riceOptions.firstIndex(where: { $0.grams == selected }) ?? nearestRiceOptionIndex(for: selected)
        let nextIndex = min(max(currentIndex + delta, riceOptions.startIndex), riceOptions.index(before: riceOptions.endIndex))
        riceArtworkTransitionDirection = delta >= 0 ? .increase : .decrease
        orderStore.setRiceGrams(riceOptions[nextIndex].grams)
    }

    private func riceSelection(for grams: Int) -> RiceSelectionOption {
        riceOptions.first(where: { $0.grams == grams }) ?? riceOptions[nearestRiceOptionIndex(for: grams)]
    }

    private func nearestRiceOptionIndex(for grams: Int) -> Int {
        riceOptions.enumerated().min(by: {
            abs($0.element.grams - grams) < abs($1.element.grams - grams)
        })?.offset ?? riceOptions.startIndex
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
                        Spacer(minLength: 0)
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

private struct CurryDetailHeroCard: View {
    let draft: DraftOrder
    let phase: CustomizationPhase

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            artwork
                .frame(height: 216)
                .clipShape(RoundedRectangle(cornerRadius: POCRadius.hero, style: .continuous))

            LinearGradient(
                colors: [Color.black.opacity(0.02), Color.black.opacity(0.62)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: POCRadius.hero, style: .continuous))

            VStack(alignment: .leading, spacing: POCSpacing.xs) {
                Text(phase.eyebrow.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.84))

                Text(draft.store.name)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.white.opacity(0.92))

                Text(draft.menuItem.name)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(draft.menuItem.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.92))
                    .lineLimit(2)

                HStack(alignment: .lastTextBaseline, spacing: POCSpacing.s) {
                    Text(draft.total.yenText)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text(currentPriceCaption)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.84))
                }
            }
            .padding(POCSpacing.m)
        }
        .overlay(
            RoundedRectangle(cornerRadius: POCRadius.hero, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)
    }

    private var currentPriceCaption: String {
        draft.toppings.isEmpty && draft.currySauce.priceDelta == 0 && draft.ricePriceDelta == 0 && draft.sauceAmount.priceDelta == 0
            ? "ベース価格"
            : "選択内容を反映"
    }

    @ViewBuilder
    private var artwork: some View {
        if let uiImage = loadMenuImage() {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            LinearGradient(
                colors: draft.menuItem.accentColors + [POCColor.elevatedStrong],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func loadMenuImage() -> UIImage? {
        guard let imagePath = draft.menuItem.imagePath else { return nil }
        let resourcePath = imagePath as NSString
        let resourceName = resourcePath.deletingPathExtension
        let resourceExtension = resourcePath.pathExtension.isEmpty ? nil : resourcePath.pathExtension
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}

private struct CompactCurryDetailHeader: View {
    let draft: DraftOrder
    let phase: CustomizationPhase

    var body: some View {
        HStack(alignment: .center, spacing: POCSpacing.m) {
            VStack(alignment: .leading, spacing: 2) {
                Text(draft.menuItem.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                    .lineLimit(1)

                Text("\(draft.store.name) ・ \(phase.title)")
                    .font(.caption)
                    .foregroundStyle(POCColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                Text(draft.total.yenText)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(POCColor.textPrimary)

                Text("現在の合計")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(POCColor.textTertiary)
            }
        }
        .padding(.horizontal, POCSpacing.m)
        .padding(.vertical, POCSpacing.s)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                .stroke(POCColor.line, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 8)
    }
}

private struct CurryDetailHeroMinYPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct CustomizationPhaseSwitcher: View {
    let currentPhase: CustomizationPhase
    let onSelect: (CustomizationPhase) -> Void

    var body: some View {
        HStack(spacing: POCSpacing.xs) {
            ForEach(CustomizationPhase.allCases) { phase in
                Button {
                    onSelect(phase)
                } label: {
                    HStack(spacing: POCSpacing.s) {
                        Text("\(phase.rawValue + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(phase == currentPhase ? Color.white : POCColor.textPrimary)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(phase == currentPhase ? POCColor.curry : POCColor.elevated)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(phase.title)
                                .font(.subheadline.weight(.semibold))
                            Text(phase == .basics ? "ソース・ライス・辛さ" : "追加トッピング")
                                .font(.caption)
                                .foregroundStyle(phase == currentPhase ? POCColor.textPrimary.opacity(0.78) : POCColor.textTertiary)
                        }

                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(phase == currentPhase ? POCColor.textPrimary : POCColor.textSecondary)
                    .padding(.horizontal, POCSpacing.m)
                    .padding(.vertical, POCSpacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                            .fill(phase == currentPhase ? POCColor.elevatedStrong : POCColor.elevated)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                            .stroke(phase == currentPhase ? POCColor.curry.opacity(0.45) : POCColor.line, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct SauceFlavorCard: View {
    let sauce: CurrySauceOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GeometryReader { proxy in
                let leftPaneWidth = max(proxy.size.width * 0.43, 158)

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(sauce.cardTitle)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.74)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(sauce.priceBadgeTitle)
                                .font(.headline.weight(.heavy))
                                .foregroundStyle(sauce.accentColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)

                            if let badgeSubtitle = sauce.priceBadgeSubtitle {
                                Text(badgeSubtitle)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(POCColor.textSecondary)
                            }
                        }
                        .padding(.horizontal, POCSpacing.s)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white.opacity(0.96))
                        )

                        Text(sauce.subtitle)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Color.white.opacity(0.96))
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, POCSpacing.m)
                    .padding(.vertical, 12)
                    .frame(width: leftPaneWidth, height: proxy.size.height, alignment: .leading)
                    .background(sauce.accentColor)

                    artwork
                        .frame(width: proxy.size.width - leftPaneWidth, height: proxy.size.height)
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .stroke(isSelected ? sauce.accentColor : POCColor.line, lineWidth: isSelected ? 2 : 1)
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                        .fill(Color.black.opacity(0.42))
                        .overlay {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundStyle(.white)
                        }
                }
            }
            .shadow(color: Color.black.opacity(isSelected ? 0.12 : 0.06), radius: isSelected ? 18 : 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var artwork: some View {
        if let uiImage = loadSauceImage() {
            ZStack(alignment: .trailing) {
                sauce.accentColor

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            .overlay {
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .clipped()
        } else {
            LinearGradient(
                colors: [sauce.accentColor.opacity(0.32), POCColor.elevatedStrong],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func loadSauceImage() -> UIImage? {
        let resourcePath = sauce.imageName as NSString
        let resourceName = resourcePath.deletingPathExtension
        let resourceExtension = resourcePath.pathExtension.isEmpty ? nil : resourcePath.pathExtension
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}

private struct RicePortionCard: View {
    let selectedOption: RiceSelectionOption
    let options: [RiceSelectionOption]
    let currySauce: CurrySauceOption
    let artworkTransitionDirection: RiceArtworkTransitionDirection
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    let onSelect: (RiceSelectionOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("ライスの量", subtitle: "写真を見ながら量感を決めつつ、現在のソースに応じた差額を確認できます。")

            VStack(alignment: .leading, spacing: POCSpacing.m) {
                HStack {
                    RiceAdjustButton(symbol: "minus", isDisabled: selectedOption.grams == options.first?.grams, action: onDecrease)
                    Spacer()
                    VStack(spacing: POCSpacing.s) {
                        RiceArtworkCarousel(
                            selectedOption: selectedOption,
                            direction: artworkTransitionDirection
                        )

                        RicePriceLine(priceText: ricePriceDeltaText, font: .title3.weight(.bold))
                            .frame(width: 220, height: 34)
                    }
                    Spacer()
                    RiceAdjustButton(symbol: "plus", isDisabled: selectedOption.grams == options.last?.grams, action: onIncrease)
                }

                RiceSelectionStrip(
                    options: options,
                    selectedOption: selectedOption,
                    currySauce: currySauce,
                    onSelect: onSelect
                )
            }
            .padding(POCSpacing.m)
            .pocCard(fill: POCColor.elevated)
        }
    }

    private var ricePriceDelta: Int {
        currySauce.ricePriceDelta(for: selectedOption.grams)
    }

    private var ricePriceDeltaText: String {
        RiceSelectionOption.priceText(for: ricePriceDelta)
    }
}

private struct RiceSelectionStrip: View {
    let options: [RiceSelectionOption]
    let selectedOption: RiceSelectionOption
    let currySauce: CurrySauceOption
    let onSelect: (RiceSelectionOption) -> Void

    private let chipWidth: CGFloat = 100
    private let stripHeight: CGFloat = 112

    var body: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                let sideInset = max((geometry.size.width - chipWidth) / 2, 0)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: POCSpacing.xs) {
                        Color.clear
                            .frame(width: sideInset, height: 1)

                        ForEach(options, id: \.grams) { option in
                            RiceSelectionChip(
                                option: option,
                                currySauce: currySauce,
                                isSelected: selectedOption == option
                            ) {
                                onSelect(option)
                            }
                            .id(option.grams)
                        }

                        Color.clear
                            .frame(width: sideInset, height: 1)
                    }
                }
                .onAppear {
                    scrollToSelected(using: proxy)
                }
            }
            .frame(height: stripHeight)
        }
    }

    private func scrollToSelected(using proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            proxy.scrollTo(selectedOption.grams, anchor: .center)
        }
    }
}

private struct RiceArtworkCarousel: View {
    let selectedOption: RiceSelectionOption
    let direction: RiceArtworkTransitionDirection

    @State private var displayedOption: RiceSelectionOption
    @State private var incomingOption: RiceSelectionOption?
    @State private var displayedOffset: CGFloat = 0
    @State private var incomingOffset: CGFloat = 0
    @State private var animationVersion = 0

    private let artworkWidth: CGFloat = 208
    private let artworkHeight: CGFloat = 134
    private let slideDistance: CGFloat = 236
    private let animationDuration = 0.24

    init(selectedOption: RiceSelectionOption, direction: RiceArtworkTransitionDirection) {
        self.selectedOption = selectedOption
        self.direction = direction
        _displayedOption = State(initialValue: selectedOption)
    }

    var body: some View {
        ZStack {
            artworkView(for: displayedOption)
                .offset(x: displayedOffset)

            if let incomingOption {
                artworkView(for: incomingOption)
                    .offset(x: incomingOffset)
            }
        }
        .frame(width: artworkWidth, height: artworkHeight)
        .background(
            RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                .fill(POCColor.elevatedStrong)
        )
        .overlay(
            RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                .stroke(POCColor.line, lineWidth: 1)
        )
        .clipped()
        .onChange(of: selectedOption.grams, initial: false) { oldValue, newValue in
            guard oldValue != newValue else { return }
            startSlideTransition(to: selectedOption)
        }
    }

    private func artworkView(for option: RiceSelectionOption) -> some View {
        RicePortionArtwork(imageName: option.imageName, title: option.title)
            .overlay(alignment: .top) {
                RiceGramsBadge(title: option.title)
                    .padding(.top, POCSpacing.s)
            }
            .frame(width: artworkWidth, height: artworkHeight)
    }

    private func startSlideTransition(to nextOption: RiceSelectionOption) {
        if let currentIncomingOption = incomingOption {
            displayedOption = currentIncomingOption
            incomingOption = nil
            displayedOffset = 0
            incomingOffset = 0
        }

        animationVersion += 1
        let currentVersion = animationVersion

        incomingOption = nextOption
        displayedOffset = 0
        incomingOffset = direction.incomingOffset(distance: slideDistance)

        withAnimation(.snappy(duration: animationDuration, extraBounce: 0)) {
            displayedOffset = direction.outgoingOffset(distance: slideDistance)
            incomingOffset = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            guard animationVersion == currentVersion else { return }
            displayedOption = nextOption
            incomingOption = nil
            displayedOffset = 0
            incomingOffset = 0
        }
    }
}

private enum RiceArtworkTransitionDirection {
    case increase
    case decrease

    func outgoingOffset(distance: CGFloat) -> CGFloat {
        switch self {
        case .increase:
            return -distance
        case .decrease:
            return distance
        }
    }

    func incomingOffset(distance: CGFloat) -> CGFloat {
        switch self {
        case .increase:
            return distance
        case .decrease:
            return -distance
        }
    }
}

private struct RiceSelectionOption: Hashable {
    let grams: Int

    var title: String {
        "\(grams)g"
    }

    var imageName: String {
        "rice_\(grams).png"
    }

    func ricePriceDelta(for sauce: CurrySauceOption) -> Int {
        sauce.ricePriceDelta(for: grams)
    }

    func ricePriceText(for sauce: CurrySauceOption) -> String {
        Self.priceText(for: ricePriceDelta(for: sauce))
    }

    static func priceText(for priceDelta: Int) -> String {
        guard priceDelta != 0 else { return "基本価格" }
        return priceDelta > 0 ? "+\(priceDelta.yenText)" : "-\(abs(priceDelta).yenText)"
    }

    static let all: [RiceSelectionOption] = [150, 200, 250, 300, 350, 400, 500, 600, 700, 800].map(RiceSelectionOption.init)
}

private struct RicePortionArtwork: View {
    let imageName: String
    let title: String

    var body: some View {
        Group {
            if let uiImage = loadRiceImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, POCSpacing.s)
                    .padding(.vertical, POCSpacing.xs)
            } else {
                VStack(spacing: POCSpacing.xs) {
                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(POCColor.curry)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(POCColor.textSecondary)
                }
            }
        }
    }

    private func loadRiceImage() -> UIImage? {
        let resourcePath = imageName as NSString
        let resourceName = resourcePath.deletingPathExtension
        let resourceExtension = resourcePath.pathExtension.isEmpty ? nil : resourcePath.pathExtension
        let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension, subdirectory: "RiceImages")
            ?? Bundle.main.url(forResource: resourceName, withExtension: resourceExtension)
        guard let url else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}

private struct RiceSelectionChip: View {
    let option: RiceSelectionOption
    let currySauce: CurrySauceOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: POCSpacing.xs) {
                RicePortionArtwork(imageName: option.imageName, title: option.title)
                    .overlay(alignment: .top) {
                        RiceGramsBadge(title: option.title, compact: true)
                            .padding(.top, POCSpacing.xxs)
                    }
                    .frame(width: 84, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: POCRadius.chip, style: .continuous)
                            .fill(isSelected ? POCColor.cheese.opacity(0.2) : Color.white.opacity(0.55))
                    )

                RicePriceLine(priceText: option.ricePriceText(for: currySauce), font: .caption.weight(.semibold), isCompact: true)
                    .frame(width: 84, height: 18)
            }
            .padding(POCSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                    .fill(isSelected ? POCColor.cheese.opacity(0.3) : POCColor.elevatedStrong)
            )
            .overlay(
                RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                    .stroke(isSelected ? POCColor.cheese : POCColor.line, lineWidth: 1)
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                        .fill(Color.black.opacity(0.24))
                        .overlay {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.white)
                        }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct RiceGramsBadge: View {
    let title: String
    var compact = false

    var body: some View {
        Text(title)
            .font(compact ? .caption2.weight(.bold) : .subheadline.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(Color.white)
            .padding(.horizontal, compact ? POCSpacing.xs : POCSpacing.s)
            .padding(.vertical, compact ? 3 : 5)
            .background(Color.black.opacity(0.38), in: Capsule())
    }
}

private struct RicePriceLine: View {
    let priceText: String
    let font: Font
    var isCompact = false

    var body: some View {
        Text(priceText)
            .font(font)
            .monospacedDigit()
            .foregroundStyle(POCColor.curry)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

private struct SpiceLevelCard: View {
    let selectedLevel: Int
    let options: [Int]
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("辛さレベル", subtitle: "辛さは離散選択で迷いなく決められる見せ方を優先します。")

            VStack(alignment: .leading, spacing: POCSpacing.m) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(selectedLevel)辛")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(POCColor.red)
                        Text(spiceHint)
                            .font(.caption)
                            .foregroundStyle(POCColor.textSecondary)
                    }

                    Spacer()

                    Image(systemName: selectedLevel >= 4 ? "flame.fill" : "flame")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(POCColor.red)
                }

                HStack(spacing: POCSpacing.xs) {
                    ForEach(options, id: \.self) { level in
                        OptionChip(
                            title: "\(level)辛",
                            isSelected: selectedLevel == level,
                            selectedFill: POCColor.red,
                            selectedForeground: .white
                        ) {
                            onSelect(level)
                        }
                    }
                }
            }
            .padding(POCSpacing.m)
            .pocCard(fill: POCColor.elevated)
        }
    }

    private var spiceHint: String {
        selectedLevel >= 4 ? "辛さを前に出す設定です" : "食べやすさを保った設定です"
    }
}

private struct SauceAmountDisclosureCard: View {
    @Binding var isExpanded: Bool
    let selectedAmount: SauceAmountOption
    let onSelect: (SauceAmountOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            Button {
                withAnimation(.snappy(duration: 0.24)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: POCSpacing.s) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ソース量を調整")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(POCColor.textPrimary)
                        Text("必要な人だけが開いて微調整する補助設定です。")
                            .font(.caption)
                            .foregroundStyle(POCColor.textSecondary)
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(selectedAmount.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(POCColor.curry)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(POCColor.textTertiary)
                    }
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: POCSpacing.s) {
                    ForEach(SauceAmountOption.allCases, id: \.self) { amount in
                        SelectionCard(
                            title: amount.rawValue,
                            subtitle: amount.subtitle,
                            value: amount.priceDelta == 0 ? "追加料金なし" : "+\(amount.priceDelta.yenText)",
                            isSelected: selectedAmount == amount,
                            accent: amount.accentColor
                        ) {
                            onSelect(amount)
                        }
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }
}

private struct OptionChip: View {
    let title: String
    let isSelected: Bool
    let selectedFill: Color
    let selectedForeground: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? selectedForeground : POCColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, POCSpacing.s)
                .padding(.vertical, POCSpacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? selectedFill : POCColor.elevatedStrong)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? selectedFill : POCColor.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct RiceAdjustButton: View {
    let symbol: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.headline.weight(.bold))
                .foregroundStyle(isDisabled ? POCColor.textTertiary : POCColor.curry)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(POCColor.elevatedStrong)
                )
                .overlay(
                    Circle()
                        .stroke(POCColor.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
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
    var title = "Current Order"
    var subtitle: String? = nil
    var fillColor: Color = POCColor.elevated
    var showsStore = false
    var showsPickup = false
    var emphasizesTotal = false

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            HStack(alignment: .firstTextBaseline) {
                SectionHeader(title, subtitle: subtitle)
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
            SummaryRow(title: "Spice", value: "\(draft.spiceLevel)辛")
            SummaryRow(title: "Rice", value: "\(draft.riceGrams)g")
            SummaryRow(title: "Sauce Amount", value: draft.sauceAmount.rawValue)
            SummaryRow(title: "Topping", value: draft.toppings.isEmpty ? "なし" : draft.toppings.map(\.name).joined(separator: " / "))
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
