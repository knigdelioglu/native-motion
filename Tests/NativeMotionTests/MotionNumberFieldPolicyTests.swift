import Foundation
import XCTest
@testable import NativeMotion

final class MotionNumberFieldPolicyTests: XCTestCase {
    private let en = Locale(identifier: "en_US")
    private let tr = Locale(identifier: "tr_TR")

    func testLocalizedDecimalParsingAndFormatting() {
        let scale = MotionSliderScale(minimum: -10, maximum: 10, step: 0.25)
        XCTAssertEqual(
            MotionNumberFieldPolicy.parse("2.25", scale: scale, locale: en),
            .accepted(2.25)
        )
        XCTAssertEqual(
            MotionNumberFieldPolicy.parse("2,25", scale: scale, locale: tr),
            .accepted(2.25)
        )
        XCTAssertEqual(
            MotionNumberFieldPolicy.parse(" -2,26 ", scale: scale, locale: tr),
            .accepted(-2.25)
        )
        XCTAssertEqual(
            MotionNumberFieldPolicy.display(2.25, scale: scale, locale: tr),
            "2,25"
        )
        XCTAssertEqual(
            MotionNumberFieldPolicy.display(2.25, scale: scale, locale: en),
            "2.25"
        )
    }

    func testStrictInvalidInputsNeverBecomePartialNumbers() {
        let scale = MotionSliderScale()
        for bad in [
            "", " ", "-", "+", ".", "1.2.3", "10abc", "5e3",
            "NaN", "Infinity", "1,000", "1_000", "1 0", "--3"
        ] {
            XCTAssertEqual(
                MotionNumberFieldPolicy.parse(bad, scale: scale, locale: en),
                .invalid,
                "Bad input was accepted: \(bad)"
            )
        }
        XCTAssertEqual(
            MotionNumberFieldPolicy.parse("3.5", scale: scale, locale: tr),
            .invalid,
            "Turkish decimal parsing must not accept a period"
        )
    }

    func testOutOfRangeInputsClampAndRespectShortFinalStep() {
        let scale = MotionSliderScale(minimum: 0, maximum: 95, step: 10)
        XCTAssertEqual(
            MotionNumberFieldPolicy.parse("900", scale: scale, locale: en),
            .accepted(95)
        )
        XCTAssertEqual(
            MotionNumberFieldPolicy.parse("-500", scale: scale, locale: en),
            .accepted(0)
        )
        XCTAssertEqual(
            MotionNumberFieldPolicy.parse("94", scale: scale, locale: en),
            .accepted(95)
        )
        XCTAssertEqual(
            MotionNumberFieldPolicy.adjacent(to: 95, direction: -1, scale: scale),
            90
        )
        XCTAssertEqual(
            MotionNumberFieldPolicy.adjacent(to: 90, direction: 1, scale: scale),
            95
        )
    }

    func testPolicyKeepsIndependentHostStateUntilValidated() {
        let scale = MotionSliderScale(minimum: 0, maximum: 100, step: 5)
        var hostValue = 50.0
        let invalid = MotionNumberFieldPolicy.parse("abc", scale: scale, locale: en)
        if case .accepted(let newValue) = invalid { hostValue = newValue }
        XCTAssertEqual(hostValue, 50)
        let valid = MotionNumberFieldPolicy.parse("52.4", scale: scale, locale: en)
        if case .accepted(let newValue) = valid { hostValue = newValue }
        XCTAssertEqual(hostValue, 50)
        let validNext = MotionNumberFieldPolicy.parse("53", scale: scale, locale: en)
        if case .accepted(let newValue) = validNext { hostValue = newValue }
        XCTAssertEqual(hostValue, 55)
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionFormFieldConstructionTests: XCTestCase {
    @MainActor
    func testTextFieldSupportsErrorHelperAndDisabled() {
        let input = MotionTextField(
            "Name",
            placeholder: "Enter name",
            text: .constant("Example"),
            feedback: MotionFieldFeedback("Name is required", style: .error)
        )
        let disabled = MotionTextField(
            "Unavailable",
            text: .constant(""),
            isEnabled: false
        )
        _ = input.body
        _ = disabled.body
    }

    @MainActor
    func testSearchFieldSupportsClearAndHostSubmit() {
        let search = MotionSearchField(
            "Find",
            query: .constant("SwiftUI"),
            feedback: MotionFieldFeedback("Showing matches", style: .hint)
        ) {}
        _ = search.body
    }

    @MainActor
    func testNumberFieldBuildsLocalizedInputAndStepper() {
        let number = MotionNumberField(
            "Amount",
            value: .constant(12.25),
            scale: .init(minimum: 0, maximum: 100, step: 0.25),
            feedback: MotionFieldFeedback("In range", style: .success)
        ) { _ in }
        _ = number.body
    }
}
#endif
