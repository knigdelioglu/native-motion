#if canImport(SwiftUI)
import SwiftUI

public enum MotionStatus: String, CaseIterable, Sendable {
    case neutral
    case processing
    case success
    case warning
    case failure

    fileprivate var title: LocalizedStringKey {
        switch self {
        case .neutral: return "Idle"
        case .processing: return "In progress"
        case .success: return "Completed"
        case .warning: return "Attention"
        case .failure: return "Failed"
        }
    }

    fileprivate var symbol: String {
        switch self {
        case .neutral: return "circle"
        case .processing: return "clock"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .failure: return "xmark.circle.fill"
        }
    }

    fileprivate var colorRole: NativeMotionColorRole {
        switch self {
        case .neutral, .processing: return .secondaryText
        case .success: return .success
        case .warning: return .warning
        case .failure: return .danger
        }
    }
}

/// Passive status feedback: display never mutates host work state or claims
/// an operation finished before the host explicitly supplies that status.
public struct MotionStatusIndicator: View {
    private let label: LocalizedStringKey
    private let detail: LocalizedStringKey?
    private let status: MotionStatus

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion
    private var reduceMotion: Bool { systemReduceMotion || previewReduceMotion }

    public init(
        _ label: LocalizedStringKey,
        status: MotionStatus,
        detail: LocalizedStringKey? = nil
    ) {
        self.label = label
        self.status = status
        self.detail = detail
    }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: colorScheme)
    }

    public var body: some View {
        HStack(alignment: .center, spacing: CGFloat(NativeMotionSpacing.medium)) {
            Group {
                if status == .processing && !reduceMotion {
                    ProgressView()
                        .controlSize(.small)
                        .tint(color(status.colorRole))
                } else {
                    Image(systemName: status.symbol)
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundStyle(color(status.colorRole))
            .frame(width: 22)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color(.primaryText))
                if let detail {
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(color(.secondaryText))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(status.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color(status.colorRole))
        }
        .padding(CGFloat(NativeMotionSpacing.medium))
        .background {
            RoundedRectangle(cornerRadius: CGFloat(NativeMotionRadius.control), style: .continuous)
                .fill(color(.surface))
        }
        .overlay {
            RoundedRectangle(cornerRadius: CGFloat(NativeMotionRadius.control), style: .continuous)
                .strokeBorder(color(.border), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}
#endif
