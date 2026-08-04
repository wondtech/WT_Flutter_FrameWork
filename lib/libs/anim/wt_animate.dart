// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.4
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';

import '../config/wt_config.dart';
import 'wt_anim_types.dart';

/// Default entrance duration when neither the widget nor [WtConfig] specify one.
const Duration _kFallbackDuration = Duration(milliseconds: 300);

/// Default entrance curve when neither the widget nor [WtConfig] specify one.
const Curve _kFallbackCurve = Curves.easeOut;

/// Resolves whether animations should run at all: honours the OS "reduce
/// motion" setting first, then [WtConfig.animationsEnabled].
bool _motionAllowed(BuildContext context) {
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  if (reduceMotion) return false;
  return WtConfig.maybeInstance?.animationsEnabled ?? true;
}

Duration _resolveDuration(Duration? d) =>
    d ?? WtConfig.maybeInstance?.animDuration ?? _kFallbackDuration;

Curve _resolveCurve(Curve? c) =>
    c ?? WtConfig.maybeInstance?.animCurve ?? _kFallbackCurve;

/// The one-shot entrance animation that powers every WT entrance widget and
/// [WtAnimateX] extension.
///
/// Composes an optional fade, slide and scale that all play together once when
/// the widget is first mounted. Supply only the parts you want via [fadeFrom],
/// [slideFrom] and [scaleFrom]; leave a part null to skip it.
///
/// Respects reduced motion: when the OS "reduce motion" setting is on, or
/// [WtConfig.animationsEnabled] is false, the child is shown immediately in its
/// final state with no animation.
class WtAnimate extends StatefulWidget {
  /// The widget to animate into view.
  final Widget child;

  /// Total animation duration. Falls back to [WtConfig.animDuration], then
  /// 300ms.
  final Duration? duration;

  /// Delay before the animation starts (useful for staggering). Defaults to
  /// zero.
  final Duration delay;

  /// Animation curve. Falls back to [WtConfig.animCurve], then [Curves.easeOut].
  final Curve? curve;

  /// Opacity to start from (0 = fully transparent). Null disables the fade.
  final double? fadeFrom;

  /// Fractional offset to start from, in child-size units (e.g. `Offset(0, .1)`
  /// starts 10% below). Null disables the slide.
  final Offset? slideFrom;

  /// Scale to start from (e.g. 0.9). Null disables the scale.
  final double? scaleFrom;

  /// Animates [child] into view, composing any of fade/slide/scale.
  const WtAnimate({
    super.key,
    required this.child,
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.fadeFrom,
    this.slideFrom,
    this.scaleFrom,
  });

  @override
  State<WtAnimate> createState() => _WtAnimateState();
}

class _WtAnimateState extends State<WtAnimate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _resolveDuration(widget.duration),
  );

  bool _started = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startOnce() {
    if (_started) return;
    _started = true;
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reduced motion (or animations disabled): show final state instantly.
    if (!_motionAllowed(context)) {
      _controller.value = 1.0;
      return widget.child;
    }

    _startOnce();

    final t = CurvedAnimation(
        parent: _controller, curve: _resolveCurve(widget.curve));

    Widget result = widget.child;

    if (widget.scaleFrom != null) {
      result = ScaleTransition(
        scale: Tween<double>(begin: widget.scaleFrom, end: 1.0).animate(t),
        child: result,
      );
    }
    if (widget.slideFrom != null) {
      result = SlideTransition(
        position:
            Tween<Offset>(begin: widget.slideFrom, end: Offset.zero).animate(t),
        child: result,
      );
    }
    if (widget.fadeFrom != null) {
      result = FadeTransition(
        opacity: Tween<double>(begin: widget.fadeFrom, end: 1.0).animate(t),
        child: result,
      );
    }
    return result;
  }
}

/// Maps a [WtDir] to the fractional [Offset] a slide should start from.
Offset _offsetFor(WtDir dir, double distance) {
  switch (dir) {
    case WtDir.top:
      return Offset(0, -distance);
    case WtDir.bottom:
      return Offset(0, distance);
    case WtDir.left:
      return Offset(-distance, 0);
    case WtDir.right:
      return Offset(distance, 0);
  }
}

/// Fades [child] in from transparent.
class WtFadeIn extends StatelessWidget {
  /// The widget to fade in.
  final Widget child;

  /// See [WtAnimate.duration].
  final Duration? duration;

  /// See [WtAnimate.delay].
  final Duration delay;

  /// See [WtAnimate.curve].
  final Curve? curve;

  /// Fades [child] into view.
  const WtFadeIn({
    super.key,
    required this.child,
    this.duration,
    this.delay = Duration.zero,
    this.curve,
  });

  @override
  Widget build(BuildContext context) => WtAnimate(
        duration: duration,
        delay: delay,
        curve: curve,
        fadeFrom: 0.0,
        child: child,
      );
}

/// Slides [child] in (with a fade) from a [WtDir] edge.
class WtSlideIn extends StatelessWidget {
  /// The widget to slide in.
  final Widget child;

  /// Edge the child slides from (default [WtDir.bottom]).
  final WtDir from;

  /// Slide distance as a fraction of the child's size (default 0.15).
  final double distance;

  /// See [WtAnimate.duration].
  final Duration? duration;

  /// See [WtAnimate.delay].
  final Duration delay;

  /// See [WtAnimate.curve].
  final Curve? curve;

  /// Whether to also fade while sliding (default true).
  final bool fade;

  /// Slides [child] into view from [from].
  const WtSlideIn({
    super.key,
    required this.child,
    this.from = WtDir.bottom,
    this.distance = 0.15,
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.fade = true,
  });

  @override
  Widget build(BuildContext context) => WtAnimate(
        duration: duration,
        delay: delay,
        curve: curve,
        fadeFrom: fade ? 0.0 : null,
        slideFrom: _offsetFor(from, distance),
        child: child,
      );
}

/// Scales [child] in (with a fade) from [scaleFrom].
class WtScaleIn extends StatelessWidget {
  /// The widget to scale in.
  final Widget child;

  /// Starting scale (default 0.9).
  final double scaleFrom;

  /// See [WtAnimate.duration].
  final Duration? duration;

  /// See [WtAnimate.delay].
  final Duration delay;

  /// See [WtAnimate.curve].
  final Curve? curve;

  /// Whether to also fade while scaling (default true).
  final bool fade;

  /// Scales [child] into view.
  const WtScaleIn({
    super.key,
    required this.child,
    this.scaleFrom = 0.9,
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.fade = true,
  });

  @override
  Widget build(BuildContext context) => WtAnimate(
        duration: duration,
        delay: delay,
        curve: curve,
        fadeFrom: fade ? 0.0 : null,
        scaleFrom: scaleFrom,
        child: child,
      );
}

/// Lays out [children] in a column, each entering with a growing delay so they
/// cascade in one after another.
///
/// Handy for feed/list screens. For very long, scrolling lists prefer building
/// items lazily and applying [WtAnimateX.wtStagger] per visible item.
class WtStagger extends StatelessWidget {
  /// The widgets to animate in sequence.
  final List<Widget> children;

  /// Delay added per item (item `i` starts at `interval * i`). Default 60ms.
  final Duration interval;

  /// Per-item animation duration. See [WtAnimate.duration].
  final Duration? duration;

  /// Edge each child slides from (default [WtDir.bottom]).
  final WtDir from;

  /// Column cross-axis alignment.
  final CrossAxisAlignment crossAxisAlignment;

  /// Column main-axis size.
  final MainAxisSize mainAxisSize;

  /// Cascades [children] into view with a per-item [interval].
  const WtStagger({
    super.key,
    required this.children,
    this.interval = const Duration(milliseconds: 60),
    this.duration,
    this.from = WtDir.bottom,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (int i = 0; i < children.length; i++)
          WtSlideIn(
            from: from,
            delay: interval * i,
            duration: duration,
            child: children[i],
          ),
      ],
    );
  }
}

/// Fluent entrance animations on any widget: `myWidget.wtFadeIn()`.
///
/// Each method wraps the receiver in a [WtAnimate], so all of them honour
/// reduced motion and [WtConfig] defaults automatically.
extension WtAnimateX on Widget {
  /// Fades this widget in. See [WtFadeIn].
  Widget wtFadeIn(
          {Duration? duration, Duration delay = Duration.zero, Curve? curve}) =>
      WtFadeIn(duration: duration, delay: delay, curve: curve, child: this);

  /// Slides this widget in from [from] (default bottom). See [WtSlideIn].
  Widget wtSlideIn({
    WtDir from = WtDir.bottom,
    double distance = 0.15,
    Duration? duration,
    Duration delay = Duration.zero,
    Curve? curve,
    bool fade = true,
  }) =>
      WtSlideIn(
        from: from,
        distance: distance,
        duration: duration,
        delay: delay,
        curve: curve,
        fade: fade,
        child: this,
      );

  /// Slides this widget up from below — shorthand for `wtSlideIn(from: bottom)`.
  Widget wtSlideUp(
          {Duration? duration, Duration delay = Duration.zero, Curve? curve}) =>
      wtSlideIn(
          from: WtDir.bottom, duration: duration, delay: delay, curve: curve);

  /// Scales this widget in. See [WtScaleIn].
  Widget wtScaleIn({
    double scaleFrom = 0.9,
    Duration? duration,
    Duration delay = Duration.zero,
    Curve? curve,
    bool fade = true,
  }) =>
      WtScaleIn(
        scaleFrom: scaleFrom,
        duration: duration,
        delay: delay,
        curve: curve,
        fade: fade,
        child: this,
      );

  /// Staggered entrance for item [index] in a list: delays the animation by
  /// `interval * index`. Use inside `ListView.builder` item builders.
  Widget wtStagger({
    required int index,
    Duration interval = const Duration(milliseconds: 60),
    WtDir from = WtDir.bottom,
    Duration? duration,
    Curve? curve,
  }) =>
      WtSlideIn(
        from: from,
        delay: interval * index,
        duration: duration,
        curve: curve,
        child: this,
      );
}
