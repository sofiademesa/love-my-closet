import 'package:flutter/material.dart';

import '../../data/accessibility_store.dart';
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
    // The closet-opening boundary (Onboarding 1 <-> 2) runs a touch longer
    // and softer so the door swing + push-in zoom actually reads instead of
    // being rushed; the rest of the flow keeps a snappier "next" feel.
    final openingCloset =
        (_page == 0 && page == 1) || (_page == 1 && page == 0);
    _controller.animateToPage(
      page,
      duration: kMotionDuration(
        Duration(milliseconds: openingCloset ? 620 : 350),
      ),
      curve: openingCloset ? Curves.easeInOutCubic : Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_page < _landingIndex) _goTo(_page + 1);
  }

  /// The default [PageView] slides the whole card sideways, which is what
  /// made this read as plain "next paging". For the Onboarding1 <-> 2
  /// boundary specifically, this cancels that built-in slide (both pages
  /// stay put, dead centre) and replaces it with a cross-fade + push-in
  /// zoom, so it plays like the camera moving through the closet doors as
  /// they swing open, rather than two cards passing each other. Every other
  /// boundary (2 <-> Landing) keeps the normal slide untouched.
  Widget _transitionChild({
    required int index,
    required double page,
    required double width,
    required Widget child,
  }) {
    final delta = page - index;

    if (index == 0) {
      // Only the forward half (departing into Onboarding 2) is customized.
      final t = delta.clamp(0.0, 1.0);
      if (t <= 0) return child;
      final eased = Curves.easeIn.transform(t);
      return IgnorePointer(
        ignoring: t > 0.02,
        child: Transform.translate(
          // Cancels the PageView's own -delta*width slide so this stays
          // centred instead of sliding off to the left.
          offset: Offset(delta * width, 0),
          child: Opacity(
            opacity: (1 - eased).clamp(0.0, 1.0),
            child: Transform.scale(scale: 1 + eased * 0.10, child: child),
          ),
        ),
      );
    }

    if (index == 1) {
      // Only the backward half (arriving from Onboarding 1) is customized;
      // moving on toward Landing keeps the default slide.
      final t = delta.clamp(-1.0, 0.0);
      if (t >= 0) return child;
      final eased = Curves.easeOut.transform(1 + t);
      return IgnorePointer(
        ignoring: eased < 0.98,
        child: Transform.translate(
          offset: Offset(delta * width, 0),
          child: Opacity(
            opacity: eased.clamp(0.0, 1.0),
            child: Transform.scale(scale: 1.14 - eased * 0.14, child: child),
          ),
        ),
      );
    }

    return child;
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
                    duration: kMotionDuration(
                      const Duration(milliseconds: 400),
                    ),
                    opacity: _onLanding ? 0 : 1,
                    child: DecoratedBox(
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          return AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              // Raw scroll position across the 3 slides, used
                              // both to drive the door swing on Onboarding 1
                              // and to work out each page's own custom
                              // transition below.
                              var page = _page.toDouble();
                              if (_controller.hasClients &&
                                  _controller.position.haveDimensions) {
                                page = _controller.page ?? page;
                              }
                              final openProgress = page.clamp(0.0, 1.0);

                              return PageView(
                                controller: _controller,
                                onPageChanged: (index) =>
                                    setState(() => _page = index),
                                children: [
                                  _transitionChild(
                                    index: 0,
                                    page: page,
                                    width: width,
                                    child: Onboarding1Page(
                                      openProgress: openProgress,
                                    ),
                                  ),
                                  _transitionChild(
                                    index: 1,
                                    page: page,
                                    width: width,
                                    child: const Onboarding2Page(),
                                  ),
                                  LandingPage(
                                    onSignUp: _openCreateAccount,
                                    onLogIn: _openLogIn,
                                  ),
                                ],
                              );
                            },
                          );
                        },
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
                          duration: kMotionDuration(
                            const Duration(milliseconds: 250),
                          ),
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