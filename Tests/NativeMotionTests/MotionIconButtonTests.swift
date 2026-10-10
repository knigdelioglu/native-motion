#if canImport(SwiftUI)
import XCTest
import SwiftUI
@testable import NativeMotion

final class MotionIconButtonTests: XCTestCase {
    func testPlatformMinimumTargetSizes() {
        XCTAssertEqual(MotionIconButtonPolicy.side(for: .small, onMac: true), 32)
        XCTAssertEqual(MotionIconButtonPolicy.side(for: .medium, onMac: true), 40)
        XCTAssertEqual(MotionIconButtonPolicy.side(for: .large, onMac: true), 48)
        XCTAssertEqual(MotionIconButtonPolicy.side(for: .small, onMac: false), 44)
        XCTAssertEqual(MotionIconButtonPolicy.side(for: .medium, onMac: false), 48)
        XCTAssertEqual(MotionIconButtonPolicy.side(for: .large, onMac: false), 56)
    }

    func testBusyStateCannotReActivate() {
        for phase in MotionButtonPhase.allCases {
            XCTAssertEqual(
                MotionIconButtonPolicy.canActivate(phase: phase),
                phase != .loading
            )
        }
    }

    @MainActor
    func testPublicSwiftUIViewCanBeConstructedForEveryVariant() {
        for variant in MotionButtonVariant.allCases {
            let button = MotionIconButton(
                systemName: "square.and.arrow.up",
                label: "Share",
                variant: variant
            ) {}
            _ = button.body
        }
    }
}
#endif
