/// Regression guard for defect **AF5-cs** (`platfrom/docs/48` §3.22a).
///
/// The backend's `CheckoutDto` carries a third field, `clientSecret`, for a provider
/// path that needs an on-device confirmation step instead of a redirect URL. Mobile's
/// `CheckoutResult` read only `checkoutUrl`, so a checkout that came back with a secret
/// and no URL fell through to the "no redirect needed" branch and told the reader they
/// were already subscribed — a false success, not an actual charge.
///
/// The fix does not build the on-device confirmation flow (that is its own project,
/// per the ledger) — it stops mobile from lying about it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/billing.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/plan.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/subscription.dart';
import 'package:qalam_mobile/features/monetization/domain/repositories/monetization_repository.dart';
import 'package:qalam_mobile/features/monetization/presentation/providers/monetization_providers.dart';
import 'package:qalam_mobile/features/monetization/presentation/screens/plans_screen.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

class _MockRepo extends Mock implements MonetizationRepository {}

const AppConfig _monetizationOn = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: false,
  enableMonetization: true,
  enableCollaboration: false,
);

const PlanCatalogue _catalogue = PlanCatalogue(
  currency: 'usd',
  plans: <Plan>[
    Plan(
      tier: PlanTier.free,
      name: 'Free',
      description: '',
      features: <String>[],
      limits: <String, int>{},
      monthlyCredits: 0,
      prices: <String, Map<String, int>>{},
      trialDays: 0,
    ),
    Plan(
      tier: PlanTier.plus,
      name: 'Plus',
      description: '',
      features: <String>[PremiumFeature.aiBudget],
      limits: <String, int>{},
      monthlyCredits: 5000,
      prices: <String, Map<String, int>>{
        BillingInterval.monthly: <String, int>{'usd': 999},
      },
      trialDays: 0,
    ),
  ],
);

const Subscription _pendingSubscription = Subscription(
  id: 'sub1',
  tier: PlanTier.plus,
  status: SubscriptionStatus.pendingActivation,
  interval: BillingInterval.monthly,
  provider: PaymentProvider.stripe,
  currency: 'usd',
  autoRenew: true,
  cancelAtPeriodEnd: false,
);

void main() {
  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
  });

  group('CheckoutResult.needsClientConfirmation (AF5-cs)', () {
    test('fromJson reads clientSecret', () {
      final CheckoutResult result = CheckoutResult.fromJson(<String, Object?>{
        'subscription': <String, Object?>{
          'id': 'sub1',
          'tier': PlanTier.plus,
          'status': SubscriptionStatus.pendingActivation,
          'interval': BillingInterval.monthly,
          'provider': PaymentProvider.stripe,
          'currency': 'usd',
          'autoRenew': true,
          'cancelAtPeriodEnd': false,
        },
        'checkoutUrl': null,
        'clientSecret': 'seti_123_secret_abc',
      });

      expect(result.clientSecret, 'seti_123_secret_abc');
      expect(result.needsClientConfirmation, isTrue);
      expect(result.needsRedirect, isFalse);
    });

    test('a redirect URL wins over a client secret', () {
      const CheckoutResult result = CheckoutResult(
        subscription: _pendingSubscription,
        checkoutUrl: 'https://checkout.stripe.com/session',
        clientSecret: 'seti_123_secret_abc',
      );

      expect(result.needsRedirect, isTrue);
    });

    test('neither field set means the subscription is already active', () {
      const CheckoutResult result = CheckoutResult(
        subscription: _pendingSubscription,
      );

      expect(result.needsRedirect, isFalse);
      expect(result.needsClientConfirmation, isFalse);
    });
  });

  group('plans screen does not claim success (AF5-cs)', () {
    testWidgets(
      'a client-secret-only checkout shows an honest refusal, not a success message',
      (WidgetTester tester) async {
        final _MockRepo repo = _MockRepo();
        when(
          () => repo.subscribe(
            tier: any(named: 'tier'),
            interval: any(named: 'interval'),
            provider: any(named: 'provider'),
            couponCode: any(named: 'couponCode'),
            receipt: any(named: 'receipt'),
            region: any(named: 'region'),
          ),
        ).thenAnswer(
          (_) async => const Ok<CheckoutResult>(
            CheckoutResult(
              subscription: _pendingSubscription,
              clientSecret: 'seti_123_secret_abc',
            ),
          ),
        );

        tester.view.physicalSize = const Size(600, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appConfigProvider.overrideWithValue(_monetizationOn),
              plansProvider.overrideWith((_) async => _catalogue),
              currentSubscriptionProvider.overrideWith((_) async => null),
              monetizationRepositoryProvider.overrideWithValue(repo),
            ],
            child: MaterialApp(
              theme: buildQalamTheme(brightness: Brightness.light),
              home: const PlansScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        await tester.tap(find.text('Upgrade'));
        await tester.pump();
        await tester.pump();

        expect(
          find.text(
            'This payment method is not supported yet. Please try another.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('You are now on'), findsNothing);
      },
    );
  });
}
