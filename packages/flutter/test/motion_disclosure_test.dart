import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_motion/native_motion.dart';

void main() {
  test('single accordion collapses older entries', () {
    final Set<String> next = MotionDisclosurePolicy.toggle(
      id: 'b', expandedIds: <String>{'a'}, enabledIds: <String>{'a', 'b'},
      allowsMultiple: false,
    );
    expect(next, <String>{'b'});
    expect(MotionDisclosurePolicy.toggle(
      id: 'b', expandedIds: next, enabledIds: <String>{'a', 'b'},
      allowsMultiple: false,
    ), isEmpty);
  });

  test('multiple accordion and disabled entries respect host values', () {
    expect(MotionDisclosurePolicy.toggle(
      id: 'b', expandedIds: <String>{'a'}, enabledIds: <String>{'a', 'b'},
      allowsMultiple: true,
    ), <String>{'a', 'b'});
    expect(MotionDisclosurePolicy.toggle(
      id: 'disabled', expandedIds: <String>{'a'},
      enabledIds: <String>{'a'}, allowsMultiple: false,
    ), <String>{'a'});
    expect(MotionDisclosurePolicy.uniqueIds(<String>['a', 'a']), isFalse);
  });

  testWidgets('host-controlled accordion keeps nested actions separate',
      (WidgetTester tester) async {
    Set<String> expanded = <String>{'general'};
    int nestedPresses = 0;
    Widget page() => MaterialApp(home: Scaffold(body: StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => MotionAccordion(
        label: 'Settings', expandedIds: expanded,
        items: const <MotionAccordionItem>[
          MotionAccordionItem(id: 'general', title: 'General'),
          MotionAccordionItem(id: 'hidden', title: 'Unavailable', enabled: false),
          MotionAccordionItem(id: 'advanced', title: 'Advanced'),
        ],
        onChanged: (Set<String> next) => setState(() => expanded = next),
        itemBuilder: (_, String id) => id == 'general'
          ? TextButton(onPressed: () => nestedPresses++, child: const Text('Nested action'))
          : Text('Content for $id'),
      ),
    )));
    await tester.pumpWidget(page());
    expect(find.text('Nested action'), findsOneWidget);
    await tester.tap(find.text('Nested action'));
    await tester.pump();
    expect(nestedPresses, 1);
    expect(expanded, <String>{'general'});
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    expect(expanded, <String>{'advanced'});
    expect(find.text('Nested action'), findsNothing);
    await tester.tap(find.text('Unavailable'));
    await tester.pumpAndSettle();
    expect(expanded, <String>{'advanced'});
  });

  testWidgets('Reduce Motion makes disclosure animation instantaneous',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: const Material(child: MotionDisclosureGroup(
        title: 'Details', expanded: true, onChanged: null,
        child: Text('Description'),
      )),
    )));
    expect(tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration,
      Duration.zero);
  });
}
