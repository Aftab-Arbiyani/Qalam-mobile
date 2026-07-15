import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';
import 'package:qalam_mobile/shared/widgets/buttons/q_button.dart';

Widget _host(Widget child) => MaterialApp(
  theme: buildQalamTheme(brightness: Brightness.light),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('renders its label and fires onPressed', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      _host(
        QButton(
          label: 'Publish',
          variant: QButtonVariant.primary,
          onPressed: () => taps++,
        ),
      ),
    );
    expect(find.text('Publish'), findsOneWidget);
    await tester.tap(find.text('Publish'));
    expect(taps, 1);
  });

  testWidgets('loading shows a spinner and blocks taps', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      _host(QButton(label: 'Save', loading: true, onPressed: () => taps++)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(QButton), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('a button without onPressed is disabled (InkWell has no onTap)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const QButton(label: 'Nope')));
    expect(find.text('Nope'), findsOneWidget);
    final InkWell inkWell = tester.widget<InkWell>(
      find.descendant(of: find.byType(QButton), matching: find.byType(InkWell)),
    );
    expect(inkWell.onTap, isNull);
  });
}
