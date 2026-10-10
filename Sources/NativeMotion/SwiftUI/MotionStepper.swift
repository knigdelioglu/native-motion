#if canImport(SwiftUI)
import SwiftUI

/// Stable workflow step, independent of its screen content.
public struct MotionStepItem: Identifiable {
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

/// A multi-stage process indicator and optional navigation surface.
///
/// The host explicitly supplies selected and completed step IDs; previous
/// steps are NEVER inferred to have completed just because the user is later
/// in the list. By default, only explicitly completed steps may be revisited.
/// Future navigation requires opt-in; host retains all business state.
public struct MotionStepper: View {
    private let label: LocalizedStringKey
    private let steps: [MotionStepItem]
    @Binding private var selection: String
    private let completedIDs: Set<String>
    private let isEnabled: Bool
    private let allowsFutureNavigation: Bool

    @FocusState private var focusedID: String?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.layoutDirection) private var direction
    @Environment(\.accessibilityReduceMotion) private var systemReducedMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReducedMotion

    public init(
        _ label: LocalizedStringKey,
        steps: [MotionStepItem],
        selection: Binding<String>,
        completedIDs: Set<String> = [],
        isEnabled: Bool = true,
        allowsFutureNavigation: Bool = false
    ) {
        assert(
            MotionStepperPolicy.identifiersAreUnique(steps.map(\.id)),
            "MotionStepItem IDs must be unique"
        )
        self.label = label
        self.steps = steps
        self._selection = selection
        self.completedIDs = completedIDs
        self.isEnabled = isEnabled
        self.allowsFutureNavigation = allowsFutureNavigation
    }

    private var reduced: Bool {
        systemReducedMotion || previewReducedMotion
    }

    private var ids: [String] { steps.map(\.id) }
    private var disabledIDs: Set<String> { Set(steps.filter { !$0.isEnabled }.map(\.id)) }

    private func canSelect(_ id: String) -> Bool {
        MotionStepperPolicy.canNavigate(
            to: id,
            currentID: selection,
            ids: ids,
            completedIDs: completedIDs,
            disabledIDs: disabledIDs,
            isEnabled: isEnabled,
            allowsFutureNavigation: allowsFutureNavigation
        )
    }

    private func color(_ role: NativeMotionColorRole) -> Color {
        NativeMotionTheme.color(role, colorScheme: scheme)
    }

    private func select(_ id: String) {
        guard canSelect(id) else { return }
        selection = id
    }

    private func state(_ id: String) -> MotionWorkflowStepState {
        MotionStepperPolicy.state(
            for: id, currentID: selection, completedIDs: completedIDs
        )
    }

    private func description(_ state: MotionWorkflowStepState) -> Text {
        switch state {
        case .current: return Text("Current step")
        case .completed: return Text("Completed step")
        case .pending: return Text("Upcoming step")
        }
    }

    #if os(macOS)
    private func move(from id: String, direction key: MoveCommandDirection) {
        let step: Int
        switch key {
        case .up: step = -1
        case .down: step = 1
        case .left: step = direction == .rightToLeft ? 1 : -1
        case .right: step = direction == .rightToLeft ? -1 : 1
        default: return
        }
        guard let next = MotionStepperPolicy.adjacentAllowed(
            from: id,
            currentID: selection,
            direction: step,
            ids: ids,
            completedIDs: completedIDs,
            disabledIDs: disabledIDs,
            allowsFutureNavigation: allowsFutureNavigation,
            isEnabled: isEnabled
        ) else { return }
        select(next)
        focusedID = next
    }
    #endif

    public var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.medium)) {
            Text(label)
                .font(.headline)
                .foregroundStyle(color(.primaryText))
            VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.xSmall)) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, item in
                    let current = state(item.id)
                    let active = canSelect(item.id)
                    Button {
                        select(item.id)
                    } label: {
                        HStack(spacing: CGFloat(NativeMotionSpacing.medium)) {
                            ZStack {
                                Circle()
                                    .fill(
                                        current == .current
                                            ? color(.accent) : color(.elevatedSurface)
                                    )
                                    .frame(width: 30, height: 30)
                                if current == .completed {
                                    Image(systemName: "checkmark")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(color(.success))
                                } else {
                                    Text("\(index + 1)")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(
                                            current == .current
                                                ? color(.accentText) : color(.secondaryText)
                                        )
                                }
                            }
                            .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title)
                                    .font(.subheadline.weight(
                                        current == .current ? .semibold : .regular
                                    ))
                                    .foregroundStyle(color(.primaryText))
                                if let detail = item.detail {
                                    Text(detail)
                                        .font(.caption)
                                        .foregroundStyle(color(.secondaryText))
                                }
                            }
                            Spacer(minLength: 0)
                            if current == .current {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 7))
                                    .foregroundStyle(color(.accent))
                                    .accessibilityHidden(true)
                            }
                        }
                        .frame(minHeight: 48)
                        .padding(.horizontal, CGFloat(NativeMotionSpacing.medium))
                        .background {
                            RoundedRectangle(
                                cornerRadius: CGFloat(NativeMotionRadius.control),
                                style: .continuous
                            )
                            .fill(
                                current == .current
                                    ? color(.elevatedSurface) : Color.clear
                            )
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!active)
                    .focused($focusedID, equals: item.id)
                    .accessibilityLabel(Text(item.title))
                    .accessibilityValue(description(current))
                    .accessibilityAddTraits(current == .current ? .isSelected : [])
                    #if os(macOS)
                    .onMoveCommand { key in move(from: item.id, direction: key) }
                    #endif
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
        .animation(
            NativeMotionAnimations.spring(.gentle, reduceMotion: reduced),
            value: selection
        )
    }
}
#endif
