import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_motion/native_motion.dart';

Widget testHost(Widget child, {bool dark = false, bool reduceMotion = false}) {
  return MaterialApp(
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(brightness: Brightness.dark),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(
      body: MediaQuery(
        data: const MediaQueryData().copyWith(disableAnimations: reduceMotion),
        child: Center(child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('button calls host action once on tap', (WidgetTester tester) async {
    int count = 0;
    await tester.pumpWidget(testHost(
      MotionButton(label: 'Save', onPressed: () { count++; }),
    ));
    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.byType(MotionButton));
    await tester.pump();
    expect(count, 1);
  });

  testWidgets('loading keeps the label visible and blocks duplicate work',
      (WidgetTester tester) async {
    int count = 0;
    await tester.pumpWidget(testHost(MotionButton(
      label: 'Save',
      phase: MotionButtonPhase.loading,
      onPressed: () { count++; },
    )));
    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(MotionButton), warnIfMissed: false);
    await tester.pump();
    expect(count, 0);
  });

  testWidgets('null callback is disabled', (WidgetTester tester) async {
    await tester.pumpWidget(testHost(
      const MotionButton(label: 'Disabled', onPressed: null),
    ));
    final InkWell ink = tester.widget<InkWell>(find.byType(InkWell));
    expect(ink.onTap, isNull);
  });

  testWidgets('reduced motion uses static progress indicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(testHost(
      const MotionButton(
        label: 'Saving',
        phase: MotionButtonPhase.loading,
        onPressed: null,
      ),
      reduceMotion: true,
    ));
    expect(find.byIcon(Icons.hourglass_bottom), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('variants and final states retain visible text in dark mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(testHost(const MotionButton(
      label: 'Done',
      variant: MotionButtonVariant.destructive,
      size: MotionButtonSize.large,
      phase: MotionButtonPhase.success,
      onPressed: null,
    ), dark: true));
    expect(find.text('Done'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('error phase never claims the host succeeded',
      (WidgetTester tester) async {
    await tester.pumpWidget(testHost(const MotionButton(
      label: 'Retry',
      phase: MotionButtonPhase.failure,
      onPressed: null,
    )));
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
