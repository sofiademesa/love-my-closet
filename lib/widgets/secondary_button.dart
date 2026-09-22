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
    final enabled = onPressed != null;
 
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: enabled
            ? AppShadows.glow(AppColors.butterYellow, alpha: 0.45)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.butterYellow,
                Color.lerp(AppColors.butterYellow, AppColors.softPink, 0.18)!,
              ],
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            splashColor: AppColors.mutedBrown.withValues(alpha: 0.08),
            highlightColor: Colors.transparent,
            child: SizedBox(
              height: 48,
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mutedBrown,
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