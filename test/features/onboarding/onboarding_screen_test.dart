import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:qalam_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('renders the first slide with Skip and Next', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(tester, onboardingComplete: false);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Skip completes onboarding and hands off to login', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(tester, onboardingComplete: false);

    await tapAndSettle(tester, find.text('Skip'));

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
