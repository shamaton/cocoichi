import Foundation
import SwiftUI

enum Pricing {
    static let virtualPriceMarkupRate = 0.08

    static func virtualDisplayedPrice(for actualPrice: Int) -> Int {
        let scaledPrice = Double(actualPrice) * (1 + virtualPriceMarkupRate)
        return Int((scaledPrice / 10).rounded(.up) * 10)
    }
}

enum SpiceLevelPricing {
    static func priceDelta(for level: Int) -> Int {
        switch level {
        case -1, 0:
            return 0
        case 1:
            return 25
        case 2:
            return 50
        case 3:
            return 75
        case 4:
            return 100
        case 5:
            return 125
        case 6...10:
            return 150
        case 15:
            return 175
        case 20:
            return 200
        default:
            return 0
        }
    }
}

enum MenuTag: String, CaseIterable, Codable, Hashable {
    case staple = "定番"
    case recommended = "おすすめ"
    case rich = "こってり"
    case spicy = "辛さ"
}

enum CurryMenuGroup: String, CaseIterable, Codable, Hashable {
    case limitedTime = "期間限定"
    case meat = "肉類のカレー"
    case seafood = "魚介類のカレー"
    case vegetableAndOther = "野菜類・その他のカレー"

    var accentHexes: [UInt] {
        switch self {
        case .limitedTime:
            return [0xB84E2F, 0xE5B94E]
        case .meat:
            return [0x8B4A1F, 0xB8752C]
        case .seafood:
            return [0x5E7D3B, 0x8DA9C4]
        case .vegetableAndOther:
            return [0x5E7D3B, 0xF2D7A6]
        }
    }

    var discoveryCardBackground: LinearGradient {
        switch self {
        case .limitedTime:
            return LinearGradient(
                colors: [Color(hex: 0xF7D8CC), Color(hex: 0xF5E6AF)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .meat:
            return LinearGradient(
                colors: [Color(hex: 0xF8ECDD), Color(hex: 0xF2E2CF)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .seafood:
            return LinearGradient(
                colors: [Color(hex: 0xEEF5F8), Color(hex: 0xE4EEF7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .vegetableAndOther:
            return LinearGradient(
                colors: [Color(hex: 0xEEF4E6), Color(hex: 0xF4EFD9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var genreImagePath: String {
        switch self {
        case .limitedTime:
            return "curry-kikan.png"
        case .meat:
            return "curry-meats.png"
        case .seafood:
            return "curry-seafoods.png"
        case .vegetableAndOther:
            return "curry-vegetables.png"
        }
    }
}

enum ToppingGroup: String, CaseIterable, Codable, Hashable {
    case meat = "肉類のトッピング"
    case seafood = "魚介類のトッピング"
    case vegetable = "野菜類のトッピング"
    case other = "その他のトッピング"

    var genreImagePath: String {
        switch self {
        case .meat:
            return "curry-meats.png"
        case .seafood:
            return "curry-seafoods.png"
        case .vegetable:
            return "curry-vegetables.png"
        case .other:
            return "curry-kikan.png"
        }
    }

    var accentHex: UInt {
        switch self {
        case .meat:
            return 0xB84E2F
        case .seafood:
            return 0x8DA9C4
        case .vegetable:
            return 0x5E7D3B
        case .other:
            return 0xE5B94E
        }
    }

    var discoveryCardBackground: LinearGradient {
        switch self {
        case .meat:
            return LinearGradient(
                colors: [Color(hex: 0xF8E5DD), Color(hex: 0xF4D8CB)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .seafood:
            return LinearGradient(
                colors: [Color(hex: 0xEAF4F8), Color(hex: 0xDDEBF5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .vegetable:
            return LinearGradient(
                colors: [Color(hex: 0xECF3E3), Color(hex: 0xE1ECD2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .other:
            return LinearGradient(
                colors: [Color(hex: 0xF8F0D8), Color(hex: 0xF5E6BE)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var symbolName: String {
        switch self {
        case .meat:
            return "fork.knife"
        case .seafood:
            return "fish"
        case .vegetable:
            return "leaf"
        case .other:
            return "sparkles"
        }
    }
}

struct Store: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let neighborhood: String
    let address: String
    let pickupLeadTimeMin: Int
    let pickupLeadTimeMax: Int

    var pickupLeadTimeText: String {
        "\(pickupLeadTimeMin)-\(pickupLeadTimeMax)分"
    }
}

enum FulfillmentMode: String, Codable, Hashable {
    case pickup
    case delivery

    var label: String {
        switch self {
        case .pickup:
            return "店舗受取"
        case .delivery:
            return "デリバリー"
        }
    }
}

struct MenuItem: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let group: CurryMenuGroup
    let subtitle: String
    let actualBasePrice: Int
    let basePrice: Int
    let tags: [MenuTag]
    let searchKeywords: [String]
    let imagePath: String?
    let recommendedToppingIDs: [String]
    let accentHexes: [UInt]
    let isGlobal: Bool
    let availableStoreIDs: [String]
    let availabilityNote: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case group
        case subtitle
        case actualBasePrice
        case basePrice
        case tags
        case searchKeywords
        case imagePath
        case recommendedToppingIDs
        case accentHexes
        case isGlobal
        case availableStoreIDs
        case availabilityNote
    }

    init(
        id: String,
        name: String,
        group: CurryMenuGroup,
        subtitle: String,
        actualBasePrice: Int,
        basePrice: Int,
        tags: [MenuTag],
        searchKeywords: [String],
        imagePath: String? = nil,
        recommendedToppingIDs: [String],
        accentHexes: [UInt],
        isGlobal: Bool = true,
        availableStoreIDs: [String] = [],
        availabilityNote: String? = nil
    ) {
        self.id = id
        self.name = name
        self.group = group
        self.subtitle = subtitle
        self.actualBasePrice = actualBasePrice
        self.basePrice = basePrice
        self.tags = tags
        self.searchKeywords = searchKeywords
        self.imagePath = imagePath
        self.recommendedToppingIDs = recommendedToppingIDs
        self.accentHexes = accentHexes
        self.isGlobal = isGlobal
        self.availableStoreIDs = availableStoreIDs
        self.availabilityNote = availabilityNote
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        group = try container.decodeIfPresent(CurryMenuGroup.self, forKey: .group) ?? .meat
        subtitle = try container.decode(String.self, forKey: .subtitle)
        let storedBasePrice = try container.decode(Int.self, forKey: .basePrice)
        let decodedActualBasePrice = try container.decodeIfPresent(Int.self, forKey: .actualBasePrice)
        actualBasePrice = decodedActualBasePrice ?? storedBasePrice
        basePrice = decodedActualBasePrice == nil ? Pricing.virtualDisplayedPrice(for: storedBasePrice) : storedBasePrice
        tags = try container.decodeIfPresent([MenuTag].self, forKey: .tags) ?? []
        searchKeywords = try container.decodeIfPresent([String].self, forKey: .searchKeywords) ?? []
        imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
        recommendedToppingIDs = try container.decodeIfPresent([String].self, forKey: .recommendedToppingIDs) ?? []
        accentHexes = try container.decodeIfPresent([UInt].self, forKey: .accentHexes) ?? group.accentHexes
        isGlobal = try container.decodeIfPresent(Bool.self, forKey: .isGlobal) ?? true
        availableStoreIDs = try container.decodeIfPresent([String].self, forKey: .availableStoreIDs) ?? []
        availabilityNote = try container.decodeIfPresent(String.self, forKey: .availabilityNote)
    }

    var accentColors: [Color] {
        accentHexes.map { Color(hex: $0) }
    }

    var isStoreLimited: Bool {
        !isGlobal || !availableStoreIDs.isEmpty
    }

    func isAvailable(at store: Store?) -> Bool {
        if isGlobal && availableStoreIDs.isEmpty {
            return true
        }

        guard let store else { return false }
        return availableStoreIDs.contains(store.id)
    }
}

struct Topping: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let price: Int
    let accentHex: UInt
    let group: ToppingGroup
    let imagePath: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case accentHex
        case group
        case imagePath
    }

    init(id: String, name: String, price: Int, accentHex: UInt, group: ToppingGroup = .other, imagePath: String? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.accentHex = accentHex
        self.group = group
        self.imagePath = imagePath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Int.self, forKey: .price)
        accentHex = try container.decode(UInt.self, forKey: .accentHex)
        group = try container.decodeIfPresent(ToppingGroup.self, forKey: .group) ?? Self.inferredGroup(from: accentHex)
        imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
    }

    var accentColor: Color {
        Color(hex: accentHex)
    }

    private static func inferredGroup(from accentHex: UInt) -> ToppingGroup {
        switch accentHex {
        case ToppingGroup.meat.accentHex:
            return .meat
        case ToppingGroup.seafood.accentHex:
            return .seafood
        case ToppingGroup.vegetable.accentHex:
            return .vegetable
        default:
            return .other
        }
    }
}

enum CouponEligibility: Codable, Hashable {
    case topping(String)
    case minimumSubtotal(Int)
    case menu(String)
}

enum CurrySauceOption: String, CaseIterable, Codable, Hashable {
    case original = "ポークソース"
    case rich = "ビーフソース"
    case butter = "ココイチベジソース"

    var cardTitle: String {
        rawValue
    }

    var subtitle: String {
        switch self {
        case .original:
            return "変わらないおいしさのココイチの基本となるソース"
        case .rich:
            return "ビーフの旨みが凝縮された\"もう一つの定番ソース\""
        case .butter:
            return "動物由来の原材料を使用していないソース"
        }
    }

    var priceDelta: Int {
        switch self {
        case .original:
            return 0
        case .rich:
            return 148
        case .butter:
            return 37
        }
    }

    func ricePriceDelta(for riceGrams: Int) -> Int {
        switch riceGrams {
        case 150:
            return -90
        case 200:
            return -60
        case 250:
            return -30
        case 300:
            return 0
        case 350:
            return self == .rich ? 78 : 65
        case let grams where grams >= 400 && grams % 100 == 0:
            let additionalHundreds = (grams - 300) / 100
            return self == .rich ? additionalHundreds * 157 : additionalHundreds * 130
        default:
            return 0
        }
    }

    var accentColor: Color {
        switch self {
        case .original:
            return Color(hex: 0x8B4A1F)
        case .rich:
            return Color(hex: 0x6E3A22)
        case .butter:
            return Color(hex: 0x5E7D3B)
        }
    }

    var imageName: String {
        switch self {
        case .original:
            return "pork-source.png"
        case .rich:
            return "beef-source.png"
        case .butter:
            return "vege-source.png"
        }
    }

    var priceBadgeTitle: String {
        if priceDelta == 0 {
            return "追加料金なし"
        }
        return "+\(priceDelta.yenText)"
    }

    var priceBadgeSubtitle: String? {
        nil
    }
}

enum SauceAmountOption: String, CaseIterable, Codable, Hashable {
    case regular = "普通"
    case extra = "ソース増し(お玉1杯分)"
    case extraExtra = "ソース増し増し(お玉2杯分)"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case Self.regular.rawValue, "ふつう", "少なめ":
            self = .regular
        case Self.extra.rawValue, "多め":
            self = .extra
        case Self.extraExtra.rawValue:
            self = .extraExtra
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown sauce amount option: \(rawValue)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var cardTitle: String {
        switch self {
        case .regular:
            return "普通"
        case .extra:
            return "ソース増し"
        case .extraExtra:
            return "ソース増し増し"
        }
    }

    var subtitle: String {
        switch self {
        case .regular:
            return "増量なし"
        case .extra:
            return "お玉1杯分"
        case .extraExtra:
            return "お玉2杯分"
        }
    }

    var priceDelta: Int {
        switch self {
        case .regular:
            return 0
        case .extra:
            return 167
        case .extraExtra:
            return 334
        }
    }

    var accentColor: Color {
        switch self {
        case .regular:
            return Color(hex: 0xB8752C)
        case .extra:
            return Color(hex: 0xB84E2F)
        case .extraExtra:
            return Color(hex: 0x9C2F1E)
        }
    }
}

struct Coupon: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let summary: String
    let discountYen: Int
    let eligibility: CouponEligibility

    var displayTitle: String {
        switch eligibility {
        case .topping("spinach"):
            return "ほうれん草トッピング \(discountYen.yenText)引き"
        case .menu("loin-cutlet-curry"):
            return "ロースカツカレー \(discountYen.yenText)引き"
        case .minimumSubtotal:
            return "注文金額 \(discountYen.yenText)引き"
        default:
            return title
        }
    }

    var displaySummary: String {
        switch eligibility {
        case .topping("spinach"):
            return "対象: ほうれん草トッピングを含む注文"
        case .menu("loin-cutlet-curry"):
            return "対象: ロースカツカレーの注文"
        case let .minimumSubtotal(amount):
            return "対象: 小計 \(amount.yenText)以上の注文"
        default:
            return summary
        }
    }

    func isApplicable(to order: DraftOrder) -> Bool {
        isApplicable(to: [order])
    }

    func isApplicable(to drafts: [DraftOrder]) -> Bool {
        switch eligibility {
        case let .topping(toppingID):
            return drafts.contains(where: { draft in
                draft.toppings.contains(where: { $0.id == toppingID })
            })
        case let .minimumSubtotal(amount):
            return drafts.map(\.subtotal).reduce(0, +) >= amount
        case let .menu(menuID):
            return drafts.contains(where: { $0.menuItem.id == menuID })
        }
    }

    func discount(for order: DraftOrder) -> Int {
        discount(for: [order])
    }

    func discount(for drafts: [DraftOrder]) -> Int {
        min(discountYen, drafts.map(\.subtotal).reduce(0, +))
    }
}

struct DraftOrder: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var store: Store
    var menuItem: MenuItem
    var currySauce: CurrySauceOption = .original
    var spiceLevel: Int
    var riceGrams: Int
    var sauceAmount: SauceAmountOption = .regular
    var toppings: [Topping]
    var appliedCoupon: Coupon?

    private enum CodingKeys: String, CodingKey {
        case id
        case store
        case menuItem
        case currySauce
        case spiceLevel
        case riceGrams
        case sauceAmount
        case toppings
        case appliedCoupon
    }

    init(
        id: UUID = UUID(),
        store: Store,
        menuItem: MenuItem,
        currySauce: CurrySauceOption = .original,
        spiceLevel: Int,
        riceGrams: Int,
        sauceAmount: SauceAmountOption = .regular,
        toppings: [Topping],
        appliedCoupon: Coupon?
    ) {
        self.id = id
        self.store = store
        self.menuItem = menuItem
        self.currySauce = currySauce
        self.spiceLevel = spiceLevel
        self.riceGrams = riceGrams
        self.sauceAmount = sauceAmount
        self.toppings = toppings
        self.appliedCoupon = appliedCoupon
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        store = try container.decode(Store.self, forKey: .store)
        menuItem = try container.decode(MenuItem.self, forKey: .menuItem)
        currySauce = try container.decodeIfPresent(CurrySauceOption.self, forKey: .currySauce) ?? .original
        spiceLevel = try container.decode(Int.self, forKey: .spiceLevel)
        riceGrams = try container.decode(Int.self, forKey: .riceGrams)
        sauceAmount = try container.decodeIfPresent(SauceAmountOption.self, forKey: .sauceAmount) ?? .regular
        toppings = try container.decode([Topping].self, forKey: .toppings)
        appliedCoupon = try container.decodeIfPresent(Coupon.self, forKey: .appliedCoupon)
    }

    var subtotal: Int {
        menuItem.basePrice + currySauce.priceDelta + ricePriceDelta + spicePriceDelta + sauceAmount.priceDelta + toppings.map(\.price).reduce(0, +)
    }

    var ricePriceDelta: Int {
        currySauce.ricePriceDelta(for: riceGrams)
    }

    var spicePriceDelta: Int {
        SpiceLevelPricing.priceDelta(for: spiceLevel)
    }

    var discount: Int {
        guard let appliedCoupon else { return 0 }
        return appliedCoupon.discount(for: self)
    }

    var total: Int {
        max(subtotal - discount, 0)
    }

    var pickupWindowText: String {
        store.pickupLeadTimeText
    }

    var spiceLevelText: String {
        switch spiceLevel {
        case -1:
            return "甘口"
        case 0:
            return "普通"
        default:
            return "\(spiceLevel)辛"
        }
    }

    var suggestedFavoriteName: String {
        "\(menuItem.name) \(spiceLevelText)"
    }

    func toggling(topping: Topping) -> DraftOrder {
        var next = self
        if next.toppings.contains(where: { $0.id == topping.id }) {
            next.toppings.removeAll { $0.id == topping.id }
        } else {
            next.toppings.append(topping)
        }
        return next.normalizedCoupon()
    }

    func with(currySauce: CurrySauceOption) -> DraftOrder {
        var next = self
        next.currySauce = currySauce
        return next.normalizedCoupon()
    }

    func with(spiceLevel: Int) -> DraftOrder {
        var next = self
        next.spiceLevel = spiceLevel
        return next.normalizedCoupon()
    }

    func with(riceGrams: Int) -> DraftOrder {
        var next = self
        next.riceGrams = riceGrams
        return next.normalizedCoupon()
    }

    func with(sauceAmount: SauceAmountOption) -> DraftOrder {
        var next = self
        next.sauceAmount = sauceAmount
        return next.normalizedCoupon()
    }

    func applying(coupon: Coupon?) -> DraftOrder {
        var next = self
        next.appliedCoupon = coupon
        return next
    }

    func sanitizedForFavorite() -> DraftOrder {
        var next = self
        next.appliedCoupon = nil
        return next
    }

    private func normalizedCoupon() -> DraftOrder {
        guard let appliedCoupon, !appliedCoupon.isApplicable(to: self) else { return self }
        var next = self
        next.appliedCoupon = nil
        return next
    }
}

struct FavoriteCombo: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var draft: DraftOrder
    var lastUsedAt: Date

    var relativeLabel: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: lastUsedAt, relativeTo: .now)
    }
}

struct CartLineItem: Identifiable, Hashable, Codable {
    let id: UUID
    var draft: DraftOrder
    let addedAt: Date

    init(id: UUID = UUID(), draft: DraftOrder, addedAt: Date = .now) {
        self.id = id
        self.draft = draft
        self.addedAt = addedAt
    }

    var subtotal: Int {
        draft.subtotal
    }
}

struct CompletedOrder: Identifiable, Hashable, Codable {
    let id: UUID
    let referenceID: String
    let placedAt: Date
    let pickupStart: Date
    let pickupEnd: Date
    let store: Store
    let cartItems: [CartLineItem]
    let appliedCoupon: Coupon?

    var subtotal: Int {
        cartItems.map(\.subtotal).reduce(0, +)
    }

    var discount: Int {
        appliedCoupon?.discount(for: cartItems.map(\.draft)) ?? 0
    }

    var total: Int {
        max(subtotal - discount, 0)
    }

    var pickupWindowText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: pickupStart)) - \(formatter.string(from: pickupEnd))"
    }
}
