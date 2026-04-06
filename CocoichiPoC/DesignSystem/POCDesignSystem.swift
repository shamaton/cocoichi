import SwiftUI

enum POCColor {
    static let background = Color(hex: 0xF6F1E7)
    static let elevated = Color(hex: 0xFFF9F0)
    static let elevatedStrong = Color(hex: 0xFFF4E4)
    static let textPrimary = Color(hex: 0x2E221B)
    static let textSecondary = Color(hex: 0x6A5648)
    static let textTertiary = Color(hex: 0x8C7869)
    static let curry = Color(hex: 0x8B4A1F)
    static let cheese = Color(hex: 0xE5B94E)
    static let green = Color(hex: 0x5E7D3B)
    static let red = Color(hex: 0xB84E2F)
    static let cream = Color(hex: 0xF2D7A6)
    static let success = Color(hex: 0x4E7A45)
    static let line = Color(red: 84.0 / 255.0, green: 58.0 / 255.0, blue: 39.0 / 255.0, opacity: 0.12)
}

enum POCSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
}

enum POCRadius {
    static let chip: CGFloat = 10
    static let field: CGFloat = 14
    static let card: CGFloat = 20
    static let hero: CGFloat = 28
    static let cta: CGFloat = 22
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

struct POCBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [POCColor.background, Color.white.opacity(0.65)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .foregroundStyle(POCColor.textPrimary)
        }
}

extension View {
    func pocBackground() -> some View {
        modifier(POCBackground())
    }

    func pocCard() -> some View {
        pocCard(fill: POCColor.elevated)
    }

    func pocCard<S: ShapeStyle>(fill: S) -> some View {
        background(fill, in: RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: POCRadius.card, style: .continuous)
                    .stroke(POCColor.line, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

struct SectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .foregroundStyle(POCColor.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PrimaryCTAButton: View {
    let title: String
    let systemImage: String?
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: POCSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.headline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(Color.white)
            .background(
                RoundedRectangle(cornerRadius: POCRadius.cta, style: .continuous)
                    .fill(isDisabled ? POCColor.curry.opacity(0.35) : POCColor.curry)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

struct SecondaryCTAButton: View {
    let title: String
    let systemImage: String?
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: POCSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.headline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(isDisabled ? POCColor.textTertiary : POCColor.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: POCRadius.cta, style: .continuous)
                    .fill(POCColor.elevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: POCRadius.cta, style: .continuous)
                    .stroke(POCColor.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? chipText : POCColor.textPrimary)
                .padding(.horizontal, POCSpacing.s)
                .padding(.vertical, POCSpacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? chipBackground : POCColor.elevated)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? chipBackground : POCColor.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var chipBackground: Color {
        title == MenuTag.spicy.rawValue ? POCColor.red : POCColor.cheese
    }

    private var chipText: Color {
        title == MenuTag.spicy.rawValue ? .white : POCColor.textPrimary
    }
}

struct StoreContextCard: View {
    let store: Store
    let onChange: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: POCSpacing.m) {
            VStack(alignment: .leading, spacing: POCSpacing.xs) {
                Text("Store: \(store.name)")
                    .font(.headline.weight(.semibold))
                Text("受取目安 \(store.pickupLeadTimeText)")
                    .font(.subheadline)
                    .foregroundStyle(POCColor.textSecondary)
                Text(store.address)
                    .font(.caption)
                    .foregroundStyle(POCColor.textTertiary)
            }

            Spacer()

            Button("Change", action: onChange)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(POCColor.curry)
        }
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }
}

struct PriceLabel: View {
    let amount: Int
    let isDiscount: Bool

    var body: some View {
        Text(amount.yenText)
            .font(isDiscount ? .headline.weight(.semibold) : .title3.weight(.bold))
            .foregroundStyle(isDiscount ? POCColor.success : POCColor.curry)
    }
}

struct SummaryRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(POCColor.textSecondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct EmptyStateCard: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            Text(title)
                .font(.headline.weight(.semibold))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(POCColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(POCSpacing.m)
        .pocCard(fill: POCColor.elevated)
    }
}

struct HeroBanner: View {
    let eyebrow: String
    let title: String
    let accent: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: POCSpacing.s) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.white.opacity(0.8))

            Text(title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(POCSpacing.l)
        .background(
            LinearGradient(colors: accent, startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: POCRadius.hero, style: .continuous)
        )
        .shadow(color: accent.last?.opacity(0.25) ?? .clear, radius: 18, x: 0, y: 10)
    }
}

extension Int {
    var yenText: String {
        "\(self)円"
    }
}
