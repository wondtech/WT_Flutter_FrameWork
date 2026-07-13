# WT Framework — Flutter Edition

<p align="center">
  <img src="https://wondtech.com/pub_wt/imgs/logo.svg" width="200" alt="WondTech Logo"/>
</p>

<p align="center">
  <b>WT Framework - Flutter Edition v1.3</b><br/>
  Inspired by the original <a href="https://github.com/mogbil/WT_FrameWork">WondTech PHP MVC Framework</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.3-blue"/>
  <img src="https://img.shields.io/badge/flutter-%3E%3D3.10-blue?logo=flutter"/>
  <img src="https://img.shields.io/badge/dart-%3E%3D3.0-blue?logo=dart"/>
  <img src="https://img.shields.io/badge/license-MIT-green"/>
</p>

---

## Overview

A lightweight MVC framework that brings the simplicity and structure of the [WT Framework — PHP Edition](https://github.com/mogbil/WT_FrameWork) to Flutter mobile development.

It enforces a clean **Model → Controller → View** separation, built-in security helpers, session management, and a centralized router — so your Flutter app feels as organized as a well-structured PHP backend.

---

## Features

- **MVC Architecture** — Clear separation of Model, Controller, and View
- **Centralized Router** — Define all routes in one place, with dynamic segments (e.g. `/users/:id`)
- **Base Model** — HTTP GET / POST / PUT / DELETE with automatic JSON parsing
- **Base View** — Synchronous and async views with built-in loading/error/empty states
- **WtSecurity** — Input sanitization, HMAC signing, base64 encode/decode helpers, secure random token generation
- **WtSession** — Persistent session in SharedPreferences; the bearer token is stored in **secure storage** (Android Keystore / iOS Keychain)
- **WtHelper** — Common utilities: date formatting, string manipulation, flash messages, dialogs
- **WtConfig** — Centralized app configuration (base URL, secret key, theme)

---

## What's new in v1.3

**Secure bearer-token storage.** The value stored under `WtConfig.tokenKey` now
lives in `flutter_secure_storage` (Android Keystore / iOS Keychain) instead of
`SharedPreferences`, mirrored in a synchronous in-memory cache so `WtModel`
header injection stays non-async. Tokens saved by 1.2.x are migrated on first
read and the plaintext copy is scrubbed — **no app code changes and no forced
logout**. `logout()` / `destroy()` clear the secure token too.

```dart
await WtSession.set('token', token); // → Keychain / Keystore, not plaintext
```

> Note: `WtSecurity.encode`/`decode` are base64 **obfuscation, not encryption** —
> never store secrets with them; use the secure token path above.

## What's new in v1.2

`WtHelper.timeAgo` is now production-grade and localisable:

- **No negative counts** — a future or clock-skewed date (a just-posted row whose server time runs ahead) clamps to "just now" instead of `-3s ago`.
- **Full range** — seconds → minutes → hours → days → **weeks, months, years** (previously it fell back to an absolute date after 7 days).
- **Localisable** — pass `TimeAgoLabels` (`enShort` default, `en`, `ar` with correct singular/dual/plural forms) so pluralisation stays out of the framework.
- **New options** — `assumeUtc` (for UTC-stored timestamps), `now` (inject for deterministic tests), `justNowSeconds`.
- **`timeAgoFrom(String?)`** — parses an ISO-8601 / `yyyy-MM-dd HH:mm:ss` string and returns `''` for null/blank/invalid input instead of throwing.

```dart
WtHelper.timeAgoFrom(ad.createdAt, assumeUtc: true, labels: TimeAgoLabels.ar());
// → "منذ 5 دقائق"
```

## What's new in v1.1

`WtModel` is now ready for real, authenticated, enveloped backends — not just bare REST:

- **Bearer auth, automatic** — the token saved with `WtSession.set('token', ...)` is injected as `Authorization: Bearer <token>` on every request.
- **Response envelopes** — set `WtConfig.envelopeKey: 'data'` and models transparently read `{ "state": true, "data": {...} }`.
- **Real error messages** — a failed response raises `WtModelException` carrying the server's `msg` (key configurable via `WtConfig.messageKey`); optional `successKey` treats `200 + {state:false}` as a failure too.
- **Low-level client** — `getJson / postJson / putJson / deleteJson / postMultipart` for action-style endpoints (`/api/login`, `/api/ad/5`) and **file uploads** (`WtUpload`).
- **Safer defaults** — client-side body sanitisation is now **opt-in** (`WtConfig.sanitizeRequests`) so it no longer mangles legitimate content; add per-model headers via the `extraHeaders` getter.

```dart
WtConfig.init(const WtConfig(
  appName: 'Findlly',
  baseUrl: 'https://findlly.co',
  secretKey: '...',
  envelopeKey: 'data',   // unwrap { state, data }
  successKey: 'state',   // 200 + state:false => error
  tokenKey: 'token',     // WtSession key holding the bearer token
));

// action endpoint + upload, all token- & envelope-aware:
class AdsModel extends WtModel<Ad> {
  @override String get endpoint => '/api/ads';
  @override Ad fromJson(Map<String, dynamic> j) => Ad.fromJson(j);

  Future<List<Ad>> search(String q) async =>
      fromJsonList((await getJson('/api/ads', query: {'q': q}))['items']);

  Future<Ad> createWithPhotos(Map<String, String> fields, List<int> jpg) async =>
      fromJson(await postMultipart('/api/createad',
        fields: fields,
        files: [WtUpload(field: 'images[]', bytes: jpg, filename: 'p.jpg', contentType: 'image/jpeg')],
      ));
}
```

---

## Project Structure

```
wt_framework/
├── lib/
│   ├── wt.dart          ← Package entry point
│   └── libs/
│       ├── core/
│       │   ├── wt_app.dart        ← App root widget
│       │   └── wt_router.dart     ← Route dispatcher
│       ├── config/
│       │   └── wt_config.dart     ← Global config
│       ├── mvc/
│       │   ├── wt_controller.dart ← Base Controller
│       │   ├── wt_model.dart      ← Base Model + HTTP
│       │   └── wt_view.dart       ← Base View
│       └── helpers/
│           ├── wt_security.dart   ← Security utilities
│           ├── wt_session.dart    ← Session manager
│           └── wt_helper.dart     ← General helpers
│
example/
├── main.dart
└── lib/
    ├── controllers/
    ├── models/
    └── views/
```
---

## Installation

### Depend on it

Run this command:

With Flutter:

```bash
$ flutter pub add wt_framework
```

This will add a line like this to your package's `pubspec.yaml` (and run an implicit `flutter pub get`):

```yaml
dependencies:
  wt_framework: ^1.3.1
```

<details>
<summary>Alternative: install from Git</summary>

```yaml
dependencies:
  wt_framework:
    git:
      url: https://github.com/wondtech/WT_Flutter_FrameWork.git
```
Then run `flutter pub get`.
</details>

Then import in your Dart files:
```dart
import 'package:wt_framework/wt.dart';
```

---

## Usage

### 1. Initialize the App — `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WtSession.init(); // equivalent to session_start()

  WtConfig.init(const WtConfig(
    appName: 'My App',
    baseUrl: 'https://api.example.com',
    secretKey: 'your_secret_key',
  ));

  runApp(WtApp(
    config: WtConfig.instance,
    router: WtRouter(
      initialRoute: '/',
      routes: [
        WtRoute(path: '/',           builder: (s) => HomeController(s)),
        WtRoute(path: '/login',      builder: (s) => LoginController(s)),
        WtRoute(path: '/users',      builder: (s) => UsersController(s)),
        WtRoute(path: '/users/:id',  builder: (s) => UserDetailController(s)),
      ],
    ),
  ));
}
```

---

### 2. Define a Model

```dart
class UserModel extends WtModel<User> {
  @override
  String get endpoint => '/users';

  @override
  User fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
  );
}

// Fetch all users
final users = await UserModel().fetchAll();

// Fetch one
final user = await UserModel().fetch(params: {'id': '1'});

// Create
await UserModel().create({'name': 'Ali', 'email': 'ali@example.com'});

// Update
await UserModel().update('1', {'name': 'Ali Updated'});

// Delete
await UserModel().delete('1');
```

---

### 3. Define a Controller

```dart
class UsersController extends WtController {
  UsersController(super.settings);

  @override
  WtView view(BuildContext context) {
    final v = UsersView();
    v.assign('title', 'All Users');
    v.assign('onTap', (int id) {
      navigate(context, '/users/:id', args: {'id': id.toString()});
    });
    return v;
  }
}
```

---

### 4. Define a View

**Synchronous:**
```dart
class HomeView extends WtView {
  @override
  Widget build(BuildContext context) {
    return scaffold(
      context: context,
      body: Center(child: Text(title)),
    );
  }
}
```

**Async (loads data before rendering):**
```dart
class UsersView extends WtAsyncView<List<User>> {
  @override
  Future<List<User>> loadData() => UserModel().fetchAll();

  @override
  Widget buildData(BuildContext context, List<User> users) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        children: users.map((u) => ListTile(title: Text(u.name))).toList(),
      ),
    );
  }
}
```

---

### 5. Security

```dart
// Sanitize input — protection against XSS and SQL injection
final safe = WtSecurity.sanitize(formData);

// Hash data with your secret key
final hash = WtSecurity.hashWithKey(data, WtConfig.instance.secretKey);

// Encode / Decode
final encoded = WtSecurity.encode(data, secretKey);
final decoded = WtSecurity.decode(encoded, secretKey);

// Validate
WtSecurity.isValidEmail('user@example.com'); // true/false
WtSecurity.isValidInput(userInput);

// Generate secure token
final token = WtSecurity.generateToken(); // 32-char random string
```

---

### 6. Session Management

```dart
// Login — saves user to session
await WtSession.login({'id': 1, 'name': 'Ali', 'email': 'ali@example.com'});

// Check login state
WtSession.isLoggedIn(); // true/false

// Get logged-in user data
final user = WtSession.getUser();

// Store and retrieve custom values
await WtSession.set('cart_count', 5);
final count = WtSession.get<int>('cart_count');

// Logout — clears session
await WtSession.logout();
```

---

### 7. Helpers

```dart
// Flash messages (success / error)
WtHelper.flash(context, 'Saved successfully!');
WtHelper.flash(context, 'Something went wrong', isError: true);

// Loading dialog
WtHelper.showLoading(context);
WtHelper.hideLoading(context);

// Confirm dialog
final confirmed = await WtHelper.confirm(context,
  title: 'Delete',
  message: 'Are you sure?',
);

// Format date
WtHelper.formatDate(DateTime.now()); // "2024-01-15"
WtHelper.timeAgo(someDate);          // "3h ago"

// Format number
WtHelper.currency(1999.5);           // "$1999.50"
WtHelper.formatNumber(1000000);      // "1,000,000"

// String utilities
WtHelper.truncate('Long text...', 20);
WtHelper.ucFirst('hello world');     // "Hello world"
WtHelper.slug('My Page Title');      // "my-page-title"
```

---

## License

MIT License © 2026 WT Framework — Flutter Edition v1.3 — Built by [WondTech](https://wondtech.com). All rights reserved.
