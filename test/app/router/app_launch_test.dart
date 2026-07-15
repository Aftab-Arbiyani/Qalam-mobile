import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:qalam_mobile/features/feed/presentation/screens/feed_screen.dart';
import 'package:qalam_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:qalam_mobile/features/shell/presentation/pages/search_placeholder_page.dart';

import '../../support/fake_feed_repository.dart';
import '../../support/harness.dart';

void main() {
  // Every feed surface reads through the repository; fake it so launch tests never
  // touch the network.
  FakeFeedRepository feed() => FakeFeedRepository();

  testWidgets('first launch (not onboarded) lands on onboarding', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(
      tester,
      onboardingComplete: false,
      feedRepository: feed(),
    );
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('onboarded + anonymous lands on the public feed', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(tester, feedRepository: feed());
    expect(find.byType(FeedScreen), findsOneWidget);
  });

  testWidgets('bottom navigation switches to a public branch', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(tester, feedRepository: feed());
    await tester.tap(find.text('Search'));
    await settleFrames(tester);
    expect(find.byType(SearchPlaceholderPage), findsOneWidget);
  });

  testWidgets('tapping a protected tab while anonymous redirects to login', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(tester, feedRepository: feed());
    await tester.tap(find.text('Profile'));
    await settleFrames(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('offline shows the connectivity banner', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(tester, online: false, feedRepository: feed());
    expect(find.textContaining('offline'), findsOneWidget);
  });
}
