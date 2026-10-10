#if canImport(SwiftUI)
import SwiftUI

/// Native anchored popover with a host-owned presentation binding.
///
/// SwiftUI manages positioning, boundary collision, system Reduce Motion and
/// platform adaptation (compact iPhone presentation may become a sheet).
/// The trigger closure is *label content*, not another Button.
public struct MotionPopover<Trigger: View, Content: View>: View {
    private let title: LocalizedStringKey
    @Binding private var isPresented: Bool
    private let isEnabled: Bool
    private let onDismiss: () -> Void
    private let trigger: () -> Trigger
    private let content: () -> Content

    @FocusState private var triggerFocused: Bool
    @FocusState private var closeFocused: Bool
    @Environment(\.colorScheme) private var scheme
    @Environment(\.isEnabled) private var environmentEnabled

    public init(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        isEnabled: Bool = true,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder trigger: @escaping () -> Trigger,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._isPresented = isPresented
        self.isEnabled = isEnabled
        self.onDismiss = onDismiss
        self.trigger = trigger
        self.content = content
    }

    private var canActivate: Bool { isEnabled && environmentEnabled }

    private func dismiss() {
        guard MotionPresentationPolicies.canDismiss(
            isPresented: isPresented
        ) else { return }
        isPresented = false
    }

    private var popoverBody: some View {
        VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.large)) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(
                        NativeMotionTheme.color(.primaryText, colorScheme: scheme)
                    )
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .frame(minWidth: 36, minHeight: 36)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Close popover"))
                .focused($closeFocused)
            }
            content()
        }
        .padding(CGFloat(NativeMotionSpacing.large))
        .frame(minWidth: 200, maxWidth: 380, alignment: .leading)
        .onAppear { closeFocused = true }
        #if os(macOS)
        .onExitCommand { dismiss() }
        #endif
    }

    public var body: some View {
        Button {
            guard MotionPresentationPolicies.canOpen(
                isEnabled: canActivate, isPresented: isPresented
            ) else { return }
            isPresented = true
        } label: {
            trigger()
        }
        .disabled(!isEnabled)
        .focused($triggerFocused)
        .accessibilityHint(Text("Open popover"))
        .popover(
            isPresented: $isPresented,
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .bottom
        ) {
            popoverBody
        }
        .onChange(of: isPresented) { nowPresented in
            if !nowPresented {
                triggerFocused = true
                onDismiss()
            }
        }
    }
}
#endif
