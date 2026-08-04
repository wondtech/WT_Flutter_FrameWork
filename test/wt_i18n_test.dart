import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wt_framework/wt.dart';

void main() {
  group('WtI18n', () {
    setUp(() async {
      await WtI18n.instance.init(
        translations: const {
          'en': {'hello': 'Hello {name}', 'only_en': 'English'},
          'ar': {'hello': 'مرحبا {name}'},
        },
        usePersisted: false,
      );
    });

    test('translates with interpolation', () {
      expect(WtI18n.tr('hello', params: {'name': 'Ali'}), 'Hello Ali');
    });

    test('falls back to fallback language then raw key', () async {
      await WtI18n.instance.setLocale('ar');
      expect(WtI18n.tr('only_en'), 'English'); // missing in ar → en fallback
      expect(WtI18n.tr('missing'), 'missing'); // absent everywhere → key
    });

    test('direction follows language', () async {
      await WtI18n.instance.setLocale('en');
      expect(WtI18n.instance.dir, TextDirection.ltr);
      expect(WtI18n.instance.isRtl, isFalse);
      await WtI18n.instance.setLocale('ar');
      expect(WtI18n.instance.dir, TextDirection.rtl);
      expect(WtI18n.instance.isRtl, isTrue);
    });

    test('toggle cycles between languages and notifies', () async {
      await WtI18n.instance.setLocale('en');
      var notified = 0;
      void listener() => notified++;
      WtI18n.instance.addListener(listener);
      await WtI18n.instance.toggle();
      expect(WtI18n.instance.lang, 'ar');
      expect(notified, greaterThan(0));
      WtI18n.instance.removeListener(listener);
    });
  });
}
