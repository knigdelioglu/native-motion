#if canImport(SwiftUI)
import SwiftUI

/// Accessible contextual help, independent of any networking or timers.
///
/// macOS supplies a genuine native hover tooltip through .help; a focusable
/// button exposes the same localized explanation to VoiceOver via its hint.
/// Touch/click opens a native popover so the text is also available without
/// hover. The popover adapts on compact iPhone displays.
public struct MotionTooltip<Trigger: View>: View {
    private let label: LocalizedStringKey
    private let message: LocalizedStringKey
    private let isEnabled: Bool
    private let trigger: () -> Trigger

    @State private var showingExplanation = false
    @FocusState private var focused: Bool
    @Environment(\.colorScheme) private var scheme

    public init(
        _ label: LocalizedStringKey,
        message: LocalizedStringKey,
        isEnabled: Bool = true,
        @ViewBuilder trigger: @escaping () -> Trigger
    ) {
        self.label = label
        self.message = message
        self.isEnabled = isEnabled
        self.trigger = trigger
    }

    private func hide() {
        showingExplanation = false
    }

    public var body: some View {
        Button {
            guard isEnabled else { return }
            showingExplanation.toggle()
        } label: {
            trigger()
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .focused($focused)
        .help(Text(message))
        .accessibilityLabel(Text(label))
        .accessibilityHint(Text(message))
        .popover(
            isPresented: $showingExplanation,
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .bottom
        ) {
            HStack(alignment: .top, spacing: CGFloat(NativeMotionSpacing.medium)) {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(
                        NativeMotionTheme.color(.primaryText, colorScheme: scheme)
                    )
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    hide()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .frame(minWidth: 32, minHeight: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Close help"))
            }
            .padding(CGFloat(NativeMotionSpacing.large))
            .frame(maxWidth: 300)
            #if os(macOS)
            .onExitCommand { hide() }
            #endif
        }
        .onChange(of: focused) { isFocused in
            if isFocused && isEnabled { showingExplanation = true }
        }
        .onChange(of: isEnabled) { enabled in
            if !enabled { showingExplanation = false }
        }
    }
}
#endif
