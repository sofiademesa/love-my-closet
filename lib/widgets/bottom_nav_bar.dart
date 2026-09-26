import 'package:flutter/material.dart';

import '../data/accessibility_store.dart';
import '../theme.dart';

/// The floating pill nav bar shown on every main screen: Home, Closet,
/// Outfit Builder, Calendar, Profile. Favoriting lives on each item tile
/// (and the "Favorites" filter chip on Closet) instead of its own tab.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _icons = [
    Icons.home_rounded,
    Icons.checkroom_rounded,
    Icons.dashboard_customize_rounded,
    Icons.calendar_month_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.blush, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < _icons.length; i++)
            _NavIcon(
              icon: _icons[i],
              selected: i == currentIndex,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              AnimatedContainer(
                duration: kMotionDuration(const Duration(milliseconds: 200)),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.buttonPink.withValues(alpha: 0.12)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.buttonPink : AppColors.mutedBrown,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: kMotionDuration(const Duration(milliseconds: 200)),
                width: selected ? 16 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.buttonPink,
                  borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}