// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.2
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';
import '../config/wt_config.dart';
import 'wt_router.dart';

class WtApp extends StatelessWidget {
  final WtConfig config;
  final WtRouter router;

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
