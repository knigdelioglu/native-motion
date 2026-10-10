import 'package:flutter/material.dart';

import '../interaction/motion_disclosure_policy.dart';
import '../theme/motion_palette.dart';
import '../theme/motion_tokens.dart';
import 'motion_disclosure_group.dart';

@immutable
class MotionAccordionItem {
  const MotionAccordionItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.enabled = true,
  });
  final String id;
  final String title;
  final String? subtitle;
  final bool enabled;
}

/// Externally controlled accordion: single or multi, disabled entries and
/// independent nested content. Does not invent initial expansion.
class MotionAccordion extends StatelessWidget {
  MotionAccordion({
    required this.label,
    required this.items,
    required this.expandedIds,
    required this.onChanged,
    required this.itemBuilder,
    this.allowsMultiple = false,
    this.enabled = true,
    super.key,
  }) : assert(MotionDisclosurePolicy.uniqueIds(
          items.map((MotionAccordionItem item) => item.id),
        ), 'MotionAccordionItem IDs must be unique');

  final String label;
  final List<MotionAccordionItem> items;
  final Set<String> expandedIds;
  final ValueChanged<Set<String>>? onChanged;
  final Widget Function(BuildContext context, String id) itemBuilder;
  final bool allowsMultiple;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Set<String> enabledIds = items
        .where((MotionAccordionItem item) => item.enabled)
        .map((MotionAccordionItem item) => item.id).toSet();
    final Color primary = MotionPalette.of(context, MotionColorRole.primaryText);
    return Semantics(
      container: true, explicitChildNodes: true, label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: MotionSpacing.medium),
          for (final MotionAccordionItem item in items) ...<Widget>[
            MotionDisclosureGroup(
              key: ValueKey<String>('motion-accordion-${item.id}'),
              title: item.title, subtitle: item.subtitle,
              expanded: expandedIds.contains(item.id),
              enabled: enabled && item.enabled,
              onChanged: onChanged == null ? null : (_) {
                onChanged!(MotionDisclosurePolicy.toggle(
                  id: item.id,
                  expandedIds: expandedIds,
                  enabledIds: enabledIds,
                  allowsMultiple: allowsMultiple,
                  controlEnabled: enabled,
                ));
              },
              child: itemBuilder(context, item.id),
            ),
            const SizedBox(height: MotionSpacing.small),
          ],
        ],
      ),
    );
  }
}
