#if canImport(SwiftUI)
import SwiftUI

/// A platform-native system switch; unlike MotionToggle's compact button,
/// this uses SwiftUI's switch control and its built-in accessibility actions.
///
/// The host owns the Boolean binding. SwiftUI handles pointer, hardware
/// keyboard, VoiceOver and switch gesture accessibility on each platform.
public struct MotionSwitch: View {
    private let label: LocalizedStringKey
    private let detail: LocalizedStringKey?
    @Binding private var isOn: Bool
    private let isEnabled: Bool

    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduceMotion

    public init(
        _ label: LocalizedStringKey,
        detail: LocalizedStringKey? = nil,
        isOn: Binding<Bool>,
        isEnabled: Bool = true
    ) {
        self.label = label
        self.detail = detail
        self._isOn = isOn
        self.isEnabled = isEnabled
    }

    public var body: some View {
        let reduced = systemReduceMotion || previewReduceMotion
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.body.weight(.medium))
                    .foregroundStyle(
                        NativeMotionTheme.color(.primaryText, colorScheme: scheme)
                    )
                if let detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(
                            NativeMotionTheme.color(.secondaryText, colorScheme: scheme)
                        )
                }
            }
        }
        .toggleStyle(.switch)
        .tint(NativeMotionTheme.color(.accent, colorScheme: scheme))
        .disabled(!isEnabled)
        .accessibilityValue(isOn ? Text("On") : Text("Off"))
        .animation(
            NativeMotionAnimations.spring(.gentle, reduceMotion: reduced),
            value: isOn
        )
    }
}
#endif
