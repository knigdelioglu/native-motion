import XCTest
@testable import NativeMotion

final class MotionSelectionNavigationTests: XCTestCase {
    private let options = ["overview", "history", "details", "settings"]

    func testMovesForwardAndBackward() {
        XCTAssertEqual(MotionSelectionNavigation.adjacentID(
            from: "history", step: 1, ids: options), "details")
        XCTAssertEqual(MotionSelectionNavigation.adjacentID(
            from: "history", step: -1, ids: options), "overview")
    }

    func testDoesNotWrapAtEdges() {
        XCTAssertNil(MotionSelectionNavigation.adjacentID(
            from: "settings", step: 1, ids: options))
        XCTAssertNil(MotionSelectionNavigation.adjacentID(
            from: "overview", step: -1, ids: options))
    }

    func testSkipsDisabledOptions() {
        XCTAssertEqual(MotionSelectionNavigation.adjacentID(
            from: "overview", step: 1, ids: options,
            disabledIDs: ["history", "details"]), "settings")
        XCTAssertNil(MotionSelectionNavigation.adjacentID(
            from: "overview", step: 1, ids: options,
            disabledIDs: ["history", "details", "settings"]))
        XCTAssertEqual(MotionSelectionNavigation.adjacentID(
            from: "settings", step: -1, ids: options,
            disabledIDs: ["history", "details"]), "overview")
    }

    func testUnknownSelectionFallsBackByDirection() {
        XCTAssertEqual(MotionSelectionNavigation.adjacentID(
            from: "removed", step: 1, ids: options), "overview")
        XCTAssertEqual(MotionSelectionNavigation.adjacentID(
            from: "removed", step: -1, ids: options), "settings")
        XCTAssertEqual(MotionSelectionNavigation.adjacentID(
            from: "removed", step: 1, ids: options,
            disabledIDs: ["overview"]), "history")
    }

    func testEmptyAndInvalidDirection() {
        XCTAssertNil(MotionSelectionNavigation.adjacentID(
            from: "any", step: 1, ids: []))
        XCTAssertNil(MotionSelectionNavigation.adjacentID(
            from: "history", step: 0, ids: options))
        XCTAssertNil(MotionSelectionNavigation.adjacentID(
            from: "history", step: 2, ids: options))
    }

    func testSingleOptionAndFullyDisabledOptions() {
        XCTAssertNil(MotionSelectionNavigation.adjacentID(
            from: "only", step: 1, ids: ["only"]))
        XCTAssertNil(MotionSelectionNavigation.adjacentID(
            from: "none", step: 1, ids: options,
            disabledIDs: Set(options)))
    }
}
