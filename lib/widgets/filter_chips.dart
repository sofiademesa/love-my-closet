import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/accessibility_store.dart';
import '../theme.dart';

/// Builds a chip's leading icon at the given [size], tinted [color] —
/// matching the chip's active (white) or inactive (muted brown) state.
typedef ChipIconBuilder = Widget Function(
  BuildContext context,
  double size,
  Color color,
);

/// The Material default only lets touch, stylus and trackpad drag a
/// scroll view — a mouse click-drag does nothing. This row is meant to be
/// scrollable on desktop/web too (e.g. presenting on a laptop with no
/// touchscreen), so mouse is added to the draggable devices.
class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

/// Horizontally-scrolling row of single-select pills. Used for the category
/// and occasion filters on Closet and Hidden Gems, and for the Occasion Tags
/// picker on Add Clothes / Edit Item.
///
/// Scrollable with a mouse click-drag or a mouse/trackpad wheel, not just a
/// touch swipe.
class FilterChips extends StatefulWidget {
  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.icons,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  /// Optional leading icon per option label — e.g. a heart on "Favorites".
  /// Options with no entry here get a plain text chip. Values are builders
  /// (rather than plain IconData) so a chip's icon can be a Material glyph
  /// or a custom asset — either way it's built at the chip's own icon size
  /// and colored to match the chip's active/inactive state.
  final Map<String, ChipIconBuilder>? icons;

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  final _scrollController = ScrollController();

  // Lets a plain vertical mouse-wheel scroll this row sideways, since a
  // wheel has no horizontal axis of its own on most mice.
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    _scrollController.jumpTo(
      (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: ScrollConfiguration(
        behavior: _MouseDragScrollBehavior(),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final option in widget.options) ...[
                _Chip(
                  label: option,
                  icon: widget.icons?[option],
                  active: option == widget.selected,
                  onTap: () => widget.onSelected(
                    option == widget.selected ? null : option,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  final String label;
  final ChipIconBuilder? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: kMotionDuration(const Duration(milliseconds: 150)),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    colors: [AppColors.softPink, AppColors.buttonPink],
                  )
                : null,
            color: active ? null : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? Colors.transparent : AppColors.blush,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!(
                  context,
                  14,
                  active ? AppColors.white : AppColors.mutedBrown,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.white : AppColors.mutedBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}