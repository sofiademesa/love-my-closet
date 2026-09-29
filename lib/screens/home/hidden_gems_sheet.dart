import 'package:flutter/material.dart';

import '../../animations/app_motion.dart';
import '../../theme.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/hidden_gem_card.dart';

/// Data for one item in the Hidden Gems list.
class HiddenGemItem {
  const HiddenGemItem({
    this.id,
    required this.name,
    required this.daysUnworn,
    this.icon = Icons.checkroom_rounded,
    this.imageUrl,
    this.backgroundColorName,
  });

  /// Closet item id, so "Wear Again" can open it in the Outfit Builder.
  final String? id;
  final String name;
  final int daysUnworn;
  final IconData icon;
  final String? imageUrl;
  final String? backgroundColorName;
}

/// Opens Hidden Gems as a sheet that slides up over Home, matching the
/// mockup's rounded-top panel over a dimmed background.
Future<void> showHiddenGemsSheet(
  BuildContext context, {
  required List<HiddenGemItem> items,
  ValueChanged<HiddenGemItem>? onWearAgain,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.hotPink.withValues(alpha: 0.25),
    builder: (context) => HiddenGemsSheet(items: items, onWearAgain: onWearAgain),
  );
}

class HiddenGemsSheet extends StatelessWidget {
  const HiddenGemsSheet({super.key, required this.items, this.onWearAgain});

  final List<HiddenGemItem> items;

  /// Called after the sheet closes, with the gem that was tapped.
  final ValueChanged<HiddenGemItem>? onWearAgain;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        final radius = BorderRadius.vertical(top: Radius.circular(28));
        return ClipRRect(
          borderRadius: radius,
          child: DotPattern(
            backgroundColor: AppColors.cream,
            dotColor: AppColors.softPink.withValues(alpha: 0.16),
            spacing: 18,
            dotRadius: 1.3,
            child: Column(
              children: [
                const SizedBox(height: Spacing.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.md,
                      Spacing.md,
                      Spacing.md,
                      Spacing.lg,
                    ),
                    children: [
                      Text(
                        'Hidden Gems',
                        style: textTheme.headlineSmall!.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pieces waiting for their moment again.',
                        style: textTheme.bodyMedium!.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: Spacing.md),
                      if (items.isEmpty)
                        const EmptyState(
                          message: 'No hidden gems right now.\nEverything has been worn recently!',
                          icon: Icons.diamond_outlined,
                        ),
                      for (var i = 0; i < items.length; i++) ...[
                        FadeSlideIn(
                          delay: staggerDelay(i + 1, stepMs: 50, maxMs: 300),
                          child: HiddenGemCard(
                            name: items[i].name,
                            daysUnworn: items[i].daysUnworn,
                            icon: items[i].icon,
                            imageUrl: items[i].imageUrl,
                            backgroundColorName: items[i].backgroundColorName,
                            onWearAgain: () {
                              final gem = items[i];
                              Navigator.of(context).pop();
                              onWearAgain?.call(gem);
                            },
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}