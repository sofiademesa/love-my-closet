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
class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key, this.userName = 'Sofia'});

  final String userName;

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final _searchController = TextEditingController();
  final List<ClothingItem> _items = List.of(sampleClosetItems);

  String? _category;
  String? _occasion;
  String _query = '';

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
      return matchesCategory && matchesOccasion && matchesQuery;
    }).toList();
  }

  void _goToTab(int index) {
    if (index == 1) return;
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
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
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
                  100, // room for the floating nav bar
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
                      message:
                          'No items found.\nTry a different filter or add something new.',
                      icon: Icons.search_off_rounded,
                      buttonLabel: 'Add Clothes',
                      onButtonPressed: _openAddClothes,
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
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, i) {
                        final item = filtered[i];
                        return ClothingCard(
                          name: item.name,
                          tags: [item.category, item.occasion],
                          icon: item.icon,
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
                child: BottomNavBar(currentIndex: 1, onTap: _goToTab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}