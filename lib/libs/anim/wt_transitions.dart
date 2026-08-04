// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.4
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';

import '../config/wt_config.dart';
import 'wt_anim_types.dart';

/// Builds the [Route] for a page, applying [transition].
///
/// Used by [WtRouter]. [WtTransition.platform] returns a plain
/// [MaterialPageRoute] (unchanged behaviour); every other value returns a
/// [PageRouteBuilder] with a pure-Flutter transition. The OS "reduce motion"
/// setting and [WtConfig.animationsEnabled] both collapse the transition to an
/// instant swap.
Route<dynamic> wtBuildRoute({
  required WidgetBuilder builder,
  required RouteSettings settings,
  required WtTransition transition,
}) {
  if (transition == WtTransition.platform) {
    return MaterialPageRoute<dynamic>(settings: settings, builder: builder);
  }

  final cfg = WtConfig.maybeInstance;
  final duration = cfg?.animDuration ?? const Duration(milliseconds: 300);
  final curve = cfg?.animCurve ?? Curves.easeOut;
  final enabled = cfg?.animationsEnabled ?? true;

  return PageRouteBuilder<dynamic>(
    settings: settings,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Reduced motion or animations disabled → no transition.
      final reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (!enabled || reduceMotion || transition == WtTransition.none) {
        return child;
      }

      final t = CurvedAnimation(parent: animation, curve: curve);
      switch (transition) {
        case WtTransition.fade:
          return FadeTransition(opacity: t, child: child);
        case WtTransition.slideRight:
          return _slide(t, const Offset(1, 0), child);
        case WtTransition.slideLeft:
          return _slide(t, const Offset(-1, 0), child);
        case WtTransition.slideUp:
          return _slide(t, const Offset(0, 1), child);
        case WtTransition.scale:
          return ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(t),
            child: child,
          );
        case WtTransition.fadeScale:
          return FadeTransition(
            opacity: t,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(t),
              child: child,
            ),
          );
        case WtTransition.platform:
        case WtTransition.none:
          return child;
      }
    },
  );
}

Widget _slide(Animation<double> t, Offset begin, Widget child) =>
    SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(t),
      child: child,
    );
