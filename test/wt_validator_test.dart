import 'package:flutter_test/flutter_test.dart';
import 'package:wt_framework/wt.dart';

void main() {
  group('WtValidator', () {
    test('required rejects blank, accepts value', () {
      final v = WtValidator.required();
      expect(v(null), isNotNull);
      expect(v('   '), isNotNull);
      expect(v('ok'), isNull);
    });

    test('email validates format, allows empty', () {
      final v = WtValidator.email();
      expect(v(''), isNull); // empty passes; combine with required
      expect(v('nope'), isNotNull);
      expect(v('user@example.com'), isNull);
    });

    test('minLength / maxLength', () {
      expect(WtValidator.minLength(3)('ab'), isNotNull);
      expect(WtValidator.minLength(3)('abc'), isNull);
      expect(WtValidator.maxLength(3)('abcd'), isNotNull);
      expect(WtValidator.maxLength(3)('abc'), isNull);
    });

    test('phone accepts plausible numbers', () {
      final v = WtValidator.phone();
      expect(v('+1 (555) 123-4567'), isNull);
      expect(v('12'), isNotNull);
      expect(v('abc'), isNotNull);
    });

    test('match compares to another field', () {
      final v = WtValidator.match(() => 'secret');
      expect(v('secret'), isNull);
      expect(v('other'), isNotNull);
    });

    test('compose returns first error only', () {
      final v = WtValidator.compose([
        WtValidator.required('req'),
        WtValidator.email('mail'),
      ]);
      expect(v(''), 'req');
      expect(v('bad'), 'mail');
      expect(v('a@b.com'), isNull);
    });
  });
}
