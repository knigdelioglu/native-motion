import XCTest
@testable import NativeMotion

final class NativeMotionTests: XCTestCase {
    func testMotionPresetsAreDistinctAndBounded() {
        var seen: [NativeMotionSpring] = []
        for preset in NativeMotionPreset.allCases {
            let spring = NativeMotionTiming.spring(for: preset)
            XCTAssertGreaterThan(spring.response, 0)
            XCTAssertGreaterThan(spring.dampingFraction, 0)
            XCTAssertLessThanOrEqual(spring.dampingFraction, 1)
            XCTAssertFalse(seen.contains(spring))
            seen.append(spring)
        }
    }

    func testSpacingScales() {
        XCTAssertLessThan(NativeMotionSpacing.xSmall, NativeMotionSpacing.small)
        XCTAssertLessThan(NativeMotionSpacing.small, NativeMotionSpacing.medium)
        XCTAssertLessThan(NativeMotionSpacing.medium, NativeMotionSpacing.large)
        XCTAssertLessThan(NativeMotionSpacing.large, NativeMotionSpacing.xLarge)
        XCTAssertLessThan(NativeMotionControlHeight.small, NativeMotionControlHeight.medium)
        XCTAssertLessThan(NativeMotionControlHeight.medium, NativeMotionControlHeight.large)
    }

    func testSemanticColorsAreValidAndReadable() {
        for appearance in NativeMotionAppearance.allCases {
            for role in NativeMotionColorRole.allCases {
                let rgb = NativeMotionPalette.color(role, appearance: appearance)
                for channel in [rgb.red, rgb.green, rgb.blue] {
                    XCTAssertTrue((0.0...1.0).contains(channel))
                }
            }
            let main = NativeMotionPalette.color(.primaryText, appearance: appearance)
            let secondary = NativeMotionPalette.color(.secondaryText, appearance: appearance)
            for surface: NativeMotionColorRole in [.background, .surface, .elevatedSurface] {
                let background = NativeMotionPalette.color(surface, appearance: appearance)
                XCTAssertGreaterThanOrEqual(main.contrastRatio(against: background), 4.5)
                XCTAssertGreaterThanOrEqual(secondary.contrastRatio(against: background), 4.5)
            }
            let accentText = NativeMotionPalette.color(.accentText, appearance: appearance)
            let accent = NativeMotionPalette.color(.accent, appearance: appearance)
            XCTAssertGreaterThanOrEqual(accentText.contrastRatio(against: accent), 4.5)
        }
    }

    func testContrastReference() {
        let white = NativeMotionRGB(hex: 0xFFFFFF)
        let black = NativeMotionRGB(hex: 0x000000)
        XCTAssertEqual(white.contrastRatio(against: black), 21, accuracy: 0.001)
        XCTAssertEqual(white.contrastRatio(against: white), 1, accuracy: 0.001)
    }
}
