// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.2
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter_test/flutter_test.dart';
import 'package:wt_framework/wt.dart';

void main() {
  // Fixed reference instant so the relative output is deterministic.
  final now = DateTime(2026, 7, 12, 16, 0, 0);
  DateTime ago(Duration d) => now.subtract(d);

  group('WtHelper.timeAgo — range (short English)', () {
    test('sub-threshold reads as just now', () {
      expect(WtHelper.timeAgo(ago(const Duration(seconds: 3)), now: now), 'just now');
    });
    test('seconds', () {
      expect(WtHelper.timeAgo(ago(const Duration(seconds: 30)), now: now), '30s ago');
    });
    test('minutes / hours / days', () {
      expect(WtHelper.timeAgo(ago(const Duration(minutes: 5)), now: now), '5m ago');
      expect(WtHelper.timeAgo(ago(const Duration(hours: 3)), now: now), '3h ago');
      expect(WtHelper.timeAgo(ago(const Duration(days: 2)), now: now), '2d ago');
    });
    test('weeks / months / years', () {
      expect(WtHelper.timeAgo(ago(const Duration(days: 10)), now: now), '1w ago');
      expect(WtHelper.timeAgo(ago(const Duration(days: 60)), now: now), '2mo ago');
      expect(WtHelper.timeAgo(ago(const Duration(days: 400)), now: now), '1y ago');
    });
  });

  group('WtHelper.timeAgo — the bug this release fixes', () {
    test('a future date never yields a negative count', () {
      final future = now.add(const Duration(hours: 3)); // clock skew / server ahead
      expect(WtHelper.timeAgo(future, now: now), 'just now');
    });
  });

  group('WtHelper.timeAgo — Arabic grammar', () {
    String ar(Duration d) =>
        WtHelper.timeAgo(ago(d), now: now, labels: TimeAgoLabels.ar());
    test('singular / dual / plural / tamyiz', () {
      expect(ar(const Duration(minutes: 1)), 'منذ دقيقة');
      expect(ar(const Duration(minutes: 2)), 'منذ دقيقتين');
      expect(ar(const Duration(minutes: 5)), 'منذ 5 دقائق');
      expect(ar(const Duration(seconds: 30)), 'منذ 30 ثانية');
      expect(ar(const Duration(days: 400)), 'منذ سنة');
    });
  });

  group('WtHelper.timeAgoFrom — string input', () {
    test('parses "yyyy-MM-dd HH:mm:ss"', () {
      expect(
        WtHelper.timeAgoFrom('2026-07-12 15:55:00', now: now),
        '5m ago',
      );
    });
    test('null / blank / invalid → empty string (no throw)', () {
      expect(WtHelper.timeAgoFrom(null, now: now), '');
      expect(WtHelper.timeAgoFrom('   ', now: now), '');
      expect(WtHelper.timeAgoFrom('not-a-date', now: now), '');
    });
  });
}
