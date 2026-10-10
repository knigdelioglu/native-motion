# Native Motion

**Calm by default. Responsive by nature. Native by design.**

Native Motion is an independent, open-source, native-first UI and motion
design system. Its first renderer uses SwiftUI, not a web view. Future Flutter
and Jetpack Compose implementations will share interaction semantics rather
than copy platform-specific spring constants.

> Experimental: APIs and visual tokens are not yet stable.

## Components

| Component | Description |
| --- | --- |
| `MotionButton` | Four variants, three sizes, idle/loading/success/failure |
| `MotionSegmentedControl` | Spring-linked selection with disabled items, horizontal scrolling and keyboard navigation |
| `MotionExpandableCard` | Host-controlled disclosure card with optional subtitle and arbitrary interactive content |
| `MotionElasticSlider` | Gesture + accessibility-adjustable value input with bounded steps and elastic edges |
| `MotionStatusIndicator` | Passive, accessible feedback with neutral/working/success/warning/failure |

Supporting these are semantic motion presets (`responsive`, `gentle`,
`morph`, `settle`), light/dark palette tokens, layout dimensions, Reduce
Motion adaptation and an interactive component catalog.

## Swift Package Manager

In Xcode, use **File → Add Package Dependencies…**:

`https://github.com/knigdelioglu/native-motion`

Choose the `NativeMotion` library product and an explicit revision or branch
until a version tag is published. The package supports **macOS 13+ and iOS 16+**.

```swift
import SwiftUI
import NativeMotion

struct Example: View {
    @State private var selected = "all"
    @State private var detailsOpen = false
    @State private var value = 50.0

    var body: some View {
        VStack(spacing: 16) {
            MotionSegmentedControl("Results", segments: [
                MotionSegment("all", title: "All"),
                MotionSegment("active", title: "Active"),
                MotionSegment("archived", title: "Archived", isEnabled: false)
            ], selection: $selected)

            MotionElasticSlider("Volume", value: $value,
                                scale: .init(minimum: 0, maximum: 100, step: 5))

            MotionStatusIndicator("Save", status: .processing)

            MotionExpandableCard("Details", isExpanded: $detailsOpen) {
                Text("Independent disclosure content")
                MotionButton("Confirm") { /* host action */ }
            }
        }
    }
}
```

The host owns selection, expansion, value state, and asynchronous work. Segments require
**unique, stable string IDs**; a current selection should refer to an enabled
segment. The control does not silently override external state.

## Quality and visual review

The quality pipeline tests semantic token reference files, slider invariants and
contrast on macOS/Linux. On macOS it captures four SwiftUI images (light, dark,
Reduce Motion, large text) and uploads them as Actions artifacts. Captured images
are not yet approved pixel baselines; a comparison CLI is provided for the
maintainer approval workflow. The release-mode microbenchmark measures only
numeric interaction logic, not GPU frames or real-device responsiveness.

Read the [quality gates and screenshot workflow](docs/QUALITY.md).

## Build, test and preview

```sh
swift test
swift build -c release
swift run NativeMotionCatalog
```

The interactive catalog requires macOS 13+ with SwiftUI. Linux compiles
platform-neutral logic, including keyboard selection policy, and shows a
catalog availability message. CI tests macOS and Linux. Manual Apple-device
visual, keyboard and accessibility checks are still needed.

## Design and contribution

Read [principles](design/PRINCIPLES.md), the
[component interaction contract](design/INTERACTION_CONTRACT.md),
[roadmap](design/ROADMAP.md) and
[contribution guidelines](CONTRIBUTING.md).

### Inspiration and independence

[Arc Library](https://github.com/kuratlielia/arc-library) inspires attention
to calm, purposeful motion. Native Motion is **not** a fork or a translation:
SwiftUI components, APIs, tokens and assets are original implementations.

## License

[MIT](LICENSE).
