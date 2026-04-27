import MapKit
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
            return "近くの店舗と受取目安をすぐ見つけます"
        case .station:
            return "名駅 / 栄 / 金山 など"
        case .postalCode:
            return "450-0002 など"
        case .storeName:
            return "広小路 / 錦通 / 金山南口 など"
        }
    }

    var systemImage: String {
        switch self {
        case .currentLocation:
            return "location.fill"
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
            return "店舗を検索"
        case .station:
            return "駅名を入力"
        case .postalCode:
            return "郵便番号を入力"
        case .storeName:
            return "店舗名を入力"
        }
    }
}

private enum StoreListTab: String, CaseIterable, Identifiable {
    case all
    case frequent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "店舗一覧"
        case .frequent:
            return "よく使う店舗"
        }
    }
}

struct StoreSelectView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    @State private var searchMethod: StoreSearchMethod = .currentLocation
    @State private var selectedListTab: StoreListTab = .all
    @State private var query = ""
    @State private var pendingStoreChange: Store?
    @State private var isShowingSearchFilters = false
    @State private var focusedStoreID: Store.ID?
    @State private var mapCameraPosition: MapCameraPosition = .region(StoreSelectView.defaultMapRegion)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                header
                fulfillmentModeSwitcher

                if orderStore.selectedFulfillmentMode == .pickup {
                    searchBarSection
                    if isShowingSearchFilters {
                        searchFilterSection
                    }
                    mapSection
                    storeTabSection
                    storeListSection
                    savedCombosSection
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    navigator.dismissStoreSelect()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(POCColor.textPrimary)
                .accessibilityLabel("閉じる")
            }
        }
        .onAppear {
            if let selectedStore = orderStore.selectedStore {
                focusedStoreID = selectedStore.id
            } else if let firstStore = filteredStores.first {
                focusedStoreID = firstStore.id
            }
            recenterMap(for: mapStores, preferredStoreID: focusedStoreID)
        }
        .onChange(of: searchMethod) {
            if searchMethod == .currentLocation {
                query = ""
            }
            syncFocusedStore()
            recenterMap(for: mapStores, preferredStoreID: focusedStoreID)
        }
        .onChange(of: query) {
            syncFocusedStore()
            recenterMap(for: mapStores, preferredStoreID: focusedStoreID)
        }
        .onChange(of: selectedListTab) {
            syncFocusedStore()
        }
        .onChange(of: orderStore.selectedStore?.id) {
            focusedStoreID = orderStore.selectedStore?.id ?? activeStores.first?.id
            recenterMap(for: mapStores, preferredStoreID: focusedStoreID)
        }
        .alert("店舗を変更しますか？", isPresented: isShowingStoreChangeAlert, presenting: pendingStoreChange) { store in
            Button("キャンセル", role: .cancel) {
                pendingStoreChange = nil
            }
            Button("変更する", role: .destructive) {
                pendingStoreChange = nil
                commitStoreSelection(store, resetsOrder: true)
            }
        } message: { _ in
            Text("現在のご注文内容はリセットされます。")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            HStack(alignment: .top, spacing: POCSpacing.s) {
                if let selectedStore = orderStore.selectedStore {
                    VStack(alignment: .trailing, spacing: POCSpacing.xxs) {
                        Text("現在の店舗")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(POCColor.textTertiary)
                        Text(selectedStore.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(POCColor.curry)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: POCSpacing.xs) {
                infoBadge(title: mapHeaderTitle, systemImage: mapHeaderSymbol, tint: POCColor.cheese)
                infoBadge(title: "\(filteredStores.count)店舗", systemImage: "fork.knife.circle", tint: POCColor.elevatedStrong)
            }
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

    private var searchBarSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            HStack(spacing: POCSpacing.s) {
                HStack(spacing: POCSpacing.s) {
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                        .foregroundStyle(POCColor.textTertiary)

                    TextField(searchMethod.searchPlaceholder, text: $query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .font(.body)
                        .foregroundStyle(POCColor.textPrimary)
                }
                .padding(.horizontal, POCSpacing.m)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                        .fill(Color.white.opacity(0.78))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                        .stroke(POCColor.line, lineWidth: 1)
                )

                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        isShowingSearchFilters.toggle()
                    }
                } label: {
                    HStack(spacing: POCSpacing.xs) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.headline)
                        Text("絞り込み")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(POCColor.textPrimary)
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
                }
                .buttonStyle(.plain)
            }

            Text(searchMethod.fieldTitle)
                .font(.caption.weight(.medium))
                .foregroundStyle(POCColor.textSecondary)
        }
    }

    private var searchFilterSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: POCSpacing.xs) {
                    ForEach(StoreSearchMethod.allCases) { method in
                        methodFilterChip(method)
                    }
                }
                .padding(.vertical, 1)
            }

            HStack(alignment: .center, spacing: POCSpacing.s) {
                Image(systemName: searchMethod.systemImage)
                    .font(.headline)
                    .foregroundStyle(POCColor.curry)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(POCColor.cream.opacity(0.65))
                    )

                VStack(alignment: .leading, spacing: POCSpacing.xxs) {
                    Text(searchMethod.prompt)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)
                    Text(searchMethodHint)
                        .font(.caption)
                        .foregroundStyle(POCColor.textSecondary)
                }

                Spacer()
            }
            .padding(POCSpacing.m)
            .pocCard(fill: POCColor.elevated)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func methodFilterChip(_ method: StoreSearchMethod) -> some View {
        Button {
            searchMethod = method
        } label: {
            HStack(spacing: POCSpacing.xs) {
                Image(systemName: method.systemImage)
                    .font(.caption.weight(.semibold))
                Text(method.title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(searchMethod == method ? POCColor.textPrimary : POCColor.textSecondary)
            .padding(.horizontal, POCSpacing.s)
            .padding(.vertical, POCSpacing.xs)
            .background(
                Capsule()
                    .fill(searchMethod == method ? POCColor.cheese : POCColor.elevated)
            )
            .overlay(
                Capsule()
                    .stroke(searchMethod == method ? POCColor.cheese : POCColor.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            HStack(alignment: .center) {
                SectionHeader("地図から選ぶ")
                Spacer()
                if let focusedStore = focusedStore {
                    Text(focusedStore.pickupLeadTimeText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(POCColor.curry)
                }
            }

            ZStack(alignment: .topLeading) {
                Map(position: $mapCameraPosition) {
                    ForEach(mapStores) { store in
                        Annotation(store.name, coordinate: coordinate(for: store), anchor: .bottom) {
                            Button {
                                focusedStoreID = store.id
                                recenterMap(for: mapStores, preferredStoreID: store.id)
                            } label: {
                                mapMarker(for: store)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .mapStyle(.standard)
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: POCRadius.hero, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: POCRadius.hero, style: .continuous)
                        .stroke(POCColor.line, lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: POCSpacing.s) {
                    infoBadge(title: mapHeaderTitle, systemImage: mapHeaderSymbol, tint: .white.opacity(0.92))
                    if searchMethod == .currentLocation {
                        infoBadge(title: "位置情報がなくても手入力に切替可能", systemImage: "hand.tap", tint: .white.opacity(0.86))
                    }
                }
                .padding(POCSpacing.m)
            }
            .overlay(alignment: .bottomLeading) {
                if let focusedStore = focusedStore {
                    mapFocusedStoreCard(store: focusedStore)
                        .padding(POCSpacing.m)
                }
            }
        }
    }

    private func mapMarker(for store: Store) -> some View {
        let isFocused = focusedStoreID == store.id
        let isSelectedStore = orderStore.selectedStore?.id == store.id

        return VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(isFocused ? POCColor.curry : Color.white)
                    .frame(width: isFocused ? 34 : 28, height: isFocused ? 34 : 28)
                Image(systemName: isSelectedStore ? "checkmark.circle.fill" : "fork.knife")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isFocused ? Color.white : POCColor.curry)
            }
            .overlay(
                Circle()
                    .stroke(POCColor.curry.opacity(isFocused ? 0 : 0.35), lineWidth: 1.5)
            )

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(isFocused ? POCColor.curry : Color.white)
                .frame(width: 4, height: 8)
        }
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
        .scaleEffect(isFocused ? 1 : 0.94)
    }

    private func mapFocusedStoreCard(store: Store) -> some View {
        HStack(alignment: .center, spacing: POCSpacing.s) {
            VStack(alignment: .leading, spacing: POCSpacing.xxs) {
                Text(store.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                Text(store.address)
                    .font(.caption)
                    .foregroundStyle(POCColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: POCSpacing.s)

            VStack(alignment: .trailing, spacing: POCSpacing.xxs) {
                Text(distanceText(for: store))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(POCColor.textPrimary)
                Text("受取 \(store.pickupLeadTimeText)")
                    .font(.caption)
                    .foregroundStyle(POCColor.curry)
            }
        }
        .padding(.horizontal, POCSpacing.m)
        .padding(.vertical, POCSpacing.s)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 8)
    }

    private var storeTabSection: some View {
        HStack(spacing: POCSpacing.xs) {
            ForEach(StoreListTab.allCases) { tab in
                Button {
                    selectedListTab = tab
                } label: {
                    Text(tab.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(selectedListTab == tab ? POCColor.textPrimary : POCColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: POCRadius.field, style: .continuous)
                                .fill(selectedListTab == tab ? Color.white : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(POCSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                .fill(POCColor.elevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                .stroke(POCColor.line, lineWidth: 1)
        )
    }

    private var storeListSection: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            if activeStores.isEmpty {
                EmptyStateCard(
                    title: selectedListTab == .all ? "候補が見つかりません" : "よく使う店舗はまだありません",
                    message: selectedListTab == .all
                        ? "検索方法を変えるか、駅名や店名を短くして試してください。"
                        : "注文完了や保存済みの組み合わせから、ここに再訪しやすい店舗が並びます。"
                )
            } else {
                ForEach(activeStores) { store in
                    storeRow(store)
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
            SectionHeader("再開ショートカット")

            if orderStore.favoriteCombos.isEmpty {
                EmptyStateCard(
                    title: "保存済みの組み合わせはまだありません",
                    message: "注文完了後に保存すると、次回ここからすぐ再開できます。"
                )
            } else {
                SecondaryCTAButton(title: "保存済みから始める", systemImage: "clock.arrow.trianglehead.counterclockwise") {
                    navigator.push(.savedCombos)
                }
            }
        }
    }

    private func storeRow(_ store: Store) -> some View {
        let isFocused = focusedStoreID == store.id
        let isSelected = orderStore.selectedStore?.id == store.id
        let isFrequent = frequentStores.contains(store)
        let hasLimitedMenu = storeHasLimitedMenu(store)

        return Button {
            handleStoreSelection(store)
        } label: {
            HStack(alignment: .top, spacing: POCSpacing.s) {
                ZStack(alignment: .topLeading) {
                    Image("shop_icon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 92, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Text(distanceText(for: store))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(POCColor.textPrimary)
                        .padding(.horizontal, POCSpacing.xs)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.9), in: Capsule())
                        .padding(POCSpacing.xs)
                }

                VStack(alignment: .leading, spacing: POCSpacing.xs) {
                    HStack(alignment: .top, spacing: POCSpacing.s) {
                        VStack(alignment: .leading, spacing: POCSpacing.xxs) {
                            Text(store.name)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(POCColor.textPrimary)

                            if isSelected {
                                Text("現在選択中")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(POCColor.curry)
                            } else {
                                Text(store.neighborhood)
                                    .font(.caption)
                                    .foregroundStyle(POCColor.textSecondary)
                            }
                        }

                        Spacer(minLength: POCSpacing.s)

                        Image(systemName: isFocused ? "location.fill" : "location")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isFocused ? POCColor.curry : POCColor.textTertiary)
                    }

                    HStack(spacing: POCSpacing.xs) {
                        storeMetaPill(title: "受取 \(store.pickupLeadTimeText)", tint: POCColor.cream)

                        if hasLimitedMenu {
                            storeMetaPill(title: "限定あり", tint: POCColor.elevatedStrong)
                        }

                        if isFrequent {
                            storeMetaPill(title: "よく使う", tint: Color.white)
                        }
                    }

                    Text(store.address)
                        .font(.caption)
                        .foregroundStyle(POCColor.textSecondary)
                        .lineLimit(2)

                    HStack {
                        Text(isSelected ? "選択済み" : "この店舗で始める")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "arrow.right")
                            .font(.footnote.weight(.bold))
                    }
                    .foregroundStyle(isSelected ? POCColor.textTertiary : POCColor.curry)
                }
            }
            .padding(POCSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .fill(cardBackground(isFocused: isFocused, isSelected: isSelected))
            )
            .overlay(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .stroke(isFocused ? POCColor.curry.opacity(0.28) : POCColor.line, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(isFocused ? 0.08 : 0.05), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(isSelected)
        .opacity(isSelected ? 0.82 : 1)
        .accessibilityHint(isSelected ? "現在選択中のため選べません" : "この店舗を選択します")
        .simultaneousGesture(
            TapGesture().onEnded {
                focusedStoreID = store.id
            }
        )
    }

    private func cardBackground(isFocused: Bool, isSelected: Bool) -> some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [POCColor.elevatedStrong, Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        if isFocused {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.white, POCColor.elevated],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        return AnyShapeStyle(POCColor.elevated)
    }

    private func storeMetaPill(title: String, tint: Color) -> some View {
        Text(title)
            .font(.caption.weight(.medium))
            .foregroundStyle(POCColor.textPrimary)
            .padding(.horizontal, POCSpacing.xs)
            .padding(.vertical, 5)
            .background(tint, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(POCColor.line.opacity(0.65), lineWidth: 1)
            )
    }

    private func infoBadge(title: String, systemImage: String, tint: Color) -> some View {
        HStack(spacing: POCSpacing.xs) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
            Text(title)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(POCColor.textPrimary)
        .padding(.horizontal, POCSpacing.s)
        .padding(.vertical, POCSpacing.xs)
        .background(tint, in: Capsule())
    }

    private var isShowingStoreChangeAlert: Binding<Bool> {
        Binding(
            get: { pendingStoreChange != nil },
            set: { isPresented in
                if !isPresented {
                    pendingStoreChange = nil
                }
            }
        )
    }

    private func handleStoreSelection(_ store: Store) {
        guard orderStore.selectedStore?.id != store.id else { return }
        if shouldConfirmStoreChange(to: store) {
            pendingStoreChange = store
            return
        }
        commitStoreSelection(store, resetsOrder: false)
    }

    private func shouldConfirmStoreChange(to store: Store) -> Bool {
        guard orderStore.selectedStore?.id != store.id else { return false }
        return orderStore.selectedStore != nil && orderStore.hasReviewItems
    }

    private func commitStoreSelection(_ store: Store, resetsOrder: Bool) {
        let hadPendingMenuSelection = orderStore.hasPendingMenuSelection
        if resetsOrder {
            orderStore.resetForNextOrder(keepingStore: false)
        }
        orderStore.selectStore(store)
        orderStore.completePendingFavoriteResumeIfNeeded(using: store)
        let startedPendingMenu = orderStore.completePendingMenuSelectionIfNeeded(using: store)
        if hadPendingMenuSelection && !startedPendingMenu {
            navigator.completeStoreSelection(pathOverride: [])
            return
        }
        navigator.completeStoreSelection()
    }

    private var filteredStores: [Store] {
        switch searchMethod {
        case .currentLocation:
            return currentLocationStores
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
                [store.name, store.neighborhood, store.address]
            }
        }
    }

    private var currentLocationStores: [Store] {
        let normalizedQuery = self.normalizedQuery
        let sortedStores = orderStore.stores.sorted { lhs, rhs in
            lhs.pickupLeadTimeMin < rhs.pickupLeadTimeMin
        }

        guard !normalizedQuery.isEmpty else { return sortedStores }
        return sortedStores.filter { store in
            [store.name, store.neighborhood, store.address]
                .joined(separator: " ")
                .localizedCaseInsensitiveContains(normalizedQuery)
        }
    }

    private func matchingStores(_ values: (Store) -> [String]) -> [Store] {
        let normalizedQuery = self.normalizedQuery
        guard !normalizedQuery.isEmpty else { return orderStore.stores }
        return orderStore.stores.filter { store in
            values(store)
                .joined(separator: " ")
                .localizedCaseInsensitiveContains(normalizedQuery)
        }
    }

    private var frequentStores: [Store] {
        var seenIDs = Set<String>()
        let stores = ([orderStore.selectedStore] + orderStore.favoriteCombos.map(\.draft.store)).compactMap { $0 }
        let uniqueStores = stores.filter { store in
            seenIDs.insert(store.id).inserted
        }

        guard !normalizedQuery.isEmpty else { return uniqueStores }
        return uniqueStores.filter { store in
            [store.name, store.neighborhood, store.address]
                .joined(separator: " ")
                .localizedCaseInsensitiveContains(normalizedQuery)
        }
    }

    private var activeStores: [Store] {
        switch selectedListTab {
        case .all:
            return filteredStores
        case .frequent:
            return frequentStores
        }
    }

    private var mapStores: [Store] {
        let stores = filteredStores.isEmpty ? orderStore.stores : filteredStores
        return Array(stores.prefix(6))
    }

    private var focusedStore: Store? {
        if let focusedStoreID {
            return (mapStores + activeStores).first(where: { $0.id == focusedStoreID })
        }
        return activeStores.first ?? mapStores.first
    }

    private var normalizedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var searchMethodHint: String {
        switch searchMethod {
        case .currentLocation:
            return "GPS で詰まらないよう、駅名や店名への切り替えもすぐできます。"
        case .station:
            return "駅名ベースで近い候補を比較しやすく並べます。"
        case .postalCode:
            return "番地まで厳密でなくても、郵便番号の断片入力で絞り込めます。"
        case .storeName:
            return "店名や地名の一部だけでも候補を出せます。"
        }
    }

    private var mapHeaderTitle: String {
        switch searchMethod {
        case .currentLocation:
            return "近くの店舗"
        case .station:
            return normalizedQuery.isEmpty ? "駅名から探す" : "\(normalizedQuery)周辺"
        case .postalCode:
            return normalizedQuery.isEmpty ? "郵便番号から探す" : normalizedQuery
        case .storeName:
            return normalizedQuery.isEmpty ? "店舗名から探す" : "「\(normalizedQuery)」の候補"
        }
    }

    private var mapHeaderSymbol: String {
        switch searchMethod {
        case .currentLocation:
            return "location.fill"
        case .station:
            return "tram.fill"
        case .postalCode:
            return "mail"
        case .storeName:
            return "magnifyingglass"
        }
    }

    private func distanceText(for store: Store) -> String {
        switch store.id {
        case "nagoya-meieki":
            return "400m"
        case "sakae-nishiki":
            return "1.1km"
        case "kanayama-ekimae":
            return "2.4km"
        case "fushimi-hirokoji":
            return "900m"
        case "chikusa-imaike":
            return "3.2km"
        default:
            return "近く"
        }
    }

    private func storeHasLimitedMenu(_ store: Store) -> Bool {
        orderStore.menuItems.contains { item in
            item.isStoreLimited && item.availableStoreIDs.contains(store.id)
        }
    }

    private func syncFocusedStore() {
        if let focusedStoreID,
           (mapStores + activeStores).contains(where: { $0.id == focusedStoreID }) {
            return
        }
        focusedStoreID = activeStores.first?.id ?? mapStores.first?.id
    }

    private func recenterMap(for stores: [Store], preferredStoreID: Store.ID?) {
        guard !stores.isEmpty else { return }

        if let preferredStoreID,
           let preferredStore = stores.first(where: { $0.id == preferredStoreID }) {
            mapCameraPosition = .region(
                MKCoordinateRegion(
                    center: coordinate(for: preferredStore),
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                )
            )
            return
        }

        let coordinates = stores.map(coordinate(for:))
        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)

        guard
            let minLatitude = latitudes.min(),
            let maxLatitude = latitudes.max(),
            let minLongitude = longitudes.min(),
            let maxLongitude = longitudes.max()
        else {
            return
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLatitude - minLatitude) * 1.9, 0.03),
            longitudeDelta: max((maxLongitude - minLongitude) * 1.9, 0.03)
        )
        mapCameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }

    private func coordinate(for store: Store) -> CLLocationCoordinate2D {
        switch store.id {
        case "nagoya-meieki":
            return CLLocationCoordinate2D(latitude: 35.1685, longitude: 136.8856)
        case "sakae-nishiki":
            return CLLocationCoordinate2D(latitude: 35.1708, longitude: 136.9084)
        case "kanayama-ekimae":
            return CLLocationCoordinate2D(latitude: 35.1430, longitude: 136.9008)
        case "fushimi-hirokoji":
            return CLLocationCoordinate2D(latitude: 35.1671, longitude: 136.8954)
        case "chikusa-imaike":
            return CLLocationCoordinate2D(latitude: 35.1680, longitude: 136.9368)
        default:
            return CLLocationCoordinate2D(latitude: 35.1698, longitude: 136.8996)
        }
    }

    private static let defaultMapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.1698, longitude: 136.8996),
        span: MKCoordinateSpan(latitudeDelta: 0.055, longitudeDelta: 0.055)
    )
}
