#if canImport(SwiftUI)
import SwiftUI

/// Platform-native right-click/long-press menu with an always-visible
/// accessible "More actions" alternative to gesture-only discovery.
/// Side effects are controlled solely by the host action callbacks.
public struct MotionContextMenu<Trigger: View>: View {
    private let label: LocalizedStringKey
    private let actions: [MotionMenuAction]
    private let isEnabled: Bool
    private let trigger: () -> Trigger

    public init(
        _ label: LocalizedStringKey,
        actions: [MotionMenuAction],
        isEnabled: Bool = true,
        @ViewBuilder trigger: @escaping () -> Trigger
    ) {
        assert(
            MotionCommandPolicies.identifiersAreUnique(actions.map(\.id)),
            "MotionContextMenu actions require unique IDs"
        )
        self.label = label
        self.actions = actions
        self.isEnabled = isEnabled
        self.trigger = trigger
    }

    @ViewBuilder
    private var actionItems: some View {
        ForEach(actions) { item in
            Button(role: item.role) {
                guard isEnabled, item.isEnabled else { return }
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
    }

    public var body: some View {
        HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
            trigger()
                .contentShape(Rectangle())
                .contextMenu {
                    actionItems
                }
            Menu {
                actionItems
            } label: {
                Image(systemName: "ellipsis")
                    .frame(minWidth: 44, minHeight: 44)
            }
            .disabled(!isEnabled || !actions.contains(where: \.isEnabled))
            .accessibilityLabel(Text(label))
            .accessibilityHint(Text("Show context actions"))
        }
    }
}
#endif
