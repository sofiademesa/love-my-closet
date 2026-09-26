import 'package:flutter/material.dart';

import '../data/accessibility_store.dart';
import '../theme.dart';

/// The floating pill nav bar shown on every main screen: Home, Closet,
/// Outfit Builder, Calendar, Profile. The active tab expands into a
/// labeled pill (icon + text); every other tab stays a plain small icon.
/// Favoriting lives on each item tile (and the "Favorites" filter chip on
/// Closet) instead of its own tab.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  // Icons.calendar_month_rounded has no heart, so the Diary tab is drawn as
  // a small composite (calendar + heart) in _NavIcon instead of a single
  // IconData — everything else uses one glyph.
  static const _icons = [
    Icons.home_rounded,
    Icons.checkroom_rounded,
    Icons.auto_awesome_rounded,
    null, // calendar + heart, drawn as a composite
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'Closet', 'Style', 'Diary', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        0,
        Spacing.md,
        3,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppShadows.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < _icons.length; i++)
              _NavIcon(
                icon: _icons[i],
                label: _labels[i],
                selected: i == currentIndex,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.white : AppColors.mutedBrown;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: kMotionDuration(const Duration(milliseconds: 220)),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.buttonPink : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _icon(fg),
            AnimatedSize(
              duration: kMotionDuration(const Duration(milliseconds: 220)),
              curve: Curves.easeOut,
              child: selected
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: fg,
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(width: 0, height: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon(Color fg) {
    if (icon != null) return Icon(icon, color: fg, size: 22);
    // Diary tab: calendar + small heart composite.
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.calendar_month_rounded, color: fg, size: 22),
          Positioned(
            bottom: 3,
            child: Icon(Icons.favorite_rounded, color: fg, size: 8),
          ),
        ],
      ),
    );
  }
}