import 'package:flutter/material.dart';

import '../theme.dart';

/// Small circular back button used on the Closet's detail and form screens
/// (Clothing Item, Edit Item, Add Clothes, Adding Item Photo).
class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.blush, width: 1.5),
          boxShadow: AppShadows.surface,
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.mutedBrown,
          size: 18,
        ),
      ),
    );
  }
}