import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_thumb.dart';
import 'dot_pattern.dart';
import 'primary_button.dart';
import 'tag_chip.dart';

/// The "Hidden Gem of the Day" spotlight card in the Wear Me section:
/// one suggested item with its tags, an "unworn for" pill, and
/// Style This / Skip actions.
class WearMeCard extends StatelessWidget {
  const WearMeCard({
    super.key,
    required this.name,
    required this.daysUnworn,
    required this.tags,
    this.icon = Icons.checkroom_rounded,
    this.onStyleThis,
    this.onSkip,
  });

  final String name;
  final int daysUnworn;
  final List<String> tags;
  final IconData icon;
  final VoidCallback? onStyleThis;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final cardRadius = BorderRadius.circular(AppRadius.card);

    return Container(
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        border: Border.all(color: AppColors.blush, width: 1.5),
        boxShadow: AppShadows.surface,
      ),
      child: ClipRRect(
        borderRadius: cardRadius,
        child: DotPattern(
          backgroundColor: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hidden Gem of the Day',
                        style: textTheme.headlineSmall!.copyWith(fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.butterYellow.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Unworn · ${daysUnworn}d',
                        style: textTheme.labelSmall!.copyWith(
                          color: AppColors.mutedBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClothingThumb(icon: icon, size: 88),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          SizedBox(
                            height: 28,
                            child: Row(
                              children: [
                                for (var i = 0; i < tags.length; i++) ...[
                                  if (i > 0) const SizedBox(width: Spacing.xs),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: TagChip(
                                        label: tags[i],
                                        tint: i == 0
                                            ? TagChipTint.pink
                                            : TagChipTint.yellow,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Divider(color: AppColors.blush, height: 1, thickness: 1),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: 'Style This',
                        onPressed: onStyleThis,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(child: _SkipButton(onPressed: onSkip)),
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

/// Plain white outline pill, the quieter of the two Wear Me actions.
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(42),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.mutedBrown,
        side: BorderSide(color: AppColors.blush, width: 1.5),
        textStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: const Text('Skip'),
    );
  }
}