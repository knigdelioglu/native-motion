#if canImport(SwiftUI)
import SwiftUI
import NativeMotion

@main
struct NativeMotionCatalogApp: App {
    var body: some Scene {
        WindowGroup("Native Motion Catalog") {
            CatalogView()
        }
    }
}

private struct CatalogView: View {
    @State private var phase: MotionButtonPhase = .idle
    @State private var actionCount = 0
    @State private var selected = "overview"
    @State private var expanded = true
    @State private var secondExpanded = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Native Motion").font(.largeTitle.bold())
                    Text("Independent native controls, visual states and gestures")
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionButton · variants").font(.title2.bold())
                    ForEach(MotionButtonVariant.allCases, id: \.self) { variant in
                        MotionButton("Perform action", variant: variant) {
                            actionCount += 1
                        }
                    }
                    Text("Actions: \(actionCount)")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionButton · phases").font(.title2.bold())
                    Picker("State", selection: $phase) {
                        ForEach(MotionButtonPhase.allCases, id: \.self) { state in
                            Text(state.rawValue.capitalized).tag(state)
                        }
                    }
                    .pickerStyle(.segmented)
                    MotionButton("Continue", size: .large, phase: phase) {
                        actionCount += 1
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionButton · sizes").font(.title2.bold())
                    ForEach(MotionButtonSize.allCases, id: \.self) { size in
                        MotionButton("Example", variant: .secondary, size: size) {
                            actionCount += 1
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionSegmentedControl").font(.title2.bold())
                    MotionSegmentedControl(
                        "Catalog section",
                        segments: [
                            MotionSegment("overview", title: "Overview", systemImage: "square.grid.2x2"),
                            MotionSegment("activity", title: "Activity", systemImage: "chart.xyaxis.line"),
                            MotionSegment("disabled", title: "Unavailable", isEnabled: false),
                            MotionSegment("details", title: "Details", systemImage: "text.alignleft"),
                            MotionSegment("settings", title: "Settings", systemImage: "gearshape")
                        ],
                        selection: $selected
                    )
                    Text("Selection: \(selected)")
                        .font(.footnote).foregroundStyle(.secondary)
                    Text("Keyboard: tab to a segment, then use the arrow keys on macOS.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionExpandableCard").font(.title2.bold())
                    MotionExpandableCard(
                        "Interaction details",
                        subtitle: "Tap or keyboard-activate to disclose",
                        isExpanded: $expanded
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Expanded content belongs to the host. Controls inside remain independently focusable.")
                            MotionButton("Nested action", variant: .secondary) {
                                actionCount += 1
                            }
                        }
                    }
                    MotionExpandableCard("Another disclosure", isExpanded: $secondExpanded) {
                        Text("Multiple cards may expand independently.")
                    }
                }

                Text("Review light/dark appearance, Dynamic Type, VoiceOver, keyboard navigation and Reduce Motion.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(32)
            .frame(maxWidth: 600, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(NativeMotionTheme.color(.background, colorScheme: colorScheme))
    }
}
#else
@main
struct NativeMotionCatalogUnsupportedPlatform {
    static func main() {
        print("NativeMotionCatalog requires macOS 13+ with SwiftUI.")
    }
}
#endif
