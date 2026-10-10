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

private struct NativeMotionOffscreenPreviewKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    var nativeMotionOffscreenPreview: Bool {
        get { self[NativeMotionOffscreenPreviewKey.self] }
        set { self[NativeMotionOffscreenPreviewKey.self] = newValue }
    }
}

public extension View {
    /// Capture variant for static image renderers that cannot host
    /// system scroll readers or indeterminate platform progress controls.
    /// It never affects ordinary app rendering or interaction behavior.
    func nativeMotionOffscreenPreview() -> some View {
        environment(\.nativeMotionOffscreenPreview, true)
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
