/// A finite, bounded, discrete numeric scale for a user-adjustable slider.
///
/// This value model is independent of SwiftUI and can be tested on Linux.
/// Non-finite inputs and malformed ranges are normalized rather than allowed
/// to propagate NaN values into the renderer.
public struct MotionSliderScale: Equatable, Sendable {
    public let minimum: Double
    public let maximum: Double
    public let step: Double

    public init(minimum: Double = 0, maximum: Double = 100, step: Double = 1) {
        let lower = minimum.isFinite ? minimum : 0
        let upper = maximum.isFinite && maximum > lower ? maximum : lower + 1
        self.minimum = lower
        self.maximum = upper.isFinite ? upper : lower + 1
        self.step = step.isFinite && step > 0 ? step : 1
    }

    public func clamped(_ value: Double) -> Double {
        guard value.isFinite else { return minimum }
        return Swift.min(maximum, Swift.max(minimum, value))
    }

    /// Round to the nearest selectable position, including a short final
    /// interval when the upper bound isn't a multiple of the normal step.
    public func snapped(_ value: Double) -> Double {
        let bounded = clamped(value)
        let intervals = ((bounded - minimum) / step).rounded(.down)
        let lower = clamped(minimum + intervals * step)
        let upper = clamped(lower + step)
        return bounded - lower <= upper - bounded ? lower : upper
    }

    public func progress(for value: Double) -> Double {
        (clamped(value) - minimum) / (maximum - minimum)
    }

    public func value(atProgress progress: Double) -> Double {
        guard progress.isFinite else { return minimum }
        return snapped(minimum + Swift.min(1, Swift.max(0, progress)) * (maximum - minimum))
    }

    public func adjacentValue(from value: Double, direction: Int) -> Double {
        guard direction == -1 || direction == 1 else { return snapped(value) }
        let current = snapped(value)
        return snapped(current + (Double(direction) * step))
    }
}
