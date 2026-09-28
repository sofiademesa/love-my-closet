import 'package:flutter/material.dart';

import '../../animations/app_motion.dart';
import '../../theme.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/hidden_gem_card.dart';

/// Data for one item in the Hidden Gems list.
class HiddenGemItem {
  const HiddenGemItem({
    required this.name,
    required this.daysUnworn,
    this.icon = Icons.checkroom_rounded,
  });

  final String name;
  final int daysUnworn;
  final IconData icon;
}

const _defaultHiddenGems = [
  HiddenGemItem(name: 'Snoopy Cream Shirt', daysUnworn: 30),
  HiddenGemItem(name: 'The Beatles Shirt', daysUnworn: 45),
  HiddenGemItem(name: 'Denim Skirt', daysUnworn: 52, icon: Icons.checkroom_rounded),
  HiddenGemItem(name: 'Floral Sundress', daysUnworn: 38, icon: Icons.checkroom_rounded),
  HiddenGemItem(name: 'Grey Knit Cardigan', daysUnworn: 60, icon: Icons.checkroom_rounded),
  HiddenGemItem(name: 'Red Beret', daysUnworn: 27, icon: Icons.checkroom_rounded),
];

/// Opens Hidden Gems as a sheet that slides up over Home, matching the
/// mockup's rounded-top panel over a dimmed background.
Future<void> showHiddenGemsSheet(
  BuildContext context, {
  List<HiddenGemItem> items = _defaultHiddenGems,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.hotPink.withValues(alpha: 0.25),
    builder: (context) => HiddenGemsSheet(items: items),
  );
}

class HiddenGemsSheet extends StatelessWidget {
  const HiddenGemsSheet({super.key, this.items = _defaultHiddenGems});

  final List<HiddenGemItem> items;

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
                      for (var i = 0; i < items.length; i++) ...[
                        FadeSlideIn(
                          delay: staggerDelay(i + 1, stepMs: 50, maxMs: 300),
                          child: HiddenGemCard(
                            name: items[i].name,
                            daysUnworn: items[i].daysUnworn,
                            icon: items[i].icon,
                            onWearAgain: () {},
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