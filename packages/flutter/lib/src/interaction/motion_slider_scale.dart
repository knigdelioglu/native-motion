/// Deterministic, platform-independent numeric scale mirroring the SwiftUI
/// MotionSliderScale contract. The final, shorter interval is selectable.
class MotionSliderScale {
  MotionSliderScale({
    double minimum = 0,
    double maximum = 100,
    double step = 1,
  })  : minimum = minimum.isFinite ? minimum : 0,
        maximum = _upper(minimum.isFinite ? minimum : 0, maximum),
        step = step.isFinite && step > 0 ? step : 1;

  final double minimum;
  final double maximum;
  final double step;

  static double _upper(double lower, double upper) {
    if (!upper.isFinite || upper <= lower) return lower + 1;
    return upper;
  }

  double clamp(double value) =>
      value.isFinite ? value.clamp(minimum, maximum).toDouble() : minimum;

  double snap(double value) {
    final double bounded = clamp(value);
    final double index = ((bounded - minimum) / step).floorToDouble();
    final double lower = clamp(minimum + index * step);
    final double upper = clamp(lower + step);
    return bounded - lower <= upper - bounded ? lower : upper;
  }

  double progress(double value) => (clamp(value) - minimum) / (maximum - minimum);

  double valueAt(double fraction) {
    if (!fraction.isFinite) return minimum;
    return snap(minimum + fraction.clamp(0, 1) * (maximum - minimum));
  }

  double adjacent(double value, int direction) {
    if (direction != 1 && direction != -1) return snap(value);
    final double current = snap(value);
    if (direction == -1 && current == maximum) {
      final double prior = clamp(
        minimum + ((maximum - minimum) / step).floorToDouble() * step,
      );
      if (prior < maximum) return prior;
    }
    return snap(current + direction * step);
  }

  /// Logical progress 0 is physically right in RTL.
  static double visualProgress(double logical, {required bool rtl}) =>
      rtl ? 1 - logical : logical;

  static double logicalProgress(double visual, {required bool rtl}) =>
      rtl ? 1 - visual : visual;

  /// Resistant, bounded overdrag displacement in physical pixels.
  static double resistance(double overshootPixels, {required bool reducedMotion}) {
    if (reducedMotion || overshootPixels == 0) return 0;
    final double distance = overshootPixels.abs();
    final double displacement = 16 * (1 - 1 / (1 + distance / 26));
    return overshootPixels.isNegative ? -displacement : displacement;
  }

  /// Display doesn't convey more precision than two decimal digits.
  static String label(double value) {
    final String decimal = value.toStringAsFixed(2);
    return decimal.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
