// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.2
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'dart:convert';
import 'wt_security.dart';
import '../config/wt_config.dart';
import 'package:shared_preferences/shared_preferences.dart';


class WtSession {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'WtSession not initialized. Call WtSession.init()');
    return _prefs!;
  }

  static Future<void> set(String key, dynamic value) async {
    final encoded = WtSecurity.encode(
      json.encode(value),
      WtConfig.instance.secretKey,
    );
    await _p.setString('wt_session_$key', encoded);
  }

  static T? get<T>(String key) {
    final raw = _p.getString('wt_session_$key');
    if (raw == null) return null;
    final decoded = WtSecurity.decode(raw, WtConfig.instance.secretKey);
    if (decoded == null) return null;
    try {
      return json.decode(decoded) as T;
    } catch (_) {
      return null;
    }
  }

  static bool has(String key) {
    return _p.containsKey('wt_session_$key');
  }

  static Future<void> remove(String key) async {
    await _p.remove('wt_session_$key');
  }

  static Future<void> destroy() async {
    final keys = _p.getKeys().where((k) => k.startsWith('wt_session_')).toList();
    for (final key in keys) {
      await _p.remove(key);
    }
  }

  static bool isLoggedIn() => has('user_id');

  static Future<void> login(Map<String, dynamic> userData) async {
    await set('user_id', userData['id']);
    await set('user_data', userData);
  }

  static Future<void> logout() async {
    await remove('user_id');
    await remove('user_data');
  }

  static Map<String, dynamic>? getUser() {
    return get<Map<String, dynamic>>('user_data');
  }
}
