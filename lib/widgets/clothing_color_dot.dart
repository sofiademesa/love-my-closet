import 'package:flutter/material.dart';

import '../theme.dart';

/// Small circular swatch shown beside a clothing color name (e.g. in the
/// Color dropdown). Soft, fashion-inspired tones rather than raw primaries.
/// Unknown names fall back to a neutral blush dot.
class ClothingColorDot extends StatelessWidget {
  const ClothingColorDot({super.key, required this.name, this.size = 22});

  final String name;
  final double size;

  static const _swatches = <String, Color>{
    'Pink': Color(0xFFF6A6C1),
    'Yellow': Color(0xFFF8D77E),
    'Blue': Color(0xFF9FC5E8),
    'Denim': Color(0xFF6F8FB3),
    'White': Color(0xFFF8F5F2),
    'Black': Color(0xFF3A3540),
  };

  /// Soft rainbow sweep used for "Multicolor".
  static const _multicolor = SweepGradient(
    colors: [
      Color(0xFFF6A6C1),
      Color(0xFFF8D77E),
      Color(0xFFB5E0C4),
      Color(0xFF9FC5E8),
      Color(0xFFC9B3E8),
      Color(0xFFF6A6C1),
    ],
  );

  /// Solid swatch color for [name], or null for 'Transparent' / 'Multicolor'
  /// / unknown names. Lets other widgets (e.g. the photo preview background)
  /// reuse this palette instead of duplicating it.
  static Color? swatchFor(String name) => _swatches[name];

  /// The soft rainbow gradient used for 'Multicolor'.
  static const SweepGradient multicolorGradient = _multicolor;

  @override
  Widget build(BuildContext context) {
    if (name == 'Transparent') return _buildTransparent();
    final isMulti = name == 'Multicolor';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isMulti ? null : (_swatches[name] ?? AppColors.blush),
        gradient: isMulti ? _multicolor : null,
        // Hairline edge keeps the White swatch visible on white.
        border: Border.all(
          color: AppColors.mutedBrown.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
    );
  }

  /// Neutral gray/white checkerboard (not pink, so it stays readable on the
  /// pale-pink selected row), the usual "see-through" cue.
  Widget _buildTransparent() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.mutedBrown.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: _CheckerPainter(const Color(0xFFCFCBD1)),
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  _CheckerPainter(this.tint);

  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    const cells = 4;
    final cell = size.width / cells;
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.white);
    final paint = Paint()..color = tint;
    for (var r = 0; r < cells; r++) {
      for (var c = 0; c < cells; c++) {
        if ((r + c).isOdd) {
          canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter old) => old.tint != tint;
}