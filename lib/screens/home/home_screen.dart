import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/clothing_card.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/wear_me_card.dart';
import '../closet/closet_screen.dart';
import 'hidden_gems_sheet.dart';

/// Home: greeting, today's Wear Me suggestion, wardrobe stats at a glance,
/// and a peek at more items worth rediscovering.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.userName = 'Sofia'});

  final String userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  void _openHiddenGems() {
    showHiddenGemsSheet(context);
  }

  void _goToTab(int index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ClosetScreen(userName: widget.userName)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: DotPattern(
        backgroundColor: AppColors.cream,
        dotColor: AppColors.softPink.withValues(alpha: 0.16),
        spacing: 18,
        dotRadius: 1.3,
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.md,
                  Spacing.md,
                  // Room for the floating nav bar *and* the FAB above it —
                  // matches the fix in Closet so the FAB never clips over
                  // the last row of content.
                  170,
                ),
                children: [
                  _Header(userName: widget.userName),
                  const SizedBox(height: Spacing.lg),
                  const _SectionHeader(title: 'Wear Me'),
                  const SizedBox(height: Spacing.sm),
                  WearMeCard(
                    name: 'Pink Polkadot Top',
                    daysUnworn: 32,
                    tags: const ['Tops', 'Casual'],
                    onStyleThis: () {},
                    onSkip: () {},
                  ),
                  const SizedBox(height: Spacing.lg),
                  const _SectionHeader(title: 'Wardrobe Stats'),
                  const SizedBox(height: Spacing.sm),
                  const Row(
                    children: [
                      Expanded(child: StatTile(value: '47', label: 'Total Items')),
                      SizedBox(width: Spacing.sm),
                      Expanded(child: StatTile(value: '12', label: 'Outfits')),
                      SizedBox(width: Spacing.sm),
                      Expanded(child: StatTile(value: '23', label: 'Worn This Mo.')),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionHeader(title: 'More Hidden Gems'),
                      ),
                      TextButton(
                        onPressed: _openHiddenGems,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mutedBrown,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('See More >'),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(
                        child: ClothingCard(
                          name: 'Yellow Bow Top',
                          tags: ['Tops', 'Casual'],
                          icon: Icons.checkroom_rounded,
                        ),
                      ),
                      SizedBox(width: Spacing.sm),
                      Expanded(
                        child: ClothingCard(
                          name: 'Blue Tiered Skirt',
                          tags: ['Bottoms', 'Casual'],
                          icon: Icons.checkroom_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Floating "add item" action, sitting above the nav bar.
              Positioned(
                right: Spacing.md,
                bottom: 92,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.glow(AppColors.buttonPink),
                  ),
                  child: FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: AppColors.buttonPink,
                    foregroundColor: AppColors.white,
                    child: const Icon(Icons.add_rounded),
                  ),
                ),
              ),
              Positioned(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.sm,
                child: BottomNavBar(
                  currentIndex: _navIndex,
                  onTap: _goToTab,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A plain text heading used above each Home section (no icon — kept
/// text-only so the only color accents on the page are the ones that
/// matter: primary buttons, the active nav item, and the FAB).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(title, style: textTheme.headlineSmall!.copyWith(fontSize: 18));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userName',
                style: textTheme.headlineSmall!.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 2),
              Text(
                'Ready to pick a gorgeous outfit?',
                style: textTheme.bodyMedium!.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blush,
            border: Border.all(color: AppColors.softPink, width: 1.5),
            boxShadow: AppShadows.surface,
          ),
          child: const Icon(Icons.person_rounded, color: AppColors.buttonPink),
        ),
      ],
    );
  }
}