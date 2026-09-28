import 'package:flutter/material.dart';

import '../data/accessibility_store.dart';

export '../data/accessibility_store.dart' show kMotionDuration;

// Shared motion toolkit for Love My Closet.
///
// Every animation in the app funnels through [kMotionDuration] (see
// `data/accessibility_store.dart`), so turning on Reduce Motion collapses
// everything here to instant with no separate wiring. Keep durations in
// the 180-400ms range and curves soft (`easeOut*`/`easeInOut*`) so motion
// reads as gentle and intentional rather than snappy or playful.

// ---------------------------------------------------------------------------
// Screen transitions
// ---------------------------------------------------------------------------

// Drop-in replacement for [MaterialPageRoute]: a soft fade + slight upward
// slide instead of Android's default hard right-to-left push, so moving
// between screens (including the app's tab-to-tab navigation, which is
// implemented as full-screen pushes) feels calm rather than mechanical.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required this.builder, super.settings, this.maintainState = true})
      : super(
          transitionDuration: kMotionDuration(const Duration(milliseconds: 320)),
          reverseTransitionDuration: kMotionDuration(const Duration(milliseconds: 280)),
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            final outCurve = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.035),
                  end: Offset.zero,
                ).animate(curved),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(0, -0.02),
                  ).animate(outCurve),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1, end: 0.0).animate(outCurve),
                    child: child,
                  ),
                ),
              ),
            );
          },
        );

  final WidgetBuilder builder;

  @override
  final bool maintainState;
}

// ---------------------------------------------------------------------------
// Dialogs
// ---------------------------------------------------------------------------

// Drop-in replacement for `showDialog`: same call shape and same
// `Navigator.pop(context, result)` usage inside the dialog, but with a
// softer fade + gentle scale-in instead of Material's default snap.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: kMotionDuration(const Duration(milliseconds: 260)),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Entrance animations
// ---------------------------------------------------------------------------

// Gentle one-shot "arrival" animation: fades in while sliding a short
// distance (a fraction of the child's own size) into place. Used for
// section headers, cards, and grid/list items appearing on screen.
///
// Safe to use inside a lazily-built list/grid: give each instance a
// [Key] tied to stable item identity (e.g. `ValueKey(item.id)`) so an
// item already on screen keeps its completed animation state across
// rebuilds, and only a genuinely new item plays the entrance again.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 340),
    this.offset = const Offset(0, 0.06),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Fractional starting offset (relative to the child's own size), e.g.
  /// `Offset(0, 0.06)` starts 6% of the child's height below its resting
  /// place and settles upward.
  final Offset offset;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: kMotionDuration(widget.duration),
  );
  late final Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  @override
  void initState() {
    super.initState();
    if (AccessibilityStore.instance.reduceMotion || widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) {
        final t = _curved.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: FractionalTranslation(
            translation: Offset(
              widget.offset.dx * (1 - t),
              widget.offset.dy * (1 - t),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// Small helper for staggering a series of [FadeSlideIn]s (Home's sections,
// a row of stat tiles, ...): `staggerDelay(i)` grows with index but caps
// out so a long list never feels like it's slowly trickling in.
Duration staggerDelay(int index, {int stepMs = 45, int maxMs = 240}) {
  return Duration(milliseconds: (index * stepMs).clamp(0, maxMs));
}

// Gentle "pop" entrance for something that appears suddenly at a point in
// time rather than scrolling into view — a piece dropped on the Outfit
// Builder board, a newly favorited item, a freshly logged outfit. Fades in
// while scaling up from slightly smaller, with a soft overshoot so it
// reads as a little bounce of delight rather than a mechanical pop.
class PopIn extends StatefulWidget {
  const PopIn({super.key, required this.child, this.duration = const Duration(milliseconds: 280)});

  final Widget child;
  final Duration duration;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: kMotionDuration(widget.duration),
  );
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// Soft exit for something leaving the screen a beat *before* it's actually
// removed from the underlying list — shrinks and fades out, then calls
// [onExited] once the animation finishes so the caller can drop it from
// state. Pair with a stable [Key] (e.g. `ValueKey(item.id)`) so the right
// instance animates when [removing] flips to true.
class FadeScaleOut extends StatefulWidget {
  const FadeScaleOut({
    super.key,
    required this.child,
    required this.removing,
    required this.onExited,
    this.duration = const Duration(milliseconds: 220),
  });

  final Widget child;
  final bool removing;
  final VoidCallback onExited;
  final Duration duration;

  @override
  State<FadeScaleOut> createState() => _FadeScaleOutState();
}

class _FadeScaleOutState extends State<FadeScaleOut> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: kMotionDuration(widget.duration),
  );
  late final Animation<double> _curved = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

  @override
  void initState() {
    super.initState();
    if (widget.removing) _startExit();
  }

  @override
  void didUpdateWidget(covariant FadeScaleOut oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.removing && !oldWidget.removing) _startExit();
  }

  void _startExit() {
    if (AccessibilityStore.instance.reduceMotion) {
      widget.onExited();
      return;
    }
    _controller.forward().whenComplete(() {
      if (mounted) widget.onExited();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) {
        final t = _curved.value;
        return Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.scale(scale: 1 - (t * 0.14), child: child),
        );
      },
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// Press feedback
// ---------------------------------------------------------------------------

// Adds a subtle press-down scale to any tappable child, purely as extra
// tactile feedback layered on top of whatever tap handling already lives
// inside [child] (an `InkWell`, a `GestureDetector`, a `FilledButton`...).
///
// Uses a [Listener] rather than a [GestureDetector] so it never joins the
// gesture arena or intercepts the tap itself — it only watches for a
// pointer going down/up/cancel on the child and animates around it,
// leaving every existing `onTap`/`onPressed` exactly as it was.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.scale = 0.96,
    this.enabled = true,
  });

  final Widget child;
  final double scale;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: kMotionDuration(const Duration(milliseconds: 110)),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Favorite / heart toggle
// ---------------------------------------------------------------------------

// A heart icon that gives a soft little bounce whenever it switches from
// inactive to active, instead of just snapping between the two glyphs.
// Purely visual — pass whatever [size]/colors match the spot it's used.
class AnimatedHeartIcon extends StatefulWidget {
  const AnimatedHeartIcon({
    super.key,
    required this.active,
    required this.size,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool active;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<AnimatedHeartIcon> createState() => _AnimatedHeartIconState();
}

class _AnimatedHeartIconState extends State<AnimatedHeartIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: kMotionDuration(const Duration(milliseconds: 340)),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 65,
    ),
  ]).animate(_bump);

  @override
  void didUpdateWidget(covariant AnimatedHeartIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _bump.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: AnimatedSwitcher(
        duration: kMotionDuration(const Duration(milliseconds: 200)),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          widget.active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(widget.active),
          size: widget.size,
          color: widget.active ? widget.activeColor : widget.inactiveColor,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading
// ---------------------------------------------------------------------------

// Small on-brand spinner for the rare moment something is being fetched or
// saved, fading in rather than popping on screen so it never reads as a
// jarring "flash of loading state".
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = 20, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: kMotionDuration(const Duration(milliseconds: 220)),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation(color ?? Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section / tab crossfade
// ---------------------------------------------------------------------------

// Standard crossfade + slight slide used whenever one whole section swaps
// for another in place (Outfit Builder's Builder/View Outfits tabs, a
// Calendar month, a day's outfit list). Wrap the switched content in this
// with a [Key] that changes whenever the content itself changes.
class AppSectionSwitcher extends StatelessWidget {
  const AppSectionSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 260),
    this.axis = Axis.vertical,
  });

  final Widget child;
  final Duration duration;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final slide = axis == Axis.vertical ? const Offset(0, 0.04) : const Offset(0.04, 0);
    return AnimatedSwitcher(
      duration: kMotionDuration(duration),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: slide, end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [...previousChildren, if (currentChild != null) currentChild],
        );
      },
      child: child,
    );
  }
}