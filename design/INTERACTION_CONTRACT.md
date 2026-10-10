# Interaction contract · phase 2

Native Motion is a component library, not a state-management framework.
Components receive bindings and emit actions; applications own domain state.

## MotionSegmentedControl

- Receives a label, a list of `MotionSegment` values and `Binding<String>`.
- Segment IDs are unique and stable. The host starts with an enabled ID.
- Disabled segments are not selectable; changing the option list does not
  silently mutate the externally owned selection.
- Selection moves by native matched geometry for continuity. Reduced Motion
  removes spring movement without changing the selected state.
- A horizontal scroll view supports large text and narrow windows.
- On macOS, left/right keyboard commands select the next enabled segment;
  the direction follows the current right-to-left layout.
- Individual buttons remain focusable and announce selection to VoiceOver.
- Programmatic changes to the Binding update the highlighted segment.

## MotionExpandableCard

- Receives an externally owned `Binding<Bool>` and arbitrary content.
- Header remains a semantic Button and is the only disclosure trigger.
- Expanded content is not nested within the header Button: links, fields and
  other controls retain their own focus and actions.
- VoiceOver announces collapsed/expanded state and the available action.
- Reduced Motion swaps geometry/translations for immediate disclosure.
- Independent instances can open and close without sharing state.

## Manual acceptance checks (macOS/iOS)

1. Keyboard Tab/Shift-Tab and left/right arrow navigation; disabled segments
   are skipped and selection never wraps at the end.
2. VoiceOver announces labels and state; a nested card button remains
   independently operable.
3. Toggle Reduce Motion before interacting; there must be no spring,
   scale or moving content.
4. Test dark/light modes, narrow windows and larger text settings.
5. Test right-to-left layout and repeated rapid state changes.
6. Verify changing external bindings stays consistent with the visual state.

Automated cross-platform navigation tests are not a replacement for the
manual accessibility and rendering walkthrough.

## MotionElasticSlider

- `Binding<Double>` remains authoritative. The host chooses minimum, maximum,
  step, marks and receives begin/end and commit callbacks separately.
- Numeric scale sanitizes invalid bounds and non-finite values and includes
  the upper endpoint even when the final interval is shorter.
- A drag follows the pointer without lag. Outside the bounds, a limited
  rubber-band displacement gives physical feedback and returns on release.
- Reduced Motion eliminates stretch and thumb scaling.
- RTL drag and arrow direction match physical layout. macOS keys and
  VoiceOver adjustable actions honor step boundaries.
- Disabled interaction does not call callbacks or write to the Binding.

## MotionStatusIndicator

- Entirely passive and host-driven; it never simulates asynchronous progress.
- Uses a combination of visible label, status text, color, and system symbol.
- Reduced Motion changes busy feedback from an indefinite spinner to a
  static clock icon.

## Additional manual checks

- Drag to both slider edges and beyond; verify constrained values and an
  immediate snap-back, including in RTL.
- Verify fractional step precision, a short final interval, and rapid changes.
- Confirm adjustable actions from VoiceOver and macOS arrow keys, including
  disabled state and a read-only host binding.
- Observe all five status variants without depending on color alone.
