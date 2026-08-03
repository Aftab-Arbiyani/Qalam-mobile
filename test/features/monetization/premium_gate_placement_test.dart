/// Regression guard for defect **M5-1** (`platfrom/docs/48` §3.7).
///
/// `PremiumGate` existed with zero call sites while its own doc comment claimed "every
/// premium affordance elsewhere wraps its content in PremiumGate", and no mobile screen
/// checked the entitlement snapshot either. So the app computed entitlements correctly,
/// cached them, and gated nothing.
///
/// These tests pin the two halves the fix has to keep true:
///
/// 1. **Placement is real and reachable** — the gate is mounted on the credit dashboard,
///    on `ai_budget`, and the balance is actually withheld when the server denies it.
///    A gate nobody renders is what the defect was.
/// 2. **The two `ai_budget` denials stay distinct** — `assertAllowed` failing is an
///    entitlement denial whose remedy is "see plans"; `assertWithinQuota` failing is
///    `QUOTA_EXCEEDED`, whose remedy is waiting. Conflating them tells a blocked writer
///    to wait for a reset that will never come (docs/48 §5.2, consequence 2).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/ai/presentation/support/ai_error_copy.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/credit.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:qalam_mobile/features/monetization/presentation/providers/monetization_providers.dart';
import 'package:qalam_mobile/features/monetization/presentation/screens/credit_dashboard_screen.dart';
import 'package:qalam_mobile/features/monetization/presentation/widgets/premium_gate.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

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

const AppConfig _monetizationOff = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: false,
  enableMonetization: false,
  enableCollaboration: false,
);

const CreditBalance _balance = CreditBalance(
  balance: 5000,
  lifetimeGranted: 8000,
  lifetimeConsumed: 3000,
  creditsPerUsd: 100,
);

EntitlementSnapshot _snapshot(EntitlementDecision budget) =>
    EntitlementSnapshot(
      tier: PlanTier.free,
      status: EntitlementStatus.allow,
      features: <EntitlementDecision>[budget],
    );

const EntitlementDecision _allowed = EntitlementDecision(
  feature: PremiumFeature.aiBudget,
  status: EntitlementStatus.allow,
  allowed: true,
  reason: EntitlementReason.planIncludes,
);

/// The plan grants no AI budget at all — never resets, so a plan is the only remedy.
const EntitlementDecision _planDenied = EntitlementDecision(
  feature: PremiumFeature.aiBudget,
  status: EntitlementStatus.deny,
  allowed: false,
  reason: EntitlementReason.planExcludes,
);

/// The budget exists and is spent — returns on its own, so an upgrade is not the answer.
const EntitlementDecision _quotaDenied = EntitlementDecision(
  feature: PremiumFeature.aiBudget,
  status: EntitlementStatus.deny,
  allowed: false,
  reason: EntitlementReason.quotaExceeded,
);

Future<void> _pumpCreditDashboard(
  WidgetTester tester,
  EntitlementDecision budget,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_monetizationOn),
        entitlementSnapshotProvider.overrideWith(
          (_) async => _snapshot(budget),
        ),
        creditBalanceProvider.overrideWith((_) async => _balance),
        creditLedgerProvider.overrideWith((_) async => <CreditTransaction>[]),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const CreditDashboardScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  group('the gate has a real call site (M5-1)', () {
    testWidgets('the credit dashboard mounts a PremiumGate on ai_budget', (
      WidgetTester tester,
    ) async {
      await _pumpCreditDashboard(tester, _allowed);

      final PremiumGate gate = tester.widget<PremiumGate>(
        find.byType(PremiumGate),
      );
      // The ONE feature the backend asserts. Gating any of the other seven would be a
      // client-only wall in front of a route the server serves to anyone.
      expect(gate.feature, PremiumFeature.aiBudget);
      expect(gate.optimistic, isTrue);
    });

    testWidgets('an entitled viewer sees the balance', (
      WidgetTester tester,
    ) async {
      await _pumpCreditDashboard(tester, _allowed);
      expect(find.text('credits available'), findsOneWidget);
      expect(find.text('See plans'), findsNothing);
    });

    testWidgets('a denied viewer gets the reason instead of the number', (
      WidgetTester tester,
    ) async {
      await _pumpCreditDashboard(tester, _planDenied);
      expect(find.text('credits available'), findsNothing);
      expect(find.textContaining('needs a paid plan'), findsOneWidget);
    });

    testWidgets('a dark build shows neither the balance nor a paywall', (
      WidgetTester tester,
    ) async {
      // With QALAM_ENABLE_MONETIZATION down the snapshot answers the free-tier default
      // without asking, which denies every feature — so without this branch the gate
      // would render a lock over an unreleased feature.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(_monetizationOff),
            creditBalanceProvider.overrideWith((_) async => _balance),
            creditLedgerProvider.overrideWith(
              (_) async => <CreditTransaction>[],
            ),
          ],
          child: MaterialApp(
            theme: buildQalamTheme(brightness: Brightness.light),
            home: const CreditDashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Credits aren’t available yet'), findsOneWidget);
      expect(find.byType(PremiumGate), findsNothing);
    });
  });

  group('a spent allowance is not a missing plan (M5-1)', () {
    testWidgets('a quota denial offers no upgrade, only the reset', (
      WidgetTester tester,
    ) async {
      await _pumpCreditDashboard(tester, _quotaDenied);

      expect(find.textContaining('You’ve used your'), findsOneWidget);
      expect(find.textContaining('resets'), findsOneWidget);
      // Selling a plan to someone who only has to wait is the defect.
      expect(find.text('See plans'), findsNothing);
    });

    testWidgets('a quota denial with an expiry names the date', (
      WidgetTester tester,
    ) async {
      await _pumpCreditDashboard(
        tester,
        EntitlementDecision(
          feature: PremiumFeature.aiBudget,
          status: EntitlementStatus.deny,
          allowed: false,
          reason: EntitlementReason.quotaExceeded,
          expiresAt: DateTime.utc(2026, 9, 15),
        ),
      );
      expect(find.textContaining('resets on'), findsOneWidget);
    });

    testWidgets('a plan denial does offer the upgrade', (
      WidgetTester tester,
    ) async {
      await _pumpCreditDashboard(tester, _planDenied);
      expect(find.text('See plans'), findsOneWidget);
      expect(find.textContaining('resets'), findsNothing);
    });

    test('the decision itself distinguishes the two', () {
      expect(_quotaDenied.isQuotaDenial, isTrue);
      expect(_planDenied.isQuotaDenial, isFalse);
    });
  });

  group('the AI surfaces distinguish them too (M5-1)', () {
    // Both codes are raised by the AF5 meter on the way into a generation, and both were
    // unmapped — so they fell through to the generic retryable failure, which invited a
    // blocked writer to try again.
    test('ENTITLEMENT_DENIED is an upgrade, not a retry', () {
      final AiErrorCopy copy = AiErrorCopy.forCode(
        ErrorCodes.entitlementDenied,
      );
      expect(copy.canUpgrade, isTrue);
      expect(copy.canRetry, isFalse);
      expect(copy.title, isNot('Something went wrong'));
    });

    test('INSUFFICIENT_CREDITS is an upgrade too', () {
      final AiErrorCopy copy = AiErrorCopy.forCode(
        ErrorCodes.insufficientCredits,
      );
      expect(copy.canUpgrade, isTrue);
      expect(copy.canRetry, isFalse);
    });

    test('QUOTA_EXCEEDED is a wait, and never an upgrade', () {
      final AiErrorCopy copy = AiErrorCopy.forCode(ErrorCodes.quotaExceeded);
      expect(copy.canUpgrade, isFalse);
      expect(copy.canRetry, isFalse);
      expect(copy.message, contains('resets'));
    });

    test('the AI module’s own cap reads the same as the plan’s', () {
      // Indistinguishable to a writer, who only needs to know the allowance returns.
      final AiErrorCopy ai = AiErrorCopy.forCode(
        ErrorCodes.aiUsageLimitExceeded,
      );
      final AiErrorCopy plan = AiErrorCopy.forCode(ErrorCodes.quotaExceeded);
      expect(ai.title, plan.title);
      expect(ai.canUpgrade, isFalse);
    });
  });
}
