# Native Motion quality gates

## Automated gates (macOS + Linux)

- `swift test`: token contrast, discrete slider edge cases,
  navigation, thousands of deterministic slider round-trips, and the checked-in
  **textual design-token goldens**.
- `swift build -c release`: ensures all package targets compile.
- `swift run -c release NativeMotionBenchmark --iterations 100000`: collects
  value-model latency as a JSON diagnostic artifact. Runtime timing is deliberately
  **not** a cross-machine PR pass/fail threshold.

## Native macOS screenshot capture

Capture with Swift Package Manager:

```sh
swift run -c release NativeMotionVisualAudit artifacts/visual
```

The macOS tool captures four rendered SwiftUI states at 2× scale:
Large text is **not** represented by these captures: the macOS headless
`ImageRenderer` did not visibly reflect changes to Dynamic Type. Large text
must be checked in the interactive Catalog and on real Apple devices.
The four offscreen scenarios are:
`light.png`, `dark.png`, `reducedMotion.png`, `rightToLeft.png`.
CI uploads these images as downloadable workflow artifacts for human review.
The offscreen SwiftUI renderer cannot draw an interactive `ScrollViewReader`
or its indeterminate `ProgressView` consistently. Audit mode therefore
uses the **same underlying segment buttons without scrolling**, and a static
hourglass instead of a spinner. This snapshot-only adaptation is not active
in actual applications. Scrolling, loading animation and real keyboard
behavior still require native manual testing.

**Important:** Capturing images is *not* the same thing as comparing against a
previously approved screenshot. CI currently verifies successful capture,
dimensions and nontrivial output size. Native pixel comparisons become a gate
only after a maintainer approves reference images for a stable macOS runner.

## Approving screenshots (manual, explicit)

1. Download the four screenshots from a successful macOS CI run. Review every
   image for clipping, alignment, readable labels, dark theme and large text.
2. Store approved images in a versioned directory such as
   `tests/approved-macos15/` (do not silently overwrite them).
3. Compare a new capture against exactly those references:

```sh
swift run -c release NativeMotionVisualAudit artifacts/visual \
  --baseline tests/approved-macos15
```

The comparison checks image dimensions and per-pixel changes (>12 per channel)
with a 2% changed-pixel tolerance. Use the same OS/toolchain and display scale;
SwiftUI fonts, antialiasing and shadows can change across OS releases.
Never auto-approve a changed image in CI.

## Manual acceptance checklist

- VoiceOver: button labels, loading/disabled state, selected segment, expandable
  card state, slider value adjustment, and status text.
- Keyboard: Tab/Shift-Tab, left/right arrows in segmented control, disabled
  options, slider step changes and boundary behavior.
- Pointer/touch: quick repeated presses, sustained drag, elastic endpoints
  and nested card actions.
- Appearance: light/dark, RTL, small windows, Dynamic Type large sizes,
  native window resizing and Reduce Motion.
- Performance: Instruments/Animation Hitches and Time Profiler on Apple
  hardware to identify frame drops and main-thread work. CLI value-model
  microbenchmarks are not a substitute for animation or energy profiling.

Accessibility and real-device frame-rate claims must not be marked PASS until
an actual human/device walkthrough is recorded.
