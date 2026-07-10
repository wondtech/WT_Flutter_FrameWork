// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.1
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/wt_config.dart';
import '../helpers/wt_security.dart';
import '../helpers/wt_session.dart';

/// One file to attach to a multipart request.
class WtUpload {
  final String field;        // form field name (e.g. 'images[]', 'avatar')
  final List<int> bytes;     // file contents
  final String filename;     // e.g. 'photo.jpg'
  final String? contentType; // e.g. 'image/jpeg' (optional)

  WtUpload({
    required this.field,
    required this.bytes,
    required this.filename,
    this.contentType,
  });
}

/// Base Model — a thin, typed HTTP client (the Flutter equivalent of a PHP
/// model). v1.1 makes it production-ready:
///  • injects `Authorization: Bearer <token>` from the session automatically,
///  • unwraps an optional response envelope (`WtConfig.envelopeKey`),
///  • surfaces the server error message (`WtConfig.messageKey`),
///  • exposes low-level [getJson]/[postJson]/[putJson]/[deleteJson]/
///    [postMultipart] so action-style endpoints and file uploads are easy.
///
/// The high-level [fetch]/[fetchAll]/[create]/[update]/[delete] helpers remain
/// for plain REST resources and are now envelope- and token-aware.
abstract class WtModel<T> {
  /// Resource endpoint used by the REST helpers (e.g. `/users`).
  String get endpoint;

  T fromJson(Map<String, dynamic> json);

  List<T> fromJsonList(List<dynamic> jsonList) =>
      jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();

  /// Extra per-model request headers (override to add your own).
  Map<String, String> get extraHeaders => const {};

  // ── High-level REST helpers (backward compatible) ────────────────────────

  Future<T> fetch({Map<String, String>? params}) async =>
      fromJson(_asMap(await getJson(endpoint, query: params)));

  Future<List<T>> fetchAll({Map<String, String>? params}) async =>
      fromJsonList(_asList(await getJson(endpoint, query: params)));

  Future<T> create(Map<String, dynamic> data) async =>
      fromJson(_asMap(await postJson(endpoint, body: data)));

  Future<T> update(String id, Map<String, dynamic> data) async =>
      fromJson(_asMap(await putJson('$endpoint/$id', body: data)));

  Future<bool> delete(String id) async {
    await deleteJson('$endpoint/$id');
    return true;
  }

  // ── Low-level client (use for action endpoints / uploads) ────────────────

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async =>
      _decode(await http.get(_url(path, query), headers: _headers()));

  Future<dynamic> postJson(String path, {Object? body}) async => _decode(
        await http.post(_url(path), headers: _headers(), body: _encode(body)),
      );

  Future<dynamic> putJson(String path, {Object? body}) async => _decode(
        await http.put(_url(path), headers: _headers(), body: _encode(body)),
      );

  Future<dynamic> deleteJson(String path, {Object? body}) async => _decode(
        await http.delete(_url(path), headers: _headers(), body: _encode(body)),
      );

  /// POST a multipart/form-data request (text fields + files).
  Future<dynamic> postMultipart(
    String path, {
    Map<String, String>? fields,
    List<WtUpload>? files,
  }) async {
    final req = http.MultipartRequest('POST', _url(path));
    // multipart sets its own Content-Type boundary — drop the JSON one.
    final h = _headers()..remove('Content-Type');
    req.headers.addAll(h);
    if (fields != null) req.fields.addAll(fields);
    for (final f in files ?? const <WtUpload>[]) {
      req.files.add(http.MultipartFile.fromBytes(
        f.field,
        f.bytes,
        filename: f.filename,
        contentType: f.contentType != null ? MediaType.parse(f.contentType!) : null,
      ));
    }
    return _decode(await http.Response.fromStream(await req.send()));
  }

  // ── internals ────────────────────────────────────────────────────────────

  Uri _url(String path, [Map<String, String>? query]) {
    final base = Uri.parse('${WtConfig.instance.baseUrl}$path');
    return (query != null && query.isNotEmpty)
        ? base.replace(queryParameters: {...base.queryParameters, ...query})
        : base;
  }

  Map<String, String> _headers() {
    final cfg = WtConfig.instance;
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      final token = WtSession.get<String>(cfg.tokenKey);
      if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    } catch (_) {/* session not initialised — send unauthenticated */}
    h.addAll(extraHeaders);
    return h;
  }

  String? _encode(Object? body) {
    if (body == null) return null;
    if (WtConfig.instance.sanitizeRequests && body is Map<String, dynamic>) {
      return json.encode(WtSecurity.sanitize(body));
    }
    return json.encode(body);
  }

  /// Decode a response: raise [WtModelException] with the server message on
  /// failure, then strip the configured envelope from a successful body.
  dynamic _decode(http.Response res) {
    final cfg = WtConfig.instance;
    dynamic body;
    try {
      body = res.body.isEmpty ? null : json.decode(res.body);
    } catch (_) {
      body = res.body; // non-JSON payload (rare)
    }

    bool ok = res.statusCode < 400;
    if (ok && cfg.successKey != null && body is Map && body.containsKey(cfg.successKey)) {
      final s = body[cfg.successKey];
      ok = s == true || s == 'true' || s == 1 || s == '1';
    }
    if (!ok) {
      final msg = (body is Map && body[cfg.messageKey] != null)
          ? body[cfg.messageKey].toString()
          : 'HTTP ${res.statusCode}';
      throw WtModelException(msg, res.statusCode);
    }

    if (cfg.envelopeKey != null && body is Map && body.containsKey(cfg.envelopeKey)) {
      return body[cfg.envelopeKey];
    }
    return body;
  }

  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    throw WtModelException('Expected an object, got ${v.runtimeType}', 0);
  }

  List<dynamic> _asList(dynamic v) {
    if (v is List) return v;
    // Convenience for paginated envelopes: { items: [...] }.
    if (v is Map && v['items'] is List) return v['items'] as List;
    throw WtModelException('Expected a list, got ${v.runtimeType}', 0);
  }
}

class WtModelException implements Exception {
  final String message;
  final int statusCode;
  WtModelException(this.message, this.statusCode);
  @override
  String toString() => 'WtModelException($statusCode): $message';
}
