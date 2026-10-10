#if canImport(SwiftUI)
import SwiftUI

/// Adaptive native sheet. Presentation, processing and operation outcome
/// belong to the host. The caller supplies its own trigger and sheet content.
public struct MotionSheet<Trigger: View, Content: View>: View {
    private let title: LocalizedStringKey
    @Binding private var isPresented: Bool
    private let isBusy: Bool
    private let isEnabled: Bool
    private let onDismiss: () -> Void
    private let trigger: () -> Trigger
    private let content: () -> Content

    @FocusState private var closeFocused: Bool
    @Environment(\.colorScheme) private var scheme

    public init(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        isBusy: Bool = false,
        isEnabled: Bool = true,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder trigger: @escaping () -> Trigger,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._isPresented = isPresented
        self.isBusy = isBusy
        self.isEnabled = isEnabled
        self.onDismiss = onDismiss
        self.trigger = trigger
        self.content = content
    }

    private func dismiss() {
        guard MotionSurfacePolicies.canDismiss(
            isPresented: isPresented, isBusy: isBusy
        ) else { return }
        isPresented = false
    }

    private var sheetBody: some View {
        VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.large)) {
            HStack {
                Text(title).font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .disabled(isBusy)
                .accessibilityLabel(Text("Close sheet"))
                .focused($closeFocused)
            }
            content()
        }
        .padding(CGFloat(NativeMotionSpacing.large))
        .frame(minWidth: 280, maxWidth: 520, alignment: .leading)
        .background(NativeMotionTheme.color(.surface, colorScheme: scheme))
        .interactiveDismissDisabled(isBusy)
        .onAppear { closeFocused = true }
        #if os(macOS)
        .onExitCommand { dismiss() }
        #endif
    }

    public var body: some View {
        Button {
            guard MotionSurfacePolicies.canOpen(
                isEnabled: isEnabled, isPresented: isPresented
            ) else { return }
            isPresented = true
        } label: {
            trigger()
        }
        .disabled(!isEnabled)
        .accessibilityHint(Text("Open sheet"))
        .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            sheetBody
        }
    }
}
#endif
