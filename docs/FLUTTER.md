# Flutter renderer contract

Native Motion is a multi-renderer design system. SwiftUI and Flutter do
**not** share binary components or a cross-platform animation engine.

## First stage

`packages/flutter` supplies a Flutter package and host-independent catalog
built entirely with Flutter SDK widgets. The first four components are `MotionButton`, `MotionSegmentedControl`,
`MotionExpandableCard` and `MotionStatusIndicator`.
`MotionElasticSlider` is the final core-five Flutter parity gap.

The visual palette and layout metrics use the established Swift renderer as
the reference. Tests compare every semantic color against the checked-in
Swift goldens on both light and dark palettes, and verify layout invariants.

## Motion mapping

| Intent | SwiftUI | Flutter (first calibration) |
| --- | --- | --- |
| responsive | Spring(response 0.28, damping 0.83) | 180 ms easeOutCubic |
| gentle | Spring(response 0.46, damping 0.90) | 290 ms easeInOutCubic |
| morph | Spring(response 0.42, damping 0.78) | 250 ms emphasized easeInOut |
| settle | Spring(response 0.50, damping 0.72) | 350 ms easeOutBack |

Matching milliseconds is **not** a requirement; the intent is perceptual
consistency. This mapping is provisional until device-level testing.

## Accessibility and state

- All async operations and success/failure decisions belong to the host.
- State text accompanies color and icons.
- A null callback disables the button. Loading phase suppresses repeat work.
- Android's disable-animation preference and iOS Reduced Motion flag are both
  observed. The renderer does not hide real application latency with animation.
- Host strings are passed as localizable text, and the status word can be
  overridden for non-English applications.

## Quality requirements before calling stable

- Native semantics/keyboard/widget tests, actual VoiceOver/TalkBack tests.
- Validate reduced-motion changes while controls are mounted.
- Device-level frame pacing, overdraw, and low-end device performance.
- Visual regression goldens for light/dark/text scale/RTL.
- All five SwiftUI components implemented in Flutter with equivalent behavior.

The Flutter package remains marked experimental until those criteria hold.

## v0.2 controlled UI contracts

| Component | Host state | Native interactions | Known difference |
|---|---|---|---|
| MotionSegmentedControl | `selection: String`, `onChanged(String)` | Touch/hover, overflow scroll, focus, left/right keyboard navigation with RTL and disabled-skip | Flutter animates individual segment backgrounds; SwiftUI uses matched-geometry highlight |
| MotionExpandableCard | `expanded: bool`, `onChanged(bool)` | Native header button, nested independent controls, disclosure semantics | Flutter AnimatedSize and rotation replace SwiftUI layout spring |
| MotionElasticSlider | Planned for next parity PR | Not available in Flutter yet | Do not advertise as implemented |

When callbacks are null, controls are read-only; displayed state remains
host-owned. Their automatic tests are not a substitute for TalkBack/VoiceOver,
keyboard-on-device and real frame pacing measurements.
