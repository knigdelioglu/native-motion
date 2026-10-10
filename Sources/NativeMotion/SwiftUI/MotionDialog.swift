#if canImport(SwiftUI)
import SwiftUI

/// Native platform modal, with a caller-owned isPresented binding.
///
/// The host owns successful/failed work and explicitly dismisses the dialog.
/// A confirm tap does NOT automatically close, fabricate completion, or run
/// another action. Loading disables both actions and interactive dismissal.
/// Trigger must be label content, not an embedded Button.
public struct MotionDialog<Trigger: View, Content: View>: View {
    private let title: LocalizedStringKey
    private let confirmTitle: LocalizedStringKey
    private let cancelTitle: LocalizedStringKey
    @Binding private var isPresented: Bool
    private let isEnabled: Bool
    private let phase: MotionButtonPhase
    private let confirmationRole: ButtonRole?
    private let onConfirm: () -> Void
    private let onCancel: () -> Void
    private let onDismiss: () -> Void
    private let trigger: () -> Trigger
    private let content: () -> Content

    @FocusState private var cancelFocused: Bool
    @Environment(\.colorScheme) private var scheme

    public init(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        confirmTitle: LocalizedStringKey = "Confirm",
        cancelTitle: LocalizedStringKey = "Cancel",
        isEnabled: Bool = true,
        phase: MotionButtonPhase = .idle,
        confirmationRole: ButtonRole? = nil,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void = {},
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder trigger: @escaping () -> Trigger,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._isPresented = isPresented
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.isEnabled = isEnabled
        self.phase = phase
        self.confirmationRole = confirmationRole
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self.onDismiss = onDismiss
        self.trigger = trigger
        self.content = content
    }

    private var isLoading: Bool { phase == .loading }

    private var canConfirm: Bool {
        MotionOverlayPolicies.canConfirmDialog(
            isEnabled: isEnabled, isLoading: isLoading
        )
    }

    private func cancel() {
        guard MotionOverlayPolicies.canDismissDialog(isLoading: isLoading) else {
            return
        }
        isPresented = false
        onCancel()
    }

    private var modalContent: some View {
        VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.large)) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(
                    NativeMotionTheme.color(.primaryText, colorScheme: scheme)
                )
                .accessibilityAddTraits(.isHeader)

            content()

            HStack(spacing: CGFloat(NativeMotionSpacing.medium)) {
                Spacer(minLength: 0)
                MotionButton(cancelTitle, variant: .ghost) { cancel() }
                    .focused($cancelFocused)
                    .disabled(isLoading)

                if confirmationRole == .destructive {
                    MotionButton(
                        confirmTitle, variant: .destructive, phase: phase
                    ) {
                        guard canConfirm else { return }
                        onConfirm()
                    }
                    .disabled(!canConfirm)
                } else {
                    MotionButton(
                        confirmTitle, variant: .primary, phase: phase
                    ) {
                        guard canConfirm else { return }
                        onConfirm()
                    }
                    .disabled(!canConfirm)
                }
            }
        }
        .padding(CGFloat(NativeMotionSpacing.xLarge))
        .frame(minWidth: 280)
        .frame(maxWidth: 480)
        .onAppear { cancelFocused = true }
        .interactiveDismissDisabled(isLoading)
        #if os(macOS)
        .onExitCommand { cancel() }
        #endif
    }

    public var body: some View {
        Button {
            guard MotionOverlayPolicies.canPresentDialog(
                isEnabled: isEnabled
            ) else { return }
            isPresented = true
        } label: {
            trigger()
        }
        .disabled(!isEnabled)
        .accessibilityHint(Text("Open dialog"))
        .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            modalContent
        }
    }
}
#endif
