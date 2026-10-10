#if canImport(SwiftUI)
import SwiftUI

public struct MotionBreadcrumbItem: Identifiable {
    public let id: String
    public let title: String
    public let isEnabled: Bool

    public init(_ id: String, title: String, isEnabled: Bool = true) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
    }
}

/// Host-managed, RTL-aware hierarchy links. Last/current item is a label,
/// while other enabled ancestors are native focusable Buttons.
public struct MotionBreadcrumb: View {
    private let label: LocalizedStringKey
    private let items: [MotionBreadcrumbItem]
    private let currentID: String
    private let onNavigate: (String) -> Void

    @Environment(\.colorScheme) private var scheme
    @Environment(\.layoutDirection) private var direction

    public init(
        _ label: LocalizedStringKey,
        items: [MotionBreadcrumbItem],
        currentID: String,
        onNavigate: @escaping (String) -> Void
    ) {
        assert(MotionNavigationPolicies.unique(items.map(\.id)),
               "MotionBreadcrumbItem IDs must be unique")
        self.label = label
        self.items = items
        self.currentID = currentID
        self.onNavigate = onNavigate
    }

    private var enabledIDs: Set<String> {
        Set(items.filter(\.isEnabled).map(\.id))
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Image(systemName: direction == .rightToLeft
                              ? "chevron.left" : "chevron.right")
                            .font(.caption)
                            .foregroundStyle(NativeMotionTheme.color(
                                .secondaryText, colorScheme: scheme))
                            .accessibilityHidden(true)
                    }
                    if item.id == currentID {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                            .accessibilityAddTraits(.isSelected)
                    } else {
                        Button(item.title) {
                            guard MotionNavigationPolicies.canNavigate(
                                to: item.id, currentID: currentID,
                                enabledIDs: enabledIDs
                            ) else { return }
                            onNavigate(item.id)
                        }
                        .disabled(!item.isEnabled)
                        .buttonStyle(.plain)
                        .font(.subheadline)
                        .foregroundStyle(NativeMotionTheme.color(
                            .accent, colorScheme: scheme))
                    }
                }
            }
            .frame(minHeight: 44)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
    }
}
#endif
