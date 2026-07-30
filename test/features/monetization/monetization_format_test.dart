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
      expect(formatMoney(83000, 'inr'), '₹830.00');
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
