import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wt_framework/wt.dart';

void main() {
  group('animation layer', () {
    testWidgets('WtFadeIn renders its child', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: WtFadeIn(child: Text('hi')),
      ));
      expect(find.text('hi'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('reduced motion shows child immediately (no controller)',
        (tester) async {
      await tester.pumpWidget(const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: WtSlideIn(child: Text('rm')),
        ),
      ));
      expect(find.text('rm'), findsOneWidget);
    });

    testWidgets('.wtStagger extension renders each item', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              for (var i = 0; i < 3; i++) const Text('row').wtStagger(index: 0),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('row'), findsNWidgets(3));
    });
  });

  group('wtBuildRoute', () {
    const settings = RouteSettings(name: '/x');
    Widget b(BuildContext c) => const SizedBox();

    test('platform → MaterialPageRoute', () {
      final r = wtBuildRoute(
        builder: b,
        settings: settings,
        transition: WtTransition.platform,
      );
      expect(r, isA<MaterialPageRoute<dynamic>>());
    });

    test('fade → non-material PageRoute', () {
      final r = wtBuildRoute(
        builder: b,
        settings: settings,
        transition: WtTransition.fade,
      );
      expect(r, isNot(isA<MaterialPageRoute<dynamic>>()));
      expect(r, isA<PageRoute<dynamic>>());
    });
  });
}
