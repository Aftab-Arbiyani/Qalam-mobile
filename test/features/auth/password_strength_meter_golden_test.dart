import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/auth/presentation/widgets/password_strength_meter.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

/// Golden test (docs/40 §38.2) for the password-strength meter — a design-system
/// component with per-level colour. Deterministic under the test runner's fixed
/// font. Regenerate with `--update-goldens`. RTL/Nastaliq goldens are deferred
/// until the reading fonts are bundled (M5) — documented debt, docs/40 §45.
void main() {
  testWidgets('PasswordStrengthMeter — strong, light', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: PasswordStrengthMeter(password: 'Str0ng-ish-passphrase'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PasswordStrengthMeter),
      matchesGoldenFile('goldens/password_strength_strong_light.png'),
    );
  });
}
