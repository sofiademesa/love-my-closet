import 'package:flutter/material.dart';

/// Faint polka-dot texture behind content, matching the dotted background in

class DotPattern extends StatelessWidget {
  const DotPattern({
    super.key,
    required this.child,
    this.backgroundColor,
    this.backgroundGradient,
    this.dotColor = const Color(0x14EE3E91),
    this.spacing = 14,
    this.dotRadius = 1.4,
  }) : assert(
         backgroundColor != null || backgroundGradient != null,
         'Provide a backgroundColor or a backgroundGradient.',
       );

  final Widget child;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color dotColor;
  final double spacing;
  final double dotRadius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: backgroundGradient != null
              ? DecoratedBox(
                  decoration: BoxDecoration(gradient: backgroundGradient),
                )
              : ColoredBox(color: backgroundColor!),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _DotPainter(color: dotColor, spacing: spacing, radius: dotRadius),
          ),
        ),
        child,
      ],
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter({required this.color, required this.spacing, required this.radius});

  final Color color;
  final double spacing;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.radius != radius;
}