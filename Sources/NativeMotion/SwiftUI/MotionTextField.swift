#if canImport(SwiftUI)
import SwiftUI

/// Host-owned single-line text input with visible helper/validation feedback.
/// Native TextField retains keyboard editing, selection, dictation and IME.
public struct MotionTextField: View {
    private let label: LocalizedStringKey
    private let placeholder: LocalizedStringKey
    @Binding private var text: String
    private let feedback: MotionFieldFeedback?
    private let isEnabled: Bool
    private let onSubmit: () -> Void

    @FocusState private var focused: Bool

    public init(
        _ label: LocalizedStringKey,
        placeholder: LocalizedStringKey = "",
        text: Binding<String>,
        feedback: MotionFieldFeedback? = nil,
        isEnabled: Bool = true,
        onSubmit: @escaping () -> Void = {}
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.feedback = feedback
        self.isEnabled = isEnabled
        self.onSubmit = onSubmit
    }

    public var body: some View {
        MotionFieldShell(
            label: label,
            feedback: feedback,
            focused: focused,
            isEnabled: isEnabled
        ) {
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .focused($focused)
                .disabled(!isEnabled)
                .accessibilityLabel(Text(label))
                .onSubmit(onSubmit)
        }
    }
}
#endif
