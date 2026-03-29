import Foundation

@MainActor
final class OrderStore: ObservableObject {
    @Published private(set) var stores = MockCatalog.stores
    @Published private(set) var menuItems = MockCatalog.menuItems
    @Published private(set) var toppings = MockCatalog.toppings
    @Published private(set) var coupons = MockCatalog.coupons
    @Published var selectedStore: Store?
    @Published var draftOrder: DraftOrder?
    @Published var favoriteCombos: [FavoriteCombo]
    @Published var completedOrder: CompletedOrder?
    // S5 初回到達時だけクーポン sheet を自動表示し、その後は明示操作に戻すためのフラグ。
    @Published var hasPresentedCouponSuggestion = false

    private let favoriteStorageKey = "jp.cocoichi.poc.favoriteCombos"

    init() {
        favoriteCombos = Self.loadFavorites(forKey: favoriteStorageKey) ?? MockCatalog.initialFavoriteCombos
    }

    var availableCoupons: [Coupon] {
        guard let draftOrder else { return [] }
        return coupons.filter { $0.isApplicable(to: draftOrder) }
    }

    var unavailableCoupons: [Coupon] {
        guard let draftOrder else { return coupons }
        return coupons.filter { !$0.isApplicable(to: draftOrder) }
    }

    var featuredFavorite: FavoriteCombo? {
        favoriteCombos.sorted(by: { $0.lastUsedAt > $1.lastUsedAt }).first
    }

    func selectStore(_ store: Store) {
        selectedStore = store
        if let draftOrder {
            self.draftOrder = draftOrder
        }
    }

    func clearStoreSelection() {
        selectedStore = nil
        draftOrder = nil
        completedOrder = nil
        hasPresentedCouponSuggestion = false
    }

    func beginOrder(with menuItem: MenuItem) {
        guard let store = selectedStore else { return }
        draftOrder = DraftOrder(
            store: store,
            menuItem: menuItem,
            spiceLevel: 2,
            riceGrams: 300,
            toppings: [],
            appliedCoupon: nil
        )
        completedOrder = nil
        hasPresentedCouponSuggestion = false
    }

    func resumeFavorite(_ favorite: FavoriteCombo) {
        selectedStore = favorite.draft.store
        // 保存済み構成は再編集前提なので、クーポンは持ち越さず注文内容だけ再開する。
        draftOrder = favorite.draft.sanitizedForFavorite()
        completedOrder = nil
        hasPresentedCouponSuggestion = false
        markFavoriteUsed(favorite.id)
    }

    func setSpiceLevel(_ level: Int) {
        guard let draftOrder else { return }
        self.draftOrder = draftOrder.with(spiceLevel: level)
    }

    func setRiceGrams(_ grams: Int) {
        guard let draftOrder else { return }
        self.draftOrder = draftOrder.with(riceGrams: grams)
    }

    func toggleTopping(_ topping: Topping) {
        guard let draftOrder else { return }
        self.draftOrder = draftOrder.toggling(topping: topping)
    }

    func applyCoupon(_ coupon: Coupon) {
        guard let draftOrder, coupon.isApplicable(to: draftOrder) else { return }
        self.draftOrder = draftOrder.applying(coupon: coupon)
    }

    func removeCoupon() {
        guard let draftOrder else { return }
        self.draftOrder = draftOrder.applying(coupon: nil)
    }

    func saveCurrentFavorite(named name: String) {
        guard let draftOrder else { return }
        let favorite = FavoriteCombo(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? draftOrder.suggestedFavoriteName : name,
            draft: draftOrder.sanitizedForFavorite(),
            lastUsedAt: .now
        )
        favoriteCombos.insert(favorite, at: 0)
        persistFavorites()
    }

    func placeOrder() {
        guard let draftOrder else { return }
        let placedAt = Date()
        let pickupStart = Calendar.current.date(byAdding: .minute, value: draftOrder.store.pickupLeadTimeMin, to: placedAt) ?? placedAt
        let pickupEnd = Calendar.current.date(byAdding: .minute, value: draftOrder.store.pickupLeadTimeMax, to: placedAt) ?? pickupStart

        // PoC では API を持たないため、完了画面に必要な受取情報をローカルで確定させる。
        completedOrder = CompletedOrder(
            id: UUID(),
            referenceID: "MOCK-\(Self.referenceStamp(from: placedAt))",
            placedAt: placedAt,
            pickupStart: pickupStart,
            pickupEnd: pickupEnd,
            draft: draftOrder
        )
    }

    func resetForNextOrder(keepingStore: Bool) {
        let store = selectedStore
        draftOrder = nil
        completedOrder = nil
        hasPresentedCouponSuggestion = false

        // 完了後の再注文では店舗維持、店舗変更では完全リセットに分ける。
        if !keepingStore {
            selectedStore = nil
        } else {
            selectedStore = store
        }
    }

    private func markFavoriteUsed(_ id: FavoriteCombo.ID) {
        guard let index = favoriteCombos.firstIndex(where: { $0.id == id }) else { return }
        favoriteCombos[index].lastUsedAt = .now
        persistFavorites()
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
