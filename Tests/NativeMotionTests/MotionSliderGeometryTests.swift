import XCTest
@testable import NativeMotion

final class MotionSliderGeometryTests: XCTestCase {
    func testPhysicalMirrorOnceInRTL() {
        XCTAssertEqual(MotionSliderGeometry.visualProgress(fromLogical: 0.65, rightToLeft: false), 0.65)
        XCTAssertEqual(MotionSliderGeometry.visualProgress(fromLogical: 0.65, rightToLeft: true), 0.35, accuracy: 1e-12)
        XCTAssertEqual(MotionSliderGeometry.logicalProgress(fromVisual: 0.35, rightToLeft: true), 0.65, accuracy: 1e-12)
    }

    func testRoundTripAndBoundsAtEveryStep() {
        for rightToLeft in [false, true] {
            for i in 0...100 {
                let logical = Double(i) / 100
                let visual = MotionSliderGeometry.visualProgress(fromLogical: logical, rightToLeft: rightToLeft)
                XCTAssertTrue((0...1).contains(visual))
                XCTAssertEqual(MotionSliderGeometry.logicalProgress(
                    fromVisual: visual, rightToLeft: rightToLeft
                ), logical, accuracy: 1e-12)
            }
        }
    }
}
