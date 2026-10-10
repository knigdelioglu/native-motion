import XCTest
@testable import NativeMotion

final class MotionWorkflowPoliciesTests: XCTestCase {
    func testToastDismissalRequiresVisibleHostState() {
        XCTAssertFalse(MotionToastPolicy.canDismiss(isPresented: false))
        XCTAssertTrue(MotionToastPolicy.canDismiss(isPresented: true))
        XCTAssertEqual(MotionToastKind.allCases.count, 4)
    }

    func testStepsNeverInferCompletionFromOrder() {
        let completed: Set<String> = ["choose"]
        XCTAssertEqual(
            MotionStepperPolicy.state(
                for: "choose", currentID: "review", completedIDs: completed
            ),
            .completed
        )
        XCTAssertEqual(
            MotionStepperPolicy.state(
                for: "review", currentID: "review", completedIDs: completed
            ),
            .current
        )
        XCTAssertEqual(
            MotionStepperPolicy.state(
                for: "submit", currentID: "review", completedIDs: completed
            ),
            .pending
        )
        XCTAssertEqual(
            MotionStepperPolicy.state(
                for: "choose", currentID: "submit", completedIDs: []
            ),
            .pending,
            "Past steps are not automatically marked completed."
        )
    }

    func testNavigationDisallowsUnconfirmedFutureAndDisabledSteps() {
        let ids = ["choose", "review", "submit"]
        let done: Set<String> = ["choose"]
        XCTAssertTrue(MotionStepperPolicy.canNavigate(
            to: "choose", currentID: "review", ids: ids, completedIDs: done,
            disabledIDs: [], isEnabled: true, allowsFutureNavigation: false
        ))
        XCTAssertFalse(MotionStepperPolicy.canNavigate(
            to: "submit", currentID: "review", ids: ids, completedIDs: done,
            disabledIDs: [], isEnabled: true, allowsFutureNavigation: false
        ))
        XCTAssertTrue(MotionStepperPolicy.canNavigate(
            to: "submit", currentID: "review", ids: ids, completedIDs: done,
            disabledIDs: [], isEnabled: true, allowsFutureNavigation: true
        ))
        XCTAssertFalse(MotionStepperPolicy.canNavigate(
            to: "submit", currentID: "review", ids: ids, completedIDs: done,
            disabledIDs: ["submit"], isEnabled: true, allowsFutureNavigation: true
        ))
        XCTAssertFalse(MotionStepperPolicy.canNavigate(
            to: "choose", currentID: "missing", ids: ids, completedIDs: done,
            disabledIDs: [], isEnabled: true, allowsFutureNavigation: false
        ))
        XCTAssertFalse(MotionStepperPolicy.identifiersAreUnique(["a", "a"]))
    }

    func testKeyboardDoesNotWrapAndSkipsDisallowed() {
        let ids = ["choose", "review", "blocked", "submit"]
        let done: Set<String> = ["choose"]
        XCTAssertEqual(MotionStepperPolicy.adjacentAllowed(
            from: "review", currentID: "review", direction: -1,
            ids: ids, completedIDs: done, disabledIDs: ["blocked"],
            allowsFutureNavigation: false, isEnabled: true
        ), "choose")
        XCTAssertNil(MotionStepperPolicy.adjacentAllowed(
            from: "review", currentID: "review", direction: 1,
            ids: ids, completedIDs: done, disabledIDs: ["blocked"],
            allowsFutureNavigation: false, isEnabled: true
        ))
        XCTAssertEqual(MotionStepperPolicy.adjacentAllowed(
            from: "review", currentID: "review", direction: 1,
            ids: ids, completedIDs: done, disabledIDs: ["blocked"],
            allowsFutureNavigation: true, isEnabled: true
        ), "submit")
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionWorkflowSwiftUIConstructionTests: XCTestCase {
    @MainActor
    func testToastKindsAndVisibleHostBindingBuild() {
        for kind in MotionToastKind.allCases {
            _ = MotionToast(
                "Saved", kind: kind,
                detail: "Host-supplied result",
                isPresented: .constant(true)
            ).body
        }
    }

    @MainActor
    func testStepperWithHostCompletionAndOptionsBuild() {
        _ = MotionStepper(
            "Workflow", steps: [
                MotionStepItem("choose", title: "Choose"),
                MotionStepItem("review", title: "Review", detail: "Verify inputs"),
                MotionStepItem("submit", title: "Submit", isEnabled: false)
            ],
            selection: .constant("review"),
            completedIDs: ["choose"]
        ).body
    }
}
#endif
