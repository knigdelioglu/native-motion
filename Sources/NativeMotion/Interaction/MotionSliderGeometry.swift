/// Normalizes physical track x-coordinates independently from localized
/// text layout, preventing a second automatic SwiftUI RTL transformation.
public enum MotionSliderGeometry {
    public static func visualProgress(fromLogical logical: Double, rightToLeft: Bool) -> Double {
        rightToLeft ? 1 - logical : logical
    }

    public static func logicalProgress(fromVisual visual: Double, rightToLeft: Bool) -> Double {
        rightToLeft ? 1 - visual : visual
    }
}
