#if canImport(SwiftUI)
import SwiftUI

/// A preview-only request to reduce animation. Unlike the system preference,
/// this value is writeable so automated visual audits and interactive catalogs
/// can exercise the reduced-motion appearance.
private struct NativeMotionPreviewReduceMotionKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    var nativeMotionPreviewReduceMotion: Bool {
        get { self[NativeMotionPreviewReduceMotionKey.self] }
        set { self[NativeMotionPreviewReduceMotionKey.self] = newValue }
    }
}

public extension View {
    /// Preview / QA convenience. Can request less animation but cannot turn
    /// system Reduce Motion OFF; native controls combine both with logical OR.
    func nativeMotionPreviewReduceMotion(_ active: Bool) -> some View {
        environment(\.nativeMotionPreviewReduceMotion, active)
    }
}
#endif
