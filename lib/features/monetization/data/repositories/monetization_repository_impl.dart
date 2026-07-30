/// Monetization repository implementation (AF5). Wraps remote calls in [guardResult]
/// (ApiException → Failure) and writes the entitlement snapshot to the local cache on
/// every successful read so premium gating stays snappy + offline-tolerant.
library;

import '../../../../core/error/result_guard.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../domain/entities/billing.dart';
import '../../domain/entities/coupon_validation.dart';
import '../../domain/entities/credit.dart';
import '../../domain/entities/entitlement.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/usage_summary.dart';
import '../../domain/repositories/monetization_repository.dart';
import '../datasources/monetization_remote_data_source.dart';
import '../local/entitlement_cache_store.dart';

class MonetizationRepositoryImpl implements MonetizationRepository {
  MonetizationRepositoryImpl(this._remote, this._cache);

  final MonetizationRemoteDataSource _remote;
  final EntitlementCacheStore _cache;

  @override
  Future<Result<PlanCatalogue>> plans({String? region}) =>
      guardResult(() => _remote.plans(region: region));

  @override
  Future<Result<EntitlementSnapshot>> entitlements() async {
    final Result<EntitlementSnapshot> result = await guardResult(_remote.entitlements);
    if (result case Ok<EntitlementSnapshot>(:final EntitlementSnapshot value)) {
      await _cache.write(value);
    }
    return result;
  }

  @override
  EntitlementSnapshot? cachedEntitlements() => _cache.read();

  @override
  Future<Result<Subscription>> subscription() => guardResult(_remote.subscription);

  @override
  Future<Result<CheckoutResult>> subscribe({
    required String tier,
    required String interval,
    required String provider,
    String? couponCode,
    String? receipt,
    String? region,
  }) => guardResult(
    () => _remote.subscribe(
      tier: tier,
      interval: interval,
      provider: provider,
      couponCode: couponCode,
      receipt: receipt,
      region: region,
    ),
  );

  @override
  Future<Result<Subscription>> changePlan({
    required String tier,
    required String interval,
    bool atPeriodEnd = false,
  }) => guardResult(
    () => _remote.changePlan(tier: tier, interval: interval, atPeriodEnd: atPeriodEnd),
  );

  @override
  Future<Result<Subscription>> cancel({bool immediate = false, String? reason}) =>
      guardResult(() => _remote.cancel(immediate: immediate, reason: reason));

  @override
  Future<Result<Subscription>> reactivate() => guardResult(_remote.reactivate);

  @override
  Future<Result<Subscription>> pause() => guardResult(_remote.pause);

  @override
  Future<Result<Subscription>> resume() => guardResult(_remote.resume);

  @override
  Future<Result<CursorPage<SubscriptionEvent>>> history({String? cursor, int? limit}) =>
      guardResult(() => _remote.history(cursor: cursor, limit: limit));

  @override
  Future<Result<MonetizationUsageSummary>> usage() => guardResult(_remote.usage);

  @override
  Future<Result<CreditBalance>> credits() => guardResult(_remote.credits);

  @override
  Future<Result<CursorPage<CreditTransaction>>> creditTransactions({String? cursor, int? limit}) =>
      guardResult(() => _remote.creditTransactions(cursor: cursor, limit: limit));

  @override
  Future<Result<Purchase>> purchaseCredits({
    required int credits,
    required String provider,
    String? receipt,
  }) => guardResult(
    () => _remote.purchaseCredits(credits: credits, provider: provider, receipt: receipt),
  );

  @override
  Future<Result<CursorPage<Invoice>>> invoices({String? cursor, int? limit}) =>
      guardResult(() => _remote.invoices(cursor: cursor, limit: limit));

  @override
  Future<Result<CursorPage<Payment>>> payments({String? cursor, int? limit}) =>
      guardResult(() => _remote.payments(cursor: cursor, limit: limit));

  @override
  Future<Result<CursorPage<Purchase>>> purchases({String? cursor, int? limit}) =>
      guardResult(() => _remote.purchases(cursor: cursor, limit: limit));

  @override
  Future<Result<RestoreResult>> restore({required String provider, required String receipt}) =>
      guardResult(() => _remote.restore(provider: provider, receipt: receipt));

  @override
  Future<Result<CouponValidation>> validateCoupon({
    required String code,
    String? tier,
    String? interval,
  }) => guardResult(() => _remote.validateCoupon(code: code, tier: tier, interval: interval));
}
