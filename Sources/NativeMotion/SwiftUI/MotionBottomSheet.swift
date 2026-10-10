#if canImport(SwiftUI)
import SwiftUI

/// Host-controlled mobile bottom sheet with explicit compact/medium/expanded
/// detents. UIKit-backed SwiftUI presentation provides native swipe gestures
/// on iOS; macOS uses a standard adaptive sheet.
public struct MotionBottomSheet<Trigger: View, Content: View>: View {
    private let title: LocalizedStringKey
    @Binding private var isPresented: Bool
    @Binding private var detent: MotionBottomDetent
    private let isBusy: Bool
    private let onDismiss: () -> Void
    private let trigger: () -> Trigger
    private let content: () -> Content

    @FocusState private var closeFocused: Bool

    public init(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        detent: Binding<MotionBottomDetent>,
        isBusy: Bool = false,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder trigger: @escaping () -> Trigger,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._isPresented = isPresented
        self._detent = detent
        self.isBusy = isBusy
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

    #if os(iOS)
    private var nativeDetent: PresentationDetent {
        switch detent {
        case .compact: return .fraction(0.3)
        case .medium: return .medium
        case .expanded: return .large
        }
    }

    private var nativeSelection: Binding<PresentationDetent> {
        Binding(
            get: { nativeDetent },
            set: { value in
                if value == .large { detent = .expanded }
                else if value == .medium { detent = .medium }
                else { detent = .compact }
            }
        )
    }
    #endif

    @ViewBuilder
    private var sheetBody: some View {
        VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.large)) {
            HStack {
                Text(title).font(.headline).accessibilityAddTraits(.isHeader)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .disabled(isBusy)
                .accessibilityLabel(Text("Close bottom sheet"))
                .focused($closeFocused)
            }
            content()
            Spacer(minLength: 0)
        }
        .padding(CGFloat(NativeMotionSpacing.large))
        .interactiveDismissDisabled(isBusy)
        .onAppear { closeFocused = true }
        #if os(iOS)
        .presentationDetents([.fraction(0.3), .medium, .large], selection: nativeSelection)
        .presentationDragIndicator(.visible)
        #else
        .frame(minWidth: 320, minHeight: 300)
        #endif
    }

    public var body: some View {
        Button { isPresented = true } label: { trigger() }
            .accessibilityHint(Text("Open bottom sheet"))
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                sheetBody
            }
    }
}
#endif
