#if canImport(SwiftUI)
import SwiftUI

/// A uniquely identified tab; the caller owns any business/content state.
public struct MotionTabItem: Identifiable {
    public let id: String
    public let title: LocalizedStringKey
    public let systemImage: String?
    public let isEnabled: Bool

    public init(
        _ id: String,
        title: LocalizedStringKey,
        systemImage: String? = nil,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.isEnabled = isEnabled
    }
}

/// Native SwiftUI scrollable tab strip with host-owned selection and content.
///
/// Selection is never silently overwritten when its ID is unknown/disabled.
/// On macOS, arrow-key navigation skips disabled items and does not wrap.
/// Right/left arrows are physical and invert under RTL; up/down follow order.
/// State that must survive switching tabs belongs in the host, not the view.
public struct MotionTabs<Content: View>: View {
    private let label: LocalizedStringKey
    private let tabs: [MotionTabItem]
    @Binding private var selection: String
    private let isEnabled: Bool
    private let content: (String) -> Content

    @Namespace private var tabHighlight
    @FocusState private var focusedID: String?
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion

    public init(
        _ label: LocalizedStringKey,
        tabs: [MotionTabItem],
        selection: Binding<String>,
        isEnabled: Bool = true,
        @ViewBuilder content: @escaping (String) -> Content
    ) {
        assert(
            MotionPresentationPolicies.identifiersAreUnique(tabs.map(\.id)),
            "MotionTabItem IDs must be unique"
        )
        self.label = label
        self.tabs = tabs
        self._selection = selection
        self.isEnabled = isEnabled
        self.content = content
    }

    private var reduceMotion: Bool { systemReduceMotion || previewReduceMotion }
    private var enabledIDs: Set<String> { Set(tabs.filter(\.isEnabled).map(\.id)) }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: scheme)
    }

    private func choose(_ tab: MotionTabItem) {
        guard MotionPresentationPolicies.canSelectTab(
            id: tab.id,
            currentID: selection,
            enabledIDs: enabledIDs,
            controlEnabled: isEnabled
        ) else { return }
        selection = tab.id
    }

    #if os(macOS)
    private func move(from id: String, direction: MoveCommandDirection) {
        guard isEnabled else { return }
        let step: Int
        switch direction {
        case .up: step = -1
        case .down: step = 1
        case .left: step = layoutDirection == .rightToLeft ? 1 : -1
        case .right: step = layoutDirection == .rightToLeft ? -1 : 1
        default: return
        }
        guard let next = MotionPresentationPolicies.adjacentTab(
            from: id,
            step: step,
            ids: tabs.map(\.id),
            disabledIDs: Set(tabs.filter { !$0.isEnabled }.map(\.id))
        ) else { return }
        selection = next
        focusedID = next
    }
    #endif

    public var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.medium)) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CGFloat(NativeMotionSpacing.xSmall)) {
                    ForEach(tabs) { tab in
                        let selected = selection == tab.id
                        Button {
                            choose(tab)
                        } label: {
                            HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
                                if let image = tab.systemImage {
                                    Image(systemName: image)
                                        .accessibilityHidden(true)
                                }
                                Text(tab.title)
                                    .lineLimit(1)
                            }
                            .font(.subheadline.weight(selected ? .semibold : .regular))
                            .foregroundStyle(
                                selected ? color(.primaryText) : color(.secondaryText)
                            )
                            .padding(.horizontal, CGFloat(NativeMotionSpacing.large))
                            .frame(minHeight: 44)
                            .background {
                                if selected {
                                    RoundedRectangle(
                                        cornerRadius: CGFloat(NativeMotionRadius.control),
                                        style: .continuous
                                    )
                                    .fill(color(.elevatedSurface))
                                    .matchedGeometryEffect(id: "selected-tab", in: tabHighlight)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!isEnabled || !tab.isEnabled)
                        .focused($focusedID, equals: tab.id)
                        .accessibilityLabel(Text(tab.title))
                        .accessibilityValue(selected ? Text("Selected") : Text("Not selected"))
                        .accessibilityAddTraits(selected ? .isSelected : [])
                        #if os(macOS)
                        .onMoveCommand { direction in
                            move(from: tab.id, direction: direction)
                        }
                        #endif
                    }
                }
                .padding(4)
            }
            .background {
                RoundedRectangle(
                    cornerRadius: CGFloat(NativeMotionRadius.control),
                    style: .continuous
                )
                .fill(color(.surface))
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: CGFloat(NativeMotionRadius.control),
                    style: .continuous
                )
                .strokeBorder(color(.border), lineWidth: 1)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text(label))

            if tabs.contains(where: { $0.id == selection && $0.isEnabled }) {
                content(selection)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .contain)
            } else {
                Text("No available tab selected")
                    .font(.subheadline)
                    .foregroundStyle(color(.secondaryText))
                    .accessibilityLabel(Text("No available tab selected"))
            }
        }
        .animation(
            NativeMotionAnimations.spring(.morph, reduceMotion: reduceMotion),
            value: selection
        )
    }
}
#endif
