import XCTest
@testable import NativeMotion

final class MotionCommandPoliciesTests: XCTestCase {
    func testIdentifierAndDisabledGates() {
        XCTAssertTrue(MotionCommandPolicies.identifiersAreUnique(["a", "b"]))
        XCTAssertFalse(MotionCommandPolicies.identifiersAreUnique(["a", "a"]))
        XCTAssertTrue(MotionCommandPolicies.canExecute(
            id: "save", validEnabledIDs: ["save"], isPresented: true
        ))
        XCTAssertFalse(MotionCommandPolicies.canExecute(
            id: "delete", validEnabledIDs: ["save"], isPresented: true
        ))
        XCTAssertFalse(MotionCommandPolicies.canExecute(
            id: "save", validEnabledIDs: ["save"], isPresented: false
        ))
    }

    func testCaseAndAccentInsensitiveSearch() {
        XCTAssertTrue(MotionCommandPolicies.matches(
            query: "sAvE", title: "Save Document", keywords: []
        ))
        XCTAssertTrue(MotionCommandPolicies.matches(
            query: "cafe", title: "Café", keywords: []
        ))
        XCTAssertTrue(MotionCommandPolicies.matches(
            query: "EXPORT", title: "Copy", keywords: ["Export PDF"]
        ))
        XCTAssertTrue(MotionCommandPolicies.matches(
            query: "  ", title: "Copy", keywords: []
        ))
        XCTAssertFalse(MotionCommandPolicies.matches(
            query: "cancel", title: "Copy", keywords: ["Export PDF"]
        ))
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionCommandConstructionTests: XCTestCase {
    @MainActor func testNativeContextAndSearchMenusCompile() {
        let actions = [
            MotionMenuAction("share", title: "Share") {},
            MotionMenuAction("blocked", title: "Unavailable", isEnabled: false) {}
        ]
        _ = MotionContextMenu("More actions", actions: actions) {
            Text("Document")
        }.body
        _ = MotionCommandMenu(
            "Commands",
            commands: [
                MotionCommandItem("save", title: "Save") {},
                MotionCommandItem("blocked", title: "Blocked", isEnabled: false) {}
            ],
            isPresented: .constant(false), query: .constant("")
        ) {
            Text("Find commands")
        }.body
    }
}
#endif
