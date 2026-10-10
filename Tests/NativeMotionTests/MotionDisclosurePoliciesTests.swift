import XCTest
@testable import NativeMotion

final class MotionDisclosurePoliciesTests: XCTestCase {
    private let enabled: Set<String> = ["a", "b", "c"]

    func testAccordionSingleSelectClosesOtherOpenItems() {
        let next = MotionDisclosurePolicies.toggle(
            id: "b", expandedIDs: ["a"],
            enabledIDs: enabled, allowsMultiple: false
        )
        XCTAssertEqual(next, ["b"])
        XCTAssertEqual(
            MotionDisclosurePolicies.toggle(
                id: "b", expandedIDs: next,
                enabledIDs: enabled, allowsMultiple: false
            ),
            []
        )
    }

    func testMultipleExpansionPreservesIndependentItems() {
        XCTAssertEqual(
            MotionDisclosurePolicies.toggle(
                id: "b", expandedIDs: ["a"],
                enabledIDs: enabled, allowsMultiple: true
            ),
            ["a", "b"]
        )
        XCTAssertEqual(
            MotionDisclosurePolicies.toggle(
                id: "a", expandedIDs: ["a", "b"],
                enabledIDs: enabled, allowsMultiple: true
            ),
            ["b"]
        )
    }

    func testDisabledAndUnknownItemsPreserveHostState() {
        for id in ["disabled", "missing"] {
            XCTAssertEqual(
                MotionDisclosurePolicies.toggle(
                    id: id, expandedIDs: ["a"],
                    enabledIDs: enabled, allowsMultiple: false
                ),
                ["a"]
            )
        }
        XCTAssertEqual(
            MotionDisclosurePolicies.toggle(
                id: "b", expandedIDs: ["a"], enabledIDs: enabled,
                allowsMultiple: true, controlEnabled: false
            ),
            ["a"]
        )
        XCTAssertTrue(MotionDisclosurePolicies.identifiersAreUnique(["a", "b"]))
        XCTAssertFalse(MotionDisclosurePolicies.identifiersAreUnique(["a", "a"]))
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionDisclosureConstructionTests: XCTestCase {
    @MainActor
    func testNestedDisclosureAndAccordionConstruct() {
        let accordion = MotionAccordion(
            "Sections",
            items: [
                MotionAccordionItem("general", title: "General"),
                MotionAccordionItem("disabled", title: "Unavailable", isEnabled: false)
            ],
            expandedIDs: .constant(["general"]),
            allowsMultiple: true
        ) { id in
            MotionDisclosureGroup(
                "Nested \(id)",
                isExpanded: .constant(false)
            ) {
                MotionButton("Nested action") {}
            }
        }
        _ = accordion.body
    }
}
#endif
