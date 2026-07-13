# Changelog

## 1.3.0

- **Secure bearer-token storage.** `WtSession` now stores the value written
  under `WtConfig.tokenKey` in `flutter_secure_storage` (Android Keystore /
  iOS Keychain) instead of `SharedPreferences`, mirrored in a synchronous
  in-memory cache so `WtModel` header injection stays non-async. All other
  keys are unchanged. Tokens saved by 1.2.x (plaintext base64 in
  SharedPreferences) are migrated to secure storage on first read and the
  plaintext copy is scrubbed — no forced logout. `logout()`/`destroy()` now
  also clear the secure token. No app code changes required.

## 1.2.0

- `WtHelper.timeAgo` reworked and hardened:
  - Never emits a negative count — future / clock-skewed dates clamp to
    "just now" instead of `-3s ago`.
  - Full range: seconds, minutes, hours, days, **weeks, months, years**
    (previously fell back to an absolute date after 7 days).
  - Localisable via the new `TimeAgoLabels` (`enShort` default, `en`, `ar`
    with correct singular/dual/plural forms) and `TimeUnit` enum.
  - New `assumeUtc`, `now` (testable) and `justNowSeconds` options.
- New `WtHelper.timeAgoFrom(String?)` — parses an ISO-8601 / `yyyy-MM-dd
  HH:mm:ss` string and returns `''` for null/blank/invalid input (no throw).

## 1.1.0

- Initial public release of the WondTech Flutter MVC Framework.
- Core: `WtApp`, `WtRouter` for app bootstrap and named-route navigation.
- MVC: `WtController`, `WtModel`, `WtView` base classes.
- Helpers: `WtHelper`, `WtSecurity`, `WtSession` utilities.
- Config: centralized `WtConfig` settings.
- Networking: enveloped `{state, data, msg}` API model with bearer-token auth
  and multipart image uploads.
- Example app demonstrating controllers, models, and routing.
