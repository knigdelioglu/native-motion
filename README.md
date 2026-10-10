# Native Motion

**Calm by default. Responsive by nature. Native by design.**

Native Motion is an independent, open-source, native-first UI and motion design
system. Its first renderer uses SwiftUI, not a web view. Future Flutter and
Jetpack Compose implementations will share interaction semantics rather than
copy platform-specific animation constants.

> Experimental foundation. APIs and visual tokens are not yet stable.

## Contents

- Semantic animation presets: responsive, gentle, morph, settle
- Light/dark color palettes and design tokens
- Native `MotionButton`: four variants, three sizes and four phases
- Reduced Motion and Dynamic Type adaptations
- Executable SwiftUI component catalog
- Cross-platform token tests and CI

## Swift Package Manager

Use Xcode **File → Add Package Dependencies**:

`https://github.com/knigdelioglu/native-motion`

Choose the `NativeMotion` library product. Until the first release tag,
select a branch or revision. Requires **macOS 13+ or iOS 16+**.

```swift
import SwiftUI
import NativeMotion

struct Example: View {
    @State private var phase: MotionButtonPhase = .idle

    var body: some View {
        MotionButton("Save", phase: phase) {
            phase = .loading
            // Host owns the operation and sets .success or .failure.
        }
    }
}
```

## Build, test and preview

```sh
swift test
swift build -c release
swift run NativeMotionCatalog
```

The catalog is interactive on macOS with SwiftUI. Linux can compile the
platform-neutral token layer and prints a catalog availability message.
CI checks both Linux and macOS. Manual UI/accessibility checks on Apple devices
are still required.

## Design system

Read [design principles](design/PRINCIPLES.md), [roadmap](design/ROADMAP.md)
and [contribution rules](CONTRIBUTING.md).

### Inspiration and independence

[Arc Library](https://github.com/kuratlielia/arc-library) inspires the
attention to calm, purposeful motion. Native Motion is **not** a fork or
source-code translation: its SwiftUI components, APIs, tokens, and assets are
developed independently.

## License

[MIT](LICENSE).
