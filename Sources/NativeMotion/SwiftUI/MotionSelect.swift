#if canImport(SwiftUI)
import SwiftUI

/// Stable, localized single-choice option. IDs must be unique within a select.
public struct MotionSelectOption: Identifiable {
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

/// Host-controlled native drop-down selector.
///
/// A missing or disabled externally supplied selection stays unchanged; the
/// control never chooses on behalf of an application. Native Picker handles
/// VoiceOver, hardware keyboard, focus, RTL and system Reduce Motion.
public struct MotionSelect: View {
    private let label: LocalizedStringKey
    private let options: [MotionSelectOption]
    @Binding private var selection: String
    private let isEnabled: Bool
    private let feedback: MotionFieldFeedback?

    @Environment(\.colorScheme) private var scheme

    public init(
        _ label: LocalizedStringKey,
        options: [MotionSelectOption],
        selection: Binding<String>,
        isEnabled: Bool = true,
        feedback: MotionFieldFeedback? = nil
    ) {
        assert(
            MotionOverlayPolicies.identifiersAreUnique(options.map(\.id)),
            "MotionSelectOption IDs must be unique"
        )
        self.label = label
        self.options = options
        self._selection = selection
        self.isEnabled = isEnabled
        self.feedback = feedback
    }

    private var enabledIDs: Set<String> {
        Set(options.filter(\.isEnabled).map(\.id))
    }

    private var safeSelection: Binding<String> {
        Binding(
            get: { selection },
            set: { proposed in
                guard MotionOverlayPolicies.canSelect(
                    id: proposed,
                    currentID: selection,
                    enabledIDs: enabledIDs,
                    controlEnabled: isEnabled
                ) else { return }
                selection = proposed
            }
        )
    }

    public var body: some View {
        MotionFieldShell(
            label: label,
            feedback: feedback,
            focused: false,
            isEnabled: isEnabled
        ) {
            Picker(selection: safeSelection) {
                ForEach(options) { option in
                    Text(option.title)
                        .tag(option.id)
                        .disabled(!option.isEnabled)
                }
            } label: {
                Text(label)
            }
            .pickerStyle(.menu)
            .tint(NativeMotionTheme.color(.primaryText, colorScheme: scheme))
            .disabled(!isEnabled || enabledIDs.isEmpty)
            .accessibilityLabel(Text(label))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
#endif
