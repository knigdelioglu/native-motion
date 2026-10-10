#if canImport(SwiftUI)
import SwiftUI

/// Deterministic size/activation behavior for the native icon control.
/// These values deliberately match MotionButton's platform-specific target
/// sizes and can be inspected by the package's macOS tests.
public enum MotionIconButtonPolicy {
    public static func side(for size: MotionButtonSize, onMac: Bool) -> Double {
        if onMac {
            switch size {
            case .small: return 32
            case .medium: return 40
            case .large: return 48
            }
        }
        switch size {
        case .small: return 44
        case .medium: return 48
        case .large: return 56
        }
    }

    public static func canActivate(phase: MotionButtonPhase) -> Bool {
        phase != .loading
    }
}

/// Compact, accessible, app-independent SwiftUI icon action.
///
/// An accessible [label] is mandatory even though the button renders only
/// symbols. Keyboard, VoiceOver, tooltip and disabled state use native SwiftUI
/// semantics. The host owns loading/success/failure transitions.
public struct MotionIconButton: View {
    private let systemName: String
    private let label: LocalizedStringKey
    private let variant: MotionButtonVariant
    private let size: MotionButtonSize
    private let phase: MotionButtonPhase
    private let action: () -> Void

    @Environment(\.colorScheme) private var scheme
    @Environment(\.nativeMotionOffscreenPreview) private var offscreen
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion
    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric(relativeTo: .body) private var dynamicScale: CGFloat = 1

    private var reduceMotion: Bool { systemReduceMotion || previewReduceMotion }

    public init(
        systemName: String,
        label: LocalizedStringKey,
        variant: MotionButtonVariant = .secondary,
        size: MotionButtonSize = .medium,
        phase: MotionButtonPhase = .idle,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.label = label
        self.variant = variant
        self.size = size
        self.phase = phase
        self.action = action
    }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: scheme)
    }

    private var foreground: Color {
        switch variant {
        case .primary: return color(.accentText)
        case .secondary, .ghost: return color(.primaryText)
        case .destructive: return color(.danger)
        }
    }

    private var background: Color {
        switch variant {
        case .primary: return color(.accent)
        case .secondary, .destructive: return color(.surface)
        case .ghost: return .clear
        }
    }

    private var outline: Color {
        switch variant {
        case .secondary, .destructive: return color(.border)
        case .primary, .ghost: return .clear
        }
    }

    private var side: CGFloat {
        #if os(macOS)
        let desktop = true
        #else
        let desktop = false
        #endif
        return CGFloat(MotionIconButtonPolicy.side(for: size, onMac: desktop))
            * dynamicScale
    }

    private var status: Text {
        switch phase {
        case .idle: return Text("")
        case .loading: return Text("In progress")
        case .success: return Text("Completed")
        case .failure: return Text("Failed")
        }
    }

    @ViewBuilder
    private var symbol: some View {
        switch phase {
        case .idle:
            Image(systemName: systemName).accessibilityHidden(true)
        case .loading:
            if offscreen || reduceMotion {
                Image(systemName: "hourglass").accessibilityHidden(true)
            } else {
                ProgressView()
                    .controlSize(.small)
                    .tint(foreground)
                    .accessibilityHidden(true)
            }
        case .success:
            Image(systemName: "checkmark").accessibilityHidden(true)
        case .failure:
            Image(systemName: "exclamationmark.circle").accessibilityHidden(true)
        }
    }

    public var body: some View {
        Button {
            guard MotionIconButtonPolicy.canActivate(phase: phase), isEnabled else {
                return
            }
            action()
        } label: {
            symbol
                .font(.system(size: 17 * dynamicScale, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(width: side, height: side)
                .background {
                    RoundedRectangle(
                        cornerRadius: CGFloat(NativeMotionRadius.control),
                        style: .continuous
                    )
                    .fill(background)
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: CGFloat(NativeMotionRadius.control),
                            style: .continuous
                        )
                        .strokeBorder(outline, lineWidth: 1)
                    }
                }
                .contentShape(RoundedRectangle(
                    cornerRadius: CGFloat(NativeMotionRadius.control)
                ))
                .animation(
                    NativeMotionAnimations.spring(.morph, reduceMotion: reduceMotion),
                    value: phase
                )
        }
        .buttonStyle(MotionIconButtonPressStyle())
        .accessibilityLabel(Text(label))
        .accessibilityValue(status)
        .accessibilityHint(phase == .loading ? Text("Please wait") : Text(""))
        .help(Text(label))
    }
}

private struct MotionIconButtonPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let reduced = systemReduceMotion || previewReduceMotion
        return configuration.label
            .scaleEffect(configuration.isPressed && isEnabled && !reduced ? 0.975 : 1)
            .opacity(isEnabled ? 1 : 0.55)
            .animation(
                NativeMotionAnimations.spring(.responsive, reduceMotion: reduced),
                value: configuration.isPressed
            )
    }
}
#endif
