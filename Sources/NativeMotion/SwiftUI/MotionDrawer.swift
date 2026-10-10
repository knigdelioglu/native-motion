#if canImport(SwiftUI)
import SwiftUI

/// Host-controlled leading/trailing drawer. The host supplies all content
/// and effects; the drawer only changes presentation upon explicit dismissal.
/// SwiftUI's sheet is reserved for adaptive modal pages; drawer has a side edge.
public struct MotionDrawer<Content: View, DrawerContent: View>: View {
    private let title: LocalizedStringKey
    @Binding private var isPresented: Bool
    private let isBusy: Bool
    private let edge: HorizontalEdge
    private let onDismiss: () -> Void
    private let content: () -> Content
    private let drawerContent: () -> DrawerContent

    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var systemReduced
    @Environment(\.nativeMotionPreviewReduceMotion) private var previewReduced
    @FocusState private var closeFocused: Bool

    public init(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        edge: HorizontalEdge = .leading,
        isBusy: Bool = false,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder drawerContent: @escaping () -> DrawerContent
    ) {
        self.title = title
        self._isPresented = isPresented
        self.edge = edge
        self.isBusy = isBusy
        self.onDismiss = onDismiss
        self.content = content
        self.drawerContent = drawerContent
    }

    private var reduced: Bool { systemReduced || previewReduced }

    private func dismiss() {
        guard MotionSurfacePolicies.canDismiss(
            isPresented: isPresented, isBusy: isBusy
        ) else { return }
        isPresented = false
    }

    private var isLeading: Bool {
        (edge == .leading) != (layoutDirection == .rightToLeft)
    }

    private var sidePanel: some View {
        VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.large)) {
            HStack {
                Text(title).font(.headline).accessibilityAddTraits(.isHeader)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .disabled(isBusy)
                .accessibilityLabel(Text("Close drawer"))
                .focused($closeFocused)
            }
            drawerContent()
            Spacer(minLength: 0)
        }
        .padding(CGFloat(NativeMotionSpacing.large))
        .frame(width: 300, alignment: .leading)
        .frame(maxHeight: .infinity)
        .background(NativeMotionTheme.color(.surface, colorScheme: scheme))
        .onAppear { closeFocused = true }
        #if os(macOS)
        .onExitCommand { dismiss() }
        #endif
    }

    public var body: some View {
        ZStack {
            content()
            if isPresented {
                HStack(spacing: 0) {
                    if !isLeading { Spacer(minLength: 0) }
                    sidePanel
                    if isLeading { Spacer(minLength: 0) }
                }
                .background {
                    Color.black.opacity(0.38)
                        .ignoresSafeArea()
                        .onTapGesture { dismiss() }
                        .accessibilityLabel(Text("Dismiss drawer"))
                        .accessibilityAddTraits(.isButton)
                }
                .transition(reduced ? .identity : .move(
                    edge: isLeading ? .leading : .trailing
                ))
                .zIndex(1)
            }
        }
        .animation(
            NativeMotionAnimations.spring(.gentle, reduceMotion: reduced),
            value: isPresented
        )
        .onChange(of: isPresented) { visible in
            if !visible { onDismiss() }
        }
    }
}
#endif
