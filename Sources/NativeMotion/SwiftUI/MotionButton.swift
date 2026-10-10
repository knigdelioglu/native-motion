#if canImport(SwiftUI)
import SwiftUI

public enum MotionButtonVariant: String, CaseIterable, Sendable {
    case primary, secondary, ghost, destructive
}
public enum MotionButtonSize: String, CaseIterable, Sendable {
    case small, medium, large

    fileprivate var height: CGFloat {
        #if os(macOS)
        switch self {
        case .small: return 32
        case .medium: return 40
        case .large: return 48
        }
        #else
        switch self {
        case .small: return 44
        case .medium: return 48
        case .large: return 56
        }
        #endif
    }
    fileprivate var horizontalPadding: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 20
        }
    }
}
public enum MotionButtonPhase: String, CaseIterable, Sendable {
    case idle, loading, success, failure
}

/// A native control without app services. The host owns work and phase changes.
public struct MotionButton: View {
    private let title: LocalizedStringKey
    private let variant: MotionButtonVariant
    private let size: MotionButtonSize
    private let phase: MotionButtonPhase
    private let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .body) private var textScale: CGFloat = 1

    public init(
        _ title: LocalizedStringKey,
        variant: MotionButtonVariant = .primary,
        size: MotionButtonSize = .medium,
        phase: MotionButtonPhase = .idle,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.phase = phase
        self.action = action
    }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: colorScheme)
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
    private var stroke: Color {
        switch variant {
        case .secondary, .destructive: return color(.border)
        case .primary, .ghost: return .clear
        }
    }

    @ViewBuilder
    private var phaseSymbol: some View {
        switch phase {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView().controlSize(.small).tint(foreground).accessibilityHidden(true)
        case .success:
            Image(systemName: "checkmark").accessibilityHidden(true)
        case .failure:
            Image(systemName: "exclamationmark.circle").accessibilityHidden(true)
        }
    }

    public var body: some View {
        Button {
            // Keep keyboard focus during loading; ignore duplicate activations.
            guard phase != .loading else { return }
            action()
        } label: {
            HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
                phaseSymbol.transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.85)))
                Text(title)
                    .font(.system(.body, design: .default, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, size.horizontalPadding * textScale)
            .frame(minHeight: size.height * textScale)
            .background {
                RoundedRectangle(cornerRadius: CGFloat(NativeMotionRadius.control), style: .continuous)
                    .fill(background)
                    .overlay {
                        RoundedRectangle(cornerRadius: CGFloat(NativeMotionRadius.control), style: .continuous)
                            .strokeBorder(stroke, lineWidth: 1)
                    }
            }
            .contentShape(RoundedRectangle(cornerRadius: CGFloat(NativeMotionRadius.control)))
            .animation(NativeMotionAnimations.spring(.morph, reduceMotion: reduceMotion), value: phase)
        }
        .buttonStyle(NativeMotionPressStyle())
        .accessibilityValue(accessibilityPhase)
        .accessibilityHint(phase == .loading ? Text("Please wait") : Text(""))
    }

    private var accessibilityPhase: Text {
        switch phase {
        case .idle: return Text("")
        case .loading: return Text("In progress")
        case .success: return Text("Completed")
        case .failure: return Text("Failed")
        }
    }
}

private struct NativeMotionPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && isEnabled && !reduceMotion ? 0.975 : 1)
            .opacity(isEnabled ? 1 : 0.55)
            .animation(
                NativeMotionAnimations.spring(.responsive, reduceMotion: reduceMotion),
                value: configuration.isPressed
            )
    }
}
#endif
