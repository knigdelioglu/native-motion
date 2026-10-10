# Roadmap

## PR 1 · Foundation
- [x] Swift Package with original semantic design and motion tokens
- [x] Native SwiftUI MotionButton and interactive catalog
- [x] macOS and Linux package CI
- [ ] Manual Apple-device VoiceOver, Dynamic Type and Reduce Motion audit

## PR 2 · Interactive controls
- [x] Spring-linked segmented control with bounded keyboard navigation
- [x] Expandable card with independent host-controlled state
- [x] Catalog examples and platform-neutral selection tests
- [x] Independent bounded elastic slider with gesture, keyboard and VoiceOver adjustment
- [x] Passive accessible status indicator with all major operation states
- [ ] Manual visual and accessibility walkthrough on Apple hardware

## PR 4 · Quality instrumentation
- [x] Deterministic design-token regression goldens on macOS/Linux
- [x] Native SwiftUI screenshot capture for light/dark/reduced-motion/right-to-left
- [x] Baseline image-comparison mode requiring approved reference screenshots
- [x] Repeatable non-UI benchmark with CI artifact (no unreliable speed threshold)
- [x] Expanded scalar/state correctness and contrast tests
- [ ] Review and approve first pixel-image baselines on a fixed macOS toolchain
- [ ] Measure real animation/frame performance with Instruments on Apple hardware
- [ ] Manual VoiceOver and visual quality walkthrough

## PR 5 · Flutter foundation
- [x] Independent native Flutter package and semantic motion/color tokens
- [x] Flutter MotionButton and MotionStatusIndicator with host-controlled state
- [x] Automated palette parity tests against Swift reference tokens
- [x] Independent gallery and pinned stable Flutter CI
- [ ] Flutter segmented control, expandable card and elastic slider
- [ ] Native Flutter golden baselines and on-device semantics/performance review

## Next
- Approve and enforce macOS screenshot goldens after a real visual review
- Flutter component expansion and screen-reader coverage
- Jetpack Compose renderer calibrated independently

Prioritize native interaction quality over the number of components.
