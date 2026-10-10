import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_motion/native_motion.dart';

Widget host({
  required double value,
  required ValueChanged<double>? onChanged,
  MotionSliderScale? scale,
  bool rtl = false,
  bool reduceMotion = false,
  bool enabled = true,
  ValueChanged<bool>? onEditingChanged,
  ValueChanged<double>? onCommit,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Center(
            child: SizedBox(
              width: 320,
              child: MotionElasticSlider(
                label: 'Level',
                value: value,
                scale: scale,
                enabled: enabled,
                marks: const <double>[0, 25, 50, 75, 100, 25, double.nan],
                onChanged: onChanged,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('tap proposes value and commits without mutating host',
      (WidgetTester tester) async {
    double? proposed;
    double? committed;
    await tester.pumpWidget(host(
      value: 50,
      onChanged: (double next) { proposed = next; },
      onCommit: (double next) { committed = next; },
    ));
    final Finder thumb = find.byKey(const ValueKey<String>('motion-slider-thumb'));
    final Rect bounds = tester.getRect(find.byType(MotionElasticSlider));
    await tester.tapAt(Offset(bounds.left + 290, bounds.bottom - 24));
    await tester.pump();
    expect(proposed, greaterThan(90));
    expect(committed, proposed);
    expect(tester.widget<MotionElasticSlider>(
      find.byType(MotionElasticSlider),
    ).value, 50);
    expect(thumb, findsOneWidget);
  });

  testWidgets('horizontal drag emits a single begin/end pair and commit',
      (WidgetTester tester) async {
    final List<bool> editing = <bool>[];
    final List<double> proposals = <double>[];
    final List<double> commits = <double>[];
    final ValueNotifier<double> value = ValueNotifier<double>(20);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder<double>(
          valueListenable: value,
          builder: (BuildContext context, double current, Widget? child) =>
              SizedBox(
                width: 320,
                child: MotionElasticSlider(
                  label: 'Level',
                  value: current,
                  onChanged: (double next) {
                    proposals.add(next);
                    value.value = next;
                  },
                  onEditingChanged: editing.add,
                  onCommit: commits.add,
                ),
              ),
        ),
      ),
    ));
    final Finder slider = find.byType(MotionElasticSlider);
    final Rect rect = tester.getRect(slider);
    final TestGesture gesture = await tester.startGesture(
      Offset(rect.left + 70, rect.bottom - 24),
    );
    await gesture.moveBy(const Offset(130, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(90, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(editing, <bool>[true, false]);
    expect(proposals, isNotEmpty);
    expect(commits, hasLength(1));
    expect(commits.single, value.value);
    value.dispose();
  });

  testWidgets('disabled state does not call app callbacks', (WidgetTester tester) async {
    int changes = 0;
    int commits = 0;
    await tester.pumpWidget(host(
      value: 20,
      enabled: false,
      onChanged: (_) { changes++; },
      onCommit: (_) { commits++; },
    ));
    final Rect bounds = tester.getRect(find.byType(MotionElasticSlider));
    await tester.tapAt(Offset(bounds.left + 275, bounds.bottom - 24));
    await tester.pump();
    expect(changes, 0);
    expect(commits, 0);
  });

  testWidgets('null callback is read-only', (WidgetTester tester) async {
    await tester.pumpWidget(host(value: 50, onChanged: null));
    final Semantics properties = tester.widget<Semantics>(
      find.byKey(const ValueKey<String>('motion-slider-semantics')),
    );
    expect(properties.properties.enabled, isFalse);
    expect(properties.properties.onIncrease, isNull);
    expect(properties.properties.onDecrease, isNull);
  });

  testWidgets('keyboard increments and honors RTL physical direction',
      (WidgetTester tester) async {
    final ValueNotifier<double> value = ValueNotifier<double>(40);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ValueListenableBuilder<double>(
            valueListenable: value,
            builder: (BuildContext context, double current, Widget? child) =>
                SizedBox(
                  width: 320,
                  child: MotionElasticSlider(
                    label: 'Level',
                    value: current,
                    scale: MotionSliderScale(step: 10),
                    onChanged: (double next) { value.value = next; },
                  ),
                ),
          ),
        ),
      ),
    ));
    final Rect bounds = tester.getRect(find.byType(MotionElasticSlider));
    await tester.tapAt(Offset(bounds.left + 150, bounds.bottom - 24));
    await tester.pump();
    final double before = value.value;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(value.value, lessThan(before));
    value.dispose();
  });

  testWidgets('reduce motion prevents stretch and spring duration',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(
      value: 40, onChanged: (_) {}, reduceMotion: true,
    ));
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
      Duration.zero,
    );
    expect(
      tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned)).duration,
      Duration.zero,
    );
  });

  testWidgets('semantics include bounded adjustable numeric values',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(
      value: 95,
      scale: MotionSliderScale(maximum: 95, step: 10),
      onChanged: (_) {},
    ));
    final Semantics semantics = tester.widget<Semantics>(
      find.byKey(const ValueKey<String>('motion-slider-semantics')),
    );
    expect(semantics.properties.label, 'Level');
    expect(semantics.properties.value, '95');
    expect(semantics.properties.decreasedValue, '90');
    expect(semantics.properties.onDecrease, isNotNull);
  });

  testWidgets('marks are filtered and duplicated marks removed',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(value: 40, onChanged: (_) {}));
    expect(find.byKey(const ValueKey<String>('motion-slider-mark-25.0')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('motion-slider-mark-100.0')), findsOneWidget);
  });
}
