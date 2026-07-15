import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';
import 'package:qalam_mobile/shared/widgets/branding/q_brand_mark.dart';

Widget _harness(Brightness brightness, Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildQalamTheme(brightness: brightness),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('renders as a labelled image with a painter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(Brightness.light, const QBrandMark()));
    expect(find.byType(QBrandMark), findsOneWidget);
    expect(find.bySemanticsLabel('Qalam'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('untiled mark builds on the paper canvas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _harness(Brightness.light, const QBrandMark(tile: false)),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(QBrandMark), findsOneWidget);
  });

  testWidgets('QBrandMark — tiled (light)', (WidgetTester tester) async {
    await tester.pumpWidget(
      _harness(Brightness.light, const QBrandMark(size: 256)),
    );
    await tester.pump();
    await expectLater(
      find.byType(QBrandMark),
      matchesGoldenFile('goldens/q_brand_mark_tiled.png'),
    );
  });

  testWidgets('QBrandMark — untiled (dark)', (WidgetTester tester) async {
    await tester.pumpWidget(
      _harness(Brightness.dark, const QBrandMark(size: 256, tile: false)),
    );
    await tester.pump();
    await expectLater(
      find.byType(QBrandMark),
      matchesGoldenFile('goldens/q_brand_mark_untiled_dark.png'),
    );
  });
}
