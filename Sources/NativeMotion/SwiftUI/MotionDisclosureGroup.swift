#if canImport(SwiftUI)
import SwiftUI

/// One host-controlled disclosure region. Content may contain another
/// MotionDisclosureGroup; state and business effects stay with the caller.
/// The native DisclosureGroup supplies system keyboard/VoiceOver semantics.
public struct MotionDisclosureGroup<Content: View>: View {
    private let title: LocalizedStringKey
    private let detail: LocalizedStringKey?
    @Binding private var isExpanded: Bool
    private let isEnabled: Bool
    private let content: Content

    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var systemReduced
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduced

    public init(
        _ title: LocalizedStringKey,
        detail: LocalizedStringKey? = nil,
        isExpanded: Binding<Bool>,
        isEnabled: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.detail = detail
        self._isExpanded = isExpanded
        self.isEnabled = isEnabled
        self.content = content()
    }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: scheme)
    }

    public var body: some View {
        let reduced = systemReduced || previewReduced
        DisclosureGroup(isExpanded: $isExpanded) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, CGFloat(NativeMotionSpacing.small))
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(color(.primaryText))
                if let detail {
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(color(.secondaryText))
                }
            }
        }
        .disabled(!isEnabled)
        .tint(color(.accent))
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
        .animation(
            NativeMotionAnimations.spring(.gentle, reduceMotion: reduced),
            value: isExpanded
        )
    }
}
#endif
