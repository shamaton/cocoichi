import SwiftUI
import UIKit

struct POCRippleEffect<Trigger: Equatable & Sendable>: ViewModifier, Sendable {
    let origin: CGPoint
    let trigger: Trigger
    var duration: TimeInterval = 0.72
    var amplitude: Double = 9
    var frequency: Double = 22
    var decay: Double = 14
    var speed: Double = 2200

    init(
        at origin: CGPoint,
        trigger: Trigger,
        duration: TimeInterval = 0.72,
        amplitude: Double = 9,
        frequency: Double = 22,
        decay: Double = 14,
        speed: Double = 2200
    ) {
        self.origin = origin
        self.trigger = trigger
        self.duration = duration
        self.amplitude = amplitude
        self.frequency = frequency
        self.decay = decay
        self.speed = speed
    }

    func body(content: Content) -> some View {
        let origin = origin
        let duration = duration
        let amplitude = amplitude
        let frequency = frequency
        let decay = decay
        let speed = speed

        content.keyframeAnimator(
            initialValue: 0.0,
            trigger: trigger
        ) { view, elapsedTime in
            view.modifier(
                POCRippleModifier(
                    origin: origin,
                    elapsedTime: elapsedTime,
                    duration: duration,
                    amplitude: amplitude,
                    frequency: frequency,
                    decay: decay,
                    speed: speed
                )
            )
        } keyframes: { _ in
            MoveKeyframe(0.0)
            LinearKeyframe(duration, duration: duration)
        }
    }
}

private struct POCRippleModifier: ViewModifier, Sendable {
    let origin: CGPoint
    let elapsedTime: TimeInterval
    let duration: TimeInterval
    let amplitude: Double
    let frequency: Double
    let decay: Double
    let speed: Double

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.Ripple(
            .float2(origin),
            .float(elapsedTime),
            .float(amplitude),
            .float(frequency),
            .float(decay),
            .float(speed)
        )

        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: CGSize(width: amplitude, height: amplitude),
                isEnabled: elapsedTime > 0 && elapsedTime < duration
            )
        }
    }
}

extension View {
    func onPOCPressingChanged(_ action: @escaping (CGPoint?) -> Void) -> some View {
        modifier(POCSpatialPressingGestureModifier(action: action))
    }
}

private struct POCSpatialPressingGestureModifier: ViewModifier {
    let onPressingChanged: (CGPoint?) -> Void

    @State private var currentLocation: CGPoint?

    init(action: @escaping (CGPoint?) -> Void) {
        onPressingChanged = action
    }

    func body(content: Content) -> some View {
        content
            .gesture(POCSpatialPressingGesture(location: $currentLocation))
            .onChange(of: currentLocation, initial: false) { _, location in
                onPressingChanged(location)
            }
    }
}

private struct POCSpatialPressingGesture: UIGestureRecognizerRepresentable {
    @Binding var location: CGPoint?

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @objc
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 0
        recognizer.delegate = context.coordinator
        return recognizer
    }

    func handleUIGestureRecognizerAction(
        _ recognizer: UILongPressGestureRecognizer,
        context: Context
    ) {
        switch recognizer.state {
        case .began:
            location = context.converter.localLocation
        case .ended, .cancelled, .failed:
            location = nil
        default:
            break
        }
    }
}
