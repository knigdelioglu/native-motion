import XCTest
@testable import NativeMotion

final class MotionSurfacePoliciesTests: XCTestCase {
    func testHostControlsPresentationAndBusyDismissal() {
        XCTAssertTrue(MotionSurfacePolicies.canOpen(isEnabled: true, isPresented: false))
        XCTAssertFalse(MotionSurfacePolicies.canOpen(isEnabled: false, isPresented: false))
        XCTAssertFalse(MotionSurfacePolicies.canOpen(isEnabled: true, isPresented: true))
        XCTAssertTrue(MotionSurfacePolicies.canDismiss(isPresented: true, isBusy: false))
        XCTAssertFalse(MotionSurfacePolicies.canDismiss(isPresented: true, isBusy: true))
        XCTAssertFalse(MotionSurfacePolicies.canDismiss(isPresented: false, isBusy: false))
    }

    func testGestureThresholdAndBusySafety() {
        XCTAssertFalse(MotionSurfacePolicies.shouldDismissDrag(translation: 95, isBusy: false))
        XCTAssertTrue(MotionSurfacePolicies.shouldDismissDrag(translation: 110, isBusy: false))
        XCTAssertFalse(MotionSurfacePolicies.shouldDismissDrag(translation: 400, isBusy: true))
        XCTAssertFalse(MotionSurfacePolicies.shouldDismissDrag(translation: -120, isBusy: false))
    }

    func testDetentTransitionsDoNotFabricateHostDismissal() {
        XCTAssertEqual(MotionBottomDetentPolicy.next(from: .expanded, dragDown: true), .medium)
        XCTAssertEqual(MotionBottomDetentPolicy.next(from: .medium, dragDown: true), .compact)
        XCTAssertNil(MotionBottomDetentPolicy.next(from: .compact, dragDown: true))
        XCTAssertEqual(MotionBottomDetentPolicy.next(from: .compact, dragDown: false), .medium)
        XCTAssertEqual(MotionBottomDetentPolicy.next(from: .medium, dragDown: false), .expanded)
    }
}

#if canImport(SwiftUI)
import SwiftUI

final class MotionSurfacesSwiftUIConstructionTests: XCTestCase {
    @MainActor func testDrawerAcceptsHostStateAndContent() {
        _ = MotionDrawer("Navigation", isPresented: .constant(true)) {
            Text("Main")
        } drawerContent: {
            MotionButton("Section") {}
        }.body
    }

    @MainActor func testSheetAndBottomSheetConstruct() {
        _ = MotionSheet("Preferences", isPresented: .constant(false)) {
            Text("Open")
        } content: {
            Text("Panel")
        }.body
        _ = MotionBottomSheet(
            "Options", isPresented: .constant(false),
            detent: .constant(.medium)
        ) {
            Text("Open bottom")
        } content: {
            Text("Bottom details")
        }.body
    }
}
#endif
