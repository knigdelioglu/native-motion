#if canImport(SwiftUI)
import SwiftUI
import NativeMotion

@main
struct NativeMotionCatalogApp: App {
    var body: some Scene {
        WindowGroup("Native Motion Catalog") { CatalogView() }
    }
}

private struct CatalogView: View {
    @State private var phase: MotionButtonPhase = .idle
    @State private var count = 0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Native Motion").font(.largeTitle.bold())
                    Text("Independent SwiftUI component catalog").foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Variants").font(.title2.bold())
                    ForEach(MotionButtonVariant.allCases, id: \.self) { variant in
                        MotionButton("Perform action", variant: variant) { count += 1 }
                    }
                    Text("Actions: \(count)").font(.footnote).foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Phases").font(.title2.bold())
                    Picker("State", selection: $phase) {
                        ForEach(MotionButtonPhase.allCases, id: \.self) { state in
                            Text(state.rawValue.capitalized).tag(state)
                        }
                    }
                    .pickerStyle(.segmented)
                    MotionButton("Continue", size: .large, phase: phase) { count += 1 }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sizes").font(.title2.bold())
                    ForEach(MotionButtonSize.allCases, id: \.self) { size in
                        MotionButton("Example", variant: .secondary, size: size) { count += 1 }
                    }
                }
                Text("Use system appearance and Reduce Motion settings to inspect adaptive behavior.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(32)
            .frame(maxWidth: 520, alignment: .leading)
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
