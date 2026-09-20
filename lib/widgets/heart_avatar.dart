import 'package:flutter/material.dart';

/// The Love My Closet logo
class HeartAvatar extends StatelessWidget {
  const HeartAvatar({super.key, this.width = 150});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/heart_avatar.png',
      width: width,
      fit: BoxFit.contain,
      semanticLabel: 'Love My Closet avatar',
    );
  }
}