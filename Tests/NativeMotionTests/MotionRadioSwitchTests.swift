import XCTest
@testable import NativeMotion

final class MotionRadioNavigationPolicyTests: XCTestCase {
    private let ids = ["overview", "active", "disabled", "archived"]
    private let disabled: Set<String> = ["disabled"]

    func testArrowNavigationSkipsDisabledAndStopsAtEdges() {
        XCTAssertEqual(
            MotionSelectionNavigation.adjacentID(
                from: "active", step: 1, ids: ids, disabledIDs: disabled
            ),
            "archived"
        )
        XCTAssertEqual(
            MotionSelectionNavigation.adjacentID(
                from: "archived", step: -1, ids: ids, disabledIDs: disabled
            ),
            "active"
        )
        XCTAssertNil(
            MotionSelectionNavigation.adjacentID(
                from: "archived", step: 1, ids: ids, disabledIDs: disabled
            )
        )
        XCTAssertNil(
            MotionSelectionNavigation.adjacentID(
                from: "overview", step: -1, ids: ids, disabledIDs: disabled
            )
        )
    }

    func testMissingSelectedItemUsesFirstEnabledInDirection() {
        XCTAssertEqual(
            MotionSelectionNavigation.adjacentID(
                from: "deleted", step: 1, ids: ids, disabledIDs: disabled
            ),
            "overview"
        )
        XCTAssertEqual(
            MotionSelectionNavigation.adjacentID(
                from: "deleted", step: -1, ids: ids, disabledIDs: disabled
            ),
            "archived"
        )
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionRadioSwitchConstructionTests: XCTestCase {
    @MainActor
    func testRadioGroupRendersEnabledAndDisabledOptions() {
        let control = MotionRadioGroup(
            "Category",
            options: [
                MotionRadioOption("all", title: "All"),
                MotionRadioOption("blocked", title: "Unavailable", isEnabled: false),
                MotionRadioOption("recent", title: "Recent")
            ],
            selection: .constant("all")
        )
        _ = control.body
    }

    @MainActor
    func testNativeSwitchRendersBothStatesAndHint() {
        let on = MotionSwitch(
            "Sync",
            detail: "Changes are saved locally",
            isOn: .constant(true)
        )
        let off = MotionSwitch(
            "Unavailable",
            isOn: .constant(false),
            isEnabled: false
        )
        _ = on.body
        _ = off.body
    }
}
#endif
