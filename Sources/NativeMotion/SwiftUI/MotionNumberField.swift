#if canImport(SwiftUI)
import SwiftUI

/// Locale-aware numeric field with host-owned snapped value.
///
/// The draft string belongs to the control so partial typing (e.g. "-")
/// remains possible. The host is updated only on valid submit, focus loss or
/// explicit +/- activation. Invalid draft stays visible with an error.
public struct MotionNumberField: View {
    private let label: LocalizedStringKey
    @Binding private var value: Double
    private let scale: MotionSliderScale
    private let isEnabled: Bool
    private let feedback: MotionFieldFeedback?
    private let onCommit: (Double) -> Void

    @State private var draft = ""
    @State private var invalid = false
    @FocusState private var focused: Bool
    @Environment(\.locale) private var locale
    @Environment(\.colorScheme) private var scheme

    public init(
        _ label: LocalizedStringKey,
        value: Binding<Double>,
        scale: MotionSliderScale = MotionSliderScale(),
        isEnabled: Bool = true,
        feedback: MotionFieldFeedback? = nil,
        onCommit: @escaping (Double) -> Void = { _ in }
    ) {
        self.label = label
        self._value = value
        self.scale = scale
        self.isEnabled = isEnabled
        self.feedback = feedback
        self.onCommit = onCommit
    }

    private var shownFeedback: MotionFieldFeedback? {
        invalid ? MotionFieldFeedback("Enter a valid number", style: .error) : feedback
    }

    private func refreshDraft() {
        draft = MotionNumberFieldPolicy.display(value, scale: scale, locale: locale)
        invalid = false
    }

    private func submit() {
        guard isEnabled else { return }
        switch MotionNumberFieldPolicy.parse(draft, scale: scale, locale: locale) {
        case .invalid:
            invalid = true
        case .accepted(let next):
            invalid = false
            draft = MotionNumberFieldPolicy.display(next, scale: scale, locale: locale)
            value = next
            onCommit(next)
        }
    }

    private func step(_ direction: Int) {
        guard isEnabled else { return }
        let next = MotionNumberFieldPolicy.adjacent(
            to: value, direction: direction, scale: scale
        )
        value = next
        draft = MotionNumberFieldPolicy.display(next, scale: scale, locale: locale)
        invalid = false
        onCommit(next)
    }

    public var body: some View {
        MotionFieldShell(
            label: label,
            feedback: shownFeedback,
            focused: focused,
            isEnabled: isEnabled
        ) {
            HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
                TextField("", text: $draft)
                    .textFieldStyle(.plain)
                    .focused($focused)
                    .disabled(!isEnabled)
                    .accessibilityLabel(Text(label))
                    .onSubmit(submit)
                    .onChange(of: draft) { _ in invalid = false }
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif

                Button { step(-1) } label: {
                    Image(systemName: "minus")
                        .frame(minWidth: 30, minHeight: 40)
                }
                .disabled(!isEnabled || scale.snapped(value) <= scale.minimum)
                .accessibilityLabel(Text("Decrease"))
                .buttonStyle(.plain)
                Button { step(1) } label: {
                    Image(systemName: "plus")
                        .frame(minWidth: 30, minHeight: 40)
                }
                .disabled(!isEnabled || scale.snapped(value) >= scale.maximum)
                .accessibilityLabel(Text("Increase"))
                .buttonStyle(.plain)
            }
            .foregroundStyle(NativeMotionTheme.color(.primaryText, colorScheme: scheme))
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: step(1)
                case .decrement: step(-1)
                @unknown default: break
                }
            }
        }
        .onAppear(perform: refreshDraft)
        .onChange(of: value) { _ in
            if !focused { refreshDraft() }
        }
        .onChange(of: locale.identifier) { _ in
            if !focused { refreshDraft() }
        }
        .onChange(of: focused) { isFocused in
            if !isFocused { submit() }
        }
    }
}
#endif
