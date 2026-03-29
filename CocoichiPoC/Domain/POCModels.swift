import Foundation
import SwiftUI

enum MenuTag: String, CaseIterable, Codable, Hashable {
    case staple = "定番"
    case recommended = "おすすめ"
    case rich = "こってり"
    case spicy = "辛さ"
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
    let subtitle: String
    let basePrice: Int
    let tags: [MenuTag]
    let searchKeywords: [String]
    let recommendedToppingIDs: [String]
    let accentHexes: [UInt]

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

struct Coupon: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let summary: String
    let discountYen: Int
    let eligibility: CouponEligibility

    func isApplicable(to order: DraftOrder) -> Bool {
        switch eligibility {
        case let .topping(toppingID):
            return order.toppings.contains(where: { $0.id == toppingID })
        case let .minimumSubtotal(amount):
            return order.subtotal >= amount
        case let .menu(menuID):
            return order.menuItem.id == menuID
        }
    }

    func discount(for order: DraftOrder) -> Int {
        min(discountYen, order.subtotal)
    }
}

struct DraftOrder: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var store: Store
    var menuItem: MenuItem
    var spiceLevel: Int
    var riceGrams: Int
    var toppings: [Topping]
    var appliedCoupon: Coupon?

    var subtotal: Int {
        menuItem.basePrice + toppings.map(\.price).reduce(0, +)
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
        if let coupon = next.appliedCoupon, !coupon.isApplicable(to: next) {
            next.appliedCoupon = nil
        }
        return next
    }

    func with(spiceLevel: Int) -> DraftOrder {
        var next = self
        next.spiceLevel = spiceLevel
        return next
    }

    func with(riceGrams: Int) -> DraftOrder {
        var next = self
        next.riceGrams = riceGrams
        return next
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

struct CompletedOrder: Identifiable, Hashable, Codable {
    let id: UUID
    let referenceID: String
    let placedAt: Date
    let pickupStart: Date
    let pickupEnd: Date
    let draft: DraftOrder

    var pickupWindowText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: pickupStart)) - \(formatter.string(from: pickupEnd))"
    }
}
