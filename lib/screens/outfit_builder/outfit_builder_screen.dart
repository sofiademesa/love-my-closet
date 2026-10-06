import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../animations/app_motion.dart';

import '../../data/accessibility_store.dart';
import '../../data/closet_store.dart';
import '../../data/filter_icons.dart';
import '../../data/outfit_store.dart';
import '../../models/clothing_item.dart';
import '../../models/outfit.dart';
import '../../services/backend_errors.dart';
import '../../theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/clothing_thumb.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../calendar/calendar_screen.dart';
import '../closet/closet_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'save_look_sheet.dart';

/// Default size of a piece on the board (scale 1). Pieces can be resized
/// from [OutfitPiece.minScale] to [OutfitPiece.maxScale] times this.
const double _kPieceSize = 124;

/// Size of a piece in the closet palette on the left.
const double _kPaletteSize = 88;

/// Outfit Builder: drag pieces from the closet palette onto the board to
/// build a look (Builder tab), or browse previously saved combos and reopen
/// them in the Builder (View Outfits tab).
class OutfitBuilderScreen extends StatefulWidget {
  const OutfitBuilderScreen({
    super.key,
    this.userName = 'Sofia',
    this.editOutfitId,
    this.startWithItemId,
  });

  final String userName;

  /// When set (a closet item id), the Builder opens on the Builder tab with
  /// that piece already placed in the middle of the board, e.g. from
  /// Home's "Style Me" or Hidden Gems' "Wear Again".
  final String? startWithItemId;

  /// When set (a calendar entry id), the Builder opens straight into the
  /// Builder tab with this saved outfit's pieces already on the board, ready
  /// to tweak. Saving updates that same outfit in Supabase instead of
  /// creating a duplicate.
  final String? editOutfitId;

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

  /// The piece showing its remove (x) and resize handles. Tapping empty
  /// board space clears it.
  String? _selectedPieceId;

  // Where a pinch / resize started, so the size follows the fingers.
  double _gestureStartScale = 1;
  Offset _gestureCenter = Offset.zero;

  /// The saved outfit currently loaded on the board for editing, if any
  /// (its calendar entry id). Null means the board holds a brand-new outfit
  /// that hasn't been saved.
  String? _editingOutfitId;

  /// The look being edited (outfits.id), alongside [_editingOutfitId].
  String? _editingLookId;

  bool _saving = false;

  /// The user's real closet items from Supabase.
  List<ClothingItem> get _closetItems => ClosetStore.instance.items;

  /// Ids mid soft-delete: still rendered while their exit fade plays, then
  /// actually removed once it finishes.
  final Set<String> _removingPieceIds = {};
  final Set<String> _removingOutfitIds = {};

  /// Saved outfits read straight from the shared store — the same data the
  /// Calendar reads from — so both stay in sync with no separate data. One
  /// card per look.
  List<SavedOutfit> get _savedOutfits => OutfitStore.instance.builderOutfits;

  @override
  void initState() {
    super.initState();
    OutfitStore.instance.addListener(_onStoreChanged);
    ClosetStore.instance.addListener(_onStoreChanged);
    final editId = widget.editOutfitId;
    if (editId != null) {
      final outfit = OutfitStore.instance.byId(editId);
      if (outfit != null) {
        _boardPieces.addAll(outfit.pieces.map((p) => p.copy()));
        _editingOutfitId = outfit.id;
        _editingLookId = outfit.outfitId;
      }
    }
    final startId = widget.startWithItemId;
    if (startId != null && editId == null) {
      // After the first frame, once the board has its real size, so the
      // piece can be centered on it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final item = ClosetStore.instance.byId(startId);
        if (item == null) return;
        final board = _boardSize;
        _addPiece(
          item,
          at: Offset((board.width - _kPieceSize) / 2, (board.height - _kPieceSize) / 2),
        );
      });
    }
  }

  @override
  void dispose() {
    OutfitStore.instance.removeListener(_onStoreChanged);
    ClosetStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  List<ClothingItem> get _palette {
    if (_category == null) return _closetItems;
    if (_category == _kFavorites) {
      return _closetItems.where((i) => i.isFavorite).toList();
    }
    return _closetItems.where((i) => i.category == _category).toList();
  }

  void _goToTab(int index) {
    const currentIndex = 2;
    if (index == currentIndex) return;
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        AppPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        AppPageRoute(builder: (_) => const ClosetScreen()),
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

  Size get _boardSize {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size ?? const Size(240, 340);
  }

  static double _sizeOf(OutfitPiece piece) => _kPieceSize * piece.scale;

  /// Keeps a piece of the given [size] fully on the board.
  Offset _clamp(Offset raw, Size boardSize, {double size = _kPieceSize}) {
    final maxX = (boardSize.width - size).clamp(0.0, double.infinity).toDouble();
    final maxY = (boardSize.height - size).clamp(0.0, double.infinity).toDouble();
    final dx = raw.dx.clamp(0.0, maxX).toDouble();
    final dy = raw.dy.clamp(0.0, maxY).toDouble();
    return Offset(dx, dy);
  }

  /// Largest scale that still fits on the board.
  double _maxScaleFor(Size boardSize) {
    final fit = boardSize.shortestSide / _kPieceSize;
    return fit.clamp(OutfitPiece.minScale, OutfitPiece.maxScale).toDouble();
  }

  /// Resizes [piece] to [scale] keeping [center] where it is (as far as the
  /// board edges allow).
  void _applyScale(OutfitPiece piece, double scale, Offset center) {
    final boardSize = _boardSize;
    final s = scale.clamp(OutfitPiece.minScale, _maxScaleFor(boardSize)).toDouble();
    final size = _kPieceSize * s;
    piece
      ..scale = s
      ..offset = _clamp(center - Offset(size / 2, size / 2), boardSize, size: size);
  }

  void _addPiece(ClothingItem item, {Offset? at}) {
    final boardSize = _boardSize;
    final fallback = Offset(
      16.0 + (_boardPieces.length % 4) * 22,
      16.0 + (_boardPieces.length % 4) * 22,
    );
    final piece = OutfitPiece(
      id: 'piece_${_pieceSeq++}',
      item: item,
      offset: _clamp(at ?? fallback, boardSize),
    );
    setState(() {
      _boardPieces.add(piece);
      _selectedPieceId = piece.id;
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

  /// Selects [piece] and draws it on top of the others.
  void _bringToFront(OutfitPiece piece) {
    setState(() {
      _boardPieces.remove(piece);
      _boardPieces.add(piece);
      _selectedPieceId = piece.id;
    });
  }

  // One finger moves the piece; two fingers (pinch) also resize it.
  void _onPieceGestureStart(OutfitPiece piece) {
    _bringToFront(piece);
    _gestureStartScale = piece.scale;
    final size = _sizeOf(piece);
    _gestureCenter = piece.offset + Offset(size / 2, size / 2);
  }

  void _onPieceGestureUpdate(OutfitPiece piece, ScaleUpdateDetails d) {
    _gestureCenter += d.focalPointDelta;
    setState(() {
      _applyScale(
        piece,
        d.pointerCount > 1 ? _gestureStartScale * d.scale : piece.scale,
        _gestureCenter,
      );
    });
    // Stay in step with where the piece actually ended up at an edge.
    final size = _sizeOf(piece);
    _gestureCenter = piece.offset + Offset(size / 2, size / 2);
  }

  // The corner handle resizes with one finger or a mouse; the top-left
  // corner stays put.
  void _onHandleDrag(OutfitPiece piece, DragUpdateDetails d) {
    final boardSize = _boardSize;
    final grow = (d.delta.dx + d.delta.dy) / 2;
    final maxByRoom = [
      boardSize.width - piece.offset.dx,
      boardSize.height - piece.offset.dy,
    ].reduce((a, b) => a < b ? a : b) / _kPieceSize;
    final s = ((_sizeOf(piece) + grow) / _kPieceSize)
        .clamp(OutfitPiece.minScale, maxByRoom.clamp(OutfitPiece.minScale, OutfitPiece.maxScale))
        .toDouble();
    setState(() => piece.scale = s);
  }

  void _removePiece(OutfitPiece piece) {
    setState(() {
      _removingPieceIds.add(piece.id);
      if (_selectedPieceId == piece.id) _selectedPieceId = null;
    });
  }

  void _finishRemovePiece(OutfitPiece piece) {
    if (!mounted) return;
    setState(() {
      _boardPieces.remove(piece);
      _removingPieceIds.remove(piece.id);
    });
  }

  /// Clears the board, with a few seconds to undo it.
  void _clearBoard() {
    final previous = [
      for (final p in _boardPieces)
        if (!_removingPieceIds.contains(p.id)) p.copy(),
    ];
    final previousEntryId = _editingOutfitId;
    final previousLookId = _editingLookId;
    setState(() {
      _removingPieceIds.clear();
      _boardPieces.clear();
      _selectedPieceId = null;
      _editingOutfitId = null;
      _editingLookId = null;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Outfit cleared'),
          duration: const Duration(seconds: 5),
          // A SnackBar with an action stays on screen forever by default in
          // newer Flutter; persist: false restores the 5-second auto-dismiss.
          persist: false,
          showCloseIcon: true,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _removingPieceIds.clear();
                _boardPieces
                  ..clear()
                  ..addAll(previous);
                _editingOutfitId = previousEntryId;
                _editingLookId = previousLookId;
              });
            },
          ),
        ),
      );
  }

  Future<void> _openSaveSheet() async {
    if (_saving) return;
    if (_boardPieces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a few pieces to the board first.')),
      );
      return;
    }
    final editing = _editingOutfitId == null && _editingLookId == null
        ? null
        : (OutfitStore.instance.byId(_editingOutfitId ?? '') ??
            OutfitStore.instance.builderOutfits
                .where((o) => o.outfitId == _editingLookId)
                .firstOrNull);
    final result = await showSaveLookSheet(
      context,
      initialName: editing?.name ?? '',
      initialDate: editing?.date,
    );
    if (result == null || !mounted) return;
    final pieces = _boardPieces
        .where((p) => !_removingPieceIds.contains(p.id))
        .map((p) => p.copy())
        .toList();
    setState(() => _saving = true);
    try {
      // Outfit + pieces + calendar date saved together in Supabase.
      final saved = await OutfitStore.instance.saveFromBuilder(
        editingEntryId: editing?.id,
        editingOutfitId: editing?.outfitId,
        name: result.name,
        date: result.date,
        pieces: pieces,
      );
      if (!mounted) return;
      setState(() {
        _editingOutfitId = saved.id;
        _editingLookId = saved.outfitId;
        _saving = false;
        _tab = 1;
      });
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      _showError(e);
    }
  }

  void _loadSavedOutfit(SavedOutfit outfit) {
    setState(() {
      _removingPieceIds.clear();
      _boardPieces
        ..clear()
        ..addAll(outfit.pieces.map((p) => p.copy()));
      _selectedPieceId = null;
      _editingOutfitId = outfit.id;
      _editingLookId = outfit.outfitId;
      _tab = 0;
    });
  }

  void _deleteSavedOutfit(SavedOutfit outfit) {
    setState(() => _removingOutfitIds.add(outfit.outfitId));
  }

  Future<void> _finishDeleteSavedOutfit(SavedOutfit outfit) async {
    try {
      await OutfitStore.instance.removeOutfit(outfit.outfitId);
      if (mounted && _editingLookId == outfit.outfitId) {
        setState(() {
          _editingOutfitId = null;
          _editingLookId = null;
        });
      }
    } catch (e) {
      _showError(e);
    }
    if (mounted) setState(() => _removingOutfitIds.remove(outfit.outfitId));
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
                      'Tap or drag pieces onto the board to see them together',
                      style: textTheme.bodyMedium!.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: Spacing.md),
                    _TabToggle(
                      index: _tab,
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: Spacing.md),
                    Expanded(
                      child: AppSectionSwitcher(
                        child: KeyedSubtree(
                          key: ValueKey(_tab),
                          child: _tab == 0
                              ? _buildBuilder(textTheme)
                              : _buildSavedOutfits(textTheme),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.xs,
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
    final onBoard = {
      for (final p in _boardPieces)
        if (!_removingPieceIds.contains(p.id)) p.item.id,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterChips(
          options: const [_kFavorites, ...clothingCategories],
          icons: categoryFilterIcons,
          selected: _category,
          onSelected: (v) => setState(() => _category = v),
        ),
        const SizedBox(height: Spacing.sm),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _kPaletteSize,
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
                          onBoard: onBoard.contains(palette[i].id),
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
              child: PrimaryButton(
                label: _saving
                    ? 'Saving…'
                    : (_editingOutfitId == null && _editingLookId == null
                        ? 'Save Outfit'
                        : 'Update Outfit'),
                onPressed: _saving ? null : _openSaveSheet,
              ),
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
          // Faint dots make the board read as a canvas to arrange on.
          child: DotPattern(
            backgroundColor: AppColors.white,
            dotColor: AppColors.softPink.withValues(alpha: 0.18),
            spacing: 16,
            dotRadius: 1.2,
            child: _boardPieces.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: Text(
                        highlighted ? 'Drop it!' : 'Tap or drag pieces here\nto build your outfit',
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
                    children: [
                      // Tapping empty board space deselects.
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _selectedPieceId = null),
                        ),
                      ),
                      Positioned(
                        left: Spacing.sm,
                        right: Spacing.sm,
                        bottom: Spacing.sm,
                        child: IgnorePointer(
                          child: Text(
                            _selectedPieceId == null
                                ? 'Tap a piece to move, resize or remove it'
                                : 'Pinch or drag the corner to resize',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 11,
                              color: AppColors.mutedBrown.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      for (final piece in _boardPieces) _boardPieceView(piece),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Room around each piece for its remove (x) and resize handles, so they
  /// sit inside the piece's bounds and stay fully tappable.
  static const double _kHandleRoom = 18;

  Widget _boardPieceView(OutfitPiece piece) {
    final size = _sizeOf(piece);
    final selected = piece.id == _selectedPieceId;
    const room = _kHandleRoom;
    return Positioned(
      key: ValueKey(piece.id),
      left: piece.offset.dx - room,
      top: piece.offset.dy - room,
      child: PopIn(
        child: FadeScaleOut(
          removing: _removingPieceIds.contains(piece.id),
          onExited: () => _finishRemovePiece(piece),
          child: SizedBox(
            width: size + room * 2,
            height: size + room * 2,
            child: Stack(
              children: [
                Positioned(
                  left: room,
                  top: room,
                  child: GestureDetector(
                    onTap: () => _bringToFront(piece),
                    // One finger moves it; a pinch also resizes it.
                    onScaleStart: (_) => _onPieceGestureStart(piece),
                    onScaleUpdate: (d) => _onPieceGestureUpdate(piece, d),
                    // Just the garment, no tile, so pieces overlap like a
                    // flat lay. A thin outline shows which one is selected.
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.field),
                        border: Border.all(
                          color: selected
                              ? AppColors.buttonPink.withValues(alpha: 0.7)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: _BoardPieceImage(item: piece.item, size: size),
                    ),
                  ),
                ),
                if (selected) ...[
                  // Centered on the top-right corner.
                  Positioned(
                    top: room - 11,
                    right: room - 11,
                    child: _RemoveDot(onTap: () => _removePiece(piece)),
                  ),
                  // Centered on the bottom-right corner.
                  Positioned(
                    right: room - 18,
                    bottom: room - 18,
                    child: GestureDetector(
                      onPanUpdate: (d) => _onHandleDrag(piece, d),
                      child: const _ResizeHandle(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedOutfits(TextTheme textTheme) {
    if (_savedOutfits.isEmpty) {
      return const Center(
        child: EmptyState(
          message: 'No saved outfits yet.\nBuild one on the Builder tab and save it here.',
          icon: Icons.dashboard_customize_rounded,
        ),
      );
    }
    return ListView.separated(
      itemCount: _savedOutfits.length,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
      itemBuilder: (context, i) {
        final outfit = _savedOutfits[i];
        return FadeScaleOut(
          key: ValueKey(outfit.outfitId),
          removing: _removingOutfitIds.contains(outfit.outfitId),
          onExited: () => _finishDeleteSavedOutfit(outfit),
          child: FadeSlideIn(
            delay: staggerDelay(i, stepMs: 40, maxMs: 200),
            child: PressableScale(
              scale: 0.98,
              child: _SavedOutfitCard(
                outfit: outfit,
                onTap: () => _loadSavedOutfit(outfit),
                onDelete: () => _deleteSavedOutfit(outfit),
              ),
            ),
          ),
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
        duration: kMotionDuration(const Duration(milliseconds: 150)),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(colors: [AppColors.softPink, AppColors.buttonPink])
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
  const _PaletteThumb({
    required this.item,
    required this.onTap,
    this.onBoard = false,
  });

  final ClothingItem item;
  final VoidCallback onTap;

  /// Already placed on the board: shows a small check.
  final bool onBoard;

  @override
  Widget build(BuildContext context) {
    final thumb = Stack(
      clipBehavior: Clip.none,
      children: [
        ClothingThumb(
          icon: item.icon,
          size: _kPaletteSize,
          iconSize: 36,
          imageUrl: item.imageUrl,
          backgroundColorName: item.color,
        ),
        if (onBoard)
          Positioned(
            top: 4,
            right: 4,
            child: Semantics(
              label: 'On the board',
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.buttonPink,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
                child: Icon(Icons.check_rounded, size: 13, color: AppColors.white),
              ),
            ),
          ),
      ],
    );

    return PressableScale(
      scale: 0.94,
      child: GestureDetector(
        onTap: onTap,
        child: Draggable<ClothingItem>(
          data: item,
          // The drag position is the finger itself; the preview is shifted
          // to sit centered under it, and the board drops the piece centered
          // on the same point, so it lands exactly where the preview was.
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: Transform.translate(
            offset: const Offset(-_kPieceSize / 2, -_kPieceSize / 2),
            child: Material(
              color: Colors.transparent,
              // Looks exactly like it will on the board.
              child: _BoardPieceImage(item: item, size: _kPieceSize),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: thumb),
          child: thumb,
        ),
      ),
    );
  }
}

/// A piece as it appears on the board: the transparent cutout with a soft
/// shadow under the garment itself. Items without a photo (or whose photo
/// can't load) fall back to their colored tile.
class _BoardPieceImage extends StatelessWidget {
  const _BoardPieceImage({required this.item, required this.size});

  final ClothingItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    final tile = ClothingThumb(
      icon: item.icon,
      size: size,
      iconSize: size * 0.36,
      backgroundColorName: item.color,
    );
    if (url == null) return tile;

    Widget image({Color? tint}) => Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          color: tint,
          colorBlendMode: tint == null ? null : BlendMode.srcIn,
          // The shadow copy just disappears on error; the main copy shows
          // the tile instead.
          errorBuilder: (context, error, stack) =>
              tint == null ? tile : const SizedBox.shrink(),
        );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, size * 0.03),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: image(tint: Colors.black.withValues(alpha: 0.18)),
              ),
            ),
          ),
          image(),
        ],
      ),
    );
  }
}

/// Bottom-right grip on the selected piece: drag it to resize.
class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle();

  @override
  Widget build(BuildContext context) {
    // Bigger invisible touch area around the visible dot.
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.buttonPink, width: 1.5),
          boxShadow: AppShadows.surface,
        ),
        child: Icon(Icons.open_in_full_rounded, size: 12, color: AppColors.buttonPink),
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
        child: Icon(Icons.close_rounded, size: 13, color: AppColors.errorRed),
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
                            child: ClothingThumb(
                              icon: shown[i].item.icon,
                              size: 36,
                              iconSize: 16,
                              imageUrl: shown[i].item.imageUrl,
                              backgroundColorName: shown[i].item.color,
                            ),
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
                  child: Padding(
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