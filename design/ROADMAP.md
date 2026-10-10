# Roadmap

## Versioned plans

The issue/PR history below records work already completed or outstanding. The
following plans describe **future cumulative version targets**, not claims of
completed releases:

- [v0.2 — foundation, 25 components](../plan/0.2.md)
- [v0.5 — advanced UI, 55 components / 6 blocks](../plan/0.5.md)
- [v1.0 — mature system, 105 components / 22 blocks](../plan/1.0.md)

Counts refer to distinct conceptual components; renderer implementations are
tracked separately. Do not label experimental platform adapters as stable.


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

## v0.2 execution
- [x] Begin machine-verifiable component/renderer coverage contract
- [x] Flutter segmented selection and expandable disclosure implementations
- [x] Flutter elastic slider source, range model and widget tests
- [x] SwiftUI MotionIconButton source and policy tests
- [x] SwiftUI split button and two-stage confirmation action policy
- [x] SwiftUI compact toggle-button and three-state checkbox
- [ ] Remaining v0.2 interaction components
- [ ] Device-level accessibility, screenshot approval, and performance review

[Detailed v0.2 implementation tracker](../plan/0.2-progress.md)

## Next
- Approve and enforce macOS screenshot goldens after a real visual review
- Flutter component expansion and screen-reader coverage
- Jetpack Compose renderer calibrated independently

Prioritize native interaction quality over the number of components.
