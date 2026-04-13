import SwiftUI

private enum StoreSearchMethod: String, CaseIterable, Identifiable {
    case currentLocation
    case station
    case postalCode
    case storeName

    var id: String { rawValue }

    var title: String {
        switch self {
        case .currentLocation:
            return "現在地"
        case .station:
            return "駅名"
        case .postalCode:
            return "郵便番号"
        case .storeName:
            return "店名"
        }
    }

    var fieldTitle: String {
        switch self {
        case .currentLocation:
            return "現在地から探す"
        case .station:
            return "駅名から探す"
        case .postalCode:
            return "郵便番号から探す"
        case .storeName:
            return "店名で探す"
        }
    }

    var prompt: String {
        switch self {
        case .currentLocation:
            return "近くの店舗と受取目安を表示"
        case .station:
            return "渋谷 / 新宿 / 池袋 など"
        case .postalCode:
            return "150-0043 など"
        case .storeName:
            return "道玄坂 / 秋葉原 / 池袋東口 など"
        }
    }

    var systemImage: String {
        switch self {
        case .currentLocation:
            return "location"
        case .station:
            return "tram.fill"
        case .postalCode:
            return "mail"
        case .storeName:
            return "magnifyingglass"
        }
    }

    var searchPlaceholder: String {
        switch self {
        case .currentLocation:
            return "現在地から近い店舗を表示"
        case .station:
            return "駅名を入力"
        case .postalCode:
            return "郵便番号を入力"
        case .storeName:
            return "店名を入力"
        }
    }
}

struct StoreSelectView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var searchMethod: StoreSearchMethod = .currentLocation
    @State private var query = ""
    @State private var selectedCandidate: Store?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                header
                fulfillmentModeSwitcher

                if showsResetNotice {
                    resetNotice
                }

                if orderStore.selectedFulfillmentMode == .pickup {
                    if let selectedCandidate {
                        confirmationCard(for: selectedCandidate)
                    } else {
                        quickStartSection
                        searchMethodSection
                        searchResultsSection
                        recentlyUsedSection
                        savedCombosSection
                    }
                } else {
                    deliveryEntrySection
                    savedCombosSection
                }
            }
            .padding(POCSpacing.l)
            .padding(.bottom, 48)
        }
        .navigationTitle("受取先を選ぶ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let selectedStore = orderStore.selectedStore, selectedCandidate == nil {
                selectedCandidate = nil
                query = selectedStore.neighborhood
                searchMethod = .station
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            Text("受取先を選ぶ")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(POCColor.textPrimary)
            Text("注文前に、どこで受け取るかだけ決めます")
                .font(.subheadline)
                .foregroundStyle(POCColor.textSecondary)
        }
    }

    private var fulfillmentModeSwitcher: some View {
        HStack(spacing: POCSpacing.s) {
            modeChip(mode: .pickup)
            modeChip(mode: .delivery)
        }
    }

    private func modeChip(mode: FulfillmentMode) -> some View {
        Button {
            orderStore.selectedFulfillmentMode = mode
            selectedCandidate = nil
            if mode == .pickup {
                searchMethod = .currentLocation
            }
        } label: {
            Text(mode.label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(orderStore.selectedFulfillmentMode == mode ? Color.white : POCColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: POCRadius.cta, style: .continuous)
                        .fill(orderStore.selectedFulfillmentMode == mode ? POCColor.curry : POCColor.elevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: POCRadius.cta, style: .continuous)
                        .stroke(POCColor.line, lineWidth: orderStore.selectedFulfillmentMode == mode ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var resetNotice: some View {
        VStack(alignment: .leading, spacing: POCSpacing.xs) {
            Text("店舗を変更すると現在の注文内容はリセットされます")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(POCColor.red)
            Text("カート、追加中の1皿、適用クーポンを破棄して新しい受取先に切り替えます。")
                .font(.caption)
                .foregroundStyle(POCColor.textSecondary)
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevatedStrong)
    }

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Quick Start")
            ForEach(StoreSearchMethod.allCases) { method in
                Button {
                    searchMethod = method
                    if method == .currentLocation {
                        query = ""
                    }
                } label: {
                    HStack(alignment: .top, spacing: POCSpacing.s) {
                        Image(systemName: method.systemImage)
                            .font(.headline)
                            .foregroundStyle(POCColor.curry)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: POCSpacing.xs) {
                            Text(method.fieldTitle)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(POCColor.textPrimary)
                            Text(method.prompt)
                                .font(.subheadline)
                                .foregroundStyle(POCColor.textSecondary)
                        }

                        Spacer()

                        if searchMethod == method {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(POCColor.curry)
                        }
                    }
                    .padding(POCSpacing.m)
                    .pocCard(fill: searchMethod == method ? POCColor.elevatedStrong : POCColor.elevated)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var searchMethodSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Search Method")

            if searchMethod != .currentLocation {
                HStack(spacing: POCSpacing.xs) {
                    ForEach([StoreSearchMethod.station, .postalCode, .storeName]) { method in
                        FilterChip(title: method.title, isSelected: searchMethod == method) {
                            searchMethod = method
                            query = ""
                        }
                    }
                }

                TextField(searchMethod.searchPlaceholder, text: $query)
                    .textInputAutocapitalization(.never)
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
            } else {
                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                    Text("Current Location")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)
                    Text("位置情報を取得できない場合も、手入力検索で続けられます。")
                        .font(.subheadline)
                        .foregroundStyle(POCColor.textSecondary)
                }
                .padding(POCSpacing.m)
                .pocCard(fill: POCColor.elevated)
            }
        }
    }

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            SectionHeader("Search Results")
            if filteredStores.isEmpty {
                EmptyStateCard(
                    title: "候補が見つかりません",
                    message: "検索方法を変えるか、店名や駅名を短くして試してください。"
                )
            } else {
                ForEach(filteredStores) { store in
                    storeRow(store)
                }
            }
        }
    }

    private var recentlyUsedSection: some View {
        Group {
            if !recentStores.isEmpty {
                VStack(alignment: .leading, spacing: POCSpacing.s) {
                    SectionHeader("Recently Used")
                    ForEach(recentStores) { store in
                        storeRow(store)
                    }
                }
            }
        }
    }

    private var deliveryEntrySection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.l) {
            VStack(alignment: .leading, spacing: POCSpacing.s) {
                Text("まず配達先エリアを選びます")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                Text("詳細な配送条件は PoC では広げすぎず、入口のわかりやすさだけ確認します。")
                    .font(.subheadline)
                    .foregroundStyle(POCColor.textSecondary)
            }
            .padding(POCSpacing.m)
            .pocCard(fill: POCColor.elevated)

            SecondaryCTAButton(title: "郵便番号から探す", systemImage: "mail") {
                query = ""
            }

            SecondaryCTAButton(title: "住所キーワードで探す", systemImage: "magnifyingglass") {
                query = ""
            }

            EmptyStateCard(
                title: "Delivery Note",
                message: "配達可否や時間は仮表示でもよいが、次に何が起きるかは明確に伝える。"
            )
        }
    }

    private var savedCombosSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            if orderStore.favoriteCombos.isEmpty {
                EmptyStateCard(
                    title: "保存済みの組み合わせはまだありません",
                    message: "商品を選んだ後に Save Combo から追加できます。"
                )
            } else {
                SecondaryCTAButton(title: "保存済みから始める", systemImage: "clock.arrow.trianglehead.counterclockwise") {
                    navigator.push(.savedCombos)
                }
            }
        }
    }

    private func confirmationCard(for store: Store) -> some View {
        VStack(alignment: .leading, spacing: POCSpacing.l) {
            SectionHeader("この店舗で始めますか？")

            VStack(alignment: .leading, spacing: POCSpacing.s) {
                Text(store.name)
                    .font(.headline.weight(.semibold))
                Text(store.address)
                    .font(.subheadline)
                    .foregroundStyle(POCColor.textSecondary)
                SummaryRow(title: "受取目安", value: store.pickupLeadTimeText)
                SummaryRow(title: "受取方法", value: orderStore.selectedFulfillmentMode.label)
            }
            .padding(POCSpacing.m)
            .pocCard(fill: POCColor.elevatedStrong)

            VStack(alignment: .leading, spacing: POCSpacing.xs) {
                Text("Next")
                    .font(.headline.weight(.semibold))
                Text("この店舗のメニューと限定商品を表示します。")
                    .font(.subheadline)
                    .foregroundStyle(POCColor.textSecondary)
            }

            PrimaryCTAButton(title: "この店舗でメニューを見る", systemImage: "arrow.right") {
                confirmStore(store)
            }
            SecondaryCTAButton(title: "保存済みから始める", systemImage: "clock") {
                confirmStore(store)
                navigator.push(.savedCombos)
            }
            SecondaryCTAButton(title: "別の店舗を探す", systemImage: "arrow.uturn.left") {
                selectedCandidate = nil
            }
        }
    }

    private func storeRow(_ store: Store) -> some View {
        Button {
            selectedCandidate = store
        } label: {
            VStack(alignment: .leading, spacing: POCSpacing.s) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: POCSpacing.xs) {
                        Text(store.name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(POCColor.textPrimary)
                        Text(store.address)
                            .font(.caption)
                            .foregroundStyle(POCColor.textSecondary)
                    }
                    Spacer()
                    Text(store.pickupLeadTimeText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(POCColor.curry)
                }

                HStack {
                    Text("この店舗で始める")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.footnote.weight(.bold))
                }
                .foregroundStyle(POCColor.curry)
            }
            .padding(POCSpacing.m)
            .pocCard(fill: POCColor.elevated)
        }
        .buttonStyle(.plain)
    }

    private func confirmStore(_ store: Store) {
        if orderStore.selectedStore?.id != store.id, orderStore.hasReviewItems {
            orderStore.resetForNextOrder(keepingStore: false)
        }
        orderStore.selectStore(store)
        navigator.completeStoreSelection()
    }

    private var filteredStores: [Store] {
        switch searchMethod {
        case .currentLocation:
            return orderStore.stores.sorted {
                $0.pickupLeadTimeMin < $1.pickupLeadTimeMin
            }
        case .station:
            return matchingStores { store in
                [store.neighborhood, store.address]
            }
        case .postalCode:
            return matchingStores { store in
                [store.address]
            }
        case .storeName:
            return matchingStores { store in
                [store.name, store.neighborhood]
            }
        }
    }

    private func matchingStores(_ values: (Store) -> [String]) -> [Store] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return orderStore.stores }
        return orderStore.stores.filter { store in
            values(store)
                .joined(separator: " ")
                .localizedCaseInsensitiveContains(normalizedQuery)
        }
    }

    private var recentStores: [Store] {
        var seenIDs = Set<String>()
        let stores = ([orderStore.selectedStore] + orderStore.favoriteCombos.map(\.draft.store)).compactMap { $0 }
        return stores.filter { store in
            seenIDs.insert(store.id).inserted
        }
    }

    private var showsResetNotice: Bool {
        orderStore.selectedStore != nil || orderStore.hasReviewItems
    }
}
