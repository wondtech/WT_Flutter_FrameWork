// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.2
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WtHelper {

  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// A relative "time ago" phrase covering seconds → years.
  ///
  /// Robust by design:
  ///  • **Never emits a negative count** — a future or clock-skewed [date]
  ///    (e.g. a just-posted row whose server time is slightly ahead) clamps to
  ///    the labels' "just now" instead of `-3s ago`.
  ///  • **Full range** — seconds, minutes, hours, days, weeks, months, years.
  ///  • **Localisable** — pass [labels] (`TimeAgoLabels.en()` / `.enShort()` /
  ///    `.ar()`, or your own) so plural/dual rules stay out of the framework.
  ///
  /// Parameters:
  ///  • [now] — reference instant; inject in tests for determinism (defaults to
  ///    `DateTime.now()`).
  ///  • [assumeUtc] — reinterpret a naive (offset-less) [date] as UTC before
  ///    comparing. Use when the value came from a server/DB that stores UTC;
  ///    a value already flagged UTC is left as-is.
  ///  • [justNowSeconds] — anything more recent than this reads as "just now".
  static String timeAgo(
    DateTime date, {
    DateTime? now,
    bool assumeUtc = false,
    int justNowSeconds = 10,
    TimeAgoLabels? labels,
  }) {
    final l = labels ?? TimeAgoLabels.enShort();
    var d = date;
    if (assumeUtc && !d.isUtc) {
      d = DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second,
          d.millisecond, d.microsecond);
    }
    var diff = (now ?? DateTime.now()).difference(d);
    if (diff.isNegative) diff = Duration.zero; // clock skew / future → "just now"

    final s = diff.inSeconds;
    if (s < justNowSeconds) return l.justNow;
    if (s < 60) return l.format(s, TimeUnit.second);
    final m = diff.inMinutes;
    if (m < 60) return l.format(m, TimeUnit.minute);
    final h = diff.inHours;
    if (h < 24) return l.format(h, TimeUnit.hour);
    final days = diff.inDays;
    if (days < 7) return l.format(days, TimeUnit.day);
    if (days < 30) return l.format(days ~/ 7, TimeUnit.week);
    if (days < 365) return l.format(days ~/ 30, TimeUnit.month);
    return l.format(days ~/ 365, TimeUnit.year);
  }

  /// [timeAgo] for a datetime **string** (ISO-8601 or `yyyy-MM-dd HH:mm:ss`).
  /// Returns `''` for null / blank / unparseable input instead of throwing —
  /// safe to drop straight into a widget from an API/DB field.
  static String timeAgoFrom(
    String? dateTime, {
    DateTime? now,
    bool assumeUtc = false,
    int justNowSeconds = 10,
    TimeAgoLabels? labels,
  }) {
    if (dateTime == null || dateTime.trim().isEmpty) return '';
    final d = DateTime.tryParse(dateTime.trim().replaceFirst(' ', 'T'));
    if (d == null) return '';
    return timeAgo(d,
        now: now,
        assumeUtc: assumeUtc,
        justNowSeconds: justNowSeconds,
        labels: labels);
  }


  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  static String ucFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String slug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  static String currency(double amount, {String symbol = '\$', int decimals = 2}) {
    return '$symbol${amount.toStringAsFixed(decimals)}';
  }

  static String formatNumber(num number) {
    return NumberFormat('#,###').format(number);
  }

  static void flash(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Time granularity emitted by [WtHelper.timeAgo].
enum TimeUnit { second, minute, hour, day, week, month, year }

/// Localisable labels for [WtHelper.timeAgo]. Supply [justNow] and a [format]
/// that turns a count + [TimeUnit] into a phrase, so any language — including
/// its singular/dual/plural rules — plugs in without touching the framework.
///
/// Built-ins: [TimeAgoLabels.enShort] (default), [TimeAgoLabels.en],
/// [TimeAgoLabels.ar].
class TimeAgoLabels {
  /// Phrase for durations under `justNowSeconds` (and for future/skewed dates).
  final String justNow;

  /// Renders `value` of `unit` into a phrase, e.g. `(5, TimeUnit.minute)`.
  final String Function(int value, TimeUnit unit) format;

  const TimeAgoLabels({required this.justNow, required this.format});

  /// Short English (default, backward compatible): `5m ago`, `3w ago`, `2mo ago`.
  factory TimeAgoLabels.enShort() {
    const u = {
      TimeUnit.second: 's',
      TimeUnit.minute: 'm',
      TimeUnit.hour: 'h',
      TimeUnit.day: 'd',
      TimeUnit.week: 'w',
      TimeUnit.month: 'mo',
      TimeUnit.year: 'y',
    };
    return TimeAgoLabels(
      justNow: 'just now',
      format: (v, unit) => '$v${u[unit]} ago',
    );
  }

  /// Long English with pluralisation: `5 minutes ago`, `1 hour ago`.
  factory TimeAgoLabels.en() {
    const u = {
      TimeUnit.second: 'second',
      TimeUnit.minute: 'minute',
      TimeUnit.hour: 'hour',
      TimeUnit.day: 'day',
      TimeUnit.week: 'week',
      TimeUnit.month: 'month',
      TimeUnit.year: 'year',
    };
    return TimeAgoLabels(
      justNow: 'just now',
      format: (v, unit) => '$v ${u[unit]}${v == 1 ? '' : 's'} ago',
    );
  }

  /// Arabic with correct singular/dual/plural forms: `منذ دقيقة`, `منذ دقيقتين`,
  /// `منذ 5 دقائق`, `منذ 30 ثانية` (11+ falls back to the singular tamyiz form).
  factory TimeAgoLabels.ar() {
    const forms = {
      TimeUnit.second: ['ثانية', 'ثانيتين', 'ثوانٍ'],
      TimeUnit.minute: ['دقيقة', 'دقيقتين', 'دقائق'],
      TimeUnit.hour: ['ساعة', 'ساعتين', 'ساعات'],
      TimeUnit.day: ['يوم', 'يومين', 'أيام'],
      TimeUnit.week: ['أسبوع', 'أسبوعين', 'أسابيع'],
      TimeUnit.month: ['شهر', 'شهرين', 'أشهر'],
      TimeUnit.year: ['سنة', 'سنتين', 'سنوات'],
    };
    return TimeAgoLabels(
      justNow: 'الآن',
      format: (v, unit) {
        final f = forms[unit]!;
        if (v == 1) return 'منذ ${f[0]}';
        if (v == 2) return 'منذ ${f[1]}';
        if (v <= 10) return 'منذ $v ${f[2]}';
        return 'منذ $v ${f[0]}';
      },
    );
  }
}
