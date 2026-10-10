#if canImport(SwiftUI)
import SwiftUI

/// Compact native two-state toggle-button. This is deliberately distinct
/// from MotionSwitch, which uses the platform's system switch appearance.
///
/// Binding belongs to the host. SwiftUI provides keyboard activation, focus,
/// VoiceOver toggle semantics and disabled behavior without a gesture shim.
public struct MotionToggle: View {
    private let label: LocalizedStringKey
    @Binding private var isOn: Bool
    private let isEnabled: Bool

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion

    public init(
        _ label: LocalizedStringKey,
        isOn: Binding<Bool>,
        isEnabled: Bool = true
    ) {
        self.label = label
        self._isOn = isOn
        self.isEnabled = isEnabled
    }

    public var body: some View {
        let reduced = systemReduceMotion || previewReduceMotion
        Toggle(isOn: $isOn) {
            Label(
                title: { Text(label).font(.subheadline.weight(.medium)) },
                icon: {
                    Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                        .accessibilityHidden(true)
                }
            )
        }
        .toggleStyle(.button)
        .tint(NativeMotionTheme.color(.accent, colorScheme: colorScheme))
        .controlSize(.large)
        .disabled(!isEnabled)
        .accessibilityValue(isOn ? Text("On") : Text("Off"))
        .animation(
            NativeMotionAnimations.spring(.responsive, reduceMotion: reduced),
            value: isOn
        )
    }
}
#endif
