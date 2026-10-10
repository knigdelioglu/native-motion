#if canImport(SwiftUI)
import SwiftUI

/// A secondary action in a native menu. Hosts own action effects and labels.
public struct MotionSplitAction: Identifiable {
    public let id: String
    public let title: LocalizedStringKey
    public let systemImage: String?
    public let isEnabled: Bool
    public let action: () -> Void

    public init(
        _ id: String,
        title: LocalizedStringKey,
        systemImage: String? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.isEnabled = isEnabled
        self.action = action
    }
}

/// Independent primary button and native secondary Menu.
/// The menu never executes the primary action and stays unavailable while
/// loading. Disabled secondary options remain visible but cannot execute.
public struct MotionSplitButton: View {
    private let title: LocalizedStringKey
    private let menuLabel: LocalizedStringKey
    private let variant: MotionButtonVariant
    private let size: MotionButtonSize
    private let phase: MotionButtonPhase
    private let actions: [MotionSplitAction]
    private let primaryAction: () -> Void

    @Environment(\.colorScheme) private var scheme
    @Environment(\.isEnabled) private var environmentEnabled
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion
    @Environment(\.nativeMotionOffscreenPreview) private var offscreen
    @ScaledMetric(relativeTo: .body) private var textScale: CGFloat = 1

    public init(
        _ title: LocalizedStringKey,
        menuLabel: LocalizedStringKey = "More actions",
        variant: MotionButtonVariant = .primary,
        size: MotionButtonSize = .medium,
        phase: MotionButtonPhase = .idle,
        actions: [MotionSplitAction],
        primaryAction: @escaping () -> Void
    ) {
        assert(
            MotionSplitButtonPolicy.identifiersAreUnique(actions.map(\.id)),
            "MotionSplitAction IDs must be unique within a split button"
        )
        self.title = title
        self.menuLabel = menuLabel
        self.variant = variant
        self.size = size
        self.phase = phase
        self.actions = actions
        self.primaryAction = primaryAction
    }

    private var reduceMotion: Bool { systemReduceMotion || previewReduceMotion }

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

    private var borderColor: Color {
        switch variant {
        case .secondary, .destructive: return color(.border)
        case .primary, .ghost: return .clear
        }
    }

    private var height: CGFloat {
        #if os(macOS)
        let desktop = true
        #else
        let desktop = false
        #endif
        return CGFloat(MotionIconButtonPolicy.side(for: size, onMac: desktop))
            * textScale
    }

    private var menuEnabled: Bool {
        MotionSplitButtonPolicy.canOpenMenu(
            isLoading: phase == .loading,
            enabledAlternativeCount: actions.filter(\.isEnabled).count
        )
    }

    @ViewBuilder
    private var primarySymbol: some View {
        switch phase {
        case .idle:
            EmptyView()
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
            Image(systemName: "exclamationmark.circle")
                .accessibilityHidden(true)
        }
    }

    private var phaseValue: Text {
        switch phase {
        case .idle: return Text("")
        case .loading: return Text("In progress")
        case .success: return Text("Completed")
        case .failure: return Text("Failed")
        }
    }

    public var body: some View {
        HStack(spacing: 0) {
            Button {
                guard phase != .loading, environmentEnabled else { return }
                primaryAction()
            } label: {
                HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
                    primarySymbol
                    Text(title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .font(.system(.body, design: .default, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(minHeight: height)
                .padding(.horizontal, 16 * textScale)
                .contentShape(Rectangle())
            }
            .buttonStyle(MotionSplitPressStyle())
            .disabled(phase == .loading)
            .accessibilityLabel(Text(title))
            .accessibilityValue(phaseValue)

            Rectangle()
                .fill(borderColor == .clear ? foreground.opacity(0.22) : borderColor)
                .frame(width: 1, height: height * 0.55)
                .accessibilityHidden(true)

            Menu {
                ForEach(actions) { item in
                    Button {
                        guard phase != .loading, environmentEnabled,
                              item.isEnabled else { return }
                        item.action()
                    } label: {
                        if let image = item.systemImage {
                            Label(item.title, systemImage: image)
                        } else {
                            Text(item.title)
                        }
                    }
                    .disabled(!item.isEnabled)
                }
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 12 * textScale, weight: .semibold))
                    .foregroundStyle(foreground)
                    .frame(width: height, height: height)
                    .contentShape(Rectangle())
            }
            .disabled(!menuEnabled)
            .accessibilityLabel(Text(menuLabel))
            .accessibilityHint(Text("Show alternative actions"))
        }
        .background {
            RoundedRectangle(
                cornerRadius: CGFloat(NativeMotionRadius.control),
                style: .continuous
            )
            .fill(background)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: CGFloat(NativeMotionRadius.control),
                style: .continuous
            )
            .strokeBorder(borderColor, lineWidth: 1)
        }
        .opacity(environmentEnabled ? 1 : 0.55)
        .animation(
            NativeMotionAnimations.spring(.morph, reduceMotion: reduceMotion),
            value: phase
        )
        .fixedSize(horizontal: true, vertical: false)
    }
}

private struct MotionSplitPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let reduced = systemReduceMotion || previewReduceMotion
        return configuration.label
            .scaleEffect(configuration.isPressed && !reduced ? 0.985 : 1)
            .animation(
                NativeMotionAnimations.spring(.responsive, reduceMotion: reduced),
                value: configuration.isPressed
            )
    }
}
#endif
