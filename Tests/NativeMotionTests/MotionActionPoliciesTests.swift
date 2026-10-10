import XCTest
@testable import NativeMotion

final class MotionActionPoliciesTests: XCTestCase {
    func testSplitMenuRequiresEnabledOptionsAndNoLoading() {
        XCTAssertFalse(MotionSplitButtonPolicy.canOpenMenu(
            isLoading: false, enabledAlternativeCount: 0
        ))
        XCTAssertTrue(MotionSplitButtonPolicy.canOpenMenu(
            isLoading: false, enabledAlternativeCount: 1
        ))
        XCTAssertFalse(MotionSplitButtonPolicy.canOpenMenu(
            isLoading: true, enabledAlternativeCount: 2
        ))
        XCTAssertFalse(MotionSplitButtonPolicy.identifiersAreUnique(["copy", "copy"]))
        XCTAssertTrue(MotionSplitButtonPolicy.identifiersAreUnique(["copy", "move"]))
    }

    func testConfirmationRequiresExactlyTwoIntentionalActivations() {
        let first = MotionConfirmButtonPolicy.transition(
            from: .idle, event: .primaryTap
        )
        XCTAssertEqual(first.next, .armed)
        XCTAssertFalse(first.firesAction)

        let second = MotionConfirmButtonPolicy.transition(
            from: first.next, event: .primaryTap
        )
        XCTAssertEqual(second.next, .idle)
        XCTAssertTrue(second.firesAction)

        let next = MotionConfirmButtonPolicy.transition(
            from: second.next, event: .primaryTap
        )
        XCTAssertEqual(next.next, .armed)
        XCTAssertFalse(next.firesAction)
    }

    func testCancelAndResetNeverTriggerDestructiveWork() {
        for original in [MotionConfirmationState.idle, .armed] {
            for event in [MotionConfirmationEvent.cancel, .reset] {
                let next = MotionConfirmButtonPolicy.transition(
                    from: original, event: event
                )
                XCTAssertEqual(next.next, .idle)
                XCTAssertFalse(next.firesAction)
            }
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionActionSwiftUIConstructionTests: XCTestCase {
    @MainActor
    func testSplitButtonCanRenderVariantsAndMenuOptions() {
        for variant in MotionButtonVariant.allCases {
            let button = MotionSplitButton(
                "Export", variant: variant,
                actions: [
                    MotionSplitAction("pdf", title: "PDF", systemImage: "doc") {},
                    MotionSplitAction("csv", title: "CSV", isEnabled: false) {}
                ],
                primaryAction: {}
            )
            _ = button.body
        }
    }

    @MainActor
    func testConfirmationCanRenderWithHostControlledPhase() {
        let control = MotionConfirmButton(
            "Delete", confirmationTitle: "Delete permanently",
            variant: .destructive, phase: .idle
        ) {}
        _ = control.body
    }
}
#endif
