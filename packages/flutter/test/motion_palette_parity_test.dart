import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_motion/native_motion.dart';

const Map<String, MotionColorRole> roles = <String, MotionColorRole>{
  'background': MotionColorRole.background,
  'surface': MotionColorRole.surface,
  'elevatedSurface': MotionColorRole.elevatedSurface,
  'primaryText': MotionColorRole.primaryText,
  'secondaryText': MotionColorRole.secondaryText,
  'accent': MotionColorRole.accent,
  'accentText': MotionColorRole.accentText,
  'border': MotionColorRole.border,
  'success': MotionColorRole.success,
  'warning': MotionColorRole.warning,
  'danger': MotionColorRole.danger,
};

void main() {
  for (final Brightness brightness in Brightness.values) {
    test('Flutter semantic colors match approved Swift goldens: $brightness', () {
      // Relative to the package root when run from packages/flutter/.
      final String theme = brightness == Brightness.light ? 'light' : 'dark';
      final File fixture = File(
        '../../Tests/NativeMotionTests/Snapshots/tokens-$theme.txt',
      );
      expect(fixture.existsSync(), isTrue,
          reason: 'This test intentionally verifies the monorepo token contract.');
      final Map<String, String> recorded = <String, String>{};
      for (final String line in fixture.readAsLinesSync()) {
        if (!line.contains('=') || !line.startsWith(RegExp(r'[a-zA-Z]'))) continue;
        final List<String> parts = line.split('=');
        if (parts.length == 2) recorded[parts[0]] = parts[1];
      }
      expect(recorded.keys.where(roles.containsKey).length, roles.length);
      for (final MapEntry<String, MotionColorRole> entry in roles.entries) {
        final int rgb = MotionPalette.color(entry.value, brightness).toARGB32()
            & 0x00FFFFFF;
        final String actual = '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
        expect(actual, recorded[entry.key], reason: 'Mismatch for $theme ${entry.key}');
      }
    });
  }

  test('cross-platform spacing and corner tokens stay canonical', () {
    expect(MotionSpacing.xSmall, 4);
    expect(MotionSpacing.small, 8);
    expect(MotionSpacing.medium, 12);
    expect(MotionSpacing.large, 16);
    expect(MotionSpacing.xLarge, 24);
    expect(MotionSpacing.xxLarge, 32);
    expect(MotionRadius.control, 12);
    expect(MotionRadius.card, 18);
    expect(MotionRadius.panel, 24);
    expect(MotionControlHeight.medium, 44);
  });

  test('motion presets are distinct and can be suppressed', () {
    final Set<Duration> durations = <Duration>{};
    for (final MotionPreset preset in MotionPreset.values) {
      final Duration active =
          MotionTiming.duration(preset, reduceMotion: false);
      expect(active, greaterThan(Duration.zero));
      expect(durations.add(active), isTrue);
      expect(MotionTiming.duration(preset, reduceMotion: true), Duration.zero);
    }
  });
}
