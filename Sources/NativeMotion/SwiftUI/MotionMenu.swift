#if canImport(SwiftUI)
import SwiftUI

/// One native menu action. The caller owns all side effects.
public struct MotionMenuAction: Identifiable {
    public let id: String
    public let title: LocalizedStringKey
    public let systemImage: String?
    public let role: ButtonRole?
    public let isEnabled: Bool
    public let action: () -> Void

    public init(
        _ id: String,
        title: LocalizedStringKey,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.isEnabled = isEnabled
        self.action = action
    }
}

/// App-independent native menu with accessibility and keyboard behavior
/// delegated to SwiftUI. Disabled entries remain visible but cannot execute.
public struct MotionMenu: View {
    private let label: LocalizedStringKey
    private let systemImage: String?
    private let actions: [MotionMenuAction]
    private let isEnabled: Bool

    @Environment(\.colorScheme) private var scheme

    public init(
        _ label: LocalizedStringKey,
        systemImage: String? = "ellipsis.circle",
        actions: [MotionMenuAction],
        isEnabled: Bool = true
    ) {
        assert(
            MotionOverlayPolicies.identifiersAreUnique(actions.map(\.id)),
            "MotionMenuAction IDs must be unique"
        )
        self.label = label
        self.systemImage = systemImage
        self.actions = actions
        self.isEnabled = isEnabled
    }

    private var menuEnabled: Bool {
        MotionOverlayPolicies.canOpenMenu(
            isEnabled: isEnabled,
            enabledActionCount: actions.filter(\.isEnabled).count
        )
    }

    public var body: some View {
        Menu {
            ForEach(actions) { item in
                Button(role: item.role) {
                    guard menuEnabled, item.isEnabled else { return }
                    item.action()
                } label: {
                    if let icon = item.systemImage {
                        Label(item.title, systemImage: icon)
                    } else {
                        Text(item.title)
                    }
                }
                .disabled(!item.isEnabled)
            }
        } label: {
            HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .accessibilityHidden(true)
                }
                Text(label).font(.body.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(
                NativeMotionTheme.color(.primaryText, colorScheme: scheme)
            )
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .background {
                RoundedRectangle(
                    cornerRadius: CGFloat(NativeMotionRadius.control),
                    style: .continuous
                )
                .fill(NativeMotionTheme.color(.surface, colorScheme: scheme))
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: CGFloat(NativeMotionRadius.control),
                    style: .continuous
                )
                .strokeBorder(NativeMotionTheme.color(.border, colorScheme: scheme))
            }
        }
        .disabled(!menuEnabled)
        .accessibilityLabel(Text(label))
        .accessibilityHint(Text("Show available actions"))
    }
}
#endif
