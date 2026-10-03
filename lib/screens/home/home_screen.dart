import 'package:flutter/material.dart';

import '../../animations/app_motion.dart';
import '../../data/closet_store.dart';
import '../../data/outfit_store.dart';
import '../../data/user_profile_store.dart';
import '../../models/clothing_item.dart';
import '../../theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/clothing_card.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/wear_me_card.dart';
import '../calendar/calendar_screen.dart';
import '../closet/add_clothes_screen.dart';
import '../closet/closet_screen.dart';
import '../outfit_builder/outfit_builder_screen.dart';
import '../../widgets/heart_avatar.dart';
import '../profile/profile_screen.dart';
import 'hidden_gems_sheet.dart';

/// Home: greeting, today's Wear Me suggestion, wardrobe stats at a glance,
/// and a peek at more items worth rediscovering — all worked out from the
/// user's real closet and calendar in Supabase.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.userName = 'Sofia'});

  final String userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  // The name shown here always reflects the saved display name, not the
  // value this screen happened to be constructed with — so it listens to
  // the shared store the same way Calendar/Builder listen to OutfitStore.
  final _profileStore = UserProfileStore.instance;

  final _closet = ClosetStore.instance;
  final _outfits = OutfitStore.instance;

  @override
  void initState() {
    super.initState();
    _profileStore.addListener(_onProfileChanged);
    _closet.addListener(_onProfileChanged);
    _outfits.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _profileStore.removeListener(_onProfileChanged);
    _closet.removeListener(_onProfileChanged);
    _outfits.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  /// Every item, longest-unworn first.
  List<ClothingItem> get _byUnworn =>
      List.of(_closet.items)..sort((a, b) => b.daysUnworn.compareTo(a.daysUnworn));

  /// Items unworn for at least the Hidden Gems Threshold set on Profile.
  List<ClothingItem> get _hiddenGems {
    final threshold = _profileStore.hiddenGemsThresholdDays;
    return _byUnworn.where((i) => i.daysUnworn >= threshold).toList();
  }

  /// Distinct items worn so far this month (the "Worn This Mo." stat).
  int get _wornThisMonth {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final ids = <String>{};
    for (final entry in _outfits.all) {
      if (entry.date.year == now.year && entry.date.month == now.month && !entry.date.isAfter(today)) {
        ids.addAll(entry.pieces.map((p) => p.item.id));
      }
    }
    return ids.length;
  }

  void _openHiddenGems() {
    showHiddenGemsSheet(
      context,
      items: [
        for (final item in _hiddenGems)
          HiddenGemItem(
            id: item.id,
            name: item.name,
            daysUnworn: item.daysUnworn,
            icon: item.icon,
            imageUrl: item.imageUrl,
            backgroundColorName: item.color,
          ),
      ],
      onWearAgain: (gem) {
        if (gem.id != null) _styleItem(gem.id!);
      },
    );
  }

  /// "Style Me" / "Wear Again": open the Outfit Builder with this piece
  /// already on the board, ready to build a look around it.
  void _styleItem(String itemId) {
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => OutfitBuilderScreen(startWithItemId: itemId)),
    );
  }

  void _openAddClothes() {
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => const AddClothesScreen()),
    );
  }

  void _goToTab(int index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.of(context).push(
        AppPageRoute(builder: (_) => const ClosetScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.of(context).push(
        AppPageRoute(builder: (_) => const OutfitBuilderScreen()),
      );
      return;
    }
    if (index == 3) {
      Navigator.of(context).push(
        AppPageRoute(builder: (_) => const CalendarScreen()),
      );
      return;
    }
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wear Me = the top hidden gem (or, if nothing has passed the threshold
    // yet, the longest-unworn piece); "More Hidden Gems" = the next two.
    final gems = _hiddenGems;
    final ranked = gems.isNotEmpty ? gems : _byUnworn;
    final wearMe = ranked.isEmpty ? null : ranked.first;
    final moreGems = gems.where((i) => i.id != wearMe?.id).take(2).toList();

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
                  FadeSlideIn(
                    delay: staggerDelay(0),
                    child: _Header(userName: _profileStore.displayName),
                  ),
                  const SizedBox(height: Spacing.lg),
                  FadeSlideIn(
                    delay: staggerDelay(1),
                    child: const _SectionHeader(title: 'Wear Me'),
                  ),
                  const SizedBox(height: Spacing.sm),
                  FadeSlideIn(
                    delay: staggerDelay(1),
                    child: wearMe == null
                        ? EmptyState(
                            message: _closet.isLoading
                                ? 'Opening your closet…'
                                : 'Your closet is empty.\nAdd your first piece to get suggestions.',
                            buttonLabel: _closet.isLoading ? null : 'Add Clothes',
                            onButtonPressed: _closet.isLoading ? null : _openAddClothes,
                          )
                        : WearMeCard(
                            name: wearMe.name,
                            daysUnworn: wearMe.daysUnworn,
                            icon: wearMe.icon,
                            imageUrl: wearMe.imageUrl,
                            backgroundColorName: wearMe.color,
                            onStyleThis: () => _styleItem(wearMe.id),
                          ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  FadeSlideIn(
                    delay: staggerDelay(2),
                    child: const _SectionHeader(title: 'Wardrobe Stats'),
                  ),
                  const SizedBox(height: Spacing.sm),
                  FadeSlideIn(
                    delay: staggerDelay(2),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatTile(value: '${_closet.items.length}', label: 'Total Items'),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: StatTile(value: '${_outfits.outfitCount}', label: 'Outfits'),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: StatTile(value: '$_wornThisMonth', label: 'Worn This Mo.'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  FadeSlideIn(
                    delay: staggerDelay(3),
                    child: Row(
                      children: [
                        const Expanded(
                          child: _SectionHeader(title: 'More Hidden Gems'),
                        ),
                        PressableScale(
                          child: TextButton(
                            onPressed: _openHiddenGems,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.mutedBrown,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('See More >'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  FadeSlideIn(
                    delay: staggerDelay(3),
                    child: moreGems.isEmpty
                        ? Text(
                            'No more hidden gems right now.',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < 2; i++) ...[
                                if (i > 0) const SizedBox(width: Spacing.sm),
                                Expanded(
                                  child: i < moreGems.length
                                      ? ClothingCard(
                                          name: moreGems[i].name,
                                          icon: moreGems[i].icon,
                                          imageUrl: moreGems[i].imageUrl,
                                          backgroundColorName: moreGems[i].color,
                                          daysUnworn: moreGems[i].daysUnworn,
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
              // Floating "add item" action, sitting above the nav bar.
              Positioned(
                right: Spacing.md,
                bottom: 92,
                child: PressableScale(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.glow(AppColors.buttonPink),
                    ),
                    child: FloatingActionButton(
                      onPressed: _openAddClothes,
                      backgroundColor: AppColors.buttonPink,
                      foregroundColor: AppColors.white,
                      child: const Icon(Icons.add_rounded),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.xs,
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
        const HeartAvatar(width: 56, small: true),
      ],
    );
  }
}