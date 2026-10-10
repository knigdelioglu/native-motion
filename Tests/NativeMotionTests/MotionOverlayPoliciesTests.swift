import XCTest
@testable import NativeMotion

final class MotionOverlayPoliciesTests: XCTestCase {
    func testUniqueIdsRejectDuplication() {
        XCTAssertTrue(MotionOverlayPolicies.identifiersAreUnique([]))
        XCTAssertTrue(MotionOverlayPolicies.identifiersAreUnique(["a", "b"]))
        XCTAssertFalse(MotionOverlayPolicies.identifiersAreUnique(["a", "a"]))
    }

    func testSelectionOnlyAllowsNewEnabledOption() {
        let enabled: Set<String> = ["all", "recent"]
        XCTAssertTrue(MotionOverlayPolicies.canSelect(
            id: "recent", currentID: "all",
            enabledIDs: enabled, controlEnabled: true
        ))
        XCTAssertFalse(MotionOverlayPolicies.canSelect(
            id: "all", currentID: "all",
            enabledIDs: enabled, controlEnabled: true
        ))
        XCTAssertFalse(MotionOverlayPolicies.canSelect(
            id: "blocked", currentID: "all",
            enabledIDs: enabled, controlEnabled: true
        ))
        XCTAssertFalse(MotionOverlayPolicies.canSelect(
            id: "recent", currentID: "all",
            enabledIDs: enabled, controlEnabled: false
        ))
        XCTAssertFalse(MotionOverlayPolicies.canSelect(
            id: "removed", currentID: "all",
            enabledIDs: enabled, controlEnabled: true
        ))
    }

    func testMenuNeedsAnEnabledAction() {
        XCTAssertFalse(MotionOverlayPolicies.canOpenMenu(
            isEnabled: true, enabledActionCount: 0
        ))
        XCTAssertTrue(MotionOverlayPolicies.canOpenMenu(
            isEnabled: true, enabledActionCount: 1
        ))
        XCTAssertFalse(MotionOverlayPolicies.canOpenMenu(
            isEnabled: false, enabledActionCount: 5
        ))
    }

    func testDialogIsHostControlledAndDisallowsRepeatedBusyWork() {
        XCTAssertTrue(MotionOverlayPolicies.canPresentDialog(isEnabled: true))
        XCTAssertFalse(MotionOverlayPolicies.canPresentDialog(isEnabled: false))
        XCTAssertTrue(MotionOverlayPolicies.canConfirmDialog(
            isEnabled: true, isLoading: false
        ))
        XCTAssertFalse(MotionOverlayPolicies.canConfirmDialog(
            isEnabled: true, isLoading: true
        ))
        XCTAssertFalse(MotionOverlayPolicies.canConfirmDialog(
            isEnabled: false, isLoading: false
        ))
        XCTAssertFalse(MotionOverlayPolicies.canDismissDialog(isLoading: true))
        XCTAssertTrue(MotionOverlayPolicies.canDismissDialog(isLoading: false))
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionOverlayConstructionTests: XCTestCase {
    @MainActor
    func testSelectRendersSelectedDisabledAndReadOnlyStates() {
        let options: [MotionSelectOption] = [
            .init("all", title: "All"),
            .init("busy", title: "Unavailable", isEnabled: false)
        ]
        let select = MotionSelect(
            "Category",
            options: options,
            selection: .constant("all"),
            feedback: MotionFieldFeedback("Choose a category", style: .hint)
        )
        let readonly = MotionSelect(
            "Read-only", options: options,
            selection: .constant("busy"), isEnabled: false
        )
        _ = select.body
        _ = readonly.body
    }

    @MainActor
    func testMenuSupportsDisabledAndDestructiveActions() {
        let menu = MotionMenu("Actions", actions: [
            MotionMenuAction("share", title: "Share", systemImage: "square.and.arrow.up") {},
            MotionMenuAction("blocked", title: "Unavailable", isEnabled: false) {},
            MotionMenuAction("delete", title: "Delete", role: .destructive) {}
        ])
        _ = menu.body
    }

    @MainActor
    func testDialogSupportsHostControlledModalAndLoading() {
        let dialog = MotionDialog(
            "Remove item",
            isPresented: .constant(false),
            phase: .loading,
            confirmationRole: .destructive,
            onConfirm: {}
        ) {
            Text("Open modal")
        } content: {
            Text("This action requires confirmation")
        }
        _ = dialog.body
    }
}
#endif
