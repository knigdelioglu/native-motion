import XCTest
@testable import NativeMotion

final class MotionNavigationPoliciesTests: XCTestCase {
    func testBreadcrumbNavigationGatingAndUniqueIDs() {
        XCTAssertTrue(MotionNavigationPolicies.unique(["root", "child"]))
        XCTAssertFalse(MotionNavigationPolicies.unique(["root", "root"]))
        XCTAssertTrue(MotionNavigationPolicies.canNavigate(
            to: "root", currentID: "child", enabledIDs: ["root"]
        ))
        XCTAssertFalse(MotionNavigationPolicies.canNavigate(
            to: "child", currentID: "child", enabledIDs: ["child"]
        ))
        XCTAssertFalse(MotionNavigationPolicies.canNavigate(
            to: "disabled", currentID: "child", enabledIDs: ["root"]
        ))
    }

    func testPaginationWindowBoundedForLargeDataSets() {
        XCTAssertEqual(MotionNavigationPolicies.pages(current: 1, total: 0), [])
        XCTAssertEqual(MotionNavigationPolicies.pages(current: 1, total: 3), [1, 2, 3])
        XCTAssertEqual(MotionNavigationPolicies.pages(current: 1, total: 100), [1, 2, 3, 4, 5])
        XCTAssertEqual(MotionNavigationPolicies.pages(current: 50, total: 100), [48, 49, 50, 51, 52])
        XCTAssertEqual(MotionNavigationPolicies.pages(current: 100, total: 100), [96, 97, 98, 99, 100])
        XCTAssertEqual(MotionNavigationPolicies.pages(current: 200, total: 100), [96, 97, 98, 99, 100])
        XCTAssertEqual(MotionNavigationPolicies.pages(current: -5, total: 5, maxVisible: 0), [1])
    }

    func testPreviousNextAreBounded() {
        XCTAssertNil(MotionNavigationPolicies.adjacent(current: 1, total: 100, delta: -1))
        XCTAssertEqual(MotionNavigationPolicies.adjacent(current: 1, total: 100, delta: 1), 2)
        XCTAssertNil(MotionNavigationPolicies.adjacent(current: 100, total: 100, delta: 1))
        XCTAssertNil(MotionNavigationPolicies.adjacent(current: 1, total: 0, delta: 1))
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionNavigationConstructionTests: XCTestCase {
    @MainActor
    func testNavigationControlsCompile() {
        _ = MotionBreadcrumb(
            "Path", items: [
                .init("home", title: "Home"),
                .init("detail", title: "Detail")
            ], currentID: "detail"
        ) { _ in }.body

        _ = MotionPagination(
            "Pages", page: .constant(2), totalPages: 100
        ).body

        _ = MotionSideNavigation(
            "Sections", items: [
                .init("general", title: "General", systemImage: "gear"),
                .init("disabled", title: "Unavailable", isEnabled: false)
            ], selection: .constant("general")
        ).body
    }
}
#endif
