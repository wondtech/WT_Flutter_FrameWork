# Changelog

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
