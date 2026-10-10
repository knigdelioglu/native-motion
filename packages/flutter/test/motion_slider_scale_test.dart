import 'package:flutter_test/flutter_test.dart';
import 'package:native_motion/native_motion.dart';

void main() {
  test('snaps, clamps and translates fractional progress', () {
    final MotionSliderScale scale = MotionSliderScale(
      minimum: 20, maximum: 80, step: 5,
    );
    expect(scale.snap(22.4), 20);
    expect(scale.snap(22.6), 25);
    expect(scale.snap(-99), 20);
    expect(scale.snap(400), 80);
    expect(scale.valueAt(0.5), 50);
    expect(scale.progress(50), 0.5);
  });

  test('short final interval is reachable from both directions', () {
    final MotionSliderScale scale = MotionSliderScale(
      minimum: 0, maximum: 95, step: 10,
    );
    expect(scale.snap(93), 95);
    expect(scale.adjacent(90, 1), 95);
    expect(scale.adjacent(95, -1), 90);
    expect(scale.adjacent(0, -1), 0);
    expect(scale.adjacent(95, 1), 95);
  });

  test('non-zero origin, fractional steps and value text', () {
    final MotionSliderScale scale = MotionSliderScale(
      minimum: 1.5, maximum: 3.5, step: 0.25,
    );
    expect(scale.snap(2.12), closeTo(2, 1e-10));
    expect(scale.snap(2.14), closeTo(2.25, 1e-10));
    expect(MotionSliderScale.label(2.50), '2.5');
    expect(MotionSliderScale.label(3), '3');
    expect(MotionSliderScale.label(2.25), '2.25');
  });

  test('invalid configuration and non-finite input do not escape bounds', () {
    final MotionSliderScale scale = MotionSliderScale(
      minimum: double.nan, maximum: double.infinity, step: -5,
    );
    expect(scale.minimum, 0);
    expect(scale.maximum, 1);
    expect(scale.step, 1);
    expect(scale.snap(double.nan), 0);
    expect(scale.snap(double.infinity), 0);
    expect(scale.valueAt(double.nan), 0);
  });

  test('four thousand deterministic slider round trips remain stable', () {
    for (final MotionSliderScale scale in <MotionSliderScale>[
      MotionSliderScale(),
      MotionSliderScale(minimum: -10, maximum: 5, step: 0.25),
      MotionSliderScale(minimum: 20, maximum: 99, step: 10),
      MotionSliderScale(minimum: 0, maximum: 1, step: 0.01),
    ]) {
      for (int i = 0; i <= 1000; i++) {
        final double value =
            scale.minimum + (scale.maximum - scale.minimum) * i / 1000;
        final double snapped = scale.snap(value);
        expect(snapped, greaterThanOrEqualTo(scale.minimum));
        expect(snapped, lessThanOrEqualTo(scale.maximum));
        expect(scale.snap(snapped), closeTo(snapped, 1e-9));
        expect(scale.valueAt(scale.progress(snapped)), closeTo(snapped, 1e-9));
      }
    }
  });

  test('RTL inverts visual mapping exactly once', () {
    for (int i = 0; i <= 100; i++) {
      final double logical = i / 100;
      final double visual = MotionSliderScale.visualProgress(logical, rtl: true);
      expect(visual, closeTo(1 - logical, 1e-12));
      expect(
        MotionSliderScale.logicalProgress(visual, rtl: true),
        closeTo(logical, 1e-12),
      );
    }
    expect(
      MotionSliderScale.visualProgress(0.25, rtl: false), 0.25,
    );
  });

  test('edge stretch is bounded and absent when motion is reduced', () {
    expect(
      MotionSliderScale.resistance(-100000, reducedMotion: false),
      greaterThan(-16),
    );
    expect(
      MotionSliderScale.resistance(100000, reducedMotion: false),
      lessThan(16),
    );
    expect(
      MotionSliderScale.resistance(1000, reducedMotion: true), 0,
    );
  });
}
