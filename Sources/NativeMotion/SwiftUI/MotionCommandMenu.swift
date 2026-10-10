#if canImport(SwiftUI)
import SwiftUI

/// One searchable action with a stable ID. Supply a localized title string
/// if the consuming application supports multiple languages.
public struct MotionCommandItem: Identifiable {
    public let id: String
    public let title: String
    public let keywords: [String]
    public let isEnabled: Bool
    public let action: () -> Void

    public init(
        _ id: String, title: String, keywords: [String] = [],
        isEnabled: Bool = true, action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.keywords = keywords
        self.isEnabled = isEnabled
        self.action = action
    }
}

/// Host-presented native searchable command list, without command execution
/// or fake completion on query/filter changes. Modal closes only after a
/// user-chosen enabled action or explicit dismissal.
public struct MotionCommandMenu<Trigger: View>: View {
    private let label: LocalizedStringKey
    private let commands: [MotionCommandItem]
    @Binding private var isPresented: Bool
    @Binding private var query: String
    private let trigger: () -> Trigger

    @FocusState private var searchFocused: Bool
    @Environment(\.colorScheme) private var scheme

    public init(
        _ label: LocalizedStringKey,
        commands: [MotionCommandItem],
        isPresented: Binding<Bool>,
        query: Binding<String>,
        @ViewBuilder trigger: @escaping () -> Trigger
    ) {
        assert(
            MotionCommandPolicies.identifiersAreUnique(commands.map(\.id)),
            "MotionCommandItem IDs must be unique"
        )
        self.label = label
        self.commands = commands
        self._isPresented = isPresented
        self._query = query
        self.trigger = trigger
    }

    private var visible: [MotionCommandItem] {
        commands.filter {
            MotionCommandPolicies.matches(
                query: query, title: $0.title, keywords: $0.keywords
            )
        }
    }

    private func execute(_ item: MotionCommandItem) {
        let enabled = Set(commands.filter(\.isEnabled).map(\.id))
        guard MotionCommandPolicies.canExecute(
            id: item.id, validEnabledIDs: enabled, isPresented: isPresented
        ) else { return }
        isPresented = false
        item.action()
    }

    public var body: some View {
        Button {
            isPresented = true
        } label: {
            trigger()
        }
        .accessibilityHint(Text("Open commands"))
        .sheet(isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: CGFloat(NativeMotionSpacing.large)) {
                HStack {
                    Text(label).font(.title2.bold())
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel(Text("Close commands"))
                }
                TextField("Search commands", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .focused($searchFocused)
                    .accessibilityLabel(Text("Search commands"))
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        if visible.isEmpty {
                            Text("No matching commands")
                                .foregroundStyle(
                                    NativeMotionTheme.color(
                                        .secondaryText, colorScheme: scheme
                                    )
                                )
                        }
                        ForEach(visible) { item in
                            Button {
                                execute(item)
                            } label: {
                                Text(item.title)
                                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            }
                            .disabled(!item.isEnabled)
                        }
                    }
                }
            }
            .padding(CGFloat(NativeMotionSpacing.large))
            .frame(minWidth: 300, minHeight: 250)
            .onAppear { searchFocused = true }
            #if os(macOS)
            .onExitCommand { isPresented = false }
            #endif
        }
    }
}
#endif
