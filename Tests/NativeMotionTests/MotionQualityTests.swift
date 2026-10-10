import XCTest
@testable import NativeMotion

final class MotionQualityTests: XCTestCase {
    func testSliderInvariantsAcrossThousandsOfValues() {
        let scales = [
            MotionSliderScale(),
            MotionSliderScale(minimum: -10, maximum: 5, step: 0.25),
            MotionSliderScale(minimum: 20, maximum: 99, step: 10),
            MotionSliderScale(minimum: 0, maximum: 1, step: 0.01)
        ]
        for scale in scales {
            for sample in 0...1000 {
                let value = scale.minimum
                    + (scale.maximum - scale.minimum) * Double(sample) / 1000
                let snap = scale.snapped(value)
                XCTAssertTrue(snap.isFinite)
                XCTAssertGreaterThanOrEqual(snap, scale.minimum)
                XCTAssertLessThanOrEqual(snap, scale.maximum)
                XCTAssertEqual(scale.snapped(snap), snap, accuracy: 0.000000001)
                let progress = scale.progress(for: snap)
                XCTAssertGreaterThanOrEqual(progress, 0)
                XCTAssertLessThanOrEqual(progress, 1)
                XCTAssertEqual(scale.value(atProgress: progress), snap,
                               accuracy: 0.000000001)
            }
        }
    }

    func testEveryMotionPresetIsPhysicalAndDistinct() {
        let springs = NativeMotionPreset.allCases.map(NativeMotionTiming.spring)
        XCTAssertEqual(Set(springs.map { $0.response }).count, springs.count)
        for spring in springs {
            XCTAssertTrue(spring.response.isFinite)
            XCTAssertGreaterThan(spring.response, 0)
            XCTAssertGreaterThan(spring.dampingFraction, 0)
            XCTAssertLessThanOrEqual(spring.dampingFraction, 1)
        }
    }

    func testAllSemanticStatesHaveReadableContrast() {
        for appearance in NativeMotionAppearance.allCases {
            let surface = NativeMotionPalette.color(.surface, appearance: appearance)
            for role: NativeMotionColorRole in [.success, .warning, .danger] {
                XCTAssertGreaterThanOrEqual(
                    NativeMotionPalette.color(role, appearance: appearance)
                        .contrastRatio(against: surface), 3.0
                )
            }
        }
    }
}
