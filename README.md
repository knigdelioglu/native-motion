# Native Motion

**Calm by default. Responsive by nature. Native by design.**

Native Motion is an independent, open-source, native-first UI and motion
design system. It has independent **SwiftUI and Flutter renderers**; the Flutter package is
experimental. Jetpack Compose is a future renderer. No WebViews, cross-platform
UI bridges or ported component source are involved. All renderers share
semantic design tokens and interaction intent, not identical spring constants.

> Experimental: APIs and visual tokens are not yet stable.

## Versioned development plans

- [v0.2 — 25 foundational components](plan/0.2.md)
- [v0.5 — 55 components and 6 reusable blocks](plan/0.5.md)
- [v1.0 — 105 components and 22 reusable blocks](plan/1.0.md)

These are cumulative **targets**, not completed releases. Per-platform coverage
and mandatory acceptance gates are defined separately in each plan.

## Components

| Component | Description |
| --- | --- |
| `MotionButton` | Four variants, three sizes, idle/loading/success/failure |
| `MotionIconButton` | Native icon-only action with a mandatory accessible label, phases, sizes and disabled support (SwiftUI) |
| `MotionSplitButton` | Separate primary action and native alternative-action menu, disabled/busy options (SwiftUI) |
| `MotionConfirmButton` | Two deliberate activations with separate cancel; host-owned completion (SwiftUI) |
| `MotionSegmentedControl` | Spring-linked selection with disabled items, horizontal scrolling and keyboard navigation |
| `MotionExpandableCard` | Host-controlled disclosure card with optional subtitle and arbitrary interactive content |
| `MotionElasticSlider` | Gesture + accessibility-adjustable value input with bounded steps and elastic edges |
| `MotionStatusIndicator` | Passive, accessible feedback with neutral/working/success/warning/failure |
| `MotionToggle` | Compact two-state native toggle-button with host-owned state (SwiftUI) |
| `MotionCheckbox` | Native tri-state checkbox (checked/unchecked/mixed), host-controlled (SwiftUI) |
| `MotionRadioGroup` | Native single choice, disabled options, bounded keyboard navigation and RTL (SwiftUI) |
| `MotionSwitch` | Platform-native system switch with host-owned Boolean state and optional detail (SwiftUI) |
| `MotionTextField` | Native text input with focus and visible helper/error state (SwiftUI) |
| `MotionSearchField` | Host-owned search input with clear and submit controls (SwiftUI) |
| `MotionNumberField` | Locale-aware bounded number entry, strict parsing, adjustable increments (SwiftUI) |
| `MotionSelect` | Native drop-down, host-controlled selection and disabled options (SwiftUI) |
| `MotionMenu` | Native action menu, disabled/destructive items and keyboard support (SwiftUI) |
| `MotionDialog` | Native host-controlled modal; safe cancel, confirmation and busy gating (SwiftUI) |

Supporting these are semantic motion presets (`responsive`, `gentle`,
`morph`, `settle`), light/dark palette tokens, layout dimensions, Reduce
Motion adaptation and an interactive component catalog.

## Flutter (experimental)

A native Flutter library, tests, and independent gallery are available in
[packages/flutter](packages/flutter/README.md). It implements all five core components, including `MotionElasticSlider`,
with native Flutter interaction, controlled states,
reduced-motion handling, and cross-renderer token parity tests.

```yaml
dependencies:
  native_motion:
    git:
      url: https://github.com/knigdelioglu/native-motion.git
      path: packages/flutter
      ref: main
```

See [Flutter renderer architecture](docs/FLUTTER.md). This is an early release,
not a feature-complete match to the five SwiftUI components.

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
Reduce Motion, right-to-left layout) and uploads them as Actions artifacts. Captured images
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
catalog availability message. Swift CI tests macOS and Linux; a separate Flutter workflow checks Flutter
analysis, widget behavior, token parity and the standalone gallery.
Manual device-level visual, keyboard and accessibility checks remain necessary.

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
