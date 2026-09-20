import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/heart_avatar.dart';
import 'onboarding_slide.dart';

/// Onboarding 2: the avatar card in a carousel + "love your closet" headline.
class Onboarding2Page extends StatelessWidget {
  const Onboarding2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      headline: 'Maybe it’s time to love your closet',
      illustration: (width, height) =>
          _AvatarCarousel(cardWidth: width, cardHeight: height),
    );
  }
}

class _AvatarCarousel extends StatelessWidget {
  const _AvatarCarousel({required this.cardWidth, required this.cardHeight});

  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final panelWidth = w * 0.09;
          final panelHeight = cardHeight * 1.13;
          final panelTop = (cardHeight - panelHeight) / 2;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Side panels peeking in from the edges (carousel neighbours).
              Positioned(
                left: w * 0.09,
                top: panelTop,
                width: panelWidth,
                height: panelHeight,
                child: const _SidePanel(outerOnLeft: true),
              ),
              Positioned(
                right: w * 0.09,
                top: panelTop,
                width: panelWidth,
                height: panelHeight,
                child: const _SidePanel(outerOnLeft: false),
              ),
              // Centre card with the avatar.
              Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.blush, width: 3),
                ),
                child: Center(child: HeartAvatar(width: cardWidth * 0.8)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.outerOnLeft});

  final bool outerOnLeft;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PanelPainter(outerOnLeft: outerOnLeft),
      child: Center(
        child: Icon(
          outerOnLeft ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          color: AppColors.cream,
          size: 18,
        ),
      ),
    );
  }
}

/// A trapezoid that is taller on its outer edge, like a door swung open.
class _PanelPainter extends CustomPainter {
  _PanelPainter({required this.outerOnLeft});

  final bool outerOnLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.height * 0.09;
    final path = Path();
    if (outerOnLeft) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, inset)
        ..lineTo(size.width, size.height - inset)
        ..lineTo(0, size.height);
    } else {
      path
        ..moveTo(size.width, 0)
        ..lineTo(0, inset)
        ..lineTo(0, size.height - inset)
        ..lineTo(size.width, size.height);
    }
    path.close();

    final fill = Paint()..color = AppColors.buttonPink;
    final round = Paint()
      ..color = AppColors.buttonPink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, fill);
    canvas.drawPath(path, round);
  }

  @override
  bool shouldRepaint(_PanelPainter oldDelegate) =>
      oldDelegate.outerOnLeft != outerOnLeft;
}