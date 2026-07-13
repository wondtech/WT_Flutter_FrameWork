// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.3
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';
import 'wt_view.dart';
import 'wt_model.dart';

/// Base class for a screen's controller: owns the route [settings], exposes
/// route [params], returns the screen's [WtView], and offers navigation
/// helpers. Subclass it and implement [view].
abstract class WtController {
  /// The route settings this controller was dispatched with.
  final RouteSettings settings;

  /// Creates the controller for the given route [settings].
  WtController(this.settings);

  /// Route arguments passed as a `Map<String,String>` (empty if none).
  Map<String, String> get params =>
      (settings.arguments as Map<String, String>?) ?? {};

  /// The view this controller renders. Implement in your subclass.
  WtView view(BuildContext context);

  /// Builds the controller's view into a widget (called by [WtRouter]).
  Widget render(BuildContext context) {
    return view(context).build(context);
  }

  /// Pushes [route] onto the stack, optionally passing [args].
  void navigate(BuildContext context, String route, {Object? args}) {
    Navigator.pushNamed(context, route, arguments: args);
  }

  /// Replaces the current route with [route] (no back stack entry).
  void redirect(BuildContext context, String route, {Object? args}) {
    Navigator.pushReplacementNamed(context, route, arguments: args);
  }

  /// Pops the current route.
  void back(BuildContext context) {
    Navigator.pop(context);
  }

  /// Convenience: awaits [model].fetch().
  Future<T> loadModel<T>(WtModel<T> model) async {
    return await model.fetch();
  }
}
