import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_motion/native_motion.dart';

Widget host({
  required bool expanded,
  required ValueChanged<bool>? onChanged,
  bool reduced = false,
}) => MaterialApp(
  home: Scaffold(
    body: MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: Center(
        child: MotionExpandableCard(
          title: 'Details',
          subtitle: 'Tap to show',
          expanded: expanded,
          onChanged: onChanged,
          child: const Text('Nested information'),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('collapsed content is absent, and host owns state',
      (WidgetTester tester) async {
    bool? requested;
    await tester.pumpWidget(host(
      expanded: false,
      onChanged: (bool next) { requested = next; },
    ));
    expect(find.text('Nested information'), findsNothing);
    await tester.tap(find.text('Details'));
    await tester.pump();
    expect(requested, isTrue);
    expect(find.text('Nested information'), findsNothing,
        reason: 'A callback alone must not rewrite host state.');
    await tester.pumpWidget(host(expanded: true, onChanged: (_) {}));
    await tester.pumpAndSettle();
    expect(find.text('Nested information'), findsOneWidget);
  });

  testWidgets('nested action remains independently clickable',
      (WidgetTester tester) async {
    int presses = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MotionExpandableCard(
          title: 'Tools',
          expanded: true,
          onChanged: (_) {},
          child: MotionButton(
            label: 'Nested action',
            onPressed: () { presses++; },
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Nested action'));
    await tester.pump();
    expect(presses, 1);
  });

  testWidgets('read-only card does not toggle',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(expanded: false, onChanged: null));
    final InkWell ink = tester.widget<InkWell>(find.byType(InkWell));
    expect(ink.onTap, isNull);
  });

  testWidgets('reduced motion disables size and rotation animations',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(
      expanded: true,
      onChanged: (_) {},
      reduced: true,
    ));
    expect(tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration,
        Duration.zero);
    expect(tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).duration,
        Duration.zero);
  });

  testWidgets('header exposes a separate accessible disclosure control',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(expanded: false, onChanged: (_) {}));
    final Semantics header = tester.widget<Semantics>(
      find.byKey(const ValueKey<String>('motion-card-header')),
    );
    expect(header.properties.button, isTrue);
    expect(header.properties.label, 'Details');
    expect(header.properties.value, 'Collapsed');
  });

  testWidgets('large text and RTL do not overflow a narrow surface',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.7)),
            child: SizedBox(
              width: 320,
              child: MotionExpandableCard(
                title: 'Extended disclosure description',
                subtitle: 'Supporting secondary heading',
                expanded: true,
                onChanged: (_) {},
                child: const Text('Content'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
