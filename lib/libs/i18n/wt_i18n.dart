// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.4
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/widgets.dart';

import '../helpers/wt_session.dart';

/// Lightweight in-app localisation with RTL support and persisted language.
///
/// A [ChangeNotifier] singleton ([WtI18n.instance]): register translation
/// tables once, then read strings with [t] / [WtI18n.tr]. Changing the language
/// with [setLocale] persists it (via [WtSession]) and notifies listeners so a
/// wrapped app rebuilds — including its text [dir]ection.
///
/// ```dart
/// await WtI18n.instance.init(translations: {
///   'en': {'hello': 'Hello {name}'},
///   'ar': {'hello': 'مرحبا {name}'},
/// });
///
/// // In the widget tree:
/// Text(WtI18n.tr('hello', params: {'name': 'Ali'}));
///
/// // Rebuild the whole app (locale + direction) on change:
/// WtI18n.instance.wrap(MaterialApp(...));
/// WtI18n.instance.setLocale('ar');
/// ```
class WtI18n extends ChangeNotifier {
  WtI18n._();

  /// The shared instance.
  static final WtI18n instance = WtI18n._();

  Map<String, Map<String, String>> _dict = const {};
  Set<String> _rtlLangs = const {'ar', 'he', 'fa', 'ur'};
  String _lang = 'en';
  String _fallback = 'en';

  /// Session key under which the chosen language is persisted.
  static const String sessionKey = 'wt_lang';

  /// The active language code (e.g. `en`, `ar`).
  String get lang => _lang;

  /// The active [Locale].
  Locale get locale => Locale(_lang);

  /// Whether the active language is right-to-left.
  bool get isRtl => _rtlLangs.contains(_lang);

  /// Text direction for the active language.
  TextDirection get dir => isRtl ? TextDirection.rtl : TextDirection.ltr;

  /// The language codes that have translation tables.
  Iterable<String> get supported => _dict.keys;

  /// Registers [translations] (`{ lang: { key: value } }`) and selects the
  /// starting language: the persisted one if available, else [fallback].
  ///
  /// Call after `WtSession.init()` and `WtConfig.init()` so the persisted
  /// language can be read. Override the RTL set with [rtlLanguages]; disable
  /// reading the saved language with `usePersisted: false`.
  Future<void> init({
    required Map<String, Map<String, String>> translations,
    String fallback = 'en',
    Set<String>? rtlLanguages,
    bool usePersisted = true,
  }) async {
    _dict = translations;
    _fallback = fallback;
    if (rtlLanguages != null) _rtlLangs = rtlLanguages;
    _lang = fallback;
    if (usePersisted) {
      final saved = _readSaved();
      if (saved != null && _dict.containsKey(saved)) _lang = saved;
    }
    notifyListeners();
  }

  String? _readSaved() {
    try {
      return WtSession.get<String>(sessionKey);
    } catch (_) {
      return null; // session/config not ready — use fallback
    }
  }

  /// Switches to [lang], persists it, and notifies listeners.
  Future<void> setLocale(String lang) async {
    if (lang == _lang) return;
    _lang = lang;
    try {
      await WtSession.set(sessionKey, lang);
    } catch (_) {/* not persisted — session unavailable */}
    notifyListeners();
  }

  /// Toggles between the first two [supported] languages (handy for an AR/EN
  /// switch button). No-op if fewer than two are registered.
  Future<void> toggle() async {
    final langs = _dict.keys.toList();
    if (langs.length < 2) return;
    final next = langs[(langs.indexOf(_lang) + 1) % langs.length];
    await setLocale(next);
  }

  /// Translates [key] for the active language, falling back to the fallback
  /// language and then the raw key. `{name}` placeholders are replaced from
  /// [params].
  String t(String key, {Map<String, String>? params}) {
    var s = _dict[_lang]?[key] ?? _dict[_fallback]?[key] ?? key;
    if (params != null) {
      params.forEach((k, v) => s = s.replaceAll('{$k}', v));
    }
    return s;
  }

  /// Static shorthand for `WtI18n.instance.t(...)`.
  static String tr(String key, {Map<String, String>? params}) =>
      instance.t(key, params: params);

  /// Rebuilds the app whenever the language changes. Wrap your root:
  ///
  /// ```dart
  /// WtI18n.instance.app((context) => MaterialApp(
  ///   locale: WtI18n.instance.locale,
  ///   builder: WtI18n.instance.applyDirection, // RTL/LTR for the subtree
  ///   onGenerateRoute: router.dispatch,
  ///   initialRoute: router.initialRoute,
  /// ));
  /// ```
  Widget app(WidgetBuilder builder) => ListenableBuilder(
      listenable: this, builder: (context, _) => builder(context));

  /// A `MaterialApp.builder` that applies the current text [dir]ection to the
  /// subtree. This is the correct place to set direction — a `Directionality`
  /// placed *above* `MaterialApp` is overridden by its own localisation.
  Widget applyDirection(BuildContext context, Widget? child) => Directionality(
      textDirection: dir, child: child ?? const SizedBox.shrink());
}
