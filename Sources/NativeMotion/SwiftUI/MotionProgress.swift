#if canImport(SwiftUI)
import SwiftUI

/// Passive native progress feedback. Pass nil for indeterminate progress,
/// or a fraction from 0 to 1; inputs outside bounds are safely clamped.
///
/// Progress is entirely owned by the host. Reaching 100% does not imply the
/// task has succeeded: the host must report any completion separately.
public struct MotionProgress: View {
    private let title: LocalizedStringKey
    private let detail: LocalizedStringKey?
    private let fraction: Double?

    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var systemReducedMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReducedMotion
    @Environment(\.nativeMotionOffscreenPreview) private var offscreenPreview

    private var reduced: Bool {
        systemReducedMotion || previewReducedMotion || offscreenPreview
    }

    public init(
        _ title: LocalizedStringKey,
        fraction: Double? = nil,
        detail: LocalizedStringKey? = nil
    ) {
        self.title = title
        self.fraction = fraction
        self.detail = detail
    }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: scheme)
    }

    private var normalized: Double? { MotionProgressPolicy.normalized(fraction) }

    private var valueDescription: Text {
        if let percent = MotionProgressPolicy.percent(fraction) {
            return Text("\(percent)%")
        }
        return Text("In progress")
    }

    @ViewBuilder
    private var progressDisplay: some View {
        if let normalized {
            ProgressView(value: normalized, total: 1)
                .progressViewStyle(.linear)
                .tint(color(.accent))
                .animation(reduced ? nil : NativeMotionAnimations.spring(
                    .gentle, reduceMotion: false
                ), value: normalized)
                .accessibilityHidden(true)
        } else if reduced {
            HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
                Image(systemName: "hourglass")
                    .foregroundStyle(color(.accent))
                Text("In progress")
                    .font(.caption)
                    .foregroundStyle(color(.secondaryText))
            }
            .accessibilityHidden(true)
        } else {
            ProgressView()
                .controlSize(.small)
                .tint(color(.accent))
                .accessibilityHidden(true)
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.medium)) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color(.primaryText))
                Spacer(minLength: 0)
                Text(valueDescription)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(color(.secondaryText))
            }
            progressDisplay
                .frame(maxWidth: .infinity, alignment: .leading)
            if let detail {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(color(.secondaryText))
            }
        }
        .padding(CGFloat(NativeMotionSpacing.large))
        .background {
            RoundedRectangle(cornerRadius: CGFloat(NativeMotionRadius.card))
                .fill(color(.surface))
        }
        .overlay {
            RoundedRectangle(cornerRadius: CGFloat(NativeMotionRadius.card))
                .strokeBorder(color(.border), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(valueDescription)
    }
}
#endif
