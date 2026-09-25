import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../models/outfit.dart';
import '../../theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/clothing_thumb.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../closet/closet_screen.dart';
import '../home/home_screen.dart';
import 'save_look_sheet.dart';

/// Diameter of a piece once it's on the board.
const double _kPieceSize = 76;

/// Outfit Builder: drag pieces from the closet palette onto the board to
/// build a look (Builder tab), or browse previously saved combos and reopen
/// them in the Builder (View Outfits tab).
class OutfitBuilderScreen extends StatefulWidget {
  const OutfitBuilderScreen({
    super.key,
    this.userName = 'Sofia',
    this.closetItems = sampleClosetItems,
  });

  final String userName;
  final List<ClothingItem> closetItems;

  @override
  State<OutfitBuilderScreen> createState() => _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends State<OutfitBuilderScreen> {
  static const _kFavorites = 'Favorites';

  final _boardKey = GlobalKey();
  int _tab = 0; // 0 = Builder, 1 = View Outfits
  String? _category;
  int _pieceSeq = 0;

  final List<OutfitPiece> _boardPieces = [];
  final List<SavedOutfit> _savedOutfits = [];

  List<ClothingItem> get _palette {
    if (_category == null) return widget.closetItems;
    if (_category == _kFavorites) {
      return widget.closetItems.where((i) => i.isHiddenGem).toList();
    }
    return widget.closetItems.where((i) => i.category == _category).toList();
  }

  void _goToTab(int index) {
    const currentIndex = 2;
    if (index == currentIndex) return;
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(userName: widget.userName)),
      );
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ClosetScreen(userName: widget.userName)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  Offset _clamp(Offset raw, Size boardSize) {
    final maxX = (boardSize.width - _kPieceSize).clamp(0.0, double.infinity).toDouble();
    final maxY = (boardSize.height - _kPieceSize).clamp(0.0, double.infinity).toDouble();
    final dx = raw.dx.clamp(0.0, maxX).toDouble();
    final dy = raw.dy.clamp(0.0, maxY).toDouble();
    return Offset(dx, dy);
  }

  void _addPiece(ClothingItem item, {Offset? at}) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    final boardSize = box?.size ?? const Size(240, 340);
    final fallback = Offset(
      16.0 + (_boardPieces.length % 4) * 22,
      16.0 + (_boardPieces.length % 4) * 22,
    );
    setState(() {
      _boardPieces.add(
        OutfitPiece(
          id: 'piece_${_pieceSeq++}',
          item: item,
          offset: _clamp(at ?? fallback, boardSize),
        ),
      );
    });
  }

  void _dropPiece(ClothingItem item, Offset globalOffset) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      _addPiece(item);
      return;
    }
    final local = box.globalToLocal(globalOffset) -
        const Offset(_kPieceSize / 2, _kPieceSize / 2);
    _addPiece(item, at: local);
  }

  void _movePiece(OutfitPiece piece, Offset delta) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    final boardSize = box?.size ?? const Size(240, 340);
    setState(() => piece.offset = _clamp(piece.offset + delta, boardSize));
  }

  void _bringToFront(OutfitPiece piece) {
    setState(() {
      _boardPieces.remove(piece);
      _boardPieces.add(piece);
    });
  }

  void _removePiece(OutfitPiece piece) {
    setState(() => _boardPieces.remove(piece));
  }

  void _clearBoard() => setState(_boardPieces.clear);

  Future<void> _openSaveSheet() async {
    if (_boardPieces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drag a few pieces onto the board first.')),
      );
      return;
    }
    final result = await showSaveLookSheet(context);
    if (result == null || !mounted) return;
    setState(() {
      _savedOutfits.insert(
        0,
        SavedOutfit(
          id: 'outfit_${DateTime.now().microsecondsSinceEpoch}',
          name: result.name,
          date: result.date,
          pieces: _boardPieces.map((p) => p.copy()).toList(),
        ),
      );
      _tab = 1;
    });
  }

  void _loadSavedOutfit(SavedOutfit outfit) {
    setState(() {
      _boardPieces
        ..clear()
        ..addAll(outfit.pieces.map((p) => p.copy()));
      _tab = 0;
    });
  }

  void _deleteSavedOutfit(SavedOutfit outfit) {
    setState(() => _savedOutfits.removeWhere((o) => o.id == outfit.id));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Outfit Builder', style: textTheme.headlineSmall!.copyWith(fontSize: 22)),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Drag pieces onto the board to see them together',
                      style: textTheme.bodyMedium!.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: Spacing.md),
                    _TabToggle(
                      index: _tab,
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: Spacing.md),
                    Expanded(
                      child: _tab == 0 ? _buildBuilder(textTheme) : _buildSavedOutfits(textTheme),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.sm,
                child: BottomNavBar(currentIndex: 2, onTap: _goToTab),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuilder(TextTheme textTheme) {
    final palette = _palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 76,
                child: palette.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: Spacing.lg),
                        child: Text(
                          'No items',
                          style: textTheme.labelSmall,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: palette.length,
                        separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
                        itemBuilder: (context, i) => _PaletteThumb(
                          item: palette[i],
                          onTap: () => _addPiece(palette[i]),
                        ),
                      ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(child: _board()),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Clear Outfit',
                onPressed: _boardPieces.isEmpty ? null : _clearBoard,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: PrimaryButton(label: 'Save Outfit', onPressed: _openSaveSheet),
            ),
          ],
        ),
      ],
    );
  }

  Widget _board() {
    return DragTarget<ClothingItem>(
      onAcceptWithDetails: (details) => _dropPiece(details.data, details.offset),
      builder: (context, candidates, rejected) {
        final highlighted = candidates.isNotEmpty;
        return Container(
          key: _boardKey,
          clipBehavior: Clip.hardEdge,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: highlighted ? AppColors.buttonPink : AppColors.blush,
              width: highlighted ? 2 : 1.5,
            ),
            boxShadow: AppShadows.surface,
          ),
          child: _boardPieces.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Text(
                      highlighted ? 'Drop it!' : 'Drag pieces here\nto build your outfit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 13,
                        color: AppColors.mutedBrown.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: [for (final piece in _boardPieces) _boardPieceView(piece)],
                ),
        );
      },
    );
  }

  Widget _boardPieceView(OutfitPiece piece) {
    return Positioned(
      key: ValueKey(piece.id),
      left: piece.offset.dx,
      top: piece.offset.dy,
      child: GestureDetector(
        onPanStart: (_) => _bringToFront(piece),
        onPanUpdate: (details) => _movePiece(piece, details.delta),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.field),
                boxShadow: AppShadows.surface,
              ),
              child: ClothingThumb(icon: piece.item.icon, size: _kPieceSize, iconSize: 32),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: _RemoveDot(onTap: () => _removePiece(piece)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedOutfits(TextTheme textTheme) {
    if (_savedOutfits.isEmpty) {
      return const EmptyState(
        message: 'No saved outfits yet.\nBuild one on the Builder tab and save it here.',
        icon: Icons.dashboard_customize_rounded,
      );
    }
    return ListView.separated(
      itemCount: _savedOutfits.length,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
      itemBuilder: (context, i) {
        final outfit = _savedOutfits[i];
        return _SavedOutfitCard(
          outfit: outfit,
          onTap: () => _loadSavedOutfit(outfit),
          onDelete: () => _deleteSavedOutfit(outfit),
        );
      },
    );
  }
}

/// The pink "Builder" / white "View Outfits" segmented control from the
/// mockup.
class _TabToggle extends StatelessWidget {
  const _TabToggle({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blush, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(child: _segment(context, 'Builder', 0)),
          Expanded(child: _segment(context, 'View Outfits', 1)),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, String label, int i) {
    final active = i == index;
    return GestureDetector(
      onTap: () => onChanged(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [AppColors.softPink, AppColors.buttonPink])
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: active ? AppColors.white : AppColors.mutedBrown,
          ),
        ),
      ),
    );
  }
}

/// A draggable closet item in the left-hand palette. Tap to add it straight
/// to the board, or drag it onto the board to place it exactly.
class _PaletteThumb extends StatelessWidget {
  const _PaletteThumb({required this.item, required this.onTap});

  final ClothingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumb = ClothingThumb(icon: item.icon, size: 64, iconSize: 28);

    return GestureDetector(
      onTap: onTap,
      child: Draggable<ClothingItem>(
        data: item,
        feedback: Material(
          color: Colors.transparent,
          child: ClothingThumb(icon: item.icon, size: 64, iconSize: 28),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: thumb),
        child: thumb,
      ),
    );
  }
}

class _RemoveDot extends StatelessWidget {
  const _RemoveDot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.blush, width: 1.5),
          boxShadow: AppShadows.surface,
        ),
        child: const Icon(Icons.close_rounded, size: 13, color: AppColors.errorRed),
      ),
    );
  }
}

/// A saved outfit combo on the "View Outfits" tab: a stack of its piece
/// thumbnails, its name and date, and a delete "x".
class _SavedOutfitCard extends StatelessWidget {
  const _SavedOutfitCard({
    required this.outfit,
    required this.onTap,
    required this.onDelete,
  });

  final SavedOutfit outfit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final shown = outfit.pieces.take(3).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.blush, width: 1.5),
        boxShadow: AppShadows.surface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 40 + 22.0 * shown.length,
                  height: 44,
                  child: Stack(
                    children: [
                      for (var i = 0; i < shown.length; i++)
                        Positioned(
                          left: i * 22.0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.field + 2),
                            ),
                            child: ClothingThumb(icon: shown[i].item.icon, size: 36, iconSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outfit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineSmall!.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${outfit.date.month.toString().padLeft(2, '0')}/'
                        '${outfit.date.day.toString().padLeft(2, '0')}/'
                        '${outfit.date.year}',
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, size: 18, color: AppColors.mutedBrown),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}