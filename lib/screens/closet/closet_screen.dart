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
  final List<ClothingItem> _items = List.of(sampleClosetItems);

  String? _category;
  String? _occasion;
  String _query = '';

  bool get _favoritesOnly => _category == _kFavorites;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClothingItem> get _filtered {
    return _items.where((item) {
      final matchesCategory = _category == null ||
          _category == _kFavorites ||
          item.category == _category;
      final matchesOccasion = _occasion == null || item.occasion == _occasion;
      final matchesQuery =
          _query.isEmpty || item.name.toLowerCase().contains(_query.toLowerCase());
      final matchesFavorite = !_favoritesOnly || item.isHiddenGem;
      return matchesCategory && matchesOccasion && matchesQuery && matchesFavorite;
    }).toList();
  }

  void _goToTab(int index) {
    const currentIndex = 1;
    if (index == currentIndex) return;
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(userName: widget.userName)),
      );
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
        builder: (_) => ItemDetailScreen(item: item, originIndex: 1),
      ),
    );
    _applyEditResult(item, result);
  }

  Future<void> _openEdit(ClothingItem item) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditItemScreen(item: item)),
    );
    _applyEditResult(item, result);
  }

  void _applyEditResult(ClothingItem item, Object? result) {
    if (result == 'deleted') {
      setState(() => _items.removeWhere((i) => i.id == item.id));
    } else if (result is ClothingItem) {
      setState(() {
        final index = _items.indexWhere((i) => i.id == result.id);
        if (index != -1) _items[index] = result;
      });
    }
  }

  Future<void> _confirmDelete(ClothingItem item) async {
    final confirmed = await showDialog<bool>(
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
      setState(() => _items.removeWhere((i) => i.id == item.id));
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
                    "${widget.userName}'s Digital Closet",
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
                    icons: const {
                      _kFavorites: Icons.favorite_rounded,
                      'Tops': Icons.checkroom_rounded,
                      'Bottoms': Icons.dry_cleaning_rounded,
                      'Outerwear': Icons.ac_unit_rounded,
                      'Accessories': Icons.watch_rounded,
                    },
                    selected: _category,
                    onSelected: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: Spacing.sm),
                  FilterChips(
                    options: const [_kAllOccasions, ...occasionTags],
                    selected: _occasion ?? _kAllOccasions,
                    onSelected: (v) => setState(
                      () => _occasion = (v == null || v == _kAllOccasions) ? null : v,
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
                        // card's content (thumb + name + tags + edit/delete)
                        // is a set height regardless of column width, so an
                        // aspect ratio was leaving a big empty gap at the
                        // bottom of every tile and pushing the grid tall
                        // enough for the FAB to clip over the last row.
                        // (Kept generous — 268, not 240 — so the card has
                        // headroom on narrower phones/larger text scales
                        // instead of overflowing by a hair at the bottom.)
                        mainAxisExtent: 268,
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
                          onEdit: () => _openEdit(item),
                          onDelete: () => _confirmDelete(item),
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