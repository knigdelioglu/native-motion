# Cross-renderer delivery policy (2026-10)

**New Native Motion components must account for all four renderers:**
SwiftUI, Flutter, React Native + Expo and Jetpack Compose. React Native is
now a standard platform track, not an optional afterthought. Compose remains
an independently beta-scoped track until device/release evidence qualifies it.

For every conceptual `Motion*` item, PRs must include a parity manifest entry,
API/interaction design and a React Native-specific implementation or explicit
`planned` state. Public package exports and documentation must agree.
`available` means *code and automated validation*, never device certification.

**v0.2:** 25 SwiftUI controls and 25 experimental React Native sources;
Flutter has 5 implemented (first-ten target remains outstanding).
**v0.5 target:** 55 conceptual components; React Native 55/55
as a release criterion, with Expo Android/iOS tests; Flutter 35/55;
Compose experimental 15/55.
**v1.0 target:** 105/105 React Native plus 105 SwiftUI / 105 Flutter,
Compose 55 beta; React Native may only claim stable parity after
device-specific accessibility, focus, animations, semantics and visual checks.
These are *targets*, not achieved release facts.

Use native components for basic controls, a declared adapter for a missing
platform primitive, and permit platform-specific interaction divergences
when explicitly documented. No WebView or copied Arc code. Ensure SDK
compatibility matrix, sample Expo app, typecheck, tests, Android/iOS
TalkBack/VoiceOver, RTL, large text, Reduce Motion, performance and approved
visual reference gates before stable tagging.
