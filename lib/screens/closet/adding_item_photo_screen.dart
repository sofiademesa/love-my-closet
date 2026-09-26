import 'package:flutter/material.dart';

import '../../data/accessibility_store.dart';
import '../../theme.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/clothing_thumb.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

/// Adding Item Photo: the capture/preview step reached from the photo box
/// on Add Clothes. Lets Sofia switch between camera and gallery, previews
/// the background-removed cutout, then Undo or Use Photo.
class AddingItemPhotoScreen extends StatefulWidget {
  const AddingItemPhotoScreen({super.key});

  @override
  State<AddingItemPhotoScreen> createState() => _AddingItemPhotoScreenState();
}

class _AddingItemPhotoScreenState extends State<AddingItemPhotoScreen> {
  bool _fromCamera = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: DotPattern(
        backgroundColor: AppColors.cream,
        dotColor: AppColors.softPink.withValues(alpha: 0.16),
        spacing: 18,
        dotRadius: 1.3,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BackCircleButton(onTap: () => Navigator.of(context).pop(false)),
                    const SizedBox(width: Spacing.sm),
                    Text('Add Clothes', style: textTheme.headlineSmall!.copyWith(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.blush, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SegmentButton(
                          label: 'Take Photo',
                          active: _fromCamera,
                          onTap: () => setState(() => _fromCamera = true),
                        ),
                      ),
                      Expanded(
                        child: _SegmentButton(
                          label: 'Choose from Gallery',
                          active: !_fromCamera,
                          onTap: () => setState(() => _fromCamera = false),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.blush, width: 1.5),
                      boxShadow: AppShadows.surface,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomPaint(painter: _CheckerPainter()),
                          const Center(
                            child: ClothingThumb(icon: Icons.checkroom_rounded, size: 140),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.buttonPink),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Text(
                        'Background removed! Looks great.',
                        style: textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Undo',
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Use Photo',
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Two-way "Take Photo / Choose from Gallery" segmented control.
class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: kMotionDuration(const Duration(milliseconds: 150)),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(colors: [AppColors.softPink, AppColors.buttonPink])
                : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.white : AppColors.mutedBrown,
            ),
          ),
        ),
      ),
    );
  }
}

/// Transparent-background checkerboard behind the cutout preview.
class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 14.0;
    final light = Paint()..color = AppColors.white;
    final dark = Paint()..color = AppColors.blush.withValues(alpha: 0.6);
    canvas.drawRect(Offset.zero & size, light);
    for (double y = 0; y < size.height; y += cell) {
      for (double x = 0; x < size.width; x += cell) {
        final isDark = ((x / cell).floor() + (y / cell).floor()).isEven;
        if (isDark) {
          canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), dark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerPainter oldDelegate) => false;
}