#if canImport(SwiftUI)
import SwiftUI

/// A stable radio option with a localized label and explicit availability.
public struct MotionRadioOption: Identifiable {
    public let id: String
    public let title: LocalizedStringKey
    public let isEnabled: Bool

    public init(
        _ id: String,
        title: LocalizedStringKey,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
    }
}

/// Native single-choice group with an externally controlled selection.
///
/// Keyboard navigation on macOS moves to the next enabled option without
/// wrapping and follows physical RTL layout. A missing or disabled externally
/// supplied selection is preserved until the user chooses another value.
public struct MotionRadioGroup: View {
    private let label: LocalizedStringKey
    private let options: [MotionRadioOption]
    @Binding private var selection: String
    private let isEnabled: Bool

    @FocusState private var focusedID: String?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion

    public init(
        _ label: LocalizedStringKey,
        options: [MotionRadioOption],
        selection: Binding<String>,
        isEnabled: Bool = true
    ) {
        assert(
            Set(options.map(\.id)).count == options.count,
            "MotionRadioOption IDs must be unique"
        )
        self.label = label
        self.options = options
        self._selection = selection
        self.isEnabled = isEnabled
    }

    private var reduced: Bool { systemReduceMotion || previewReduceMotion }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: scheme)
    }

    private func activate(_ option: MotionRadioOption) {
        guard isEnabled, option.isEnabled, selection != option.id else { return }
        selection = option.id
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
        let next = MotionSelectionNavigation.adjacentID(
            from: id,
            step: step,
            ids: options.map(\.id),
            disabledIDs: Set(options.filter { !$0.isEnabled }.map(\.id))
        )
        guard let next else { return }
        selection = next
        focusedID = next
    }
    #endif

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundStyle(color(.primaryText))

            VStack(alignment: .leading, spacing: 4) {
                ForEach(options) { option in
                    let selected = selection == option.id
                    Button {
                        activate(option)
                    } label: {
                        HStack(spacing: CGFloat(NativeMotionSpacing.medium)) {
                            Circle()
                                .strokeBorder(
                                    selected ? color(.accent) : color(.border),
                                    lineWidth: 1.8
                                )
                                .background {
                                    Circle()
                                        .fill(selected ? color(.accent) : .clear)
                                        .padding(5)
                                }
                                .frame(width: 22, height: 22)
                                .accessibilityHidden(true)
                            Text(option.title)
                                .font(.body)
                                .foregroundStyle(color(.primaryText))
                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: 44)
                        .padding(.horizontal, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selected ? color(.elevatedSurface) : Color.clear)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!isEnabled || !option.isEnabled)
                    .focused($focusedID, equals: option.id)
                    .accessibilityLabel(Text(option.title))
                    .accessibilityValue(selected ? Text("Selected") : Text("Not selected"))
                    .accessibilityAddTraits(selected ? .isSelected : [])
                    .animation(
                        NativeMotionAnimations.spring(.responsive, reduceMotion: reduced),
                        value: selection
                    )
                    #if os(macOS)
                    .onMoveCommand { direction in
                        move(from: option.id, direction: direction)
                    }
                    #endif
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
    }
}
#endif
