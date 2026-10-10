import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/motion_accessibility.dart';
import '../theme/motion_palette.dart';
import '../theme/motion_tokens.dart';

/// Stable identity and display text for one segment.
@immutable
class MotionSegment {
  const MotionSegment({
    required this.id,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final String id;
  final String label;
  final IconData? icon;
  final bool enabled;
}

/// Controlled native selection. The host owns [selection] and can veto
/// [onChanged]; this widget never silently changes the selected value.
///
/// Overflow uses a horizontal native scroll view, and arrow keys skip disabled
/// items without wrapping. Text direction reverses the physical key mapping.
class MotionSegmentedControl extends StatefulWidget {
  MotionSegmentedControl({
    required this.label,
    required this.segments,
    required this.selection,
    required this.onChanged,
    super.key,
  }) : assert(segments.length > 0, 'At least one segment is required.'),
       assert(
         _uniqueSegmentIds(segments),
         'MotionSegment IDs must be unique.',
       );

  final String label;
  final List<MotionSegment> segments;
  final String selection;
  final ValueChanged<String>? onChanged;

  static bool _uniqueSegmentIds(List<MotionSegment> segments) =>
      segments.map((MotionSegment item) => item.id).toSet().length ==
      segments.length;

  @override
  State<MotionSegmentedControl> createState() => _MotionSegmentedControlState();
}

class _MotionSegmentedControlState extends State<MotionSegmentedControl>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  void _select(MotionSegment segment) {
    if (!segment.enabled || widget.onChanged == null ||
        segment.id == widget.selection) {
      return;
    }
    widget.onChanged!(segment.id);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.onChanged == null) {
      return KeyEventResult.ignored;
    }
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final int step;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      step = rtl ? -1 : 1;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      step = rtl ? 1 : -1;
    } else {
      return KeyEventResult.ignored;
    }
    final int current = widget.segments.indexWhere(
      (MotionSegment item) => item.id == widget.selection,
    );
    final int start = current < 0
        ? (step > 0 ? -1 : widget.segments.length)
        : current;
    for (int i = start + step; i >= 0 && i < widget.segments.length; i += step) {
      if (widget.segments[i].enabled) {
        _select(widget.segments[i]);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MotionAccessibility.reduceMotion(context);
    final Duration duration = MotionTiming.duration(
      MotionPreset.morph,
      reduceMotion: reduceMotion,
    );
    final Color surface = MotionPalette.of(context, MotionColorRole.surface);
    final Color background = MotionPalette.of(context, MotionColorRole.background);
    final Color border = MotionPalette.of(context, MotionColorRole.border);
    final Color primary = MotionPalette.of(context, MotionColorRole.primaryText);
    final Color secondary = MotionPalette.of(context, MotionColorRole.secondaryText);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: Focus(
        skipTraversal: true,
        onKeyEvent: _handleKey,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(MotionRadius.control),
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final MotionSegment segment in widget.segments)
                    _buildSegment(
                      context: context,
                      segment: segment,
                      duration: duration,
                      surface: surface,
                      primary: primary,
                      secondary: secondary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegment({
    required BuildContext context,
    required MotionSegment segment,
    required Duration duration,
    required Color surface,
    required Color primary,
    required Color secondary,
  }) {
    final bool selected = segment.id == widget.selection;
    final bool enabled = segment.enabled && widget.onChanged != null;
    return Semantics(
      key: ValueKey<String>('motion-segment-${segment.id}'),
      button: true,
      selected: selected,
      enabled: enabled,
      label: segment.label,
      onTap: enabled ? () => _select(segment) : null,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? () => _select(segment) : null,
            borderRadius: BorderRadius.circular(9),
            child: AnimatedContainer(
              duration: duration,
              curve: MotionTiming.curve(MotionPreset.morph),
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? surface : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                boxShadow: selected
                    ? const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (segment.icon != null) ...<Widget>[
                    Icon(segment.icon, size: 18,
                         color: selected ? primary : secondary),
                    const SizedBox(width: MotionSpacing.small),
                  ],
                  Text(
                    segment.label,
                    maxLines: 1,
                    softWrap: false,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: enabled ? (selected ? primary : secondary) : secondary.withValues(alpha: 0.55),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
