import Foundation
import SwiftUI

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

struct MenuItem: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let group: CurryMenuGroup
    let subtitle: String
    let basePrice: Int
    let tags: [MenuTag]
    let searchKeywords: [String]
    let imagePath: String?
    let recommendedToppingIDs: [String]
    let accentHexes: [UInt]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case group
        case subtitle
        case basePrice
        case tags
        case searchKeywords
        case imagePath
        case recommendedToppingIDs
        case accentHexes
    }

    init(
        id: String,
        name: String,
        group: CurryMenuGroup,
        subtitle: String,
        basePrice: Int,
        tags: [MenuTag],
        searchKeywords: [String],
        imagePath: String? = nil,
        recommendedToppingIDs: [String],
        accentHexes: [UInt]
    ) {
        self.id = id
        self.name = name
        self.group = group
        self.subtitle = subtitle
        self.basePrice = basePrice
        self.tags = tags
        self.searchKeywords = searchKeywords
        self.imagePath = imagePath
        self.recommendedToppingIDs = recommendedToppingIDs
        self.accentHexes = accentHexes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        group = try container.decodeIfPresent(CurryMenuGroup.self, forKey: .group) ?? .meat
        subtitle = try container.decode(String.self, forKey: .subtitle)
        basePrice = try container.decode(Int.self, forKey: .basePrice)
        tags = try container.decodeIfPresent([MenuTag].self, forKey: .tags) ?? []
        searchKeywords = try container.decodeIfPresent([String].self, forKey: .searchKeywords) ?? []
        imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
        recommendedToppingIDs = try container.decodeIfPresent([String].self, forKey: .recommendedToppingIDs) ?? []
        accentHexes = try container.decodeIfPresent([UInt].self, forKey: .accentHexes) ?? group.accentHexes
    }

    var accentColors: [Color] {
        accentHexes.map { Color(hex: $0) }
    }

}

struct Topping: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let price: Int
    let accentHex: UInt

    var accentColor: Color {
        Color(hex: accentHex)
    }
}

enum CouponEligibility: Codable, Hashable {
    case topping(String)
    case minimumSubtotal(Int)
    case menu(String)
}

enum CurrySauceOption: String, CaseIterable, Codable, Hashable {
    case original = "オリジナル"
    case rich = "濃厚ビーフ"
    case butter = "バターリッチ"

    var subtitle: String {
        switch self {
        case .original:
            return "迷わず始める定番のソース"
        case .rich:
            return "コクを足したい日に向く深めの味"
        case .butter:
            return "まろやかさを強めたい時の変化球"
        }
    }

    var priceDelta: Int {
        switch self {
        case .original:
            return 0
        case .rich:
            return 90
        case .butter:
            return 120
        }
    }

    var accentColor: Color {
        switch self {
        case .original:
            return Color(hex: 0x8B4A1F)
        case .rich:
            return Color(hex: 0x6E3A22)
        case .butter:
            return Color(hex: 0xE5B94E)
        }
    }
}

enum SauceAmountOption: String, CaseIterable, Codable, Hashable {
    case light = "少なめ"
    case regular = "ふつう"
    case extra = "多め"

    var subtitle: String {
        switch self {
        case .light:
            return "ライスを軽めに楽しむ"
        case .regular:
            return "まずは基準の量で確認する"
        case .extra:
            return "最後までソース感を残したい"
        }
    }

    var priceDelta: Int {
        switch self {
        case .light, .regular:
            return 0
        case .extra:
            return 80
        }
    }

    var accentColor: Color {
        switch self {
        case .light:
            return Color(hex: 0xF2D7A6)
        case .regular:
            return Color(hex: 0xB8752C)
        case .extra:
            return Color(hex: 0xB84E2F)
        }
    }
}

struct Coupon: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let summary: String
    let discountYen: Int
    let eligibility: CouponEligibility

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
        menuItem.basePrice + currySauce.priceDelta + sauceAmount.priceDelta + toppings.map(\.price).reduce(0, +)
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

    var suggestedFavoriteName: String {
        "\(menuItem.name) \(spiceLevel)辛"
    }

    func toggling(topping: Topping) -> DraftOrder {
        var next = self
        if next.toppings.contains(topping) {
            next.toppings.removeAll { $0 == topping }
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
