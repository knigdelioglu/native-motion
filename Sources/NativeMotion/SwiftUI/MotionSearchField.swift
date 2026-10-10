#if canImport(SwiftUI)
import SwiftUI

/// Host-owned search query input. No hidden debounce, network request,
/// search result or state transition occurs in the library.
public struct MotionSearchField: View {
    private let label: LocalizedStringKey
    private let placeholder: LocalizedStringKey
    @Binding private var query: String
    private let feedback: MotionFieldFeedback?
    private let isEnabled: Bool
    private let onSubmit: () -> Void

    @FocusState private var focused: Bool
    @Environment(\.colorScheme) private var scheme

    public init(
        _ label: LocalizedStringKey,
        placeholder: LocalizedStringKey = "Search",
        query: Binding<String>,
        feedback: MotionFieldFeedback? = nil,
        isEnabled: Bool = true,
        onSubmit: @escaping () -> Void = {}
    ) {
        self.label = label
        self.placeholder = placeholder
        self._query = query
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
            HStack(spacing: CGFloat(NativeMotionSpacing.small)) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(NativeMotionTheme.color(.secondaryText, colorScheme: scheme))
                    .accessibilityHidden(true)
                TextField(placeholder, text: $query)
                    .textFieldStyle(.plain)
                    .focused($focused)
                    .disabled(!isEnabled)
                    .accessibilityLabel(Text(label))
                    .onSubmit(onSubmit)
                if !query.isEmpty {
                    Button {
                        query = ""
                        focused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(
                                NativeMotionTheme.color(.secondaryText, colorScheme: scheme)
                            )
                            .frame(minWidth: 30, minHeight: 36)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isEnabled)
                    .accessibilityLabel(Text("Clear search"))
                    .help(Text("Clear search"))
                }
            }
        }
    }
}
#endif
