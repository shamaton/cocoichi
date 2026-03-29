import Foundation

enum MockCatalog {
    static let stores: [Store] = [
        Store(
            id: "shibuya-dogenzaka",
            name: "渋谷道玄坂店",
            neighborhood: "渋谷",
            address: "東京都渋谷区道玄坂1-8-5",
            pickupLeadTimeMin: 12,
            pickupLeadTimeMax: 18
        ),
        Store(
            id: "ebisu-ekimae",
            name: "恵比寿駅前店",
            neighborhood: "恵比寿",
            address: "東京都渋谷区恵比寿南1-4-15",
            pickupLeadTimeMin: 10,
            pickupLeadTimeMax: 16
        ),
        Store(
            id: "shinagawa-konan",
            name: "品川港南口店",
            neighborhood: "品川",
            address: "東京都港区港南2-3-10",
            pickupLeadTimeMin: 14,
            pickupLeadTimeMax: 20
        ),
    ]

    static let toppings: [Topping] = [
        Topping(id: "cheese", name: "チーズ", price: 180, accentHex: 0xE5B94E),
        Topping(id: "spinach", name: "ほうれん草", price: 120, accentHex: 0x5E7D3B),
        Topping(id: "egg", name: "半熟たまご", price: 110, accentHex: 0xF2D7A6),
        Topping(id: "sausage", name: "ソーセージ", price: 240, accentHex: 0xB84E2F),
    ]

    static let menuItems: [MenuItem] = [
        MenuItem(
            id: "pork-curry",
            name: "ポークカレー",
            subtitle: "軽く始めたい日の定番",
            basePrice: 720,
            tags: [.staple],
            searchKeywords: ["ポーク", "定番", "やさしい"],
            recommendedToppingIDs: ["egg", "spinach"],
            accentHexes: [0xB84E2F, 0x8B4A1F]
        ),
        MenuItem(
            id: "butter-chicken",
            name: "バターチキンカレー",
            subtitle: "まろやかで人気上昇",
            basePrice: 840,
            tags: [.recommended],
            searchKeywords: ["バター", "チキン", "まろやか"],
            recommendedToppingIDs: ["cheese"],
            accentHexes: [0xE5B94E, 0x8B4A1F]
        ),
        MenuItem(
            id: "loin-cutlet",
            name: "ロースカツカレー",
            subtitle: "サクサク食感の王道",
            basePrice: 980,
            tags: [.staple, .rich],
            searchKeywords: ["ロースカツ", "定番", "がっつり"],
            recommendedToppingIDs: ["spinach", "cheese"],
            accentHexes: [0x8B4A1F, 0x5E7D3B]
        ),
        MenuItem(
            id: "crispy-chicken",
            name: "パリパリチキンカレー",
            subtitle: "食感重視の人気メニュー",
            basePrice: 930,
            tags: [.recommended, .rich],
            searchKeywords: ["チキン", "パリパリ", "香ばしい"],
            recommendedToppingIDs: ["egg", "cheese"],
            accentHexes: [0xB8752C, 0x8B4A1F]
        ),
        MenuItem(
            id: "beef-spicy",
            name: "ビーフカレー",
            subtitle: "辛さを楽しむならこれ",
            basePrice: 890,
            tags: [.spicy],
            searchKeywords: ["ビーフ", "辛口", "刺激"],
            recommendedToppingIDs: ["sausage", "cheese"],
            accentHexes: [0xB84E2F, 0x2E221B]
        ),
    ]

    static let coupons: [Coupon] = [
        Coupon(
            id: "coupon-spinach-50",
            title: "ほうれん草トッピング 50円引き",
            summary: "対象: ほうれん草トッピングを含む注文",
            discountYen: 50,
            eligibility: .topping("spinach")
        ),
        Coupon(
            id: "coupon-cutlet-80",
            title: "ロースカツカレー 80円引き",
            summary: "対象: ロースカツカレーの注文",
            discountYen: 80,
            eligibility: .menu("loin-cutlet")
        ),
        Coupon(
            id: "coupon-order-30",
            title: "注文金額 30円引き",
            summary: "対象: 小計 1,000円以上の注文",
            discountYen: 30,
            eligibility: .minimumSubtotal(1000)
        ),
    ]

    static var initialFavoriteCombos: [FavoriteCombo] {
        let shibuya = stores[0]
        let loinCutlet = menuItems.first(where: { $0.id == "loin-cutlet" })!
        let butterChicken = menuItems.first(where: { $0.id == "butter-chicken" })!
        let cheese = toppings.first(where: { $0.id == "cheese" })!
        let spinach = toppings.first(where: { $0.id == "spinach" })!

        return [
            FavoriteCombo(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
                name: "いつものロースカツ3辛",
                draft: DraftOrder(
                    store: shibuya,
                    menuItem: loinCutlet,
                    spiceLevel: 3,
                    riceGrams: 400,
                    toppings: [cheese, spinach],
                    appliedCoupon: nil
                ),
                lastUsedAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now
            ),
            FavoriteCombo(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
                name: "まろやかチキン",
                draft: DraftOrder(
                    store: shibuya,
                    menuItem: butterChicken,
                    spiceLevel: 2,
                    riceGrams: 300,
                    toppings: [cheese],
                    appliedCoupon: nil
                ),
                lastUsedAt: Calendar.current.date(byAdding: .day, value: -8, to: .now) ?? .now
            ),
        ]
    }
}
