/// Deterministic value and placeholder normalization. These pure policies
/// are compiled and tested on macOS and Linux independently of SwiftUI.
public enum MotionProgressPolicy {
    /// A nil value is indeterminate. Non-finite values are treated as
    /// indeterminate, never displayed as zero or as successful completion.
    public static func normalized(_ value: Double?) -> Double? {
        guard let value, value.isFinite else { return nil }
        return min(1, max(0, value))
    }

    public static func percent(_ value: Double?) -> Int? {
        guard let fraction = normalized(value) else { return nil }
        return Int((fraction * 100).rounded())
    }
}

public enum MotionSkeletonPolicy {
    /// Prevent zero or unbounded placeholder rows from breaking layout.
    public static func visibleRows(_ requested: Int) -> Int {
        min(8, max(1, requested))
    }
}
