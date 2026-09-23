import 'package:flutter/material.dart';

import '../theme.dart';
import 'primary_button.dart';

/// Centered placeholder shown when a list has nothing to display —
/// "No Items Found" on Closet, or an empty calendar/closet state.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.checkroom_rounded,
    this.buttonLabel,
    this.onButtonPressed,
  });

  final String message;
  final IconData icon;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.lg * 2),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: AppColors.blush.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: AppColors.buttonPink),
          ),
          const SizedBox(height: Spacing.md),
          Text(message, textAlign: TextAlign.center, style: textTheme.bodyMedium),
          if (buttonLabel != null) ...[
            const SizedBox(height: Spacing.md),
            SizedBox(
              width: 180,
              child: PrimaryButton(label: buttonLabel!, onPressed: onButtonPressed),
            ),
          ],
        ],
      ),
    );
  }
}