import 'package:flutter/widgets.dart';

/// Flutter on Android supports remove-animations through MediaQuery.
/// iOS reports Reduced Motion separately; explicitly check both.
///
/// Widgets also subscribe to accessibility feature changes so a control
/// already on screen can drop its non-essential animation.
abstract final class MotionAccessibility {
  static bool reduceMotion(BuildContext context) {
    final bool disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final bool iosReduce =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.reduceMotion;
    return disable || iosReduce;
  }
}
