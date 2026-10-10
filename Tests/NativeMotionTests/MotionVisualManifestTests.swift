import Foundation
import XCTest
@testable import NativeMotion

final class MotionVisualManifestTests: XCTestCase {
    private func assertGolden(_ appearance: NativeMotionAppearance, file: String,
                              filePath: StaticString = #filePath, line: UInt = #line) throws {
        let reference = try XCTUnwrap(Bundle.module.url(forResource: file, withExtension: "txt",
                                                     subdirectory: "Snapshots"),
                                      file: filePath, line: line)
        let expected = try String(contentsOf: reference, encoding: .utf8)
        XCTAssertEqual(MotionVisualManifest.snapshot(appearance: appearance), expected,
                       "A visual token changed. Review the manifest and update its golden explicitly.",
                       file: filePath, line: line)
    }

    func testLightTokenGolden() throws {
        try assertGolden(.light, file: "tokens-light")
    }

    func testDarkTokenGolden() throws {
        try assertGolden(.dark, file: "tokens-dark")
    }

    func testCatalogQualityContract() {
        XCTAssertEqual(MotionQualityContract.expectedScenarios.count, 4)
        XCTAssertEqual(Set(MotionQualityContract.componentNames).count, 5)
    }
}
