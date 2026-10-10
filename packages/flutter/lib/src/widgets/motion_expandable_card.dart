import 'package:flutter/material.dart';

import '../theme/motion_accessibility.dart';
import '../theme/motion_palette.dart';
import '../theme/motion_tokens.dart';

/// Native host-controlled disclosure surface.
///
/// The expansion state belongs to the host. Child content is *not* inside the
/// header button, so nested buttons and inputs preserve their own semantics.
class MotionExpandableCard extends StatefulWidget {
  const MotionExpandableCard({
    required this.title,
    required this.expanded,
    required this.onChanged,
    required this.child,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool expanded;
  final ValueChanged<bool>? onChanged;
  final Widget child;

  @override
  State<MotionExpandableCard> createState() => _MotionExpandableCardState();
}

class _MotionExpandableCardState extends State<MotionExpandableCard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAccessibilityFeatures() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MotionAccessibility.reduceMotion(context);
    final Duration duration = MotionTiming.duration(
      MotionPreset.gentle,
      reduceMotion: reduceMotion,
    );
    final Color primary = MotionPalette.of(context, MotionColorRole.primaryText);
    final Color secondary = MotionPalette.of(context, MotionColorRole.secondaryText);
    final Color border = MotionPalette.of(context, MotionColorRole.border);
    final Color surface = MotionPalette.of(context, MotionColorRole.surface);
    final bool enabled = widget.onChanged != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(MotionRadius.card),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MotionRadius.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              key: const ValueKey<String>('motion-card-header'),
              button: true,
              enabled: enabled,
              label: widget.title,
              value: widget.expanded ? 'Expanded' : 'Collapsed',
              hint: widget.expanded ? 'Collapse details' : 'Expand details',
              onTap: enabled ? () => widget.onChanged!(!widget.expanded) : null,
              child: ExcludeSemantics(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: enabled ? () => widget.onChanged!(!widget.expanded) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(MotionSpacing.large),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: primary, fontWeight: FontWeight.w600),
                                ),
                                if (widget.subtitle != null) ...<Widget>[
                                  const SizedBox(height: MotionSpacing.xSmall),
                                  Text(widget.subtitle!,
                                       style: Theme.of(context).textTheme.bodySmall
                                           ?.copyWith(color: secondary)),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: MotionSpacing.medium),
                          AnimatedRotation(
                            duration: duration,
                            turns: widget.expanded ? 0.5 : 0,
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
              alignment: Alignment.topCenter,
              curve: MotionTiming.curve(MotionPreset.gentle),
              duration: duration,
              child: widget.expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Divider(height: 1, thickness: 1, color: border),
                        Padding(
                          padding: const EdgeInsets.all(MotionSpacing.large),
                          child: widget.child,
                        ),
                      ],
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}
