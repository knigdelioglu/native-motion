#if canImport(SwiftUI)
import SwiftUI

public struct MotionAccordionItem: Identifiable {
    public let id: String
    public let title: LocalizedStringKey
    public let detail: LocalizedStringKey?
    public let isEnabled: Bool

    public init(
        _ id: String,
        title: LocalizedStringKey,
        detail: LocalizedStringKey? = nil,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.isEnabled = isEnabled
    }
}

/// Controlled single- or multiple-expansion native accordion.
/// Disabled entries stay visible. Nested buttons belong to separate
/// disclosure content, not inside a parent header action.
public struct MotionAccordion<Content: View>: View {
    private let label: LocalizedStringKey
    private let items: [MotionAccordionItem]
    @Binding private var expandedIDs: Set<String>
    private let allowsMultiple: Bool
    private let isEnabled: Bool
    private let content: (String) -> Content

    public init(
        _ label: LocalizedStringKey,
        items: [MotionAccordionItem],
        expandedIDs: Binding<Set<String>>,
        allowsMultiple: Bool = false,
        isEnabled: Bool = true,
        @ViewBuilder content: @escaping (String) -> Content
    ) {
        assert(
            MotionDisclosurePolicies.identifiersAreUnique(items.map(\.id)),
            "MotionAccordionItem IDs must be unique"
        )
        self.label = label
        self.items = items
        self._expandedIDs = expandedIDs
        self.allowsMultiple = allowsMultiple
        self.isEnabled = isEnabled
        self.content = content
    }

    private var enabledIDs: Set<String> {
        Set(items.filter(\.isEnabled).map(\.id))
    }

    private func expansion(for item: MotionAccordionItem) -> Binding<Bool> {
        Binding(
            get: { expandedIDs.contains(item.id) },
            set: { requested in
                guard requested != expandedIDs.contains(item.id) else { return }
                expandedIDs = MotionDisclosurePolicies.toggle(
                    id: item.id,
                    expandedIDs: expandedIDs,
                    enabledIDs: enabledIDs,
                    allowsMultiple: allowsMultiple,
                    controlEnabled: isEnabled
                )
            }
        )
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.medium)) {
            Text(label)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            ForEach(items) { item in
                MotionDisclosureGroup(
                    item.title,
                    detail: item.detail,
                    isExpanded: expansion(for: item),
                    isEnabled: isEnabled && item.isEnabled
                ) {
                    content(item.id)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
    }
}
#endif
