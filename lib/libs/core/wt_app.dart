// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.3
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';
import '../config/wt_config.dart';
import 'wt_router.dart';

/// Root widget: a thin [MaterialApp] wired to a [WtConfig] and a [WtRouter].
///
/// For a bilingual / RTL app build your own `MaterialApp` root instead and
/// reuse the [router] (see the framework's localization recipe).
class WtApp extends StatelessWidget {
  /// Global configuration (app name, theme, API/token keys).
  final WtConfig config;

  /// The router whose [WtRouter.dispatch] generates routes.
  final WtRouter router;

  /// Creates the app shell from a [config] and a [router].
  const WtApp({
    super.key,
    required this.config,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: config.theme ?? _defaultTheme(),
      initialRoute: router.initialRoute,
      onGenerateRoute: router.dispatch,
    );
  }

  ThemeData _defaultTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
      useMaterial3: true,
    );
  }
}
