#if canImport(SwiftUI)
import SwiftUI

/// Precise, bounded value input with a resilient edge gesture.
/// The Binding is the source of truth; onCommit fires only when the user
/// completes an adjustment, not when the host changes the Binding.
public struct MotionElasticSlider: View {
    private let label: LocalizedStringKey
    @Binding private var value: Double
    private let scale: MotionSliderScale
    private let marks: [Double]
    private let isEnabled: Bool
    private let onEditingChanged: ((Bool) -> Void)?
    private let onCommit: ((Double) -> Void)?

    @State private var isDragging = false
    @State private var edgeDisplacement: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion
    private var reduceMotion: Bool { systemReduceMotion || previewReduceMotion }
    @Environment(\.isEnabled) private var environmentEnabled
    @ScaledMetric(relativeTo: .body) private var thumbSize: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var hitHeight: CGFloat = 44

    public init(
        _ label: LocalizedStringKey,
        value: Binding<Double>,
        scale: MotionSliderScale = MotionSliderScale(),
        marks: [Double] = [],
        isEnabled: Bool = true,
        onEditingChanged: ((Bool) -> Void)? = nil,
        onCommit: ((Double) -> Void)? = nil
    ) {
        self.label = label
        self._value = value
        self.scale = scale
        self.marks = Array(Set(marks.filter { $0.isFinite && $0 >= scale.minimum && $0 <= scale.maximum })).sorted()
        self.isEnabled = isEnabled
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }

    private var enabled: Bool { isEnabled && environmentEnabled }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: colorScheme)
    }

    private func updateValue(_ next: Double) {
        guard enabled else { return }
        let snapped = scale.snapped(next)
        if snapped != value { value = snapped }
    }

    private func adjust(_ direction: Int) {
        guard enabled else { return }
        let next = scale.adjacentValue(from: value, direction: direction)
        updateValue(next)
        onCommit?(next)
    }

    private func updateDrag(at point: CGFloat, trackWidth: CGFloat) {
        guard enabled else { return }
        if !isDragging {
            isDragging = true
            onEditingChanged?(true)
        }
        let rawLTR = Double((point - thumbSize / 2) / Swift.max(trackWidth, 1))
        let raw = MotionSliderGeometry.logicalProgress(fromVisual: rawLTR,
                                                       rightToLeft: layoutDirection == .rightToLeft)
        let bounded = Swift.max(0, Swift.min(1, raw))
        updateValue(scale.value(atProgress: bounded))
        guard !reduceMotion else {
            edgeDisplacement = 0
            return
        }
        // Diminishing resistance stops the thumb moving indefinitely outside
        // its physical range. Position resets with a spring on release.
        let overflow = raw - bounded
        let physicalDistance = abs(overflow * Double(trackWidth))
        let resistance = 16 * (1 - 1 / (1 + physicalDistance / 26))
        let direction = overflow < 0 ? -1.0 : 1.0
        let rtlSign = layoutDirection == .rightToLeft ? -1.0 : 1.0
        edgeDisplacement = CGFloat(direction * rtlSign * resistance)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(color(.primaryText))
                Spacer()
                Text(scale.snapped(value), format: .number.precision(.fractionLength(0...2)))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(color(.secondaryText))
            }

            GeometryReader { geometry in
                let span = Swift.max(0, geometry.size.width - thumbSize)
                let fraction = CGFloat(scale.progress(for: value))
                let visual = CGFloat(MotionSliderGeometry.visualProgress(
                    fromLogical: Double(fraction),
                    rightToLeft: layoutDirection == .rightToLeft
                ))
                let filled = span * fraction
                let left = thumbSize / 2
                ZStack {
                    Capsule()
                        .fill(color(.border))
                        .frame(width: span, height: 6)
                        .position(x: geometry.size.width / 2, y: hitHeight / 2)

                    Capsule()
                        .fill(color(.accent))
                        .frame(width: filled, height: 6)
                        .position(
                            x: layoutDirection == .rightToLeft
                                ? geometry.size.width - left - filled / 2
                                : left + filled / 2,
                            y: hitHeight / 2
                        )

                    ForEach(marks, id: \.self) { mark in
                        let position = CGFloat(scale.progress(for: mark))
                        let visualMark = CGFloat(MotionSliderGeometry.visualProgress(
                            fromLogical: Double(position),
                            rightToLeft: layoutDirection == .rightToLeft
                        ))
                        Circle()
                            .fill(color(.secondaryText))
                            .frame(width: 3, height: 3)
                            .position(x: left + visualMark * span, y: hitHeight / 2)
                            .accessibilityHidden(true)
                    }

                    Circle()
                        .fill(color(.surface))
                        .frame(width: thumbSize, height: thumbSize)
                        .overlay {
                            Circle().strokeBorder(color(.accent), lineWidth: 2.5)
                        }
                        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                        .scaleEffect(isDragging && !reduceMotion ? 1.13 : 1)
                        .position(
                            x: left + visual * span + edgeDisplacement,
                            y: hitHeight / 2
                        )
                        .animation(
                            NativeMotionAnimations.spring(.responsive, reduceMotion: reduceMotion),
                            value: isDragging
                        )
                }
                .frame(width: geometry.size.width, height: hitHeight)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            updateDrag(at: gesture.location.x, trackWidth: span)
                        }
                        .onEnded { _ in
                            guard enabled, isDragging else { return }
                            withAnimation(NativeMotionAnimations.spring(.settle, reduceMotion: reduceMotion)) {
                                isDragging = false
                                edgeDisplacement = 0
                            }
                            onEditingChanged?(false)
                            onCommit?(scale.snapped(value))
                        }
                )
            }
            // SwiftUI's native RTL geometry mirroring plus our explicit logical
            // value inversion otherwise mirrors the track twice. Keep the
            // physical track coordinates left-to-right; the value model
            // remains RTL-aware and the surrounding labels keep native RTL.
            .environment(\.layoutDirection, .leftToRight)
            .frame(height: hitHeight)
        }
        .opacity(enabled ? 1 : 0.5)
        .disabled(!isEnabled)
        .focusable(enabled)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text(scale.snapped(value), format: .number.precision(.fractionLength(0...2))))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: adjust(1)
            case .decrement: adjust(-1)
            @unknown default: break
            }
        }
        #if os(macOS)
        .onMoveCommand { direction in
            let step: Int
            switch direction {
            case .left: step = layoutDirection == .rightToLeft ? 1 : -1
            case .right: step = layoutDirection == .rightToLeft ? -1 : 1
            case .up: step = 1
            case .down: step = -1
            default: return
            }
            adjust(step)
        }
        #endif
    }
}
#endif
