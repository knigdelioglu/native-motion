// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "NativeMotion",
  platforms: [.macOS(.v13), .iOS(.v16)],
  products: [
    .library(name: "NativeMotion", targets: ["NativeMotion"]),
    .executable(name: "NativeMotionCatalog", targets: ["NativeMotionCatalog"]),
    .executable(name: "NativeMotionVisualAudit", targets: ["NativeMotionVisualAudit"]),
    .executable(name: "NativeMotionBenchmark", targets: ["NativeMotionBenchmark"])
  ],
  targets: [
    .target(name: "NativeMotion", path: "Sources/NativeMotion"),
    .executableTarget(name: "NativeMotionCatalog", dependencies: ["NativeMotion"],
                      path: "Examples/SwiftUICatalog"),
    .executableTarget(name: "NativeMotionVisualAudit", dependencies: ["NativeMotion"],
                      path: "Tools/VisualAudit"),
    .executableTarget(name: "NativeMotionBenchmark", dependencies: ["NativeMotion"],
                      path: "Tools/Benchmark"),
    .testTarget(name: "NativeMotionTests", dependencies: ["NativeMotion"],
                path: "Tests/NativeMotionTests",
                resources: [.copy("Snapshots")])
  ]
)
