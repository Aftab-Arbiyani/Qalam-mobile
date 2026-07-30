/// The Monetization repository contract (AF5) — the boundary the presentation layer
/// depends on. Returns domain entities / [Failure]s only; the concrete impl talks to
/// the wire + local cache.
library;

import '../../../../core/utils/result.dart';
import '../../../../shared/api/api_envelope.dart';
import '../entities/billing.dart';
import '../entities/coupon_validation.dart';
import '../entities/credit.dart';
import '../entities/entitlement.dart';
import '../entities/plan.dart';
import '../entities/subscription.dart';
import '../entities/usage_summary.dart';

abstract interface class MonetizationRepository {
  Future<Result<PlanCatalogue>> plans({String? region});

  /// The server-authoritative entitlement snapshot; caches it locally on success.
  Future<Result<EntitlementSnapshot>> entitlements();

  /// The last cached snapshot (sync, offline-tolerant read), or null.
  EntitlementSnapshot? cachedEntitlements();

  Future<Result<Subscription>> subscription();

  Future<Result<CheckoutResult>> subscribe({
    required String tier,
    required String interval,
    required String provider,
    String? couponCode,
    String? receipt,
    String? region,
  });

  Future<Result<Subscription>> changePlan({
    required String tier,
    required String interval,
    bool atPeriodEnd,
  });

  Future<Result<Subscription>> cancel({bool immediate, String? reason});
  Future<Result<Subscription>> reactivate();
  Future<Result<Subscription>> pause();
  Future<Result<Subscription>> resume();
  Future<Result<CursorPage<SubscriptionEvent>>> history({String? cursor, int? limit});

  Future<Result<MonetizationUsageSummary>> usage();
  Future<Result<CreditBalance>> credits();
  Future<Result<CursorPage<CreditTransaction>>> creditTransactions({String? cursor, int? limit});
  Future<Result<Purchase>> purchaseCredits({
    required int credits,
    required String provider,
    String? receipt,
  });

  Future<Result<CursorPage<Invoice>>> invoices({String? cursor, int? limit});
  Future<Result<CursorPage<Payment>>> payments({String? cursor, int? limit});
  Future<Result<CursorPage<Purchase>>> purchases({String? cursor, int? limit});
  Future<Result<RestoreResult>> restore({required String provider, required String receipt});

  Future<Result<CouponValidation>> validateCoupon({
    required String code,
    String? tier,
    String? interval,
  });
}
