#if canImport(SwiftUI)
import SwiftUI

/// Compact, bounded pagination with host-owned page and action semantics.
public struct MotionPagination: View {
    private let label: LocalizedStringKey
    @Binding private var page: Int
    private let totalPages: Int
    private let maxVisible: Int
    private let isEnabled: Bool

    public init(
        _ label: LocalizedStringKey,
        page: Binding<Int>,
        totalPages: Int,
        maxVisible: Int = 5,
        isEnabled: Bool = true
    ) {
        self.label = label
        self._page = page
        self.totalPages = totalPages
        self.maxVisible = maxVisible
        self.isEnabled = isEnabled
    }

    private func select(_ requested: Int) {
        guard isEnabled, (1...max(1, totalPages)).contains(requested),
              requested != page, totalPages > 0 else { return }
        page = requested
    }

    public var body: some View {
        HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
            Button {
                if let previous = MotionNavigationPolicies.adjacent(
                    current: page, total: totalPages, delta: -1
                ) { select(previous) }
            } label: {
                Image(systemName: "chevron.backward")
                    .frame(minWidth: 44, minHeight: 44)
            }
            .disabled(!isEnabled || page <= 1 || totalPages <= 0)
            .accessibilityLabel(Text("Previous page"))

            ForEach(
                MotionNavigationPolicies.pages(
                    current: page, total: totalPages, maxVisible: maxVisible
                ), id: \.self
            ) { number in
                Button {
                    select(number)
                } label: {
                    Text("\(number)")
                        .frame(minWidth: 36, minHeight: 44)
                }
                .disabled(!isEnabled || number == page)
                .accessibilityLabel(Text("Page \(number)"))
                .accessibilityValue(number == page ? Text("Current page") : Text(""))
                .accessibilityAddTraits(number == page ? .isSelected : [])
            }
            Button {
                if let next = MotionNavigationPolicies.adjacent(
                    current: page, total: totalPages, delta: 1
                ) { select(next) }
            } label: {
                Image(systemName: "chevron.forward")
                    .frame(minWidth: 44, minHeight: 44)
            }
            .disabled(!isEnabled || page >= totalPages || totalPages <= 0)
            .accessibilityLabel(Text("Next page"))
        }
        .buttonStyle(.borderless)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
    }
}
#endif
