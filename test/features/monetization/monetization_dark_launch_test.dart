/// Regression guard for defect **M5-4** (`platfrom/docs/48` §3.7) and the fourth-tab
/// wiring **M5-6**.
///
/// `QALAM_ENABLE_MONETIZATION` used to gate exactly one thing on mobile: whether the
/// Premium section appeared in the settings hub. The `/billing/*` routes are registered
/// unconditionally, so every screen behind them stayed deep-linkable in a dark build and
/// rendered normally — issuing live `/monetization/*` requests for a platform the build
/// says is off. Web's five pages all had the branch; mobile's did not.
///
/// The routes stay registered on purpose (web's do too) — a dark build 404ing a link
/// that a flag flip makes valid is a worse answer than a screen saying plainly that the
/// feature has not shipped. So the assertion is per-screen, not per-route.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/billing.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/subscription.dart';
import 'package:qalam_mobile/features/monetization/presentation/domain_labels.dart';
import 'package:qalam_mobile/features/monetization/presentation/providers/monetization_providers.dart';
import 'package:qalam_mobile/features/monetization/presentation/screens/billing_history_screen.dart';
import 'package:qalam_mobile/features/monetization/presentation/screens/credit_dashboard_screen.dart';
import 'package:qalam_mobile/features/monetization/presentation/screens/plans_screen.dart';
import 'package:qalam_mobile/features/monetization/presentation/screens/subscription_screen.dart';
import 'package:qalam_mobile/features/monetization/presentation/screens/usage_dashboard_screen.dart';
import 'package:qalam_mobile/features/monetization/presentation/widgets/monetization_off_screen.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

const AppConfig _off = AppConfig(
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

const AppConfig _on = AppConfig(
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

final Purchase _purchase = Purchase(
  id: 'pur1',
  kind: PurchaseKind.credits,
  status: PurchaseStatus.restored,
  provider: PaymentProvider.appleAppStore,
  amount: 499,
  currency: 'usd',
  creditsGranted: 5000,
  createdAt: DateTime.utc(2026, 7, 20),
);

final SubscriptionEvent _upgrade = SubscriptionEvent(
  id: 'ev1',
  type: 'plan_changed',
  createdAt: DateTime.utc(2026, 7, 21),
  fromTier: PlanTier.free,
  toTier: PlanTier.pro,
);

/// A lifecycle event: no tiers move, so the row must not render a bare arrow.
final SubscriptionEvent _renewal = SubscriptionEvent(
  id: 'ev2',
  type: 'renewed',
  createdAt: DateTime.utc(2026, 7, 22),
);

/// The dark-launch pump: only the config is overridden, because a screen that reads a
/// data provider before checking the flag would fail here — which is the point.
Future<void> _pumpDark(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(700, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      // Untyped on purpose: riverpod does not export the concrete `Override` type, so
      // the element type has to be inferred (the same note the shared harness carries).
      overrides: [appConfigProvider.overrideWithValue(_off)],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: screen,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _pumpBillingHistory(
  WidgetTester tester, {
  AppConfig config = _on,
  List<Invoice> invoices = const <Invoice>[],
  List<Payment> payments = const <Payment>[],
  List<Purchase> purchases = const <Purchase>[],
  List<SubscriptionEvent> events = const <SubscriptionEvent>[],
}) async {
  tester.view.physicalSize = const Size(700, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        invoiceHistoryProvider.overrideWith((_) async => invoices),
        paymentHistoryProvider.overrideWith((_) async => payments),
        purchaseHistoryProvider.overrideWith((_) async => purchases),
        subscriptionEventsProvider.overrideWith((_) async => events),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const BillingHistoryScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  group('every monetization screen honours the flag (M5-4)', () {
    // The whole point of the row: it was one screen, and it needed to be five.
    final List<(String, Widget, String)> screens = <(String, Widget, String)>[
      ('plans', const PlansScreen(), 'Plans aren’t available yet'),
      (
        'subscription',
        const SubscriptionScreen(),
        'Plans aren’t available yet',
      ),
      ('usage', const UsageDashboardScreen(), 'Usage isn’t available yet'),
      (
        'credits',
        const CreditDashboardScreen(),
        'Credits aren’t available yet',
      ),
      (
        'billing history',
        const BillingHistoryScreen(),
        'Billing history isn’t available yet',
      ),
    ];

    for (final (String name, Widget screen, String title) in screens) {
      testWidgets('$name says so in a dark build', (WidgetTester tester) async {
        await _pumpDark(tester, screen);
        expect(find.byType(MonetizationOffScreen), findsOneWidget);
        expect(find.text(title), findsOneWidget);
      });
    }

    testWidgets('and none of them shows that state when the flag is up', (
      WidgetTester tester,
    ) async {
      // The guard must be the flag, not something incidental — a screen that renders
      // the dark state with monetization ON would be a worse bug than the one fixed.
      await _pumpBillingHistory(tester);
      expect(find.byType(MonetizationOffScreen), findsNothing);
      expect(find.text('Invoices'), findsOneWidget);
    });
  });

  group('the two unwired ledgers now have a surface (M5-6)', () {
    testWidgets('billing history offers all four tabs', (
      WidgetTester tester,
    ) async {
      await _pumpBillingHistory(tester);
      // `purchases()` and `history()` reached the data source and no screen.
      expect(find.text('Purchases'), findsOneWidget);
      expect(find.text('Plan changes'), findsOneWidget);
    });

    testWidgets('the purchases tab renders a row through the real provider', (
      WidgetTester tester,
    ) async {
      await _pumpBillingHistory(tester, purchases: <Purchase>[_purchase]);
      await tester.tap(find.text('Purchases'));
      await tester.pumpAndSettle();

      expect(find.text('AI credits'), findsOneWidget);
      // `restored` is not a synonym for `completed`: it means the entitlement was
      // re-granted from a store receipt rather than bought again.
      expect(find.textContaining('Restored'), findsOneWidget);
      expect(find.textContaining('App Store'), findsOneWidget);
    });

    testWidgets('the events tab shows where the plan moved', (
      WidgetTester tester,
    ) async {
      await _pumpBillingHistory(
        tester,
        events: <SubscriptionEvent>[_upgrade, _renewal],
      );
      await tester.tap(find.text('Plan changes'));
      await tester.pumpAndSettle();

      expect(find.text('Free → Pro'), findsOneWidget);
      expect(find.text('plan changed'), findsOneWidget);
      // A lifecycle event moves no tier, so it renders no arrow at all.
      expect(find.textContaining('→'), findsOneWidget);
    });
  });

  group('no surface prints a raw wire string (M5-6)', () {
    // Mobile labelled five of the thirteen monetization enumerations and let the rest
    // fall through to the wire value — which is why billing history read "succeeded"
    // and the credit ledger read "subscription grant".
    test('the statuses that were rendering raw now have labels', () {
      expect(paymentStatusLabel(PaymentStatus.succeeded), 'Paid');
      expect(invoiceStatusLabel(InvoiceStatus.open), 'Unpaid');
      expect(
        creditReasonLabel(CreditReason.subscriptionGrant),
        'Included with your plan',
      );
      expect(purchaseKindLabel(PurchaseKind.oneTime), 'One-off purchase');
      expect(providerLabel(PaymentProvider.googlePlay), 'Google Play');
    });

    test('an unknown value falls through instead of blanking', () {
      // These enumerations are OPEN on the wire (varchar columns), so an unrecognised
      // value is a forward-compatible server, not a bug.
      expect(paymentStatusLabel('teleported'), 'teleported');
      expect(purchaseStatusLabel(''), '');
    });

    test('a subscription event type is destructured, not mapped', () {
      // The wire types `SubscriptionEventResponse.type` as a plain string, so the set
      // the server emits is not pinned by the contract — mapping would invent one.
      expect(subscriptionEventLabel('plan_changed'), 'plan changed');
      expect(subscriptionEventLabel('anything_at_all'), 'anything at all');
    });
  });
}
