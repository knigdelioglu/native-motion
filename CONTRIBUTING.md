# Contributing

Build original native components independent of any host application.

Every component contribution should include its interaction purpose, accessible
and reduced-motion behavior, documented public API, catalog demonstration and
automated coverage where practicable.

Run `swift test` and `swift build -c release` before opening a PR.

## Flutter

`packages/flutter` uses the Flutter stable toolchain specified in
`.github/workflows/flutter.yml`. Changes to semantic colors must retain parity
with the Swift reference goldens. Run `flutter analyze`, `flutter test`
from the package, and analyze the independent `example/` gallery before PR.
Never modify application repositories as part of design-system development.
