import 'package:flutter/material.dart';

import '../../animations/app_motion.dart';
import '../../data/closet_store.dart';
import '../../data/filter_icons.dart';
import '../../data/user_profile_store.dart';
import '../../models/clothing_item.dart';
import '../../services/backend_errors.dart';
import '../../theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/clothing_card.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/search_bar.dart';
import '../calendar/calendar_screen.dart';
import '../home/home_screen.dart';
import '../outfit_builder/outfit_builder_screen.dart';
import '../profile/profile_screen.dart';
import 'add_clothes_screen.dart';
import 'edit_item_screen.dart';
import 'item_detail_screen.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key, this.userName = 'Sofia'});

  final String userName;

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  static const _kFavorites = 'Favorites';
  static const _kAllOccasions = 'All Occasions';

  final _searchController = TextEditingController();
  // The user's saved items, straight from Supabase via the shared store.
  final _closet = ClosetStore.instance;
  List<ClothingItem> get _items => _closet.items;

  // Read live so the header keeps showing whatever name Edit Profile was
  // last saved with, not the value this screen happened to be built with.
  final _profileStore = UserProfileStore.instance;

  String? _category;
  String? _occasion;
  String _query = '';

  /// Item ids currently mid soft-delete animation: still in [_items] (so
  /// they keep rendering) but flagged so their tile plays its exit fade
  /// before actually being dropped from the list — see [_actuallyRemove].
  final Set<String> _removingIds = {};

  bool get _favoritesOnly => _category == _kFavorites;

  @override
  void initState() {
    super.initState();
    _profileStore.addListener(_onProfileChanged);
    _closet.addListener(_onProfileChanged);
    if (!_closet.hasLoaded && !_closet.isLoading) _closet.load();
  }

  @override
  void dispose() {
    _profileStore.removeListener(_onProfileChanged);
    _closet.removeListener(_onProfileChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  List<ClothingItem> get _filtered {
    return _items.where((item) {
      final matchesCategory = _category == null ||
          _category == _kFavorites ||
          item.category == _category;
      final matchesOccasion = _occasion == null || item.occasion == _occasion;
      final matchesQuery =
          _query.isEmpty || item.name.toLowerCase().contains(_query.toLowerCase());
      final matchesFavorite = !_favoritesOnly || item.isFavorite;
      return matchesCategory && matchesOccasion && matchesQuery && matchesFavorite;
    }).toList();
  }

  void _goToTab(int index) {
    const currentIndex = 1;
    if (index == currentIndex) return;
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        AppPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushReplacement(
        AppPageRoute(
          builder: (_) => const OutfitBuilderScreen(),
        ),
      );
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushReplacement(
        AppPageRoute(
          builder: (_) => const CalendarScreen(),
        ),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      AppPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  Future<void> _toggleFavorite(ClothingItem item) async {
    try {
      await _closet.toggleFavorite(item.id);
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
  }

  Future<void> _openAddClothes() async {
    // Add Clothes saves to Supabase; the store then shows it here.
    await Navigator.of(context).push<ClothingItem>(
      AppPageRoute(builder: (_) => const AddClothesScreen()),
    );
  }

  Future<void> _openDetail(ClothingItem item) async {
    final result = await Navigator.of(context).push(
      AppPageRoute(
        builder: (_) => ItemDetailScreen(item: item, originIndex: 1),
      ),
    );
    _applyEditResult(item, result);
  }

  Future<void> _openEdit(ClothingItem item) async {
    final result = await Navigator.of(context).push(
      AppPageRoute(builder: (_) => EditItemScreen(item: item)),
    );
    _applyEditResult(item, result);
  }

  /// Edits are already saved to Supabase by the time we're back here (the
  /// store refreshes the grid); only a delete still needs its exit animation.
  void _applyEditResult(ClothingItem item, Object? result) {
    if (result == 'deleted') {
      setState(() => _removingIds.add(item.id));
    }
  }

  Future<void> _confirmDelete(ClothingItem item) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this item?'),
        content: Text('"${item.name}" will be removed from your closet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _removingIds.add(item.id));
    }
  }

  /// Called once a tile's exit animation has finished: only now is the
  /// item really deleted (database row, then its photo in Storage). If
  /// that fails the tile comes back.
  Future<void> _actuallyRemove(String id) async {
    try {
      await _closet.delete(id);
    } catch (e) {
      _showError(e);
    }
    if (!mounted) return;
    setState(() => _removingIds.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filtered = _filtered;

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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.md,
                  Spacing.md,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_profileStore.displayName}'s Digital Closet",
                      style: textTheme.headlineSmall!.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: Spacing.md),
                    AppSearchBar(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: Spacing.md),
                    FilterChips(
                      options: const [_kFavorites, ...clothingCategories],
                      icons: categoryFilterIcons,
                      selected: _category,
                      onSelected: (v) => setState(() => _category = v),
                    ),
                    const SizedBox(height: Spacing.sm),
                    FilterChips(
                      options: const [_kAllOccasions, ...occasionTags],
                      icons: occasionFilterIcons,
                      selected: _occasion ?? _kAllOccasions,
                      onSelected: (v) => setState(
                        () => _occasion = (v == null || v == _kAllOccasions) ? null : v,
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    Expanded(
                      child: filtered.isEmpty && _closet.isLoading
                          ? const Center(child: AppLoadingIndicator(size: 30))
                          : filtered.isEmpty && _closet.error != null
                          ? Center(
                              child: EmptyState(
                                message: _closet.error!,
                                icon: Icons.cloud_off_rounded,
                                buttonLabel: 'Try Again',
                                onButtonPressed: _closet.load,
                              ),
                            )
                          : filtered.isEmpty
                          ? Center(
                              child: EmptyState(
                                message: _favoritesOnly
                                    ? 'No favorites yet.\nTap the heart on any item to add it here.'
                                    : 'No items found.\nTry a different filter or add something new.',
                                icon: _favoritesOnly
                                    ? Icons.favorite_border_rounded
                                    : Icons.search_off_rounded,
                                buttonLabel: _favoritesOnly ? null : 'Add Clothes',
                                onButtonPressed: _favoritesOnly ? null : _openAddClothes,
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                // Size each tile from the actual column width
                                // instead of guessing a fixed height — a flat
                                // number either overflows on some screens or
                                // leaves a dead gap under the name row on
                                // others.
                                const crossAxisCount = 2;
                                final cardWidth =
                                    (constraints.maxWidth - Spacing.sm * (crossAxisCount - 1)) /
                                        crossAxisCount;
                                final imageHeight = cardWidth / 1.35;
                                const chromeHeight = Spacing.sm * 2 // outer top+bottom padding
                                    + Spacing.xs // gap under image
                                    + 22 // name row (heart icon sets the height)
                                    + 6; // safety margin for larger text scales
                                return GridView.builder(
                                  // Room for the floating nav bar *and* the
                                  // FAB above it, so the FAB never clips over
                                  // the last grid row.
                                  padding: const EdgeInsets.only(bottom: 150),
                                  itemCount: filtered.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: Spacing.sm,
                                    crossAxisSpacing: Spacing.sm,
                                    mainAxisExtent: imageHeight + chromeHeight,
                                  ),
                                  itemBuilder: (context, i) {
                                    final item = filtered[i];
                                    return FadeScaleOut(
                                      key: ValueKey(item.id),
                                      removing: _removingIds.contains(item.id),
                                      onExited: () => _actuallyRemove(item.id),
                                      child: FadeSlideIn(
                                        delay: staggerDelay(i, stepMs: 30, maxMs: 180),
                                        child: ClothingCard(
                                          name: item.name,
                                          icon: item.icon,
                                          imageUrl: item.imageUrl,
                                          backgroundColorName: item.color,
                                          isFavorite: item.isFavorite,
                                          onFavoriteToggle: () => _toggleFavorite(item),
                                          onTap: () => _openDetail(item),
                                          onEdit: () => _openEdit(item),
                                          onDelete: () => _confirmDelete(item),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              // Floating "add clothes" action, sitting above the nav bar.
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
                  currentIndex: 1,
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