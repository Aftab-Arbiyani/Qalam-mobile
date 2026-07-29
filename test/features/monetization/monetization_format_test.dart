import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:qalam_mobile/features/monetization/presentation/monetization_format.dart';

void main() {
  group('formatMoney', () {
    test('formats minor units with the currency symbol', () {
      expect(formatMoney(1499, 'usd'), r'$14.99');
      expect(formatMoney(4990, 'usd'), r'$49.90');
      expect(formatMoney(0, 'usd'), r'$0.00');
      expect(formatMoney(1200, 'gbp'), '£12.00');
      expect(formatMoney(83000, 'inr'), contains('830.00'));
    });

    test('does NOT divide zero-decimal currencies by 100', () {
      // The defect this guards: ¥1499 is ¥1,499, not ¥14.99. A blanket /100 under-reports a yen
      // price by two orders of magnitude, and the wrong figure still looks like a plausible price.
      // Found on web during W4 and fixed here for parity (docs/48 §3.6).
      expect(formatMoney(1499, 'jpy'), contains('1,499'));
      expect(formatMoney(1499, 'jpy'), isNot(contains('14.99')));
      expect(formatMoney(1499, 'krw'), contains('1,499'));
    });

    test('divides three-decimal currencies by 1000', () {
      expect(formatMoney(1499, 'kwd'), contains('1.499'));
    });

    test('keeps two decimals for PKR, overriding the locale convention', () {
      // CLDR renders PKR with no decimals, so the default formatting of 1499 paisa would be a
      // rounded "PKR 15" that does not match the amount charged.
      expect(formatMoney(1499, 'pkr'), contains('14.99'));
    });

    test('formats a currency the old symbol table did not know', () {
      // The hand-written table knew five currencies and fell back to a bare code for the rest.
      expect(formatMoney(1499, 'aud'), contains('14.99'));
      expect(formatMoney(1499, 'cad'), contains('14.99'));
    });
  });

  group('formatCount', () {
    test('compacts large counts', () {
      expect(formatCount(500), '500');
      expect(formatCount(1200), '1.2K');
      expect(formatCount(2500000), '2.5M');
    });
  });

  group('labels', () {
    test('map wire strings to human copy', () {
      expect(planLabel(PlanTier.pro), 'Pro');
      expect(intervalLabel(BillingInterval.yearly), 'Yearly');
      expect(subscriptionStatusLabel(SubscriptionStatus.gracePeriod), 'Grace period');
      expect(featureLabel(PremiumFeature.aiWriting), 'AI Writing Assistant');
    });
  });
}
