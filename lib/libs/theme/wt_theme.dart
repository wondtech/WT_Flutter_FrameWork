// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.4
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';

/// Central design tokens and ready-made light/dark [ThemeData] for a WT app.
///
/// Use the spacing/radius constants for consistent layout, and
/// [WtTheme.light]/[WtTheme.dark] to build a Material 3 theme from a single
/// seed colour — pass the result to `WtConfig(theme: ...)` or your own
/// `MaterialApp`.
///
/// ```dart
/// WtConfig.init(WtConfig(
///   appName: 'My App', baseUrl: '...', secretKey: '...',
///   theme: WtTheme.light(seed: const Color(0xFF1A73E8)),
/// ));
/// ```
class WtTheme {
  const WtTheme._();

  // ── Spacing scale (logical pixels) ───────────────────────────────────────

  /// 4px.
  static const double xs = 4;

  /// 8px.
  static const double sm = 8;

  /// 16px — the default gutter.
  static const double md = 16;

  /// 24px.
  static const double lg = 24;

  /// 32px.
  static const double xl = 32;

  /// 48px.
  static const double xxl = 48;

  // ── Corner radii ─────────────────────────────────────────────────────────

  /// 8px radius.
  static const double radiusSm = 8;

  /// 12px radius (cards, buttons).
  static const double radiusMd = 12;

  /// 16px radius.
  static const double radiusLg = 16;

  /// Fully rounded (pill / circle).
  static const double radiusPill = 999;

  /// Default seed colour (WondTech blue) used when none is supplied.
  static const Color defaultSeed = Color(0xFF1A73E8);

  // ── EdgeInsets / gap helpers ─────────────────────────────────────────────

  /// Symmetric all-round padding of [value].
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// A `SizedBox` gap of [value] logical pixels, square.
  static SizedBox gap(double value) => SizedBox(width: value, height: value);

  /// A vertical `SizedBox` gap of [value] logical pixels.
  static SizedBox vGap(double value) => SizedBox(height: value);

  /// A horizontal `SizedBox` gap of [value] logical pixels.
  static SizedBox hGap(double value) => SizedBox(width: value);

  /// A [RoundedRectangleBorder] with a [radius] corner (default [radiusMd]).
  static RoundedRectangleBorder rounded([double radius = radiusMd]) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  // ── Theme builders ───────────────────────────────────────────────────────

  /// A Material 3 light theme seeded from [seed].
  static ThemeData light({Color seed = defaultSeed}) =>
      _base(seed, Brightness.light);

  /// A Material 3 dark theme seeded from [seed].
  static ThemeData dark({Color seed = defaultSeed}) =>
      _base(seed, Brightness.dark);

  static ThemeData _base(Color seed, Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: rounded(radiusLg),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: lg, vertical: md),
          shape: rounded(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: md, vertical: md),
      ),
    );
  }
}
