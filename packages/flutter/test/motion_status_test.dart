import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_motion/native_motion.dart';

void main() {
  for (final MotionStatus status in MotionStatus.values) {
    testWidgets('status renders visible text: $status', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MotionStatusIndicator(
            label: 'Task',
            detail: 'Host-owned',
            status: status,
          ),
        ),
      ));
      expect(find.text('Task'), findsOneWidget);
      expect(find.text('Host-owned'), findsOneWidget);
      expect(find.text(status.defaultLabel), findsOneWidget);
      if (status == MotionStatus.processing) {
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      }
    });
  }

  testWidgets('status text is overridable for localization',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MotionStatusIndicator(
          label: 'Kayıt',
          status: MotionStatus.success,
          statusLabel: 'Tamamlandı',
        ),
      ),
    ));
    expect(find.text('Tamamlandı'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
  });

  testWidgets('busy status is static when animation is suppressed',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const MotionStatusIndicator(
            label: 'Task',
            status: MotionStatus.processing,
          ),
        ),
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
  });
}
