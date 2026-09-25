import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import 'onboarding_slide.dart';

/// Onboarding 1: closet doors + "nothing to wear" headline.
///
/// [openProgress] is driven by the enclosing [PageController] (0 while this
/// slide is fully in view, 1 once the user has fully swiped across to
/// Onboarding 2). The closet doors use it to swing open on their hinges and
/// reveal a peek of the closet interior underneath, so the transition to
/// Onboarding 2 reads as "the closet opening" rather than a plain slide.
class Onboarding1Page extends StatelessWidget {
  const Onboarding1Page({super.key, this.openProgress = 0});

  final double openProgress;

  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      eyebrow: 'SOUND FAMILIAR?',
      headline: 'When \u2018nothing to wear\u2019 is your daily problem...',
      illustration: (width, height) => _ClosetDoors(
        width: width,
        height: height,
        openProgress: openProgress,
      ),
    );
  }
}

class _ClosetDoors extends StatelessWidget {
  const _ClosetDoors({
    required this.width,
    required this.height,
    required this.openProgress,
  });

  final double width;
  final double height;

  /// 0 = closed, 1 = fully open.
  final double openProgress;

  // How far each door swings open, in radians, at full progress. Kept just
  // shy of a right angle so the doors read as "open" rather than vanishing
  // edge-on.
  static const double _maxSwing = math.pi * 0.42;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);

    // The doors themselves stay 1:1 with the finger/scroll for a direct,
    // grabbable feel. The push-in zoom is a secondary, eased embellishment
    // on top, so it reads as the "camera" drifting closer as the doors part
    // rather than a linear resize.
    final zoom = Curves.easeOut.transform(openProgress);

    return Semantics(
      label: openProgress > 0.5 ? 'Open closet doors' : 'Closed closet doors',
      child: SizedBox(
        width: width,
        height: height,
        child: Transform.scale(
          scale: 1 + zoom * 0.18,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              // Closet interior, revealed as the doors swing open.
              ClipRRect(
                borderRadius: radius,
                child: _ClosetInterior(reveal: openProgress),
              ),
              // The two doors, hinged on their outer edges.
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: _DoorPanel(
                        height: height,
                        hingeOnLeft: true,
                        angle: openProgress * _maxSwing,
                        fade: openProgress,
                        borderRadius: BorderRadius.only(
                          topLeft: radius.topLeft,
                          bottomLeft: radius.bottomLeft,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _DoorPanel(
                        height: height,
                        hingeOnLeft: false,
                        angle: openProgress * _maxSwing,
                        fade: openProgress,
                        borderRadius: BorderRadius.only(
                          topRight: radius.topRight,
                          bottomRight: radius.bottomRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A soft peek of the inside of the closet: a hanging rail with a couple of
/// garments, sitting behind the doors.
class _ClosetInterior extends StatelessWidget {
  const _ClosetInterior({required this.reveal});

  /// 0 = fully hidden behind closed doors, 1 = doors fully open.
  final double reveal;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOut.transform(reveal.clamp(0.0, 1.0));

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.blush.withValues(alpha: 0.9), AppColors.cream],
        ),
      ),
      child: Opacity(
        // Nothing to see while closed; ease in as the doors part.
        opacity: Curves.easeIn.transform(reveal.clamp(0.0, 1.0)),
        child: Transform.scale(
          // Starts a touch small and settles to full size, so the rail and
          // hangers feel like they're drifting into a closeup rather than
          // just fading in place.
          scale: 0.86 + eased * 0.14,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: Spacing.lg),
                // Hanging rail.
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.mutedBrown.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_Hanger(), _Hanger(), _Hanger()],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hanger extends StatelessWidget {
  const _Hanger();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 1.5, height: 8, color: AppColors.mutedBrown.withValues(alpha: 0.3)),
        Container(
          width: 26,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.softPink.withValues(alpha: 0.55),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10),
              top: Radius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

/// One half of the closet doors, hinged on its outer edge (left door hinges
/// on the left, right door hinges on the right) and rotated in 3D so it
/// reads as swinging open rather than just sliding away.
class _DoorPanel extends StatelessWidget {
  const _DoorPanel({
    required this.height,
    required this.hingeOnLeft,
    required this.angle,
    required this.fade,
    required this.borderRadius,
  });

  final double height;
  final bool hingeOnLeft;

  /// Swing angle in radians (always positive; direction is baked in below).
  final double angle;

  /// 0 = fully opaque, 1 = fully open (faded away so we never see the
  /// unlit backface of the door).
  final double fade;

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    // Rotate around the hinge (outer edge) so the door swings away from the
    // viewer, like a real closet door opening.
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateY(hingeOnLeft ? -angle : angle);

    return Opacity(
      // Keep the door solid through most of the swing, then dissolve over
      // the last stretch so the reveal feels seamless.
      opacity: (1 - (fade / 0.85)).clamp(0.0, 1.0),
      child: Transform(
        alignment: hingeOnLeft ? Alignment.centerLeft : Alignment.centerRight,
        transform: matrix,
        child: _DoorFace(
          height: height,
          hingeOnLeft: hingeOnLeft,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class _DoorFace extends StatelessWidget {
  const _DoorFace({
    required this.height,
    required this.hingeOnLeft,
    required this.borderRadius,
  });

  final double height;
  final bool hingeOnLeft;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonPink.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.softPink, AppColors.buttonPink],
            ),
          ),
          child: Stack(
            children: [
              // Glossy highlight across the top of the door.
              Positioned(
                top: -height * 0.28,
                left: -height * 0.15,
                right: -height * 0.15,
                child: Container(
                  height: height * 0.55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.16),
                  ),
                ),
              ),
              // Seam line on the inner edge (the edge nearest the other
              // door).
              Positioned(
                top: 0,
                bottom: 0,
                left: hingeOnLeft ? null : 0,
                right: hingeOnLeft ? 0 : null,
                child: Container(
                  width: 1,
                  color: AppColors.mutedBrown.withValues(alpha: 0.18),
                ),
              ),
              // Handle near the inner edge.
              Positioned(
                top: 0,
                bottom: 0,
                left: hingeOnLeft ? null : 14,
                right: hingeOnLeft ? 14 : null,
                child: Center(
                  child: Container(
                    width: 5,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mutedBrown.withValues(alpha: 0.25),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}