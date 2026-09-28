import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_thumb.dart';
import 'photo_preview_background.dart';

/// Dashed-outline photo box used on Add Clothes, Edit Item, and Edit
/// Profile. Shows an upload prompt when empty, or the picked photo with a
/// small remove (x) badge. Pass [imageBytes] to show a real photo (e.g. a
/// transparent PNG cutout) on top of a preview backdrop.
class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    this.imagePath,
    this.imageBytes,
    this.backgroundColorName = 'Transparent',
    required this.onPick,
    this.onRemove,
    this.icon = Icons.checkroom_rounded,
  });

  final String? imagePath;

  /// A real photo to display. Takes priority over [imagePath].
  final Uint8List? imageBytes;

  /// Preview-only backdrop behind [imageBytes] ('Transparent' shows a
  /// checkerboard). Never merged into the image itself.
  final String backgroundColorName;
  final VoidCallback onPick;
  final VoidCallback? onRemove;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bytes = imageBytes;
    final hasPhoto = imagePath != null || bytes != null;

    return AspectRatio(
      aspectRatio: 1.4,
      child: Stack(
        children: [
          Positioned.fill(
            child: _DottedBorderBox(
              onTap: hasPhoto ? null : onPick,
              child: bytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      child: SizedBox.expand(
                        child: PhotoPreviewBackground(
                          colorName: backgroundColorName,
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.sm),
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                    )
                  : hasPhoto
                  ? Center(child: ClothingThumb(icon: icon, size: 96))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Spacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.blush,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            color: AppColors.buttonPink,
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          'Tap to add a photo',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13,
                            color: AppColors.mutedBrown.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (hasPhoto && onRemove != null)
            Positioned(
              top: Spacing.sm,
              right: Spacing.sm,
              child: GestureDetector(
                onTap: onRemove,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.errorRed,
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DottedBorderBox extends StatelessWidget {
  const _DottedBorderBox({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: CustomPaint(
          painter: _DashedBorderPainter(color: AppColors.softPink),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadius.card),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}