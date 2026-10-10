import XCTest
@testable import NativeMotion

final class MotionPresentationPoliciesTests: XCTestCase {
    func testPopoverOpeningAndDismissalAreExplicit() {
        XCTAssertTrue(MotionPresentationPolicies.canOpen(
            isEnabled: true, isPresented: false
        ))
        XCTAssertFalse(MotionPresentationPolicies.canOpen(
            isEnabled: false, isPresented: false
        ))
        XCTAssertFalse(MotionPresentationPolicies.canOpen(
            isEnabled: true, isPresented: true
        ))
        XCTAssertTrue(MotionPresentationPolicies.canDismiss(isPresented: true))
        XCTAssertFalse(MotionPresentationPolicies.canDismiss(isPresented: false))
    }

    func testTabIDsRequireUniqueness() {
        XCTAssertTrue(MotionPresentationPolicies.identifiersAreUnique([]))
        XCTAssertTrue(MotionPresentationPolicies.identifiersAreUnique(["one", "two"]))
        XCTAssertFalse(MotionPresentationPolicies.identifiersAreUnique(["one", "one"]))
    }

    func testTabSelectionPreservesHostStateOnDisabledOrMissingIDs() {
        let enabled: Set<String> = ["all", "recent", "archived"]
        XCTAssertTrue(MotionPresentationPolicies.canSelectTab(
            id: "recent", currentID: "all", enabledIDs: enabled, controlEnabled: true
        ))
        XCTAssertFalse(MotionPresentationPolicies.canSelectTab(
            id: "all", currentID: "all", enabledIDs: enabled, controlEnabled: true
        ))
        XCTAssertFalse(MotionPresentationPolicies.canSelectTab(
            id: "blocked", currentID: "all", enabledIDs: enabled, controlEnabled: true
        ))
        XCTAssertFalse(MotionPresentationPolicies.canSelectTab(
            id: "deleted", currentID: "all", enabledIDs: enabled, controlEnabled: true
        ))
        XCTAssertFalse(MotionPresentationPolicies.canSelectTab(
            id: "recent", currentID: "all", enabledIDs: enabled, controlEnabled: false
        ))
    }

    func testNavigationSkipsDisabledAndDoesNotWrap() {
        let ids = ["all", "recent", "disabled", "archived"]
        let disabled: Set<String> = ["disabled"]
        XCTAssertEqual(MotionPresentationPolicies.adjacentTab(
            from: "recent", step: 1, ids: ids, disabledIDs: disabled
        ), "archived")
        XCTAssertEqual(MotionPresentationPolicies.adjacentTab(
            from: "archived", step: -1, ids: ids, disabledIDs: disabled
        ), "recent")
        XCTAssertNil(MotionPresentationPolicies.adjacentTab(
            from: "archived", step: 1, ids: ids, disabledIDs: disabled
        ))
        XCTAssertNil(MotionPresentationPolicies.adjacentTab(
            from: "all", step: -1, ids: ids, disabledIDs: disabled
        ))
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionPresentationSwiftUIConstructionTests: XCTestCase {
    @MainActor
    func testPopoverUsesHostOwnedBindingAndNestedControls() {
        let popover = MotionPopover(
            "Information",
            isPresented: .constant(false)
        ) {
            Text("Open information")
        } content: {
            MotionButton("Nested action") {}
        }
        _ = popover.body
    }

    @MainActor
    func testTooltipSupportsNativeHelpAndFocusableTrigger() {
        let tooltip = MotionTooltip(
            "Help", message: "Explains this action"
        ) {
            Image(systemName: "questionmark.circle")
        }
        _ = tooltip.body
    }

    @MainActor
    func testTabsSupportHostSelectionDisabledOptionsAndContent() {
        let tabs = MotionTabs(
            "Sections",
            tabs: [
                MotionTabItem("all", title: "All", systemImage: "square.grid.2x2"),
                MotionTabItem("disabled", title: "Unavailable", isEnabled: false),
                MotionTabItem("recent", title: "Recent")
            ],
            selection: .constant("all")
        ) { tabID in
            Text("Current: \(tabID)")
        }
        _ = tabs.body
    }
}
#endif
