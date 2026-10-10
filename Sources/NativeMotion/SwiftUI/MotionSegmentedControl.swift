#if canImport(SwiftUI)
import SwiftUI

/// A segment with stable identity. IDs must be unique within a control.
public struct MotionSegment: Identifiable {
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

/// A horizontal, scrollable native control with one selection.
/// Ownership of the selected value stays with the host via Binding.
public struct MotionSegmentedControl: View {
    private let label: LocalizedStringKey
    private let segments: [MotionSegment]
    @Binding private var selection: String

    @Namespace private var selectionNamespace
    @FocusState private var focusedID: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion
    private var reduceMotion: Bool { systemReduceMotion || previewReduceMotion }
    @ScaledMetric(relativeTo: .body) private var minimumHeight: CGFloat = 40

    public init(
        _ label: LocalizedStringKey,
        segments: [MotionSegment],
        selection: Binding<String>
    ) {
        self.label = label
        self.segments = segments
        self._selection = selection
    }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: colorScheme)
    }

    private func activate(_ segment: MotionSegment) {
        guard segment.isEnabled, selection != segment.id else { return }
        selection = segment.id
    }

    #if os(macOS)
    private func moveSelection(_ command: MoveCommandDirection) {
        let step: Int
        switch command {
        case .left: step = layoutDirection == .rightToLeft ? 1 : -1
        case .right: step = layoutDirection == .rightToLeft ? -1 : 1
        default: return
        }
        let next = MotionSelectionNavigation.adjacentID(
            from: focusedID ?? selection,
            step: step,
            ids: segments.map(\.id),
            disabledIDs: Set(segments.filter { !$0.isEnabled }.map(\.id))
        )
        if let next {
            selection = next
            focusedID = next
        }
    }
    #endif

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(segments) { segment in
                        let selected = selection == segment.id
                        Button {
                            activate(segment)
                        } label: {
                            HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
                                if let icon = segment.systemImage {
                                    Image(systemName: icon).accessibilityHidden(true)
                                }
                                Text(segment.title)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .font(.system(.body, design: .default, weight: selected ? .semibold : .regular))
                            .foregroundStyle(selected ? color(.primaryText) : color(.secondaryText))
                            .padding(.horizontal, 14)
                            .frame(minHeight: minimumHeight)
                            .background {
                                if selected {
                                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        .fill(color(.surface))
                                        .matchedGeometryEffect(id: "selected-segment", in: selectionNamespace)
                                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.07), radius: 3, y: 1)
                                }
                            }
                            .contentShape(RoundedRectangle(cornerRadius: 9))
                        }
                        .buttonStyle(.plain)
                        .disabled(!segment.isEnabled)
                        .focused($focusedID, equals: segment.id)
                        .accessibilityAddTraits(selected ? .isSelected : [])
                        .accessibilityValue(selected ? Text("Selected") : Text("Not selected"))
                        .id(segment.id)
                    }
                }
                .padding(4)
                .animation(NativeMotionAnimations.spring(.morph, reduceMotion: reduceMotion), value: selection)
            }
            .background {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(color(.background))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(color(.border), lineWidth: 1)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text(label))
            .onAppear { proxy.scrollTo(selection, anchor: .center) }
            .onChange(of: selection) { next in
                withAnimation(NativeMotionAnimations.spring(.gentle, reduceMotion: reduceMotion)) {
                    proxy.scrollTo(next, anchor: .center)
                }
            }
            #if os(macOS)
            .onMoveCommand(perform: moveSelection)
            #endif
        }
    }
}
#endif
