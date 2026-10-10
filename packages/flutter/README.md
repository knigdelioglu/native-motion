# Native Motion for Flutter — experimental

Original, app-independent Flutter implementation of Native Motion.

## Installation

Until a tagged release, depend on this monorepo path directly:

```yaml
dependencies:
  native_motion:
    git:
      url: https://github.com/knigdelioglu/native-motion.git
      path: packages/flutter
      ref: main
```

Import with `import 'package:native_motion/native_motion.dart';`.

## Current components

- `MotionButton`: primary/secondary/ghost/destructive; small/medium/large;
  idle/loading/success/failure; host-owned callback; duplicate taps blocked
  while loading; native pointer/keyboard focus.
- `MotionSegmentedControl`: host-controlled string ID selection, horizontal
  overflow, disabled options, native keyboard arrow handling with RTL direction,
  light/dark theme and reduced-motion animation policy.
- `MotionExpandableCard`: controlled disclosure header, optional subtitle,
  independent nested actions, accessible expanded/collapsed value.
- `MotionElasticSlider`: controlled double value, bounded discrete step model,
  irregular last interval, bidirectional/RTL track, elastic overdrag,
  accessible adjustable actions and keyboard increments, reduced-motion fallback.
- `MotionStatusIndicator`: neutral/processing/success/warning/failure;
  label, optional detail and localizable status text; status is host-controlled.
- Semantic color, spacing and radius tokens with repository-level parity tests
  against the Swift package's goldens.

## v0.5 incremental components

- `MotionAccordion`: host-supplied open ID set, single/multiple mode,
  disabled entries and nested independent actions.
- `MotionDisclosureGroup`: externally controlled native disclosure
  with localized semantic label and reduced-motion collapse/expand.

These are v0.5 **development components**, not an independently released or
device-certified API; see [v0.5 progress](../../plan/0.5-progress.md).

## Accessibility

A reduced-motion preference stops press animations and switches indefinite busy
feedback to a static status. Flutter exposes animation suppression through
`MediaQueryData.disableAnimations`; iOS also exposes a separate
`PlatformDispatcher.accessibilityFeatures.reduceMotion` flag, so both are
respected. A native platform observer updates controls when accessibility
preferences change. <i>Automated widget tests are not real-device screen reader tests.</i>

## Catalog

The standalone catalog lives at `example/`. To launch on a new device:

```sh
cd packages/flutter/example
flutter pub get
flutter create --project-name native_motion_gallery --platforms=android,ios,macos .
flutter run
```

Platform shell files are generated locally so the repo stays focused on the
native component implementation. CI analyzes the catalog's Dart source.

## Quality

```sh
cd packages/flutter
flutter pub get
flutter analyze
flutter test
```

Parity tests intentionally read the root repo's Swift token fixture files;
run them from this monorepo rather than a repackaged standalone tarball.
No third-party state manager, navigation package, or animation engine is used.

## Status

Experimental: package APIs may change before the first stable tag.
Remaining: additional 0.2 controls, Flutter golden
tests, and device-level accessibility/performance review.
The segmented selection, disclosure and slider components use native Flutter motion
parameters; shared element travel and exact SwiftUI spring parity are not claimed.
