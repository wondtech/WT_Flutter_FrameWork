// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.2
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';
import 'wt_view.dart';
import 'wt_model.dart';

abstract class WtController {
  final RouteSettings settings;

  WtController(this.settings);

  Map<String, String> get params =>
      (settings.arguments as Map<String, String>?) ?? {};

  WtView view(BuildContext context);

  Widget render(BuildContext context) {
    return view(context).build(context);
  }

  void navigate(BuildContext context, String route, {Object? args}) {
    Navigator.pushNamed(context, route, arguments: args);
  }

  void redirect(BuildContext context, String route, {Object? args}) {
    Navigator.pushReplacementNamed(context, route, arguments: args);
  }

  void back(BuildContext context) {
    Navigator.pop(context);
  }

  Future<T> loadModel<T>(WtModel<T> model) async {
    return await model.fetch();
  }
}
