import XCTest
@testable import NativeMotion

final class MotionFeedbackPoliciesTests: XCTestCase {
    func testProgressPreservesIndeterminateAndRejectsNonfinite() {
        XCTAssertNil(MotionProgressPolicy.normalized(nil))
        XCTAssertNil(MotionProgressPolicy.normalized(.nan))
        XCTAssertNil(MotionProgressPolicy.normalized(.infinity))
        XCTAssertNil(MotionProgressPolicy.normalized(-.infinity))
        XCTAssertNil(MotionProgressPolicy.percent(.nan))
    }

    func testProgressClampsAndNeverInfersSuccess() {
        XCTAssertEqual(MotionProgressPolicy.normalized(-4), 0)
        XCTAssertEqual(MotionProgressPolicy.normalized(3), 1)
        XCTAssertEqual(MotionProgressPolicy.normalized(0.725), 0.725)
        XCTAssertEqual(MotionProgressPolicy.percent(0.725), 73)
        XCTAssertEqual(MotionProgressPolicy.percent(0.999), 100)
        XCTAssertEqual(MotionProgressPolicy.percent(0.0), 0)
    }

    func testProgressInvariantsAcrossDenseRange() {
        for i in -1000...2000 {
            let progress = MotionProgressPolicy.normalized(Double(i) / 1000)
            XCTAssertNotNil(progress)
            XCTAssertTrue((0...1).contains(progress!))
            XCTAssertEqual(
                MotionProgressPolicy.normalized(progress),
                progress
            )
        }
    }

    func testSkeletonRowsStayWithinLayoutBounds() {
        XCTAssertEqual(MotionSkeletonPolicy.visibleRows(-200), 1)
        XCTAssertEqual(MotionSkeletonPolicy.visibleRows(0), 1)
        XCTAssertEqual(MotionSkeletonPolicy.visibleRows(3), 3)
        XCTAssertEqual(MotionSkeletonPolicy.visibleRows(8), 8)
        XCTAssertEqual(MotionSkeletonPolicy.visibleRows(1000), 8)
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionFeedbackSwiftUIConstructionTests: XCTestCase {
    @MainActor
    func testProgressVariantsBuild() {
        _ = MotionProgress("Download", fraction: 0.45).body
        _ = MotionProgress("Download", fraction: nil).body
        _ = MotionProgress("Download", fraction: 1, detail: "Finishing").body
    }

    @MainActor
    func testSkeletonVariationsBuild() {
        _ = MotionSkeleton(rows: 1).body
        _ = MotionSkeleton("Loading profile", rows: 4, showsAvatar: true).body
        _ = MotionSkeleton("Loading data", rows: 0).body
    }
}
#endif
