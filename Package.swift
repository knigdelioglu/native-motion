// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "NativeMotion",
  platforms: [.macOS(.v13), .iOS(.v16)],
  products: [
    .library(name: "NativeMotion", targets: ["NativeMotion"]),
    .executable(name: "NativeMotionCatalog", targets: ["NativeMotionCatalog"])
  ],
  targets: [
    .target(name: "NativeMotion", path: "Sources/NativeMotion"),
    .executableTarget(name: "NativeMotionCatalog", dependencies: ["NativeMotion"], path: "Examples/SwiftUICatalog"),
    .testTarget(name: "NativeMotionTests", dependencies: ["NativeMotion"], path: "Tests/NativeMotionTests")
  ]
)
