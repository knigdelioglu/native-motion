#if canImport(SwiftUI)
import SwiftUI

/// Native, non-interactive loading placeholder.
///
/// No data is fetched and no completion is invented. Subtle pulsing runs
/// only while visible and not when Reduce Motion/offscreen preview is active.
/// The placeholder has one semantic announcement, not one per decorative row.
public struct MotionSkeleton: View {
    private let label: LocalizedStringKey
    private let rows: Int
    private let showsAvatar: Bool

    @State private var pulses = false
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var systemReducedMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReducedMotion
    @Environment(\.nativeMotionOffscreenPreview) private var offscreenPreview
    @ScaledMetric(relativeTo: .body) private var lineHeight: CGFloat = 13

    public init(
        _ label: LocalizedStringKey = "Loading content",
        rows: Int = 3,
        showsAvatar: Bool = false
    ) {
        self.label = label
        self.rows = MotionSkeletonPolicy.visibleRows(rows)
        self.showsAvatar = showsAvatar
    }

    private var reduced: Bool {
        systemReducedMotion || previewReducedMotion || offscreenPreview
    }

    private var placeholderColor: Color {
        NativeMotionTheme.color(.border, colorScheme: scheme)
    }

    private func beginPulse() {
        guard !reduced else {
            pulses = false
            return
        }
        pulses = false
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            pulses = true
        }
    }

    public var body: some View {
        HStack(alignment: .top, spacing: CGFloat(NativeMotionSpacing.large)) {
            if showsAvatar {
                Circle()
                    .fill(placeholderColor)
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.medium)) {
                ForEach(0..<rows, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(placeholderColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: lineHeight)
                        .padding(.trailing, index == rows - 1 && rows > 1 ? 70 : 0)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(CGFloat(NativeMotionSpacing.large))
        .background {
            RoundedRectangle(cornerRadius: CGFloat(NativeMotionRadius.card))
                .fill(NativeMotionTheme.color(.surface, colorScheme: scheme))
        }
        .opacity(reduced ? 0.8 : (pulses ? 0.55 : 0.92))
        .onAppear { beginPulse() }
        .onDisappear { pulses = false }
        .onChange(of: reduced) { _ in beginPulse() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text("Loading"))
    }
}
#endif
