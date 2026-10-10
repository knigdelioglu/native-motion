#if canImport(SwiftUI)
import SwiftUI

/// Host-controlled three-state checkbox.
///
/// Hosts can set `.mixed` for partial selection. A user activation converts
/// mixed -> checked, then checked -> unchecked; neither state is inferred from
/// child controls. The button remains accessible via keyboard and VoiceOver.
public struct MotionCheckbox: View {
    private let label: LocalizedStringKey
    @Binding private var state: MotionCheckboxState
    private let isEnabled: Bool

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion

    public init(
        _ label: LocalizedStringKey,
        state: Binding<MotionCheckboxState>,
        isEnabled: Bool = true
    ) {
        self.label = label
        self._state = state
        self.isEnabled = isEnabled
    }

    private var valueDescription: Text {
        switch state {
        case .unchecked: return Text("Unchecked")
        case .checked: return Text("Checked")
        case .mixed: return Text("Partially checked")
        }
    }

    private var isActive: Bool { state != .unchecked }

    public var body: some View {
        let reduced = systemReduceMotion || previewReduceMotion
        let accent = NativeMotionTheme.color(.accent, colorScheme: colorScheme)
        let border = NativeMotionTheme.color(.border, colorScheme: colorScheme)
        let ink = NativeMotionTheme.color(.primaryText, colorScheme: colorScheme)
        Button {
            state = MotionCheckboxPolicy.next(state)
        } label: {
            HStack(spacing: CGFloat(NativeMotionSpacing.medium)) {
                RoundedRectangle(
                    cornerRadius: 5,
                    style: .continuous
                )
                .fill(isActive ? accent : Color.clear)
                .frame(width: 23, height: 23)
                .overlay {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(isActive ? accent : border, lineWidth: 1.5)
                }
                .overlay {
                    Group {
                        switch state {
                        case .unchecked:
                            EmptyView()
                        case .checked:
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                        case .mixed:
                            Image(systemName: "minus")
                                .font(.system(size: 13, weight: .bold))
                        }
                    }
                    .foregroundStyle(
                        NativeMotionTheme.color(.accentText, colorScheme: colorScheme)
                    )
                    .accessibilityHidden(true)
                }
                Text(label)
                    .font(.body)
                    .foregroundStyle(ink)
                Spacer(minLength: 0)
            }
            .frame(minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(valueDescription)
        .accessibilityAddTraits(state == .checked ? .isSelected : [])
        .animation(
            NativeMotionAnimations.spring(.responsive, reduceMotion: reduced),
            value: state
        )
    }
}
#endif
