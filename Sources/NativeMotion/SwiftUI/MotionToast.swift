#if canImport(SwiftUI)
import SwiftUI

/// A passive, host-controlled notice with an explicit accessible dismissal.
///
/// The host determines content, severity, and whether a toast is presented.
/// There is no hidden timer, automatic success, or network activity. Place in
/// an overlay or stack chosen by the host; multiple toasts require host queuing.
public struct MotionToast: View {
    private let title: LocalizedStringKey
    private let detail: LocalizedStringKey?
    @Binding private var isPresented: Bool
    private let kind: MotionToastKind
    private let onDismiss: () -> Void

    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var systemReducedMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReducedMotion

    public init(
        _ title: LocalizedStringKey,
        kind: MotionToastKind = .neutral,
        detail: LocalizedStringKey? = nil,
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.title = title
        self.kind = kind
        self.detail = detail
        self._isPresented = isPresented
        self.onDismiss = onDismiss
    }

    private var reduced: Bool {
        systemReducedMotion || previewReducedMotion
    }

    private var role: NativeMotionColorRole {
        switch kind {
        case .neutral: return .accent
        case .success: return .success
        case .warning: return .warning
        case .failure: return .danger
        }
    }

    private var icon: String {
        switch kind {
        case .neutral: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .failure: return "xmark.circle.fill"
        }
    }

    private var statusDescription: Text {
        switch kind {
        case .neutral: return Text("Notice")
        case .success: return Text("Success")
        case .warning: return Text("Warning")
        case .failure: return Text("Error")
        }
    }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: scheme)
    }

    private func dismiss() {
        guard MotionToastPolicy.canDismiss(isPresented: isPresented) else { return }
        isPresented = false
        onDismiss()
    }

    public var body: some View {
        Group {
            if isPresented {
                HStack(alignment: .top, spacing: CGFloat(NativeMotionSpacing.medium)) {
                    Image(systemName: icon)
                        .foregroundStyle(color(role))
                        .font(.title3)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(color(.primaryText))
                        if let detail {
                            Text(detail)
                                .font(.footnote)
                                .foregroundStyle(color(.secondaryText))
                        }
                        statusDescription
                            .font(.caption)
                            .foregroundStyle(color(role))
                    }
                    Spacer(minLength: 4)
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Dismiss notification"))
                }
                .padding(CGFloat(NativeMotionSpacing.medium))
                .background {
                    RoundedRectangle(
                        cornerRadius: CGFloat(NativeMotionRadius.card),
                        style: .continuous
                    )
                    .fill(color(.surface))
                }
                .overlay {
                    RoundedRectangle(
                        cornerRadius: CGFloat(NativeMotionRadius.card),
                        style: .continuous
                    )
                    .strokeBorder(color(.border), lineWidth: 1)
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(Text(title))
                .accessibilityValue(statusDescription)
                .transition(reduced ? .identity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(
            NativeMotionAnimations.spring(.gentle, reduceMotion: reduced),
            value: isPresented
        )
    }
}
#endif
