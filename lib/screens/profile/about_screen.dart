import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/heart_avatar.dart';

/// About Love My Closet: what the app is, what it's for, who built it, and
/// how to get in touch with the developer.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _email = 'sofiardmesa@gmail.com';
  static const _linkedInHandle = 'linkedin.com/in/sofiademesa';
  static const _linkedInUrl = 'https://www.linkedin.com/in/sofiademesa';

  Future<void> _launch(BuildContext context, Uri uri) async {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't open ${uri.toString()}")),
      );
    }
  }

  void _openEmail(BuildContext context) {
    _launch(context, Uri(scheme: 'mailto', path: _email));
  }

  void _openLinkedIn(BuildContext context) {
    _launch(context, Uri.parse(_linkedInUrl));
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
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.md,
              Spacing.md,
              Spacing.lg,
            ),
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
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.hotPink,
                          size: 32,
                        ),
                      ),
                    ),
                    Text(
                      'About Love My Closet',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall!.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              const Center(child: HeartAvatar(width: 96)),
              const SizedBox(height: Spacing.md),
              Text(
                'Love My Closet: Made to Be Loved Again',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall!.copyWith(fontSize: 19),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Love My Closet is a digital wardrobe app created to help you '
                'organize, rediscover, and make better use of the clothes you '
                'already own.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium!.copyWith(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: Spacing.lg),
              const _InfoCard(
                title: 'The Idea',
                body:
                    'Choosing what to wear can sometimes feel difficult, '
                    'especially when you have a closet full of clothes but '
                    'still feel like you have nothing to wear. Love My Closet '
                    'was created to make outfit planning simpler, more '
                    'organized, and more enjoyable.',
              ),
              const SizedBox(height: Spacing.sm),
              _InfoCard(
                title: 'What You Can Do',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _BulletLine('Organize your clothes in one digital closet'),
                    _BulletLine('Create and save outfit combinations'),
                    _BulletLine('Plan and keep track of outfits'),
                    _BulletLine('Rediscover pieces you haven\u2019t worn recently'),
                    _BulletLine('Make everyday outfit planning easier'),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.sm),
              const _InfoCard(
                title: 'Made to Be Loved Again',
                body:
                    'Love My Closet encourages you to rediscover the clothes '
                    'you already have and give them another chance to be '
                    'worn, styled, and loved again.',
              ),
              const SizedBox(height: Spacing.sm),
              const _InfoCard(
                title: 'About the Developer',
                body:
                    'Hi, I\u2019m Sofia Ryza D. De Mesa, a Computer Science '
                    'student with a love for technology, creativity, and '
                    'organization. I created Love My Closet as a personal '
                    'academic project, bringing together my interest in '
                    'technology and my love for organized spaces and '
                    'thoughtful design.\n\n'
                    'From the concept and interface design to the Flutter '
                    'implementation, Love My Closet is a project I developed '
                    'throughout my journey as a Computer Science student.',
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
                      'Connect with Me',
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.hotPink,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'For questions, feedback, or inquiries about Love My '
                      'Closet, you may personally connect with me through:',
                      style: textTheme.bodyMedium!.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: Spacing.sm),
                    _LinkRow(
                      icon: Icons.mail_outline_rounded,
                      label: _email,
                      onTap: () => _openEmail(context),
                    ),
                    const SizedBox(height: Spacing.sm),
                    _LinkRow(
                      icon: Icons.link_rounded,
                      label: _linkedInHandle,
                      onTap: () => _openLinkedIn(context),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, this.body, this.child})
    : assert(body != null || child != null);

  final String title;
  final String? body;
  final Widget? child;

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
          if (body != null)
            Text(
              body!,
              style: textTheme.bodyMedium!.copyWith(fontSize: 14, height: 1.4),
            )
          else
            child!,
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\u2022  ',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.buttonPink,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                height: 1.4,
                color: AppColors.mutedBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable contact line (email or LinkedIn) styled like Help & Support's
/// email row. Tapping opens the appropriate external app.
class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
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
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: AppColors.blush, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.buttonPink, size: 18),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedBrown,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedBrown,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}