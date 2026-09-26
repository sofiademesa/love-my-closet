import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme.dart';
import '../../widgets/dot_pattern.dart';

/// Help & Support: what the app does, how to manage your closet, what to
/// try if something's not working, and how to reach us.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _emails = [
    'lovemycloset@gmail.com',
    'lovemycloset.support@gmail.com',
  ];

  void _copyEmail(BuildContext context, String email) {
    Clipboard.setData(ClipboardData(text: email));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied $email')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: DotPattern(
        backgroundColor: AppColors.cream,
        dotColor: AppColors.softPink.withValues(alpha: 0.16),
        spacing: 18,
        dotRadius: 1.3,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.lg),
            children: [
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.hotPink,
                          size: 32,
                        ),
                      ),
                    ),
                    Text(
                      'Help & Support',
                      style: textTheme.headlineSmall!.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Need help with Love My Closet?',
                style: textTheme.headlineSmall!.copyWith(fontSize: 19),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                "We're here to help you make the most out of your digital closet.",
                style: textTheme.bodyMedium!.copyWith(fontSize: 14),
              ),
              const SizedBox(height: Spacing.lg),
              const _InfoCard(
                title: 'Getting Started',
                body:
                    'Add your favorite clothing pieces to your closet, organize '
                    'them by category, and create outfits for different '
                    'occasions. You can also save your outfits and keep track '
                    'of the pieces you wear.',
              ),
              const SizedBox(height: Spacing.sm),
              const _InfoCard(
                title: 'Managing Your Closet',
                body:
                    'You can add, edit, or remove clothing items anytime. Keep '
                    'your closet updated so it\u2019s easier to find pieces and '
                    'plan what to wear.',
              ),
              const SizedBox(height: Spacing.sm),
              const _InfoCard(
                title: 'Planning Outfits',
                body:
                    'Use the Outfit Builder to mix and match items from your '
                    'closet. Save your favorite combinations to your Outfit '
                    'Diary for easy reference.',
              ),
              const SizedBox(height: Spacing.sm),
              const _InfoCard(
                title: 'Having an Issue?',
                body:
                    'If something isn\u2019t working as expected, try closing and '
                    'reopening the app first. Make sure your app is updated and '
                    'that you have a stable internet connection for features '
                    'that require online access.',
              ),
              const SizedBox(height: Spacing.sm),
              const _InfoCard(
                title: 'Need More Help?',
                body:
                    'If you have questions, encounter a problem, or have '
                    'suggestions for improving Love My Closet, feel free to '
                    'contact us.',
              ),
              const SizedBox(height: Spacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.blush, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Support',
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.hotPink,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text('Email us at:', style: textTheme.bodyMedium!.copyWith(fontSize: 14)),
                    const SizedBox(height: Spacing.sm),
                    for (final email in _emails) ...[
                      _EmailRow(email: email, onTap: () => _copyEmail(context, email)),
                      if (email != _emails.last) const SizedBox(height: Spacing.sm),
                    ],
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.blush, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.hotPink,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            body,
            style: textTheme.bodyMedium!.copyWith(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// A tappable email line — tapping copies the address to the clipboard,
/// since this project has no email-launcher dependency.
class _EmailRow extends StatelessWidget {
  const _EmailRow({required this.email, required this.onTap});

  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.field),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: AppColors.blush, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.mail_outline_rounded, color: AppColors.buttonPink, size: 18),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedBrown,
                  ),
                ),
              ),
              const Icon(Icons.copy_rounded, color: AppColors.mutedBrown, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}