import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/accessibility_store.dart';

/// Keeps the text on a single line.
/// If the text is too long, it smoothly scrolls from side to side so the
/// entire text can still be read without changing the widget's size.

class MarqueeText extends StatefulWidget {
  const MarqueeText(
    this.text, {
    super.key,
    this.style,
    this.pause = const Duration(milliseconds: 1200),
    this.pixelsPerSecond = 28,
  });

  final String text;
  final TextStyle? style;

  /// How long the text rests at each end before sliding again.
  final Duration pause;

  /// Scroll speed. Gentle on purpose so names stay readable.
  final double pixelsPerSecond;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late final AnimationController _controller =
      AnimationController(vsync: this)..addListener(_tick);

  double _overflow = 0;
  double _travelMs = 600;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// 0 = resting at the start, 1 = resting at the end.
  double _profile(double v) {
    final pause = widget.pause.inMilliseconds.toDouble();
    final total = 2 * pause + 2 * _travelMs;
    final t = v * total;
    if (t < pause) return 0;
    if (t < pause + _travelMs) {
      return Curves.easeInOut.transform((t - pause) / _travelMs);
    }
    if (t < 2 * pause + _travelMs) return 1;
    return 1 -
        Curves.easeInOut.transform((t - 2 * pause - _travelMs) / _travelMs);
  }

  void _tick() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    _scroll.jumpTo((_profile(_controller.value) * max).clamp(0.0, max));
  }

  void _sync(double overflow, bool animate) {
    if (!animate) {
      if (_controller.isAnimating) _controller.stop();
      if (_controller.value != 0) _controller.value = 0;
      return;
    }
    if (_controller.isAnimating && (overflow - _overflow).abs() < 0.5) return;

    _overflow = overflow;
    _travelMs = math.max(600, overflow / widget.pixelsPerSecond * 1000);
    final total = 2 * widget.pause.inMilliseconds + 2 * _travelMs;
    _controller
      ..duration = Duration(milliseconds: total.round())
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AccessibilityStore.instance,
      builder: (context, _) {
        final reduceMotion = AccessibilityStore.instance.reduceMotion;

        return LayoutBuilder(
          builder: (context, constraints) {
            final style = DefaultTextStyle.of(context).style.merge(widget.style);
            final painter = TextPainter(
              text: TextSpan(text: widget.text, style: style),
              maxLines: 1,
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout();
            final overflow = painter.width - constraints.maxWidth;
            painter.dispose();

            final animate = !reduceMotion && overflow > 0.5;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _sync(overflow, animate);
            });

            if (!animate) {
              return Text(
                widget.text,
                style: widget.style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }

            // A non-scrollable horizontal scroll view keeps the row exactly as
            // tall as a normal one-line Text, so the tile size never changes.
            return SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Text(
                widget.text,
                style: widget.style,
                maxLines: 1,
                softWrap: false,
              ),
            );
          },
        );
      },
    );
  }
}