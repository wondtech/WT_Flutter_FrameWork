// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.3
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'dart:async';
import 'dart:convert';
import 'wt_security.dart';
import '../config/wt_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistent key/value session.
///
/// Ordinary values live in [SharedPreferences] (base64-obfuscated, NOT
/// encrypted — do not put secrets here). The **bearer token** is the one
/// exception: whenever a value is stored under the configured
/// [WtConfig.tokenKey] it is transparently redirected to
/// [FlutterSecureStorage] (Android Keystore / iOS Keychain) and mirrored in a
/// synchronous in-memory cache so [get] stays non-async for `WtModel`. Tokens
/// written by an older release (plaintext in SharedPreferences) are migrated
/// to secure storage on first read and the plaintext copy is scrubbed.
class WtSession {
  static SharedPreferences? _prefs;

  // v10+ encrypts with modern ciphers by default (the old
  // encryptedSharedPreferences flag is deprecated and ignored).
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  /// Fixed secure-storage key — independent of [WtConfig] so the token can be
  /// preloaded in [init] before the config singleton exists.
  static const String _kSecureToken = 'wt_secure_token';

  /// Synchronous mirror of the secure token (so [get] can stay non-async).
  static String? _tokenCache;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Preload the token from the Keychain/Keystore into the sync cache.
    try {
      _tokenCache = await _secure.read(key: _kSecureToken);
    } catch (_) {
      _tokenCache = null; // secure storage unavailable — fail closed (no token)
    }
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'WtSession not initialized. Call WtSession.init()');
    return _prefs!;
  }

  /// The configured token key, or null if [WtConfig] isn't initialised yet.
  static String? _tokenKeyOrNull() {
    try {
      return WtConfig.instance.tokenKey;
    } catch (_) {
      return null;
    }
  }

  static Future<void> set(String key, dynamic value) async {
    // Bearer token → secure storage (never SharedPreferences).
    if (key == _tokenKeyOrNull()) {
      final token = value?.toString() ?? '';
      _tokenCache = token;
      await _secure.write(key: _kSecureToken, value: token);
      await _p.remove('wt_session_$key'); // scrub any legacy plaintext copy
      return;
    }
    final encoded = WtSecurity.encode(
      json.encode(value),
      WtConfig.instance.secretKey,
    );
    await _p.setString('wt_session_$key', encoded);
  }

  static T? get<T>(String key) {
    if (key == _tokenKeyOrNull()) {
      if (_tokenCache != null) return _tokenCache as T?;
      // One-time migration: a token saved by an older release still lives in
      // SharedPreferences. Read it synchronously, then move it to secure
      // storage and delete the plaintext copy (fire-and-forget).
      final raw = _p.getString('wt_session_$key');
      if (raw == null) return null;
      final decoded = WtSecurity.decode(raw, WtConfig.instance.secretKey);
      if (decoded == null) return null;
      String? tok;
      try {
        tok = json.decode(decoded) as String?;
      } catch (_) {
        tok = decoded;
      }
      if (tok == null || tok.isEmpty) return null;
      _tokenCache = tok;
      unawaited(_secure.write(key: _kSecureToken, value: tok));
      unawaited(_p.remove('wt_session_$key'));
      return tok as T?;
    }

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
    if (key == _tokenKeyOrNull()) return _tokenCache != null;
    return _p.containsKey('wt_session_$key');
  }

  static Future<void> remove(String key) async {
    if (key == _tokenKeyOrNull()) {
      _tokenCache = null;
      await _secure.delete(key: _kSecureToken);
      await _p.remove('wt_session_$key');
      return;
    }
    await _p.remove('wt_session_$key');
  }

  static Future<void> destroy() async {
    _tokenCache = null;
    try {
      await _secure.delete(key: _kSecureToken);
    } catch (_) {/* ignore */}
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
    // Also revoke the locally-held bearer token.
    final tk = _tokenKeyOrNull();
    if (tk != null) await remove(tk);
  }

  static Map<String, dynamic>? getUser() {
    return get<Map<String, dynamic>>('user_data');
  }
}
