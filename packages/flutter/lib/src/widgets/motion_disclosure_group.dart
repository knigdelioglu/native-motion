import 'package:flutter/material.dart';

import '../theme/motion_accessibility.dart';
import '../theme/motion_palette.dart';
import '../theme/motion_tokens.dart';

/// Native host-controlled disclosure. Child controls are outside the
/// header's InkWell and keep their own interaction/semantics.
class MotionDisclosureGroup extends StatelessWidget {
  const MotionDisclosureGroup({
    required this.title,
    required this.expanded,
    required this.onChanged,
    required this.child,
    this.subtitle,
    this.enabled = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool expanded;
  final ValueChanged<bool>? onChanged;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool active = enabled && onChanged != null;
    final bool reduced = MotionAccessibility.reduceMotion(context);
    final Duration duration = MotionTiming.duration(
      MotionPreset.gentle, reduceMotion: reduced,
    );
    final Color primary = MotionPalette.of(context, MotionColorRole.primaryText);
    final Color secondary = MotionPalette.of(context, MotionColorRole.secondaryText);
    final Color border = MotionPalette.of(context, MotionColorRole.border);
    final Color surface = MotionPalette.of(context, MotionColorRole.surface);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(MotionRadius.card),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MotionRadius.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              key: ValueKey<String>('motion-disclosure-${title.replaceAll(' ', '-')}'),
              button: true, enabled: active, label: title,
              value: expanded ? 'Expanded' : 'Collapsed',
              hint: expanded ? 'Collapse details' : 'Expand details',
              onTap: active ? () => onChanged!(!expanded) : null,
              child: ExcludeSemantics(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: active ? () => onChanged!(!expanded) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(MotionSpacing.medium),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(title, style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: primary, fontWeight: FontWeight.w600)),
                              if (subtitle != null) Text(subtitle!,
                                style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: secondary)),
                            ],
                          )),
                          AnimatedRotation(
                            turns: expanded ? .5 : 0,
                            duration: duration,
                            child: Icon(Icons.keyboard_arrow_down, color: secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: duration,
              curve: MotionTiming.curve(MotionPreset.gentle),
              alignment: Alignment.topCenter,
              child: expanded ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Divider(height: 1, color: border),
                  Padding(
                    padding: const EdgeInsets.all(MotionSpacing.medium),
                    child: child,
                  ),
                ],
              ) : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}
