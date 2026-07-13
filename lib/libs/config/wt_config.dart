// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.3
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';

/// Global, immutable application configuration (the Flutter equivalent of
/// `wt_config.php`). Initialise once in `main()` with [WtConfig.init].
///
/// v1.1 adds the knobs a real backend needs — response envelopes, a bearer
/// token pulled from the session, a logical success flag and request-body
/// sanitisation control — so [WtModel] works against enveloped/authenticated
/// APIs, not just bare REST endpoints.
class WtConfig {
  /// App display name (MaterialApp title).
  final String appName;

  /// API base URL, no trailing slash (e.g. `https://findlly.co`).
  final String baseUrl;

  /// Shared secret for [WtSecurity] hashing / session obfuscation.
  final String secretKey;

  /// Optional Material theme.
  final ThemeData? theme;

  /// Verbose logging when true.
  final bool debugMode;

  // ── v1.1: real-API plumbing (all optional, backward compatible) ──────────

  /// When set, [WtModel] unwraps `response[envelopeKey]` before parsing, so an
  /// API that replies `{ "state": true, "data": {...} }` is read transparently.
  /// Leave null for a bare API that returns the object/array directly.
  final String? envelopeKey;

  /// Key holding a human-readable error message in a failed response body
  /// (e.g. `msg`). Surfaced in [WtModelException.message].
  final String messageKey;

  /// When set, a 2xx response whose `body[successKey]` is falsy is still
  /// treated as a failure (for APIs that return 200 with `{ "state": false }`).
  final String? successKey;

  /// Session key under which the bearer token is stored; [WtModel] injects it
  /// as `Authorization: Bearer <token>` automatically when present.
  final String tokenKey;

  /// Client-side sanitisation of request bodies. Off by default: the server is
  /// the source of truth (prepared statements / server escaping) and blanket
  /// keyword stripping corrupts legitimate content.
  final bool sanitizeRequests;

  const WtConfig({
    required this.appName,
    required this.baseUrl,
    required this.secretKey,
    this.theme,
    this.debugMode = false,
    this.envelopeKey,
    this.messageKey = 'msg',
    this.successKey,
    this.tokenKey = 'token',
    this.sanitizeRequests = false,
  });

  static WtConfig? _instance;

  static void init(WtConfig config) {
    _instance = config;
  }

  static WtConfig get instance {
    assert(_instance != null, 'WtConfig not initialized. Call WtConfig.init() first.');
    return _instance!;
  }
}
