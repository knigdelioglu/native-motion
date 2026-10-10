import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

/// Shared intent names; Flutter motion values are tuned independently
/// of SwiftUI's spring response/damping representation.
enum MotionPreset { responsive, gentle, morph, settle }

abstract final class MotionSpacing {
  static const double xSmall = 4;
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xLarge = 24;
  static const double xxLarge = 32;
}

abstract final class MotionRadius {
  static const double control = 12;
  static const double card = 18;
  static const double panel = 24;
}

abstract final class MotionControlHeight {
  static const double small = 36;
  static const double medium = 44;
  static const double large = 52;
}

/// Durations and curves express a perceptual contract, not matching
/// spring constants between animation engines.
abstract final class MotionTiming {
  static Duration duration(MotionPreset preset, {required bool reduceMotion}) {
    if (reduceMotion) return Duration.zero;
    return switch (preset) {
      MotionPreset.responsive => const Duration(milliseconds: 180),
      MotionPreset.gentle => const Duration(milliseconds: 290),
      MotionPreset.morph => const Duration(milliseconds: 250),
      MotionPreset.settle => const Duration(milliseconds: 350),
    };
  }

  static Curve curve(MotionPreset preset) => switch (preset) {
        MotionPreset.responsive => Curves.easeOutCubic,
        MotionPreset.gentle => Curves.easeInOutCubic,
        MotionPreset.morph => Curves.easeInOutCubicEmphasized,
        MotionPreset.settle => Curves.easeOutBack,
      };
}
