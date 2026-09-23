import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/clothing_card.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/search_bar.dart';
import '../home/home_screen.dart';
import 'add_clothes_screen.dart';
import 'item_detail_screen.dart';

/// Closet: Sofia's full wardrobe grid — searchable, filterable by category
/// and occasion, with an "Add Clothes" FAB and a tap-through to item detail.
/// Favoriting happens right on each tile's heart — there's no separate
/// Favorites screen; tapping the nav bar's heart just filters this same
/// grid down to hearted items.
class ClosetScreen extends StatefulWidget {
  const ClosetScreen({
    super.key,
    this.userName = 'Sofia',
    this.initialFavoritesOnly = false,
  });

  final String userName;

  /// Opens straight into the "favorites only" filter — used when Home's
  /// nav bar links here since Home doesn't keep its own item list.
  final bool initialFavoritesOnly;

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final _searchController = TextEditingController();
  final List<ClothingItem> _items = List.of(sampleClosetItems);

  String? _category;
  String? _occasion;
  String _query = '';
  late bool _favoritesOnly = widget.initialFavoritesOnly;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClothingItem> get _filtered {
    return _items.where((item) {
      final matchesCategory = _category == null || item.category == _category;
      final matchesOccasion = _occasion == null || item.occasion == _occasion;
      final matchesQuery =
          _query.isEmpty || item.name.toLowerCase().contains(_query.toLowerCase());
      final matchesFavorite = !_favoritesOnly || item.isHiddenGem;
      return matchesCategory && matchesOccasion && matchesQuery && matchesFavorite;
    }).toList();
  }

  void _goToTab(int index) {
    final currentIndex = _favoritesOnly ? 2 : 1;
    if (index == currentIndex) return;
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(userName: widget.userName)),
      );
      return;
    }
    if (index == 1) {
      setState(() => _favoritesOnly = false);
      return;
    }
    if (index == 2) {
      setState(() => _favoritesOnly = true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  void _toggleFavorite(ClothingItem item) {
    setState(() {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(isHiddenGem: !_items[index].isHiddenGem);
      }
    });
  }

  Future<void> _openAddClothes() async {
    final added = await Navigator.of(context).push<ClothingItem>(
      MaterialPageRoute(builder: (_) => const AddClothesScreen()),
    );
    if (added != null) {
      setState(() => _items.insert(0, added));
    }
  }

  Future<void> _openDetail(ClothingItem item) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(item: item, originIndex: _favoritesOnly ? 2 : 1),
      ),
    );
    if (result == 'deleted') {
      setState(() => _items.removeWhere((i) => i.id == item.id));
    } else if (result is ClothingItem) {
      setState(() {
        final index = _items.indexWhere((i) => i.id == result.id);
        if (index != -1) _items[index] = result;
      });
    }
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
              ListView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.md,
                  Spacing.md,
                  // Room for the floating nav bar *and* the FAB above it,
                  // so the FAB never clips over the last grid row.
                  150,
                ),
                children: [
                  Text(
                    _favoritesOnly ? 'Favorites' : "${widget.userName}'s Digital Closet",
                    style: textTheme.headlineSmall!.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: Spacing.md),
                  AppSearchBar(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: Spacing.md),
                  FilterChips(
                    options: const ['All', 'Tops', 'Bottoms', 'Dresses'],
                    selected: _category ?? 'All',
                    onSelected: (v) => setState(
                      () => _category = (v == null || v == 'All') ? null : v,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  FilterChips(
                    options: const ['All', ...occasionTags],
                    selected: _occasion ?? 'All',
                    onSelected: (v) => setState(
                      () => _occasion = (v == null || v == 'All') ? null : v,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  if (filtered.isEmpty)
                    EmptyState(
                      message: _favoritesOnly
                          ? 'No favorites yet.\nTap the heart on any item to add it here.'
                          : 'No items found.\nTry a different filter or add something new.',
                      icon: _favoritesOnly
                          ? Icons.favorite_border_rounded
                          : Icons.search_off_rounded,
                      buttonLabel: _favoritesOnly ? null : 'Add Clothes',
                      onButtonPressed: _favoritesOnly ? null : _openAddClothes,
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: Spacing.sm,
                        crossAxisSpacing: Spacing.sm,
                        // A fixed height instead of an aspect ratio — the
                        // card's content (thumb + name + tags) is a set
                        // height regardless of column width, so an aspect
                        // ratio was leaving a big empty gap at the bottom
                        // of every tile and pushing the grid tall enough
                        // for the FAB to clip over the last row.
                        mainAxisExtent: 176,
                      ),
                      itemBuilder: (context, i) {
                        final item = filtered[i];
                        return ClothingCard(
                          name: item.name,
                          tags: [item.category, item.occasion],
                          icon: item.icon,
                          isFavorite: item.isHiddenGem,
                          onFavoriteToggle: () => _toggleFavorite(item),
                          onTap: () => _openDetail(item),
                        );
                      },
                    ),
                ],
              ),
              // Floating "add clothes" action, sitting above the nav bar.
              Positioned(
                right: Spacing.md,
                bottom: 92,
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
              Positioned(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.sm,
                child: BottomNavBar(
                  currentIndex: _favoritesOnly ? 2 : 1,
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