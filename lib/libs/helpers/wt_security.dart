// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.1
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class WtSecurity {

  static Map<String, dynamic> sanitize(Map<String, dynamic> data) {
    return data.map((key, value) {
      return MapEntry(key, _sanitizeValue(value));
    });
  }

  static dynamic _sanitizeValue(dynamic value) {
    if (value is String) {
      return _escapeHtml(_stripSqlInjection(value));
    } else if (value is Map<String, dynamic>) {
      return sanitize(value);
    } else if (value is List) {
      return value.map(_sanitizeValue).toList();
    }
    return value;
  }

  static String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  static String _stripSqlInjection(String input) {
    final dangerous = RegExp(
      r"(--|;|/\*|\*/|xp_|exec|insert|select|delete|update|drop|create|alter|union|cast|convert|char|varchar|nchar|nvarchar|declare|exec|execute)",
      caseSensitive: false,
    );
    return input.replaceAll(dangerous, '');
  }

  static String hashWithKey(String data, String secretKey) {
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  static String encode(String data, String secretKey) {
    final combined = '$data:$secretKey';
    return base64Url.encode(utf8.encode(combined));
  }

  static String? decode(String encoded, String secretKey) {
    try {
      final decoded = utf8.decode(base64Url.decode(encoded));
      final parts = decoded.split(':');
      if (parts.length < 2) return null;
      parts.removeLast(); // remove key
      return parts.join(':');
    } catch (_) {
      return null;
    }
  }

  static String generateToken({int length = 32}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidInput(String input) {
    return input.trim().isNotEmpty && input.length <= 1000;
  }
}
