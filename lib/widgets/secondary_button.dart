import 'package:flutter/material.dart';

import '../theme.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.button);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: Color.lerp(AppColors.butterYellow, Colors.black, 0.12)!,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.butterYellow,
          foregroundColor: AppColors.mutedBrown,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: Text(label),
      ),
    );
  }
}