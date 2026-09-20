import 'package:flutter/material.dart';

import '../theme.dart';

/// Main call-to-action button: pink fill, white bold label, soft bottom edge.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
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
                  color: Color.lerp(AppColors.buttonPink, Colors.black, 0.18)!,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: Text(label),
      ),
    );
  }
}