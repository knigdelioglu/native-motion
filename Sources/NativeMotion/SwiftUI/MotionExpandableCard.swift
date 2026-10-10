#if canImport(SwiftUI)
import SwiftUI

/// A disclosure surface that keeps its expansion state in the host.
///
/// The header is a semantic Button, while expanded content retains its own
/// accessibility and interaction tree (including nested controls).
public struct MotionExpandableCard<Content: View>: View {
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey?
    @Binding private var isExpanded: Bool
    private let content: Content

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion
    private var reduceMotion: Bool { systemReduceMotion || previewReduceMotion }
    @ScaledMetric(relativeTo: .body) private var inset: CGFloat = 16

    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self._isExpanded = isExpanded
        self.content = content()
    }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: colorScheme)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(NativeMotionAnimations.spring(.gentle, reduceMotion: reduceMotion)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(color(.primaryText))
                        if let subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(color(.secondaryText))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(color(.secondaryText))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .accessibilityHidden(true)
                }
                .padding(inset)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(title))
            .accessibilityValue(isExpanded ? Text("Expanded") : Text("Collapsed"))
            .accessibilityHint(isExpanded ? Text("Collapse details") : Text("Expand details"))

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Divider().accessibilityHidden(true)
                    content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(inset)
                }
                .transition(reduceMotion ? .identity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .background {
            RoundedRectangle(cornerRadius: CGFloat(NativeMotionRadius.card), style: .continuous)
                .fill(color(.surface))
        }
        .overlay {
            RoundedRectangle(cornerRadius: CGFloat(NativeMotionRadius.card), style: .continuous)
                .strokeBorder(color(.border), lineWidth: 1)
        }
        .animation(NativeMotionAnimations.spring(.gentle, reduceMotion: reduceMotion), value: isExpanded)
    }
}
#endif
