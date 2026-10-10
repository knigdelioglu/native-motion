#if canImport(SwiftUI)
import SwiftUI

public struct MotionSideNavigationItem: Identifiable {
    public let id: String
    public let title: String
    public let systemImage: String?
    public let isEnabled: Bool
    public init(
        _ id: String, title: String, systemImage: String? = nil,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.isEnabled = isEnabled
    }
}

/// Native, scrollable side navigation with host-controlled selection.
public struct MotionSideNavigation: View {
    private let label: LocalizedStringKey
    private let items: [MotionSideNavigationItem]
    @Binding private var selection: String
    private let isEnabled: Bool

    @Environment(\.colorScheme) private var scheme

    public init(
        _ label: LocalizedStringKey,
        items: [MotionSideNavigationItem],
        selection: Binding<String>,
        isEnabled: Bool = true
    ) {
        assert(MotionNavigationPolicies.unique(items.map(\.id)),
               "MotionSideNavigationItem IDs must be unique")
        self.label = label
        self.items = items
        self._selection = selection
        self.isEnabled = isEnabled
    }

    private var enabledIDs: Set<String> {
        Set(items.filter(\.isEnabled).map(\.id))
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.small)) {
                Text(label).font(.headline).accessibilityAddTraits(.isHeader)
                ForEach(items) { item in
                    let selected = selection == item.id
                    Button {
                        guard isEnabled, MotionNavigationPolicies.canNavigate(
                            to: item.id, currentID: selection, enabledIDs: enabledIDs
                        ) else { return }
                        selection = item.id
                    } label: {
                        HStack(spacing: CGFloat(NativeMotionSpacing.medium)) {
                            if let icon = item.systemImage {
                                Image(systemName: icon).accessibilityHidden(true)
                            }
                            Text(item.title)
                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: 44)
                        .padding(.horizontal, CGFloat(NativeMotionSpacing.medium))
                        .background {
                            RoundedRectangle(
                                cornerRadius: CGFloat(NativeMotionRadius.control)
                            )
                            .fill(selected
                                  ? NativeMotionTheme.color(.elevatedSurface, colorScheme: scheme)
                                  : Color.clear)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(!isEnabled || !item.isEnabled)
                    .accessibilityValue(selected ? Text("Selected") : Text(""))
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(CGFloat(NativeMotionSpacing.medium))
        }
        .frame(maxWidth: 280, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
    }
}
#endif
