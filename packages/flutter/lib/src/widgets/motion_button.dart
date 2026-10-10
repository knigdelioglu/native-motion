import 'package:flutter/material.dart';

import '../theme/motion_accessibility.dart';
import '../theme/motion_palette.dart';
import '../theme/motion_tokens.dart';

enum MotionButtonVariant { primary, secondary, ghost, destructive }
enum MotionButtonSize { small, medium, large }
enum MotionButtonPhase { idle, loading, success, failure }

/// A native Flutter button with app-owned work and declarative phase state.
///
/// Loading suppresses duplicate activation. Null [onPressed] also disables
/// the control; completion is NEVER simulated by the library.
class MotionButton extends StatefulWidget {
  const MotionButton({
    required this.label,
    required this.onPressed,
    this.variant = MotionButtonVariant.primary,
    this.size = MotionButtonSize.medium,
    this.phase = MotionButtonPhase.idle,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final MotionButtonVariant variant;
  final MotionButtonSize size;
  final MotionButtonPhase phase;

  @override
  State<MotionButton> createState() => _MotionButtonState();
}

class _MotionButtonState extends State<MotionButton> with WidgetsBindingObserver {
  bool _highlighted = false;

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
    final Duration duration =
        MotionTiming.duration(MotionPreset.responsive, reduceMotion: reduceMotion);
    final bool enabled =
        widget.onPressed != null && widget.phase != MotionButtonPhase.loading;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = switch (widget.variant) {
      MotionButtonVariant.primary => MotionPalette.of(context, MotionColorRole.accentText),
      MotionButtonVariant.secondary ||
      MotionButtonVariant.ghost => MotionPalette.of(context, MotionColorRole.primaryText),
      MotionButtonVariant.destructive => MotionPalette.of(context, MotionColorRole.danger),
    };
    final Color fill = switch (widget.variant) {
      MotionButtonVariant.primary => MotionPalette.of(context, MotionColorRole.accent),
      MotionButtonVariant.secondary ||
      MotionButtonVariant.destructive => MotionPalette.of(context, MotionColorRole.surface),
      MotionButtonVariant.ghost => Colors.transparent,
    };
    final Color borderColor = switch (widget.variant) {
      MotionButtonVariant.secondary ||
      MotionButtonVariant.destructive => MotionPalette.of(context, MotionColorRole.border),
      _ => Colors.transparent,
    };
    final double minHeight = switch (widget.size) {
      MotionButtonSize.small => 44,
      MotionButtonSize.medium => 48,
      MotionButtonSize.large => 56,
    };
    final double horizontalInset = switch (widget.size) {
      MotionButtonSize.small => 12,
      MotionButtonSize.medium => 16,
      MotionButtonSize.large => 20,
    };

    final String stateDescription = switch (widget.phase) {
      MotionButtonPhase.idle => '',
      MotionButtonPhase.loading => 'In progress',
      MotionButtonPhase.success => 'Completed',
      MotionButtonPhase.failure => 'Failed',
    };

    Widget? symbol = switch (widget.phase) {
      MotionButtonPhase.idle => null,
      MotionButtonPhase.loading => reduceMotion
          ? Icon(Icons.hourglass_bottom, size: 18, color: textColor)
          : SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor,
              ),
            ),
      MotionButtonPhase.success => Icon(Icons.check, color: textColor, size: 18),
      MotionButtonPhase.failure =>
        Icon(Icons.error_outline, color: textColor, size: 18),
    };
    // The symbol belongs to the visual label only, never the semantic label.
    if (symbol != null) {
      symbol = KeyedSubtree(
        key: ValueKey<MotionButtonPhase>(widget.phase),
        child: symbol,
      );
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      value: stateDescription.isEmpty ? null : stateDescription,
      onTap: enabled ? widget.onPressed : null,
      child: ExcludeSemantics(
        child: AnimatedScale(
          scale: _highlighted && enabled && !reduceMotion ? 0.975 : 1,
          duration: duration,
          curve: MotionTiming.curve(MotionPreset.responsive),
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: enabled ? widget.onPressed : null,
                onHighlightChanged: (bool pressed) {
                  if (_highlighted != pressed && mounted) {
                    setState(() { _highlighted = pressed; });
                  }
                },
                borderRadius: BorderRadius.circular(MotionRadius.control),
                splashColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                child: AnimatedContainer(
                  duration: duration,
                  curve: MotionTiming.curve(MotionPreset.gentle),
                  constraints: BoxConstraints(minHeight: minHeight),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalInset,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(MotionRadius.control),
                    border: Border.all(color: borderColor),
                  ),
                  child: DefaultTextStyle(
                    style: (Theme.of(context).textTheme.labelLarge ??
                            const TextStyle(fontSize: 14))
                        .copyWith(color: textColor, fontWeight: FontWeight.w600),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (symbol != null) ...<Widget>[
                          symbol,
                          const SizedBox(width: MotionSpacing.small),
                        ],
                        Flexible(child: Text(widget.label, maxLines: 2,
                                             overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
