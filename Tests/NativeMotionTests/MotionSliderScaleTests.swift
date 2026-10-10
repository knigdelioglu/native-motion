import XCTest
@testable import NativeMotion

final class MotionSliderScaleTests: XCTestCase {
    func testSnappingAndBoundaryClamping() {
        let scale = MotionSliderScale(minimum: 20, maximum: 80, step: 5)
        XCTAssertEqual(scale.snapped(22.4), 20)
        XCTAssertEqual(scale.snapped(22.6), 25)
        XCTAssertEqual(scale.snapped(-1), 20)
        XCTAssertEqual(scale.snapped(900), 80)
        XCTAssertEqual(scale.value(atProgress: 0.5), 50)
        XCTAssertEqual(scale.progress(for: 50), 0.5, accuracy: 0.000001)
    }

    func testShortFinalIntervalIsReachable() {
        let scale = MotionSliderScale(minimum: 0, maximum: 95, step: 10)
        XCTAssertEqual(scale.snapped(95), 95)
        XCTAssertEqual(scale.snapped(93), 95)
        XCTAssertEqual(scale.adjacentValue(from: 90, direction: 1), 95)
        XCTAssertEqual(scale.adjacentValue(from: 95, direction: -1), 85)
    }

    func testNonZeroMinimumAndFractionalSteps() {
        let scale = MotionSliderScale(minimum: 1.5, maximum: 3.5, step: 0.25)
        XCTAssertEqual(scale.snapped(2.12), 2.0, accuracy: 0.00001)
        XCTAssertEqual(scale.snapped(2.14), 2.25, accuracy: 0.00001)
        XCTAssertEqual(scale.progress(for: 1.5), 0)
        XCTAssertEqual(scale.progress(for: 3.5), 1)
    }

    func testInvalidInputsDoNotEscapeScale() {
        let scale = MotionSliderScale(minimum: .nan, maximum: .infinity, step: -.infinity)
        XCTAssertEqual(scale.minimum, 0)
        XCTAssertEqual(scale.maximum, 1)
        XCTAssertEqual(scale.step, 1)
        XCTAssertEqual(scale.snapped(.nan), 0)
        XCTAssertEqual(scale.value(atProgress: .nan), 0)
        XCTAssertEqual(scale.snapped(.infinity), 0)
        XCTAssertEqual(scale.adjacentValue(from: 0.4, direction: 0), 0)
    }

    func testAccessibilityStepAdjustmentsRespectBounds() {
        let scale = MotionSliderScale(minimum: 0, maximum: 100, step: 10)
        XCTAssertEqual(scale.adjacentValue(from: 0, direction: -1), 0)
        XCTAssertEqual(scale.adjacentValue(from: 100, direction: 1), 100)
        XCTAssertEqual(scale.adjacentValue(from: 20, direction: 1), 30)
        XCTAssertEqual(scale.adjacentValue(from: 20, direction: -1), 10)
    }
}
