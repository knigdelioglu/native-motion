import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_motion/native_motion.dart';

const List<MotionSegment> segments = <MotionSegment>[
  MotionSegment(id: 'all', label: 'All'),
  MotionSegment(id: 'active', label: 'Active'),
  MotionSegment(id: 'hidden', label: 'Hidden', enabled: false),
  MotionSegment(id: 'archived', label: 'Archived'),
];

Widget host({
  required String selection,
  required ValueChanged<String>? onChanged,
  bool rtl = false,
  bool reduced = false,
}) => MaterialApp(
  home: Scaffold(
    body: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Center(
          child: MotionSegmentedControl(
            label: 'Results',
            segments: segments,
            selection: selection,
            onChanged: onChanged,
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('tapping a segment reports a selection without mutating host',
      (WidgetTester tester) async {
    String? requested;
    await tester.pumpWidget(host(
      selection: 'all',
      onChanged: (String id) { requested = id; },
    ));
    await tester.tap(find.text('Active'));
    await tester.pump();
    expect(requested, 'active');
    final MotionSegmentedControl control =
        tester.widget<MotionSegmentedControl>(find.byType(MotionSegmentedControl));
    expect(control.selection, 'all', reason: 'The host Binding owns state.');
  });

  testWidgets('disabled option does not emit selection',
      (WidgetTester tester) async {
    int requests = 0;
    await tester.pumpWidget(host(
      selection: 'all',
      onChanged: (_) { requests++; },
    ));
    await tester.tap(find.text('Hidden'), warnIfMissed: false);
    await tester.pump();
    expect(requests, 0);
  });

  testWidgets('read-only selection cannot be activated',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(selection: 'active', onChanged: null));
    final InkWell ink = tester.widgetList<InkWell>(find.byType(InkWell)).first;
    expect(ink.onTap, isNull);
  });

  testWidgets('external selection changes update displayed selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(selection: 'all', onChanged: (_) {}));
    final SemanticsHandle semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byKey(const ValueKey<String>('motion-segment-all')))
          .hasFlag(SemanticsFlag.isSelected),
      isTrue,
    );
    await tester.pumpWidget(host(selection: 'active', onChanged: (_) {}));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.getSemantics(find.byKey(const ValueKey<String>('motion-segment-active')))
          .hasFlag(SemanticsFlag.isSelected),
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('keyboard advances past disabled option without wrapping',
      (WidgetTester tester) async {
    final ValueNotifier<String> chosen = ValueNotifier<String>('active');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder<String>(
          valueListenable: chosen,
          builder: (BuildContext context, String value, Widget? child) =>
              MotionSegmentedControl(
                label: 'Results',
                segments: segments,
                selection: value,
                onChanged: (String next) { chosen.value = next; },
              ),
        ),
      ),
    ));
    await tester.tap(find.text('Active'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(chosen.value, 'archived');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(chosen.value, 'archived', reason: 'No wrap at the last enabled item.');
    chosen.dispose();
  });

  testWidgets('RTL physical right key moves toward preceding item',
      (WidgetTester tester) async {
    final ValueNotifier<String> chosen = ValueNotifier<String>('active');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ValueListenableBuilder<String>(
            valueListenable: chosen,
            builder: (BuildContext context, String value, Widget? child) =>
                MotionSegmentedControl(
                  label: 'Results',
                  segments: segments,
                  selection: value,
                  onChanged: (String next) { chosen.value = next; },
                ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Active'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(chosen.value, 'all');
    chosen.dispose();
  });

  testWidgets('reduced motion drops segment animation duration',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(
      selection: 'all',
      onChanged: (_) {},
      reduced: true,
    ));
    for (final AnimatedContainer container
        in tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer))) {
      expect(container.duration, Duration.zero);
    }
  });

  testWidgets('many segments scroll instead of overflowing',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 220,
          child: MotionSegmentedControl(
            label: 'Sections',
            selection: 's0',
            onChanged: (_) {},
            segments: <MotionSegment>[
              for (int i = 0; i < 15; i++)
                MotionSegment(id: 's$i', label: 'Section $i'),
            ],
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
