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

    static let menuItems: [MenuItem] = CurryMenuMasterLoader.load()

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
            eligibility: .menu("loin-cutlet-curry")
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
        let loinCutlet = menuItems.first(where: { $0.name == "ロースカツカレー" }) ?? menuItems[0]
        let porkCurry = menuItems.first(where: { $0.name == "ポークカレー" }) ?? menuItems[1]
        let cheese = toppings.first(where: { $0.id == "cheese" })!
        let spinach = toppings.first(where: { $0.id == "spinach" })!

        return [
            FavoriteCombo(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
                name: "いつものロースカツ3辛",
                draft: DraftOrder(
                    store: shibuya,
                    menuItem: loinCutlet,
                    currySauce: .rich,
                    spiceLevel: 3,
                    riceGrams: 400,
                    sauceAmount: .extra,
                    toppings: [cheese, spinach],
                    appliedCoupon: nil
                ),
                lastUsedAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now
            ),
            FavoriteCombo(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
                name: "軽めのポーク",
                draft: DraftOrder(
                    store: shibuya,
                    menuItem: porkCurry,
                    currySauce: .original,
                    spiceLevel: 2,
                    riceGrams: 300,
                    sauceAmount: .regular,
                    toppings: [spinach],
                    appliedCoupon: nil
                ),
                lastUsedAt: Calendar.current.date(byAdding: .day, value: -8, to: .now) ?? .now
            ),
        ]
    }
}

private struct CurryMenuMasterEntry {
    let group: CurryMenuGroup
    let name: String
    let price: Int
    let comment: String
}

private enum CurryMenuMasterLoader {
    static func load() -> [MenuItem] {
        parse(loadSource()).enumerated().map { index, entry in
            MenuItem(
                id: makeID(for: entry.name, index: index),
                name: entry.name,
                group: entry.group,
                subtitle: entry.comment,
                basePrice: entry.price,
                tags: makeTags(for: entry),
                searchKeywords: makeKeywords(for: entry),
                recommendedToppingIDs: makeRecommendedToppings(for: entry),
                accentHexes: entry.group.accentHexes
            )
        }
    }

    private static func loadSource() -> String {
        if let url = Bundle.main.url(forResource: "curry-menu-master", withExtension: "yaml"),
           let source = try? String(contentsOf: url, encoding: .utf8) {
            return source
        }
        return fallbackYAML
    }

    private static func parse(_ source: String) -> [CurryMenuMasterEntry] {
        var entries: [CurryMenuMasterEntry] = []
        var currentGroup: CurryMenuGroup?
        var currentName: String?
        var currentPrice: Int?
        var currentComment: String?

        func flushCurrentItem() {
            guard
                let group = currentGroup,
                let name = currentName,
                let price = currentPrice,
                let comment = currentComment
            else { return }
            entries.append(
                CurryMenuMasterEntry(
                    group: group,
                    name: name,
                    price: price,
                    comment: comment
                )
            )
            currentName = nil
            currentPrice = nil
            currentComment = nil
        }

        for rawLine in source.components(separatedBy: .newlines) {
            if rawLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }

            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)

            if !rawLine.hasPrefix(" "), trimmed.hasSuffix(":") {
                flushCurrentItem()
                currentGroup = CurryMenuGroup(rawValue: String(trimmed.dropLast()))
                continue
            }

            if trimmed.hasPrefix("- ") {
                flushCurrentItem()
                let firstKey = String(trimmed.dropFirst(2))
                if firstKey.hasPrefix("name:") {
                    currentName = parseValue(from: firstKey)
                }
                continue
            }

            if trimmed.hasPrefix("name:") {
                currentName = parseValue(from: trimmed)
            } else if trimmed.hasPrefix("price:") {
                currentPrice = Int(parseValue(from: trimmed))
            } else if trimmed.hasPrefix("comment:") {
                currentComment = parseValue(from: trimmed)
            }
        }

        flushCurrentItem()
        return entries
    }

    private static func parseValue(from line: String) -> String {
        guard let separator = line.firstIndex(of: ":") else { return "" }
        return line[line.index(after: separator)...]
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "\"", with: "")
    }

    private static func makeID(for name: String, index: Int) -> String {
        switch name {
        case "THE牛カレー":
            return "the-gyu-curry"
        case "手仕込ささみカツ(2本)カレー":
            return "handmade-chicken-tender-cutlet-curry"
        case "桜えびとあさりの春野菜カレー":
            return "sakura-shrimp-asari-spring-vegetable-curry"
        case "ロースカツカレー":
            return "loin-cutlet-curry"
        case "ポークカレー":
            return "pork-curry"
        case "甘口ポークカレー":
            return "mild-pork-curry"
        case "チキンにこみカレー":
            return "stewed-chicken-curry"
        case "フライドチキン(5個)カレー":
            return "fried-chicken-curry"
        case "ハンバーグ(2個)カレー":
            return "hamburger-curry"
        case "豚しゃぶカレー":
            return "pork-shabu-curry"
        case "メンチカツカレー":
            return "minced-cutlet-curry"
        case "ソーセージ(4本)カレー":
            return "sausage-curry"
        case "チキンカツカレー":
            return "chicken-cutlet-curry"
        case "パリパリチキンカレー":
            return "crispy-chicken-curry"
        case "ビーフカレー":
            return "beef-curry"
        case "手仕込とんかつカレー":
            return "handmade-tonkatsu-curry"
        case "牛すじ煮込みカレー":
            return "stewed-beef-tendon-curry"
        case "プチエビフライカレー":
            return "petite-shrimp-fry-curry"
        case "フィッシュフライ(2本)カレー":
            return "fish-fry-curry"
        case "たっぷりあさりカレー":
            return "asari-clam-curry"
        case "イカカレー":
            return "squid-curry"
        case "エビにこみカレー":
            return "stewed-shrimp-curry"
        case "エビあさりカレー":
            return "shrimp-asari-curry"
        case "海の幸カレー":
            return "seafood-curry"
        case "なす(6個)カレー":
            return "eggplant-curry"
        case "ほうれん草カレー":
            return "spinach-curry"
        case "やさいカレー":
            return "vegetable-curry"
        case "とろ～りたまフライカレー":
            return "runny-egg-fry-curry"
        case "ココイチベジカレー":
            return "cocoichi-vegetarian-curry"
        case "オムカレー":
            return "omelet-curry"
        case "低糖質カレー":
            return "low-carb-curry"
        case "納豆カレー":
            return "natto-curry"
        case "スクランブルエッグカレー":
            return "scrambled-egg-curry"
        case "チーズカレー":
            return "cheese-curry"
        case "クリームコロッケ(カニ入り）(2個)カレー":
            return "crab-cream-croquette-curry"
        case "きのこカレー":
            return "mushroom-curry"
        default:
            let base = name
                .lowercased()
                .replacingOccurrences(of: " ", with: "-")
                .replacingOccurrences(of: "　", with: "-")
            return base.isEmpty ? "curry-\(index)" : "\(base)-\(index)"
        }
    }

    private static func makeTags(for entry: CurryMenuMasterEntry) -> [MenuTag] {
        var tags: [MenuTag] = []

        if entry.group == .limitedTime || entry.comment.contains("限定") || entry.comment.contains("今だけ") || entry.comment.contains("人気") {
            tags.append(.recommended)
        }
        if entry.comment.contains("定番") || entry.comment.contains("王道") {
            tags.append(.staple)
        }
        if entry.name.contains("ビーフ") || entry.name.contains("ロースカツ") || entry.name.contains("チーズ") || entry.comment.contains("香ば") {
            tags.append(.rich)
        }
        if entry.comment.contains("辛") || entry.name.contains("スパイス") {
            tags.append(.spicy)
        }
        if tags.isEmpty {
            tags.append(entry.group == .meat ? .staple : .recommended)
        }

        return Array(Set(tags)).sorted { $0.rawValue < $1.rawValue }
    }

    private static func makeKeywords(for entry: CurryMenuMasterEntry) -> [String] {
        let candidates = [
            entry.group.rawValue,
            entry.name,
            entry.comment,
            "限定",
            "肉",
            "魚介",
            "野菜",
            "チキン",
            "ポーク",
            "ビーフ",
            "えび",
            "海老",
            "チーズ"
        ]

        return candidates.filter { keyword in
            entry.group.rawValue.contains(keyword) || entry.name.contains(keyword) || entry.comment.contains(keyword)
        }
    }

    private static func makeRecommendedToppings(for entry: CurryMenuMasterEntry) -> [String] {
        switch entry.group {
        case .limitedTime:
            return entry.name.contains("海老") || entry.name.contains("えび") ? ["egg"] : ["cheese", "egg"]
        case .meat:
            if entry.name.contains("ロースカツ") {
                return ["spinach", "cheese"]
            }
            if entry.name.contains("チキン") {
                return ["egg", "cheese"]
            }
            return ["egg", "spinach"]
        case .seafood:
            return ["egg", "spinach"]
        case .vegetableAndOther:
            return entry.name.contains("チーズ") ? ["spinach"] : ["cheese", "spinach"]
        }
    }

    private static let fallbackYAML = """
    期間限定:
      - name: THE牛カレー
        price: 1120
        comment: 牛の旨みを強く打ち出した数量限定の一皿
      - name: 手仕込ささみカツ(2本)カレー
        price: 1082
        comment: 手仕込のささみカツで食べごたえを足せる限定メニュー
      - name: 桜えびとあさりの春野菜カレー
        price: 920
        comment: 春らしい具材を重ねて軽やかに楽しめる限定カレー

    肉類のカレー:
      - name: ポークカレー
        price: 588
        comment: 迷った時に戻れるベーシックな一皿
      - name: 甘口ポークカレー
        price: 588
        comment: 辛さを抑えてやさしく楽しめる定番
      - name: ビーフカレー
        price: 722
        comment: コクをしっかり味わいたい日に向く
      - name: チキンにこみカレー
        price: 850
        comment: やわらかなチキンをソースになじませた一皿
      - name: フライドチキン(5個)カレー
        price: 865
        comment: 食べごたえのあるフライドチキンが主役
      - name: ハンバーグ(2個)カレー
        price: 888
        comment: ハンバーグをしっかり楽しめる満足感重視
      - name: 豚しゃぶカレー
        price: 893
        comment: 軽やかな豚しゃぶで食べ進めやすい
      - name: メンチカツカレー
        price: 884
        comment: 旨みのあるメンチカツで気分を変えられる
      - name: ソーセージ(4本)カレー
        price: 904
        comment: ソーセージの塩気でリズムよく食べられる
      - name: チキンカツカレー
        price: 904
        comment: 王道の揚げもの気分に応えるバランス型
      - name: パリパリチキンカレー
        price: 904
        comment: 香ばしい食感を前面に楽しめる人気メニュー
      - name: ロースカツカレー
        price: 908
        comment: サクッとした王道の満足感がある定番
      - name: 手仕込とんかつカレー
        price: 1084
        comment: 手仕込ならではの厚みをしっかり味わえる
      - name: 牛すじ煮込みカレー
        price: 1030
        comment: 煮込みの旨みを深く感じたい時に向く

    魚介類のカレー:
      - name: プチエビフライカレー
        price: 748
        comment: 小ぶりなエビフライで軽快に食べ進められる
      - name: フィッシュフライ(2本)カレー
        price: 780
        comment: 白身フライの食感で満足感を足せる
      - name: たっぷりあさりカレー
        price: 780
        comment: あさりの旨みを前面に感じられる一皿
      - name: イカカレー
        price: 828
        comment: イカの食感で海鮮らしさをしっかり楽しめる
      - name: エビにこみカレー
        price: 828
        comment: エビの旨みをソースになじませて味わえる
      - name: エビあさりカレー
        price: 804
        comment: エビとあさりをまとめて楽しめる定番の魚介系
      - name: 海の幸カレー
        price: 924
        comment: 魚介をしっかり入れて満足感を高めた一皿

    野菜類・その他のカレー:
      - name: なす(6個)カレー
        price: 751
        comment: なすのやわらかさで軽やかに食べ進められる
      - name: ほうれん草カレー
        price: 817
        comment: ほうれん草の風味を素直に感じられる一皿
      - name: やさいカレー
        price: 835
        comment: 野菜をしっかり楽しみたい時の定番
      - name: とろ～りたまフライカレー
        price: 769
        comment: とろけるたまごのコクでやさしくまとまる
      - name: ココイチベジカレー
        price: 621
        comment: 動物性原材料を使わず軽やかに楽しめる
      - name: オムカレー
        price: 709
        comment: たまごのまろやかさで食べやすく仕上がる
      - name: 低糖質カレー
        price: 660
        comment: 糖質を抑えつつカレー気分を満たせる
      - name: 納豆カレー
        price: 740
        comment: 納豆の風味で好みをはっきり出せる一皿
      - name: スクランブルエッグカレー
        price: 788
        comment: ふんわりたまごでソースをやさしく受け止める
      - name: チーズカレー
        price: 828
        comment: まろやかさをしっかり足したい時の定番
      - name: クリームコロッケ(カニ入り）(2個)カレー
        price: 808
        comment: クリーミーなコロッケで濃厚さを重ねられる
      - name: きのこカレー
        price: 808
        comment: きのこの香りで落ち着いた味わいに寄せられる
    """
}
