import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/heart_avatar.dart';

/// Shared layout for Create Account, Log In and Forgot Password: optional
/// avatar, serif title, subtitle, the form, and a footer link pinned to the
/// bottom.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.showAvatar = false,
    required this.child,
    required this.footer,
  });

  final String title;
  final String? subtitle;
  final bool showAvatar;
  final Widget child;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showAvatar) ...[
                              const Center(child: HeartAvatar(width: 150)),
                              const SizedBox(height: Spacing.md),
                            ],
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style:
                                  textTheme.headlineSmall!.copyWith(fontSize: 28),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: Spacing.xs),
                              Text(
                                subtitle!,
                                textAlign: TextAlign.center,
                                style: textTheme.labelSmall,
                              ),
                            ],
                            const SizedBox(height: Spacing.lg),
                            child,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: Spacing.sm,
                bottom: Spacing.lg,
              ),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Already have an account? Log In" style footer.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final caption = Theme.of(context).textTheme.labelSmall!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: caption),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xs,
              vertical: Spacing.sm,
            ),
            child: Text(
              action,
              style: caption.copyWith(
                color: AppColors.hotPink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Simple validators shared by the onboarding forms.
class Validators {
  static String? notEmpty(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email address';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    return valid ? null : 'Please enter a valid email address';
  }
}