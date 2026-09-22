import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/page_dots.dart';
import '../../widgets/primary_button.dart';
import 'create_account_screen.dart';
import 'landing_page.dart';
import 'log_in_screen.dart';
import 'onboarding_1_page.dart';
import 'onboarding_2_page.dart';

/// Hosts Onboarding 1 -> Onboarding 2 -> Main Landing Page as swipeable pages
/// with a shared dotted background, dots and "Next" button. From the landing
/// page the user goes to Create Account or Log In.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  static const _slideCount = 3; // Onboarding 1, Onboarding 2, Landing
  static const _landingIndex = 2;

  final _controller = PageController();
  int _page = 0;

  bool get _onLanding => _page == _landingIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_page < _landingIndex) _goTo(_page + 1);
  }

  void _openCreateAccount() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CreateAccountScreen()),
    );
  }

  void _openLogIn() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LogInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // System back steps through the slides before leaving the flow.
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goTo(_page - 1);
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: DotPattern(
          backgroundColor: AppColors.cream,
          dotColor: AppColors.hotPink.withValues(alpha: 0.06),
          spacing: 20,
          dotRadius: 1.6,
          child: Stack(
            children: [
              // Warm blush wash that eases in behind the two intro slides
              // and fades away on the landing page.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _onLanding ? 0 : 1,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00FAD7E7), AppColors.blush],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: PageView(
                        controller: _controller,
                        onPageChanged: (index) => setState(() => _page = index),
                        children: [
                          const Onboarding1Page(),
                          const Onboarding2Page(),
                          LandingPage(
                            onSignUp: _openCreateAccount,
                            onLogIn: _openLogIn,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        ignoring: _onLanding,
                        child: AnimatedOpacity(
                          opacity: _onLanding ? 0 : 1,
                          duration: const Duration(milliseconds: 250),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Spacing.md,
                              0,
                              Spacing.md,
                              Spacing.md,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PageDots(count: _slideCount, current: _page),
                                const SizedBox(height: Spacing.md),
                                PrimaryButton(label: 'Next', onPressed: _next),
                              ],
                            ),
                          ),
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