import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';
import 'package:qalam_mobile/shared/widgets/buttons/q_button.dart';

/// Golden test (docs/40 §38.2). Deterministic in the test environment (the test
/// runner substitutes a fixed font). Regenerate with `--update-goldens`.
void main() {
  testWidgets('QButton variants — light', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  QButton(label: 'Primary', variant: QButtonVariant.primary),
                  SizedBox(height: 12),
                  QButton(label: 'Secondary'),
                  SizedBox(height: 12),
                  QButton(label: 'Danger', variant: QButtonVariant.danger),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Column),
      matchesGoldenFile('goldens/q_button_light.png'),
    );
  });
}
