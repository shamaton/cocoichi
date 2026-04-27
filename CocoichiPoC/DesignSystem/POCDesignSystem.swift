import MetalKit
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
            .background(POCBackgroundLayer())
            .foregroundStyle(POCColor.textPrimary)
    }
}

struct POCBackgroundLayer: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [POCColor.background, Color.white.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.12),
                    POCColor.background.opacity(0.12),
                    POCColor.elevatedStrong.opacity(0.28),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            WaterWaveBackground(
                fillLevel: 0.16,
                amplitude: 0.045,
                frequency: 8.4,
                speed: 0.95,
                detailAmplitude: 0.016,
                detailFrequency: 21,
                opacity: 0.98
            )
        }
        .ignoresSafeArea()
    }
}

struct POCWaveAccentBackground: View {
    var fillLevel: Float = 0.82
    var amplitude: Float = 0.018
    var frequency: Float = 7.2
    var speed: Float = 1.05
    var detailAmplitude: Float = 0.007
    var detailFrequency: Float = 19
    var opacity: Float = 1

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white.opacity(0.1),
                    POCColor.cream.opacity(0.14),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            WaterWaveBackground(
                fillLevel: fillLevel,
                amplitude: amplitude,
                frequency: frequency,
                speed: speed,
                detailAmplitude: detailAmplitude,
                detailFrequency: detailFrequency,
                opacity: opacity
            )
        }
    }
}

enum POCProgressWaveStage {
    case menuDiscovery
    case basics
    case toppings
    case review

    var fillLevel: Float {
        switch self {
        case .menuDiscovery:
            return 0.8
        case .basics:
            return 0.6
        case .toppings:
            return 0.4
        case .review:
            return 0.2
        }
    }
}

extension View {
    func pocBackground() -> some View {
        modifier(POCBackground())
    }

    func pocProgressWaveBackground(_ stage: POCProgressWaveStage) -> some View {
        background {
            POCWaveAccentBackground(fillLevel: stage.fillLevel)
                .ignoresSafeArea()
        }
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
                Text(store.name)
                    .font(.headline.weight(.semibold))
                Text(store.address)
                    .font(.caption)
                    .foregroundStyle(POCColor.textTertiary)
            }

            Spacer()

            Button(action: onChange) {
                Text("変更")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(POCColor.curry)
                    .padding(.horizontal, POCSpacing.s)
                    .padding(.vertical, POCSpacing.xs)
                    .background(
                        Capsule()
                            .fill(POCColor.elevatedStrong)
                    )
                    .overlay(
                        Capsule()
                            .stroke(POCColor.line, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
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

private struct WaterWaveBackground: View {
    let fillLevel: Float
    let amplitude: Float
    let frequency: Float
    let speed: Float
    let detailAmplitude: Float
    let detailFrequency: Float
    let opacity: Float

    var body: some View {
        Group {
            #if targetEnvironment(simulator)
            WaterWaveFallbackView(
                fillLevel: fillLevel,
                amplitude: amplitude,
                frequency: frequency,
                speed: speed,
                detailAmplitude: detailAmplitude,
                detailFrequency: detailFrequency,
                opacity: opacity
            )
            #else
            WaterWaveMetalView(
                fillLevel: fillLevel,
                amplitude: amplitude,
                frequency: frequency,
                speed: speed,
                detailAmplitude: detailAmplitude,
                detailFrequency: detailFrequency,
                opacity: opacity
            )
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct WaterWaveFallbackView: View {
    let fillLevel: Float
    let amplitude: Float
    let frequency: Float
    let speed: Float
    let detailAmplitude: Float
    let detailFrequency: Float
    let opacity: Float

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let width = size.width
                    let height = size.height
                    let mainAmplitude = CGFloat(amplitude) * height
                    let fineAmplitude = CGFloat(detailAmplitude) * height

                    func surfaceY(at x: CGFloat) -> CGFloat {
                        let normalizedX = max(0, min(1, x / max(width, 1)))
                        let primary = sin((normalizedX * CGFloat(frequency)) + (time * CGFloat(speed))) * mainAmplitude
                        let secondary = sin((normalizedX * CGFloat(detailFrequency)) - (time * CGFloat(speed) * 1.35)) * fineAmplitude
                        return (CGFloat(fillLevel) * height) + primary + secondary
                    }

                    var liquid = Path()
                    liquid.move(to: CGPoint(x: 0, y: surfaceY(at: 0)))

                    let stepCount = max(Int(width / 8), 48)
                    for step in 1...stepCount {
                        let x = width * CGFloat(step) / CGFloat(stepCount)
                        liquid.addLine(to: CGPoint(x: x, y: surfaceY(at: x)))
                    }

                    liquid.addLine(to: CGPoint(x: width, y: height))
                    liquid.addLine(to: CGPoint(x: 0, y: height))
                    liquid.closeSubpath()

                    let liquidGradient = Gradient(colors: [
                        Color(red: 0.99, green: 0.97, blue: 0.93, opacity: Double(opacity)),
                        Color(red: 0.95, green: 0.89, blue: 0.78, opacity: Double(opacity)),
                        Color(red: 0.89, green: 0.79, blue: 0.62, opacity: Double(opacity)),
                    ])
                    context.fill(
                        liquid,
                        with: .linearGradient(
                            liquidGradient,
                            startPoint: CGPoint(x: width * 0.5, y: height * CGFloat(fillLevel) * 0.8),
                            endPoint: CGPoint(x: width * 0.5, y: height)
                        )
                    )

                    var highlight = Path()
                    highlight.move(to: CGPoint(x: 0, y: surfaceY(at: 0)))
                    for step in 1...stepCount {
                        let x = width * CGFloat(step) / CGFloat(stepCount)
                        highlight.addLine(to: CGPoint(x: x, y: surfaceY(at: x)))
                    }

                    context.stroke(
                        highlight,
                        with: .color(Color.white.opacity(0.92)),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )

                    context.addFilter(.blur(radius: 7))
                    context.stroke(
                        highlight,
                        with: .color(Color(red: 0.95, green: 0.88, blue: 0.76, opacity: 0.42)),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                    )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

private struct WaterWaveMetalView: UIViewRepresentable {
    let fillLevel: Float
    let amplitude: Float
    let frequency: Float
    let speed: Float
    let detailAmplitude: Float
    let detailFrequency: Float
    let opacity: Float

    func makeCoordinator() -> WaterWaveRenderer {
        WaterWaveRenderer()
    }

    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView(frame: .zero, device: context.coordinator.device)
        metalView.delegate = context.coordinator
        metalView.backgroundColor = .clear
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.enableSetNeedsDisplay = false
        metalView.isPaused = false
        metalView.isOpaque = false
        metalView.preferredFramesPerSecond = 30
        metalView.framebufferOnly = true
        context.coordinator.update(
            fillLevel: fillLevel,
            amplitude: amplitude,
            frequency: frequency,
            speed: speed,
            detailAmplitude: detailAmplitude,
            detailFrequency: detailFrequency,
            opacity: opacity
        )
        return metalView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.update(
            fillLevel: fillLevel,
            amplitude: amplitude,
            frequency: frequency,
            speed: speed,
            detailAmplitude: detailAmplitude,
            detailFrequency: detailFrequency,
            opacity: opacity
        )
    }
}

private final class WaterWaveRenderer: NSObject, MTKViewDelegate {
    private struct Uniforms {
        var viewport: SIMD4<Float> = .zero
        var wave: SIMD4<Float> = .zero
        var appearance: SIMD4<Float> = .zero
    }

    let device: MTLDevice?

    private let commandQueue: MTLCommandQueue?
    private let pipelineState: MTLRenderPipelineState?
    private let startTime = CACurrentMediaTime()

    private var fillLevel: Float = 0.16
    private var amplitude: Float = 0.045
    private var frequency: Float = 8.4
    private var speed: Float = 0.95
    private var detailAmplitude: Float = 0.016
    private var detailFrequency: Float = 21
    private var opacity: Float = 0.98

    override init() {
        let resolvedDevice = MTLCreateSystemDefaultDevice()
        device = resolvedDevice

        if let resolvedDevice {
            commandQueue = resolvedDevice.makeCommandQueue()
            pipelineState = WaterWaveRenderer.makePipelineState(device: resolvedDevice)
        } else {
            commandQueue = nil
            pipelineState = nil
        }

        super.init()
    }

    func update(
        fillLevel: Float,
        amplitude: Float,
        frequency: Float,
        speed: Float,
        detailAmplitude: Float,
        detailFrequency: Float,
        opacity: Float
    ) {
        self.fillLevel = fillLevel
        self.amplitude = amplitude
        self.frequency = frequency
        self.speed = speed
        self.detailAmplitude = detailAmplitude
        self.detailFrequency = detailFrequency
        self.opacity = opacity
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard
            let commandQueue,
            let pipelineState,
            let descriptor = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable
        else {
            return
        }

        var uniforms = Uniforms(
            viewport: SIMD4(
                Float(view.drawableSize.width),
                Float(view.drawableSize.height),
                Float(CACurrentMediaTime() - startTime),
                fillLevel
            ),
            wave: SIMD4(amplitude, frequency, speed, detailAmplitude),
            appearance: SIMD4(detailFrequency, opacity, 0, 0)
        )

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private static func makePipelineState(device: MTLDevice) -> MTLRenderPipelineState? {
        do {
            let library = try device.makeLibrary(source: shaderSource, options: nil)
            guard let vertexFunction = library.makeFunction(name: "waterVertex"),
                  let fragmentFunction = library.makeFunction(name: "waterFragment") else {
                return nil
            }

            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = fragmentFunction
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Metal water background setup failed: \(error)")
            return nil
        }
    }

    private static let shaderSource = """
    #include <metal_stdlib>
    using namespace metal;

    struct Uniforms {
        float4 viewport;
        float4 wave;
        float4 appearance;
    };

    struct RasterizerData {
        float4 position [[position]];
        float2 uv;
    };

    vertex RasterizerData waterVertex(uint vertexID [[vertex_id]]) {
        const float2 positions[4] = {
            float2(-1.0, -1.0),
            float2( 1.0, -1.0),
            float2(-1.0,  1.0),
            float2( 1.0,  1.0)
        };

        const float2 uvs[4] = {
            float2(0.0, 1.0),
            float2(1.0, 1.0),
            float2(0.0, 0.0),
            float2(1.0, 0.0)
        };

        RasterizerData out;
        out.position = float4(positions[vertexID], 0.0, 1.0);
        out.uv = uvs[vertexID];
        return out;
    }

    fragment float4 waterFragment(RasterizerData in [[stage_in]], constant Uniforms& uniforms [[buffer(0)]]) {
        float2 uv = in.uv;
        float time = uniforms.viewport.z;
        float fillLevel = uniforms.viewport.w;

        float amplitude = uniforms.wave.x;
        float frequency = uniforms.wave.y;
        float speed = uniforms.wave.z;
        float detailAmplitude = uniforms.wave.w;

        float detailFrequency = uniforms.appearance.x;
        float opacity = uniforms.appearance.y;

        float primaryWave = sin((uv.x * frequency) + (time * speed)) * amplitude;
        float secondaryWave = sin((uv.x * detailFrequency) - (time * speed * 1.35)) * detailAmplitude;
        float surfaceY = fillLevel + primaryWave + secondaryWave;

        float liquidMask = smoothstep(surfaceY - 0.004, surfaceY + 0.06, uv.y);
        float depth = saturate((uv.y - surfaceY) / max(1.0 - surfaceY, 0.001));
        float shimmer = 0.5 + 0.5 * sin((uv.x * 18.0) - (time * 0.7) + (uv.y * 10.0));
        float highlight = 1.0 - smoothstep(0.001, 0.02, abs(uv.y - surfaceY));
        float surfaceBand = 1.0 - smoothstep(0.0, 0.012, abs(uv.y - surfaceY));
        float undersideGlow = (1.0 - smoothstep(0.0, 0.08, uv.y - surfaceY)) * liquidMask;

        float3 topColor = float3(0.99, 0.97, 0.93);
        float3 bottomColor = float3(0.89, 0.79, 0.62);
        float3 warmTint = float3(0.95, 0.87, 0.72);
        float3 bodyColor = mix(topColor, bottomColor, depth);
        bodyColor = mix(bodyColor, warmTint, depth * 0.28);
        bodyColor += (0.045 * shimmer) * (1.0 - depth);
        bodyColor += 0.28 * highlight;
        bodyColor += 0.16 * surfaceBand;
        bodyColor += 0.1 * undersideGlow;

        float alpha = liquidMask * opacity;
        alpha += highlight * 0.2 * opacity;
        alpha += surfaceBand * 0.14;
        alpha = min(alpha, 1.0);

        return float4(bodyColor, alpha);
    }
    """
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
