import 'package:flutter/material.dart';
import '../../animations/app_motion.dart';

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
    // The closet-opening boundary (Onboarding 1 <-> 2) is a little scene with
    // its own stages (see [_ClosetStages]), each with its own easing. The
    // page itself therefore moves at an even, gentle pace here: a strong
    // ease-in-out would squeeze the whole door swing into a split second in
    // the middle, which is what made it feel like the closet just popped
    // open. The rest of the flow keeps a snappier "next" feel.
    final openingCloset =
        (_page == 0 && page == 1) || (_page == 1 && page == 0);
    _controller.animateToPage(
      page,
      duration: kMotionDuration(
        Duration(milliseconds: openingCloset ? 1150 : 350),
      ),
      curve: openingCloset ? Curves.easeInOutSine : Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_page < _landingIndex) _goTo(_page + 1);
  }

  /// The default [PageView] slides the whole card sideways, which reads as
  /// plain "next paging". For the Onboarding 1 <-> 2 boundary this cancels
  /// that slide (both pages stay put, dead centre) and plays the stages in
  /// [_ClosetStages] instead: doors swing open, the camera pushes in, and the
  /// closet view dissolves into Onboarding 2. Every other boundary
  /// (2 <-> Landing) keeps the normal slide untouched.
  Widget _transitionChild({
    required int index,
    required double page,
    required double width,
    required Widget child,
  }) {
    final delta = page - index;

    if (index == 0) {
      // Only the forward half (departing into Onboarding 2) is customized.
      final t = delta.clamp(0.0, 1.0).toDouble();
      if (t <= 0) return child;
      final stages = _ClosetStages(t);
      return IgnorePointer(
        ignoring: t > 0.02,
        child: Transform.translate(
          // Cancels the PageView's own -delta*width slide so this stays
          // centred instead of sliding off to the left.
          offset: Offset(delta * width, 0),
          child: Opacity(
            opacity: stages.closetOpacity,
            child: Transform.scale(scale: stages.closetZoom, child: child),
          ),
        ),
      );
    }

    if (index == 1) {
      // Only the backward half (arriving from Onboarding 1) is customized;
      // moving on toward Landing keeps the default slide.
      final d = delta.clamp(-1.0, 0.0).toDouble();
      if (d >= 0) return child;
      final stages = _ClosetStages(1 + d);
      return IgnorePointer(
        ignoring: stages.t < 0.98,
        child: Transform.translate(
          offset: Offset(delta * width, 0),
          child: Opacity(
            opacity: stages.nextOpacity,
            child: Transform.scale(scale: stages.nextScale, child: child),
          ),
        ),
      );
    }

    return child;
  }

  void _openCreateAccount() {
    Navigator.of(context).push(
      AppPageRoute<void>(builder: (_) => const CreateAccountScreen()),
    );
  }

  void _openLogIn() {
    Navigator.of(context).push(
      AppPageRoute<void>(builder: (_) => const LogInScreen()),
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
                              final stages = _ClosetStages(
                                page.clamp(0.0, 1.0).toDouble(),
                              );

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
                                      openProgress: stages.doorOpen,
                                      textOpacity: stages.oldTextOpacity,
                                      textOffsetY: stages.oldTextOffsetY,
                                    ),
                                  ),
                                  _transitionChild(
                                    index: 1,
                                    page: page,
                                    width: width,
                                    child: Onboarding2Page(
                                      textOpacity: stages.newTextOpacity,
                                      textOffsetY: stages.newTextOffsetY,
                                    ),
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

/// Timeline of the Onboarding 1 -> 2 "closet opening", worked out from how
/// far the pages have moved ([t]: 0 = on Onboarding 1, 1 = on Onboarding 2).
///
/// Each effect gets its own window and easing so they happen one after
/// another instead of all at once:
///
///   0.00-0.25  "nothing to wear" text drifts down and fades out
///   0.05-0.60  doors swing open (eased at both ends)
///   0.00-1.00  camera keeps pushing gently into the closet
///   0.50-0.90  closet view dissolves...
///   0.50-1.00  ...while Onboarding 2's card settles in from a slight zoom
///   0.70-1.00  the new headline rises into place
///
/// Swiping runs the same timeline under the finger; backing up plays it in
/// reverse. With Reduce Motion on, the page jump is instant, so none of it
/// shows.
class _ClosetStages {
  _ClosetStages(this.t);

  final double t;

  static const _oldText = Interval(0.0, 0.25, curve: Curves.easeOut);
  static const _doors = Interval(0.05, 0.60, curve: Curves.easeInOutCubic);
  static const _push = Interval(0.0, 1.0, curve: Curves.easeInCubic);
  static const _closetOut = Interval(0.50, 0.90, curve: Curves.easeIn);
  static const _nextIn = Interval(0.50, 0.90, curve: Curves.easeOut);
  static const _nextSettle = Interval(0.50, 1.0, curve: Curves.easeOutCubic);
  static const _newText = Interval(0.70, 1.0, curve: Curves.easeOutCubic);

  /// Door swing for [Onboarding1Page.openProgress] (0 closed, 1 open).
  double get doorOpen => _doors.transform(t);

  double get oldTextOpacity => 1 - _oldText.transform(t);
  double get oldTextOffsetY => _oldText.transform(t) * 10;

  /// Onboarding 1 as a whole: pushes in and dissolves late, once the doors
  /// are already open.
  double get closetZoom => 1 + _push.transform(t) * 0.12;
  double get closetOpacity => 1 - _closetOut.transform(t);

  /// Onboarding 2 as a whole: fades in and settles from a slight zoom, as
  /// if arriving from the push-in.
  double get nextOpacity => _nextIn.transform(t);
  double get nextScale => 1.08 - _nextSettle.transform(t) * 0.08;

  double get newTextOpacity => _newText.transform(t);
  double get newTextOffsetY => (1 - _newText.transform(t)) * 14;
}