#if canImport(SwiftUI)
import SwiftUI

/// Deliberate two-activation confirmation with a separate native Cancel.
///
/// The control owns only an ephemeral armed state; applications own the
/// real operation, loading, success and failure. No timer/automatic success.
/// Escape cancels the armed state on macOS, and the host can reset by
/// changing the phase or disabling the entire control.
public struct MotionConfirmButton: View {
    private let title: LocalizedStringKey
    private let confirmationTitle: LocalizedStringKey
    private let variant: MotionButtonVariant
    private let size: MotionButtonSize
    private let phase: MotionButtonPhase
    private let action: () -> Void

    @State private var state: MotionConfirmationState = .idle
    @Environment(\.isEnabled) private var environmentEnabled

    public init(
        _ title: LocalizedStringKey,
        confirmationTitle: LocalizedStringKey = "Confirm action",
        variant: MotionButtonVariant = .destructive,
        size: MotionButtonSize = .medium,
        phase: MotionButtonPhase = .idle,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.confirmationTitle = confirmationTitle
        self.variant = variant
        self.size = size
        self.phase = phase
        self.action = action
    }

    private func advance(_ event: MotionConfirmationEvent) {
        guard environmentEnabled, phase != .loading else { return }
        let transition = MotionConfirmButtonPolicy.transition(from: state, event: event)
        state = transition.next
        if transition.firesAction {
            action()
        }
    }

    public var body: some View {
        HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
            MotionButton(
                state == .armed ? confirmationTitle : title,
                variant: variant,
                size: size,
                phase: phase
            ) {
                advance(.primaryTap)
            }
            .accessibilityHint(
                state == .armed
                    ? Text("Activate again to confirm")
                    : Text("Activate to request confirmation")
            )
            .accessibilityValue(
                state == .armed ? Text("Confirmation required") : Text("")
            )

            if state == .armed {
                MotionButton("Cancel", variant: .ghost, size: size) {
                    advance(.cancel)
                }
                .accessibilityHint(Text("Keep the operation unchanged"))
                .transition(.opacity)
            }
        }
        .disabled(phase == .loading)
        .onChange(of: phase) { _ in
            state = .idle
        }
        .onChange(of: environmentEnabled) { enabled in
            if !enabled { state = .idle }
        }
        #if os(macOS)
        .onExitCommand {
            if state == .armed { advance(.cancel) }
        }
        #endif
    }
}
#endif
