import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../interaction/motion_slider_scale.dart';
import '../theme/motion_accessibility.dart';
import '../theme/motion_palette.dart';
import '../theme/motion_tokens.dart';

/// An app-controlled numeric slider, implemented with native Flutter gestures.
///
/// The host owns [value]. The widget never writes to application state on its
/// own; callbacks request changes and report the latest *proposed* value on
/// gesture completion. It does not claim a host-side operation has succeeded.
class MotionElasticSlider extends StatefulWidget {
  const MotionElasticSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    this.scale,
    this.marks = const <double>[],
    this.enabled = true,
    this.onEditingChanged,
    this.onCommit,
    super.key,
  });

  final String label;
  final double value;
  final ValueChanged<double>? onChanged;
  final MotionSliderScale? scale;
  final List<double> marks;
  final bool enabled;
  final ValueChanged<bool>? onEditingChanged;
  final ValueChanged<double>? onCommit;

  @override
  State<MotionElasticSlider> createState() => _MotionElasticSliderState();
}

class _MotionElasticSliderState extends State<MotionElasticSlider>
    with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  bool _dragging = false;
  double _edgeOffset = 0;
  double? _lastRequested;

  MotionSliderScale get _scale => widget.scale ?? MotionSliderScale();
  bool get _enabled => widget.enabled && widget.onChanged != null;

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
  void didUpdateWidget(covariant MotionElasticSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && _dragging) {
      _dragging = false;
      _edgeOffset = 0;
      _lastRequested = null;
      // Cancel, not commit, if a host disabled the control mid-gesture.
      widget.onEditingChanged?.call(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }

  void _propose(double proposed) {
    if (!_enabled) return;
    final double snapped = _scale.snap(proposed);
    if (snapped != (_lastRequested ?? _scale.snap(widget.value))) {
      _lastRequested = snapped;
      widget.onChanged?.call(snapped);
    }
  }

  void _adjust(int direction) {
    if (!_enabled) return;
    final double previous = _scale.snap(widget.value);
    final double next = _scale.adjacent(previous, direction);
    if (next == previous) return;
    _propose(next);
    widget.onCommit?.call(next);
    _lastRequested = null;
  }

  KeyEventResult _onKey(FocusNode focus, KeyEvent event) {
    if (!_enabled || event is! KeyDownEvent) return KeyEventResult.ignored;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final int? direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowRight => rtl ? -1 : 1,
      LogicalKeyboardKey.arrowLeft => rtl ? 1 : -1,
      LogicalKeyboardKey.arrowUp => 1,
      LogicalKeyboardKey.arrowDown => -1,
      _ => null,
    };
    if (direction == null) return KeyEventResult.ignored;
    _adjust(direction);
    return KeyEventResult.handled;
  }

  void _updateAt(Offset local, double span, bool rtl, bool reduced) {
    if (!_enabled) return;
    final double rawVisual = (local.dx - 14) / math.max(span, 1);
    final double visual = rawVisual.clamp(0, 1).toDouble();
    final double logical = MotionSliderScale.logicalProgress(visual, rtl: rtl);
    _propose(_scale.valueAt(logical));
    final double overflow = (rawVisual - visual) * span;
    final double displacement = MotionSliderScale.resistance(
      overflow,
      reducedMotion: reduced,
    );
    if (_edgeOffset != displacement) setState(() => _edgeOffset = displacement);
  }

  void _beginDrag() {
    if (!_enabled || _dragging) return;
    _focusNode.requestFocus();
    setState(() => _dragging = true);
    widget.onEditingChanged?.call(true);
  }

  void _complete({bool commit = true}) {
    if (!_dragging) return;
    final double proposed = _lastRequested ?? _scale.snap(widget.value);
    setState(() {
      _dragging = false;
      _edgeOffset = 0;
      _lastRequested = null;
    });
    widget.onEditingChanged?.call(false);
    if (commit) widget.onCommit?.call(proposed);
  }

  @override
  Widget build(BuildContext context) {
    final bool reduced = MotionAccessibility.reduceMotion(context);
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double logical = _scale.progress(widget.value);
    final double visual = MotionSliderScale.visualProgress(logical, rtl: rtl);
    final Color background = MotionPalette.of(context, MotionColorRole.border);
    final Color accent = MotionPalette.of(context, MotionColorRole.accent);
    final Color surface = MotionPalette.of(context, MotionColorRole.surface);
    final Color primary = MotionPalette.of(context, MotionColorRole.primaryText);
    final Color secondary = MotionPalette.of(context, MotionColorRole.secondaryText);
    final List<double> marks = widget.marks
        .where((double m) => m.isFinite && m >= _scale.minimum && m <= _scale.maximum)
        .toSet().toList()..sort();

    return Semantics(
      key: const ValueKey<String>('motion-slider-semantics'),
      slider: true,
      enabled: _enabled,
      label: widget.label,
      value: MotionSliderScale.label(_scale.snap(widget.value)),
      increasedValue: MotionSliderScale.label(_scale.adjacent(widget.value, 1)),
      decreasedValue: MotionSliderScale.label(_scale.adjacent(widget.value, -1)),
      onIncrease: _enabled ? () => _adjust(1) : null,
      onDecrease: _enabled ? () => _adjust(-1) : null,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: _enabled ? 1 : 0.5,
          child: Focus(
            focusNode: _focusNode,
            canRequestFocus: _enabled,
            onKeyEvent: _onKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.label,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: primary, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      MotionSliderScale.label(_scale.snap(widget.value)),
                      key: const ValueKey<String>('motion-slider-value'),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: secondary, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double width = math.max(constraints.maxWidth, 28);
                    final double span = math.max(width - 28, 1);
                    final double selected = span * logical;
                    final Duration settle = MotionTiming.duration(
                      MotionPreset.settle,
                      reduceMotion: reduced,
                    );
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: _enabled ? (TapDownDetails details) {
                        _focusNode.requestFocus();
                      } : null,
                      onTapUp: _enabled ? (TapUpDetails details) {
                        _updateAt(details.localPosition, span, rtl, reduced);
                        final double value = _lastRequested ?? _scale.snap(widget.value);
                        widget.onCommit?.call(value);
                        _lastRequested = null;
                      } : null,
                      onPanStart: _enabled ? (DragStartDetails details) {
                        _beginDrag();
                        _updateAt(details.localPosition, span, rtl, reduced);
                      } : null,
                      onPanUpdate: _enabled ? (DragUpdateDetails details) {
                        _updateAt(details.localPosition, span, rtl, reduced);
                      } : null,
                      onPanEnd: _enabled ? (DragEndDetails details) => _complete() : null,
                      onPanCancel: _enabled ? () => _complete(commit: false) : null,
                      child: SizedBox(
                        height: 48,
                        width: width,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Positioned(
                              left: 14, right: 14, top: 21, height: 6,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: background,
                                  borderRadius: BorderRadius.circular(3)),
                              ),
                            ),
                            Positioned(
                              left: rtl ? 14 + span - selected : 14,
                              top: 21,
                              width: selected,
                              height: 6,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: accent,
                                  borderRadius: BorderRadius.circular(3)),
                              ),
                            ),
                            for (final double mark in marks)
                              Positioned(
                                key: ValueKey<String>('motion-slider-mark-$mark'),
                                left: 14 + span * MotionSliderScale.visualProgress(
                                  _scale.progress(mark), rtl: rtl) - 2,
                                top: 22,
                                width: 4, height: 4,
                                child: DecoratedBox(decoration: BoxDecoration(
                                  color: secondary, shape: BoxShape.circle)),
                              ),
                            AnimatedPositioned(
                              key: const ValueKey<String>('motion-slider-thumb'),
                              duration: _dragging ? Duration.zero : settle,
                              curve: MotionTiming.curve(MotionPreset.settle),
                              left: span * visual + _edgeOffset,
                              top: 10,
                              width: 28, height: 28,
                              child: AnimatedScale(
                                duration: MotionTiming.duration(
                                  MotionPreset.responsive, reduceMotion: reduced),
                                scale: _dragging && !reduced ? 1.13 : 1,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: surface, shape: BoxShape.circle,
                                    border: Border.all(color: accent, width: 2.5),
                                    boxShadow: const <BoxShadow>[
                                      BoxShadow(color: Color(0x1F000000),
                                        blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
