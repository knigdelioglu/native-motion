/// Behavior names are cross-platform; numerical spring values belong to renderers.
public enum NativeMotionPreset: String, CaseIterable, Sendable {
    case responsive, gentle, morph, settle
}

public struct NativeMotionSpring: Equatable, Sendable {
    public let response: Double
    public let dampingFraction: Double
    public init(response: Double, dampingFraction: Double) {
        self.response = response
        self.dampingFraction = dampingFraction
    }
}

/// SwiftUI calibration targets, not universal physical constants.
public enum NativeMotionTiming {
    public static let instant: Double = 0.12
    public static let quick: Double = 0.18
    public static let standard: Double = 0.26

    public static func spring(for preset: NativeMotionPreset) -> NativeMotionSpring {
        switch preset {
        case .responsive: return .init(response: 0.28, dampingFraction: 0.83)
        case .gentle: return .init(response: 0.46, dampingFraction: 0.90)
        case .morph: return .init(response: 0.42, dampingFraction: 0.78)
        case .settle: return .init(response: 0.50, dampingFraction: 0.72)
        }
    }
}
