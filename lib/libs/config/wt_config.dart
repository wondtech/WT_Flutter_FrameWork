// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.4
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';

import '../anim/wt_anim_types.dart';

/// Global, immutable application configuration (the Flutter equivalent of
/// `wt_config.php`). Initialise once in `main()` with [WtConfig.init].
///
/// v1.1 adds the knobs a real backend needs — response envelopes, a bearer
/// token pulled from the session, a logical success flag and request-body
/// sanitisation control — so [WtModel] works against enveloped/authenticated
/// APIs, not just bare REST endpoints.
///
/// v1.4 adds the animation defaults ([animationsEnabled], [pageTransition],
/// [animDuration], [animCurve]) used by the WT animation layer and [WtRouter].
class WtConfig {
  /// App display name (MaterialApp title).
  final String appName;

  /// API base URL, no trailing slash (e.g. `https://example.com`).
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

  // ── v1.4: animation defaults (all optional, backward compatible) ─────────

  /// Global animation switch. When false, WT entrance animations show their
  /// final state instantly and [WtRouter] skips page transitions. The OS
  /// "reduce motion" setting is always honoured regardless of this flag.
  final bool animationsEnabled;

  /// Default page transition used by [WtRouter] when a [WtRoute] doesn't set
  /// its own. Defaults to [WtTransition.platform] so upgrading changes nothing.
  final WtTransition pageTransition;

  /// Default duration for WT entrance animations and page transitions.
  final Duration animDuration;

  /// Default curve for WT entrance animations and page transitions.
  final Curve animCurve;

  // ── v1.4: network resilience (used by [WtModel]) ─────────────────────────

  /// Per-request timeout for JSON calls. Null disables the timeout. Multipart
  /// uploads are exempt (they can legitimately run long).
  final Duration? requestTimeout;

  /// How many times [WtModel] retries a **GET** that times out, fails to
  /// connect, or returns 5xx (exponential backoff). 0 = no retry (default).
  /// Non-idempotent verbs (POST/PUT/DELETE) are never auto-retried.
  final int maxRetries;

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
    this.animationsEnabled = true,
    this.pageTransition = WtTransition.platform,
    this.animDuration = const Duration(milliseconds: 300),
    this.animCurve = Curves.easeOut,
    this.requestTimeout = const Duration(seconds: 30),
    this.maxRetries = 0,
  });

  static WtConfig? _instance;

  static void init(WtConfig config) {
    _instance = config;
  }

  static WtConfig get instance {
    assert(_instance != null,
        'WtConfig not initialized. Call WtConfig.init() first.');
    return _instance!;
  }

  /// The active config, or null if [init] hasn't been called. Non-throwing —
  /// used by the animation layer so it can fall back to defaults before
  /// [init] runs.
  static WtConfig? get maybeInstance => _instance;
}
