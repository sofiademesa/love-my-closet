import 'package:flutter/material.dart';

/// The Love My Closet logo
class HeartAvatar extends StatelessWidget {
  const HeartAvatar({super.key, this.width = 150, this.small = false});

  final double width;

  /// Use the pre-shrunk, cleaned-up logo for small spots (under ~100px) so
  /// the line art stays crisp instead of getting jagged when downscaled.
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      small
          ? 'assets/images/heart_avatar_small.png'
          : 'assets/images/heart_avatar.png',
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      semanticLabel: 'Love My Closet avatar',
    );
  }
}