import 'package:flutter/material.dart';

/// Roles correspond to SwiftUI's semantic palette contract.
enum MotionColorRole {
  background,
  surface,
  elevatedSurface,
  primaryText,
  secondaryText,
  accent,
  accentText,
  border,
  success,
  warning,
  danger,
}

/// Original Flutter palette using shared semantic roles.
/// The repository's token parity tests compare these values with SwiftUI.
abstract final class MotionPalette {
  static Color color(MotionColorRole role, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return switch (role) {
        MotionColorRole.background => const Color(0xFF141922),
        MotionColorRole.surface => const Color(0xFF1D2531),
        MotionColorRole.elevatedSurface => const Color(0xFF293241),
        MotionColorRole.primaryText => const Color(0xFFF5F7FB),
        MotionColorRole.secondaryText => const Color(0xFFB5C0D0),
        MotionColorRole.accent => const Color(0xFF91B4FF),
        MotionColorRole.accentText => const Color(0xFF101925),
        MotionColorRole.border => const Color(0xFF445064),
        MotionColorRole.success => const Color(0xFF74DFA7),
        MotionColorRole.warning => const Color(0xFFFFCB70),
        MotionColorRole.danger => const Color(0xFFFF9198),
      };
    }
    return switch (role) {
      MotionColorRole.background => const Color(0xFFF7F8FA),
      MotionColorRole.surface => const Color(0xFFFFFFFF),
      MotionColorRole.elevatedSurface => const Color(0xFFFFFFFF),
      MotionColorRole.primaryText => const Color(0xFF171A21),
      MotionColorRole.secondaryText => const Color(0xFF526074),
      MotionColorRole.accent => const Color(0xFF245DCC),
      MotionColorRole.accentText => const Color(0xFFFFFFFF),
      MotionColorRole.border => const Color(0xFFD5DDE8),
      MotionColorRole.success => const Color(0xFF187448),
      MotionColorRole.warning => const Color(0xFF875000),
      MotionColorRole.danger => const Color(0xFFB62D39),
    };
  }

  static Color of(BuildContext context, MotionColorRole role) =>
      color(role, Theme.of(context).brightness);
}
