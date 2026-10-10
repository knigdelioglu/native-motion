import 'package:flutter/material.dart';

import '../theme/motion_accessibility.dart';
import '../theme/motion_palette.dart';
import '../theme/motion_tokens.dart';

enum MotionStatus { neutral, processing, success, warning, failure }

extension MotionStatusPresentation on MotionStatus {
  String get defaultLabel => switch (this) {
        MotionStatus.neutral => 'Idle',
        MotionStatus.processing => 'In progress',
        MotionStatus.success => 'Completed',
        MotionStatus.warning => 'Attention',
        MotionStatus.failure => 'Failed',
      };

  MotionColorRole get role => switch (this) {
        MotionStatus.neutral || MotionStatus.processing => MotionColorRole.secondaryText,
        MotionStatus.success => MotionColorRole.success,
        MotionStatus.warning => MotionColorRole.warning,
        MotionStatus.failure => MotionColorRole.danger,
      };

  IconData get icon => switch (this) {
        MotionStatus.neutral => Icons.circle_outlined,
        MotionStatus.processing => Icons.schedule,
        MotionStatus.success => Icons.check_circle,
        MotionStatus.warning => Icons.warning_amber_rounded,
        MotionStatus.failure => Icons.cancel,
      };
}

/// Passive feedback; status is always supplied by the host application.
/// Colors alone never communicate a state.
class MotionStatusIndicator extends StatefulWidget {
  const MotionStatusIndicator({
    required this.label,
    required this.status,
    this.detail,
    this.statusLabel,
    super.key,
  });

  final String label;
  final String? detail;
  final String? statusLabel;
  final MotionStatus status;

  @override
  State<MotionStatusIndicator> createState() => _MotionStatusIndicatorState();
}

class _MotionStatusIndicatorState extends State<MotionStatusIndicator>
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
    final bool reduced = MotionAccessibility.reduceMotion(context);
    final MotionStatus status = widget.status;
    final String statusText = widget.statusLabel ?? status.defaultLabel;
    final Color color = MotionPalette.of(context, status.role);
    final Color text = MotionPalette.of(context, MotionColorRole.primaryText);
    final Color muted = MotionPalette.of(context, MotionColorRole.secondaryText);

    final Widget symbol = status == MotionStatus.processing && !reduced
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        : Icon(status.icon, size: 20, color: color);

    return Semantics(
      container: true,
      liveRegion: true,
      label: <String>[
        widget.label,
        statusText,
        if (widget.detail != null) widget.detail!,
      ].join(', '),
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(MotionSpacing.medium),
          decoration: BoxDecoration(
            color: MotionPalette.of(context, MotionColorRole.surface),
            borderRadius: BorderRadius.circular(MotionRadius.control),
            border: Border.all(
              color: MotionPalette.of(context, MotionColorRole.border),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(width: 22, child: Center(child: symbol)),
              const SizedBox(width: MotionSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(widget.label,
                         style: Theme.of(context).textTheme.labelLarge?.copyWith(
                           color: text, fontWeight: FontWeight.w600)),
                    if (widget.detail != null)
                      Text(widget.detail!,
                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
                             color: muted)),
                  ],
                ),
              ),
              const SizedBox(width: MotionSpacing.small),
              Text(
                statusText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
