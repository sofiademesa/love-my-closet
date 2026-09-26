import 'package:flutter/material.dart';

import '../theme.dart';

/// One row inside a Profile settings section: a rounded, blush-bordered
/// card with a leading icon, a label, and a trailing accessory — a chevron
/// by default, or a custom [trailing] widget (a [Switch], a threshold
/// picker, etc.) for rows that aren't simple navigation taps.
class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium!;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.field),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: AppColors.blush, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.buttonPink, size: 20),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedBrown,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.mutedBrown,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}