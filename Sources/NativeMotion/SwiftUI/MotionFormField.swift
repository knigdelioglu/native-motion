#if canImport(SwiftUI)
import SwiftUI

/// Visible form-feedback semantics; errors are not communicated by color alone.
public enum MotionFieldFeedbackStyle: Sendable {
    case hint, success, error
}

public struct MotionFieldFeedback {
    public let message: LocalizedStringKey
    public let style: MotionFieldFeedbackStyle

    public init(_ message: LocalizedStringKey, style: MotionFieldFeedbackStyle) {
        self.message = message
        self.style = style
    }
}

/// Shared original visual shell, not an input recognizer. Platform-native
/// TextField remains responsible for selection, IME, keyboard and VoiceOver.
struct MotionFieldShell<Content: View>: View {
    let label: LocalizedStringKey
    let feedback: MotionFieldFeedback?
    let focused: Bool
    let isEnabled: Bool
    @ViewBuilder let content: () -> Content

    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: scheme)
    }

    var body: some View {
        let reduced = systemReduceMotion || previewReduceMotion
        let hasError = feedback?.style == .error
        let border = hasError ? color(.danger) : (focused ? color(.accent) : color(.border))
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color(.primaryText))
            content()
                .frame(minHeight: 44)
                .padding(.horizontal, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color(.surface))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(border, lineWidth: focused || hasError ? 1.5 : 1)
                }
            if let feedback {
                Text(feedback.message)
                    .font(.caption)
                    .foregroundStyle(
                        feedback.style == .error ? color(.danger) :
                            (feedback.style == .success ? color(.success) : color(.secondaryText))
                    )
                    .accessibilityAddTraits(feedback.style == .error ? .isStaticText : [])
            }
        }
        .opacity(isEnabled ? 1 : 0.6)
        .animation(
            NativeMotionAnimations.spring(.responsive, reduceMotion: reduced),
            value: focused
        )
        .animation(
            NativeMotionAnimations.spring(.responsive, reduceMotion: reduced),
            value: hasError
        )
    }
}
#endif
