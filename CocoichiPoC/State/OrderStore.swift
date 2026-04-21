import Foundation

enum FavoriteResumeState: Equatable {
    case ready(message: String)
    case needsReview(message: String)
}

@MainActor
final class OrderStore: ObservableObject {
    @Published private(set) var stores = MockCatalog.stores
    @Published private(set) var menuItems = MockCatalog.menuItems
    @Published private(set) var toppings = MockCatalog.toppings
    @Published private(set) var coupons = MockCatalog.coupons
    @Published var selectedStore: Store?
    @Published var selectedFulfillmentMode: FulfillmentMode = .pickup
    @Published var cartItems: [CartLineItem] = []
    @Published var draftOrder: DraftOrder?
    @Published var isDraftConfirmedForReview = false
    @Published var appliedCoupon: Coupon?
    @Published var favoriteCombos: [FavoriteCombo]
    @Published var completedOrder: CompletedOrder?
    @Published var recentlySavedFavoriteName: String?
    // S5 初回到達時だけクーポン sheet を自動表示し、その後は明示操作に戻すためのフラグ。
    @Published var hasPresentedCouponSuggestion = false

    private let favoriteStorageKey = "jp.cocoichi.poc.favoriteCombos"

    init() {
        favoriteCombos = Self.loadFavorites(forKey: favoriteStorageKey) ?? MockCatalog.initialFavoriteCombos
    }

    var availableCoupons: [Coupon] {
        guard !reviewDrafts.isEmpty else { return [] }
        return coupons
            .filter { $0.isApplicable(to: reviewDrafts) }
            .sorted { $0.discount(for: reviewDrafts) > $1.discount(for: reviewDrafts) }
    }

    var unavailableCoupons: [Coupon] {
        guard !reviewDrafts.isEmpty else { return coupons }
        return coupons.filter { !$0.isApplicable(to: reviewDrafts) }
    }

    var featuredFavorite: FavoriteCombo? {
        favoriteCombos.sorted(by: { $0.lastUsedAt > $1.lastUsedAt }).first
    }

    var visibleMenuItems: [MenuItem] {
        menuItems.filter { $0.isAvailable(at: selectedStore) }
    }

    var storeLimitedMenuItems: [MenuItem] {
        guard selectedStore != nil else { return [] }
        return visibleMenuItems.filter(\.isStoreLimited)
    }

    var reviewSubtotal: Int {
        reviewDrafts.map(\.subtotal).reduce(0, +)
    }

    var reviewDiscount: Int {
        appliedCoupon?.discount(for: reviewDrafts) ?? 0
    }

    var reviewTotal: Int {
        max(reviewSubtotal - reviewDiscount, 0)
    }

    func previewTotal(afterApplying coupon: Coupon) -> Int {
        max(reviewSubtotal - coupon.discount(for: reviewDrafts), 0)
    }

    var reviewStore: Store? {
        selectedStore ?? draftOrder?.store ?? cartItems.first?.draft.store
    }

    var hasReviewItems: Bool {
        !cartItems.isEmpty || draftOrder != nil
    }

    var pendingReviewLineItem: CartLineItem? {
        guard let draftOrder else { return nil }
        return CartLineItem(id: draftOrder.id, draft: draftOrder)
    }

    var favoriteSaveCandidate: DraftOrder? {
        if let completedDraft = completedOrder?.cartItems.last?.draft {
            return completedDraft.sanitizedForFavorite()
        }
        return draftOrder?.sanitizedForFavorite()
    }

    private var reviewDrafts: [DraftOrder] {
        cartItems.map(\.draft) + (draftOrder.map { [$0] } ?? [])
    }

    func selectStore(_ store: Store) {
        selectedStore = store
        selectedFulfillmentMode = .pickup
        if let draftOrder {
            self.draftOrder = draftOrder
        }
    }

    func clearStoreSelection() {
        selectedStore = nil
        selectedFulfillmentMode = .pickup
        cartItems = []
        draftOrder = nil
        isDraftConfirmedForReview = false
        appliedCoupon = nil
        completedOrder = nil
        recentlySavedFavoriteName = nil
        hasPresentedCouponSuggestion = false
    }

    func beginOrder(with menuItem: MenuItem) {
        guard let store = selectedStore else { return }
        draftOrder = DraftOrder(
            store: store,
            menuItem: menuItem,
            currySauce: .original,
            spiceLevel: 0,
            riceGrams: 300,
            sauceAmount: .regular,
            toppings: [],
            appliedCoupon: nil
        )
        isDraftConfirmedForReview = false
        completedOrder = nil
        recentlySavedFavoriteName = nil
        if cartItems.isEmpty {
            hasPresentedCouponSuggestion = false
        }
    }

    func resumeFavorite(_ favorite: FavoriteCombo) {
        let resumeStore = selectedStore ?? favorite.draft.store
        selectedFulfillmentMode = .pickup
        // 保存済み構成は再編集前提なので、クーポンは持ち越さず注文内容だけ再開する。
        var resumedDraft = favorite.draft.sanitizedForFavorite()
        resumedDraft.store = resumeStore
        selectedStore = resumeStore
        draftOrder = resumedDraft
        isDraftConfirmedForReview = false
        completedOrder = nil
        recentlySavedFavoriteName = nil
        if cartItems.isEmpty {
            hasPresentedCouponSuggestion = false
        }
        markFavoriteUsed(favorite.id)
    }

    func favoriteResumeState(for favorite: FavoriteCombo) -> FavoriteResumeState {
        guard let selectedStore else {
            return .ready(message: "保存時の店舗でそのまま再開します")
        }

        let savedStore = favorite.draft.store
        let isSameStore = savedStore.id == selectedStore.id
        let isAvailableAtCurrentStore = favorite.draft.menuItem.isAvailable(at: selectedStore)

        if isSameStore {
            return .ready(message: "\(selectedStore.name)ですぐ再開できます")
        }

        if isAvailableAtCurrentStore {
            return .ready(message: "\(selectedStore.name)向けに受取時間を再計算して再開します")
        }

        return .needsReview(message: "この店舗では限定商品がない可能性があります")
    }

    func setSpiceLevel(_ level: Int) {
        updateDraft { $0.with(spiceLevel: level) }
    }

    func setCurrySauce(_ sauce: CurrySauceOption) {
        updateDraft { $0.with(currySauce: sauce) }
    }

    func setRiceGrams(_ grams: Int) {
        updateDraft { $0.with(riceGrams: grams) }
    }

    func setSauceAmount(_ amount: SauceAmountOption) {
        updateDraft { $0.with(sauceAmount: amount) }
    }

    func addTopping(_ topping: Topping) {
        updateDraft { $0.adding(topping: topping) }
    }

    func removeTopping(_ topping: Topping) {
        updateDraft { $0.removingOne(topping: topping) }
    }

    func clearTopping(_ topping: Topping) {
        updateDraft { $0.removingAll(topping: topping) }
    }

    func applyCoupon(_ coupon: Coupon) {
        guard coupon.isApplicable(to: reviewDrafts) else { return }
        appliedCoupon = coupon
    }

    func confirmCurrentDraftForReview() {
        guard draftOrder != nil else { return }
        isDraftConfirmedForReview = true
    }

    func removeCoupon() {
        appliedCoupon = nil
    }

    func saveFavorite(named name: String) {
        guard let draftOrder = favoriteSaveCandidate else { return }
        let resolvedName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? draftOrder.suggestedFavoriteName : name.trimmingCharacters(in: .whitespacesAndNewlines)
        let favorite = FavoriteCombo(
            id: UUID(),
            name: resolvedName,
            draft: draftOrder.sanitizedForFavorite(),
            lastUsedAt: .now
        )
        favoriteCombos.insert(favorite, at: 0)
        recentlySavedFavoriteName = resolvedName
        persistFavorites()
    }

    func moveCurrentDraftToCart() {
        guard let draftOrder else { return }
        cartItems.append(CartLineItem(draft: draftOrder.sanitizedForFavorite()))
        self.draftOrder = nil
        isDraftConfirmedForReview = false
        normalizeAppliedCoupon()
    }

    func beginEditingCartItem(_ lineItemID: CartLineItem.ID) {
        guard let index = cartItems.firstIndex(where: { $0.id == lineItemID }) else { return }

        let selectedItem = cartItems.remove(at: index)
        if let draftOrder {
            cartItems.insert(CartLineItem(draft: draftOrder.sanitizedForFavorite()), at: index)
        }

        selectedStore = selectedItem.draft.store
        draftOrder = selectedItem.draft.sanitizedForFavorite()
        normalizeAppliedCoupon()
    }

    func placeOrder() {
        let finalizedItems = cartItems + (draftOrder.map { [CartLineItem(draft: $0.sanitizedForFavorite())] } ?? [])
        guard let store = reviewStore, !finalizedItems.isEmpty else { return }
        let placedAt = Date()
        let pickupStart = Calendar.current.date(byAdding: .minute, value: store.pickupLeadTimeMin, to: placedAt) ?? placedAt
        let pickupEnd = Calendar.current.date(byAdding: .minute, value: store.pickupLeadTimeMax, to: placedAt) ?? pickupStart
        recentlySavedFavoriteName = nil

        // PoC では API を持たないため、完了画面に必要な受取情報をローカルで確定させる。
        completedOrder = CompletedOrder(
            id: UUID(),
            referenceID: "MOCK-\(Self.referenceStamp(from: placedAt))",
            placedAt: placedAt,
            pickupStart: pickupStart,
            pickupEnd: pickupEnd,
            store: store,
            cartItems: finalizedItems,
            appliedCoupon: appliedCoupon
        )
    }

    func resetForNextOrder(keepingStore: Bool) {
        let store = selectedStore
        cartItems = []
        draftOrder = nil
        isDraftConfirmedForReview = false
        appliedCoupon = nil
        completedOrder = nil
        recentlySavedFavoriteName = nil
        hasPresentedCouponSuggestion = false

        // 完了後の再注文では店舗維持、店舗変更では完全リセットに分ける。
        if !keepingStore {
            selectedStore = nil
            selectedFulfillmentMode = .pickup
        } else {
            selectedStore = store
        }
    }

    private func markFavoriteUsed(_ id: FavoriteCombo.ID) {
        guard let index = favoriteCombos.firstIndex(where: { $0.id == id }) else { return }
        favoriteCombos[index].lastUsedAt = .now
        persistFavorites()
    }

    private func updateDraft(_ transform: (DraftOrder) -> DraftOrder) {
        guard let draftOrder else { return }
        self.draftOrder = transform(draftOrder)
        normalizeAppliedCoupon()
    }

    private func normalizeAppliedCoupon() {
        guard let appliedCoupon, !reviewDrafts.isEmpty else {
            if reviewDrafts.isEmpty {
                self.appliedCoupon = nil
            }
            return
        }

        if !appliedCoupon.isApplicable(to: reviewDrafts) {
            self.appliedCoupon = nil
        }
    }

    private func persistFavorites() {
        guard let data = try? JSONEncoder().encode(favoriteCombos) else { return }
        UserDefaults.standard.set(data, forKey: favoriteStorageKey)
    }

    private static func loadFavorites(forKey key: String) -> [FavoriteCombo]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([FavoriteCombo].self, from: data)
    }

    private static func referenceStamp(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmm"
        return formatter.string(from: date)
    }
}
