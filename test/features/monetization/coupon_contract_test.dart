/// Regression guard for defect **M5-2** (`platfrom/docs/48` §3.7).
///
/// `MonetizationRepository.validateCoupon` existed, was implemented through to the data
/// source, and **was called by nothing**. `plans_screen` passed no `couponCode` to
/// `subscribe()` and there was no field to type one into, so a mobile subscriber could
/// not use a promotion and the whole `PromotionType` catalogue was unreachable.
///
/// These tests pin the wire shape at the layer that knows it, and the reachability that
/// the defect was actually about — a repository method with no caller is not a feature.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/network/api_client.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/monetization/data/datasources/monetization_remote_data_source.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/billing.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/coupon_validation.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/plan.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/subscription.dart';
import 'package:qalam_mobile/features/monetization/domain/repositories/monetization_repository.dart';
import 'package:qalam_mobile/features/monetization/presentation/controllers/coupon_controller.dart';
import 'package:qalam_mobile/features/monetization/presentation/providers/monetization_providers.dart';
import 'package:qalam_mobile/features/monetization/presentation/screens/plans_screen.dart';
import 'package:qalam_mobile/features/monetization/presentation/widgets/coupon_field.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

class _MockApiClient extends Mock implements ApiClient {}

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

const CouponValidation _validCoupon = CouponValidation(
  code: 'SUMMER24',
  valid: true,
  type: PromotionType.percentageDiscount,
  description: '20% off',
  discountedAmount: 799,
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

const Subscription _activeSubscription = Subscription(
  id: 'sub1',
  tier: PlanTier.plus,
  status: SubscriptionStatus.active,
  interval: BillingInterval.monthly,
  provider: PaymentProvider.stripe,
  currency: 'usd',
  autoRenew: true,
  cancelAtPeriodEnd: false,
);

const CheckoutResult _checkout = CheckoutResult(
  subscription: _activeSubscription,
);

Future<void> _pumpPlans(
  WidgetTester tester, {
  required Subscription? subscription,
}) async {
  tester.view.physicalSize = const Size(600, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // The plans screen now opens with the dark-launch branch (M5-4), so the flag
        // has to be up for there to be a coupon field at all.
        appConfigProvider.overrideWithValue(_monetizationOn),
        plansProvider.overrideWith((_) async => _catalogue),
        currentSubscriptionProvider.overrideWith((_) async => subscription),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const PlansScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
  });

  group('validateCoupon wire shape (M5-2)', () {
    late _MockApiClient api;
    late MonetizationRemoteDataSource remote;

    setUp(() {
      api = _MockApiClient();
      remote = MonetizationRemoteDataSource(api);
      when(
        () => api.post<CouponValidation>(
          any(),
          body: any(named: 'body'),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer((_) async => _validCoupon);
    });

    test('posts {code, tier, interval} to the validate endpoint', () async {
      await remote.validateCoupon(
        code: 'SUMMER24',
        tier: PlanTier.plus,
        interval: BillingInterval.monthly,
      );

      final Map<String, Object?> body =
          verify(
                () => api.post<CouponValidation>(
                  '/monetization/coupons/validate',
                  body: captureAny(named: 'body'),
                  decode: any(named: 'decode'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(body, <String, Object?>{
        'code': 'SUMMER24',
        'tier': PlanTier.plus,
        'interval': BillingInterval.monthly,
      });
    });

    test('omits tier and interval rather than sending nulls', () async {
      // `ValidateCouponDto` runs under
      // `ValidationPipe({whitelist: true, forbidNonWhitelisted: true})` with
      // `@IsIn(...)` on both optional fields, so an explicit null is a 400 — not a
      // politely-ignored absent value. This is the M-1 trap in a different module.
      await remote.validateCoupon(code: 'SUMMER24');

      final Map<String, Object?> body =
          verify(
                () => api.post<CouponValidation>(
                  any(),
                  body: captureAny(named: 'body'),
                  decode: any(named: 'decode'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(body, <String, Object?>{'code': 'SUMMER24'});
      expect(body.containsKey('tier'), isFalse);
      expect(body.containsKey('interval'), isFalse);
    });
  });

  group('the code is normalized before it leaves (M5-2)', () {
    test('normalizeCouponCode trims and upper-cases', () {
      // The server looks a coupon up by its normalized form, so an untrimmed
      // lower-case code finds nothing and reads to the user as "invalid".
      expect(normalizeCouponCode('  summer24 '), 'SUMMER24');
      expect(normalizeCouponCode(''), '');
      expect(normalizeCouponCode('   '), '');
    });

    test(
      'the controller sends the normalized form, not the raw input',
      () async {
        final _MockRepo repo = _MockRepo();
        when(
          () => repo.validateCoupon(
            code: any(named: 'code'),
            tier: any(named: 'tier'),
            interval: any(named: 'interval'),
          ),
        ).thenAnswer((_) async => const Ok<CouponValidation>(_validCoupon));

        final ProviderContainer container = ProviderContainer(
          overrides: [monetizationRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        final String? accepted = await container
            .read(couponControllerProvider.notifier)
            .validate(code: ' summer24 ', interval: BillingInterval.monthly);

        expect(accepted, 'SUMMER24');
        verify(
          // `tier` is omitted here exactly as the field omits it — the reader has
          // not chosen a plan when they type the code.
          () => repo.validateCoupon(
            code: 'SUMMER24',
            interval: BillingInterval.monthly,
          ),
        ).called(1);
      },
    );

    test('a refused code yields null, and is not an error state', () async {
      // `valid: false` is a normal answer — the endpoint catches the coupon exceptions
      // and resolves with a false flag — so it must not surface as a failure.
      final _MockRepo repo = _MockRepo();
      when(
        () => repo.validateCoupon(
          code: any(named: 'code'),
          tier: any(named: 'tier'),
          interval: any(named: 'interval'),
        ),
      ).thenAnswer(
        (_) async => const Ok<CouponValidation>(
          CouponValidation(
            code: 'NOPE',
            valid: false,
            type: '',
            description: '',
          ),
        ),
      );

      final ProviderContainer container = ProviderContainer(
        overrides: [monetizationRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final String? accepted = await container
          .read(couponControllerProvider.notifier)
          .validate(code: 'NOPE');

      expect(accepted, isNull);
      expect(container.read(couponControllerProvider).hasError, isFalse);
    });

    test('an empty code never reaches the server', () async {
      final _MockRepo repo = _MockRepo();
      final ProviderContainer container = ProviderContainer(
        overrides: [monetizationRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final String? accepted = await container
          .read(couponControllerProvider.notifier)
          .validate(code: '   ');

      expect(accepted, isNull);
      verifyNever(
        () => repo.validateCoupon(
          code: any(named: 'code'),
          tier: any(named: 'tier'),
          interval: any(named: 'interval'),
        ),
      );
    });
  });

  group('the field is reachable from the plans screen (M5-2)', () {
    testWidgets('a would-be subscriber sees the promo field', (
      WidgetTester tester,
    ) async {
      await _pumpPlans(tester, subscription: null);
      expect(find.byType(CouponField), findsOneWidget);
      expect(find.text('Promo code'), findsOneWidget);
    });

    testWidgets('an existing subscriber does not', (WidgetTester tester) async {
      // `ChangePlanDto` has no `couponCode`, and the API forbids non-whitelisted
      // properties — so offering the field to a subscriber would 400 their plan change
      // rather than quietly ignore the code.
      await _pumpPlans(tester, subscription: _activeSubscription);
      expect(find.byType(CouponField), findsNothing);
    });
  });

  group('checkout carries the accepted code (M5-2)', () {
    test('subscribe puts couponCode on the wire', () async {
      final _MockApiClient api = _MockApiClient();
      final MonetizationRemoteDataSource remote = MonetizationRemoteDataSource(
        api,
      );
      when(
        () => api.post<CheckoutResult>(
          any(),
          body: any(named: 'body'),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer((_) async => _checkout);

      await remote.subscribe(
        tier: PlanTier.plus,
        interval: BillingInterval.monthly,
        provider: PaymentProvider.stripe,
        couponCode: 'SUMMER24',
      );

      final Map<String, Object?> body =
          verify(
                () => api.post<CheckoutResult>(
                  '/monetization/subscription',
                  body: captureAny(named: 'body'),
                  decode: any(named: 'decode'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(body['couponCode'], 'SUMMER24');
    });

    test('and omits it entirely when no code was accepted', () async {
      final _MockApiClient api = _MockApiClient();
      final MonetizationRemoteDataSource remote = MonetizationRemoteDataSource(
        api,
      );
      when(
        () => api.post<CheckoutResult>(
          any(),
          body: any(named: 'body'),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer((_) async => _checkout);

      await remote.subscribe(
        tier: PlanTier.plus,
        interval: BillingInterval.monthly,
        provider: PaymentProvider.stripe,
      );

      final Map<String, Object?> body =
          verify(
                () => api.post<CheckoutResult>(
                  any(),
                  body: captureAny(named: 'body'),
                  decode: any(named: 'decode'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(body.containsKey('couponCode'), isFalse);
    });
  });
}
