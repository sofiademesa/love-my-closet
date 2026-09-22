import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/heart_avatar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

/// Main Landing Page: logo, name, tagline, Sign Up and Log In.
class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
    required this.onSignUp,
    required this.onLogIn,
  });

  final VoidCallback onSignUp;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final avatarWidth = math.min(constraints.maxWidth * 0.55, 220.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Column(
            children: [
              const Spacer(flex: 3),
              SizedBox(
                width: avatarWidth * 1.4,
                height: avatarWidth * 1.4,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: avatarWidth * 1.4,
                      height: avatarWidth * 1.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.softPink.withValues(alpha: 0.32),
                            AppColors.softPink.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    HeartAvatar(width: avatarWidth),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'Love My Closet',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall!.copyWith(fontSize: 30),
              ),
              const SizedBox(height: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.butterYellow.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'MADE TO BE LOVED AGAIN',
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: AppColors.hotPink,
                  ),
                ),
              ),
              const Spacer(flex: 4),
              PrimaryButton(label: 'Sign Up', onPressed: onSignUp),
              const SizedBox(height: Spacing.sm),
              SecondaryButton(label: 'Log In', onPressed: onLogIn),
              const SizedBox(height: Spacing.lg * 2),
            ],
          ),
        );
      },
    );
  }
}