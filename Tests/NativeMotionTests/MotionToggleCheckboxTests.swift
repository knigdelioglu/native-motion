import XCTest
@testable import NativeMotion

final class MotionToggleCheckboxPolicyTests: XCTestCase {
    func testCheckboxBinaryCycleAndMixedResolution() {
        XCTAssertEqual(MotionCheckboxPolicy.next(.unchecked), .checked)
        XCTAssertEqual(MotionCheckboxPolicy.next(.checked), .unchecked)
        XCTAssertEqual(MotionCheckboxPolicy.next(.mixed), .checked)
        XCTAssertEqual(MotionCheckboxState.allCases.count, 3)
    }

    func testToggleIsReversible() {
        for original in [false, true] {
            XCTAssertEqual(
                MotionTogglePolicy.next(MotionTogglePolicy.next(original)),
                original
            )
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionToggleCheckboxConstructionTests: XCTestCase {
    @MainActor
    func testToggleAcceptsExternalBindingAndDisabledState() {
        let enabled = MotionToggle("Compact option", isOn: .constant(true))
        let disabled = MotionToggle("Off", isOn: .constant(false), isEnabled: false)
        _ = enabled.body
        _ = disabled.body
    }

    @MainActor
    func testCheckboxRendersAllHostSuppliedStates() {
        for state in MotionCheckboxState.allCases {
            let checkbox = MotionCheckbox("Select", state: .constant(state))
            _ = checkbox.body
        }
    }
}
#endif
