/// Monetization remote data source (AF5) — the only place the `/monetization/*`
/// endpoints + `ApiClient` are touched. Maps envelope payloads to typed entities;
/// the client sends only declared params and never trusts a purchase locally (the
/// server validates receipts + owns entitlement).
library;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../domain/entities/billing.dart';
import '../../domain/entities/coupon_validation.dart';
import '../../domain/entities/credit.dart';
import '../../domain/entities/entitlement.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/usage_summary.dart';

class MonetizationRemoteDataSource {
  const MonetizationRemoteDataSource(this._api);

  final ApiClient _api;

  Future<PlanCatalogue> plans({String? region, CancelToken? cancelToken}) => _api.get(
    ApiPaths.monetizationPlans,
    query: region != null ? <String, Object?>{'region': region} : null,
    decode: PlanCatalogue.fromJson,
    cancelToken: cancelToken,
  );

  Future<EntitlementSnapshot> entitlements({CancelToken? cancelToken}) => _api.get(
    ApiPaths.monetizationEntitlements,
    decode: EntitlementSnapshot.fromJson,
    cancelToken: cancelToken,
  );

  Future<EntitlementDecision> entitlement(String feature, {CancelToken? cancelToken}) =>
      _api.get(
        ApiPaths.monetizationEntitlement(feature),
        decode: EntitlementDecision.fromJson,
        cancelToken: cancelToken,
      );

  Future<Subscription> subscription({CancelToken? cancelToken}) => _api.get(
    ApiPaths.monetizationSubscription,
    decode: Subscription.fromJson,
    cancelToken: cancelToken,
  );

  Future<CheckoutResult> subscribe({
    required String tier,
    required String interval,
    required String provider,
    String? couponCode,
    String? receipt,
    String? region,
  }) => _api.post(
    ApiPaths.monetizationSubscription,
    body: <String, Object?>{
      'tier': tier,
      'interval': interval,
      'provider': provider,
      'couponCode': ?couponCode,
      'receipt': ?receipt,
      'region': ?region,
    },
    decode: CheckoutResult.fromJson,
  );

  Future<Subscription> changePlan({
    required String tier,
    required String interval,
    bool atPeriodEnd = false,
  }) => _api.post(
    ApiPaths.monetizationSubscriptionChange,
    body: <String, Object?>{'tier': tier, 'interval': interval, 'atPeriodEnd': atPeriodEnd},
    decode: Subscription.fromJson,
  );

  Future<Subscription> cancel({bool immediate = false, String? reason}) => _api.post(
    ApiPaths.monetizationSubscriptionCancel,
    body: <String, Object?>{'immediate': immediate, 'reason': ?reason},
    decode: Subscription.fromJson,
  );

  Future<Subscription> reactivate() => _api.post(
    ApiPaths.monetizationSubscriptionReactivate,
    decode: Subscription.fromJson,
  );

  Future<Subscription> pause() =>
      _api.post(ApiPaths.monetizationSubscriptionPause, decode: Subscription.fromJson);

  Future<Subscription> resume() =>
      _api.post(ApiPaths.monetizationSubscriptionResume, decode: Subscription.fromJson);

  Future<CursorPage<SubscriptionEvent>> history({String? cursor, int? limit}) => _api.getPage(
    ApiPaths.monetizationSubscriptionHistory,
    query: <String, Object?>{'cursor': ?cursor, 'limit': ?limit},
    decodeItem: SubscriptionEvent.fromJson,
  );

  Future<MonetizationUsageSummary> usage({CancelToken? cancelToken}) => _api.get(
    ApiPaths.monetizationUsage,
    decode: MonetizationUsageSummary.fromJson,
    cancelToken: cancelToken,
  );

  Future<CreditBalance> credits({CancelToken? cancelToken}) => _api.get(
    ApiPaths.monetizationCredits,
    decode: CreditBalance.fromJson,
    cancelToken: cancelToken,
  );

  Future<CursorPage<CreditTransaction>> creditTransactions({String? cursor, int? limit}) =>
      _api.getPage(
        ApiPaths.monetizationCreditTransactions,
        query: <String, Object?>{
          'cursor': ?cursor,
          'limit': ?limit,
        },
        decodeItem: CreditTransaction.fromJson,
      );

  Future<Purchase> purchaseCredits({
    required int credits,
    required String provider,
    String? receipt,
  }) => _api.post(
    ApiPaths.monetizationCreditPurchase,
    body: <String, Object?>{
      'credits': credits,
      'provider': provider,
      'receipt': ?receipt,
    },
    decode: Purchase.fromJson,
  );

  Future<CursorPage<Invoice>> invoices({String? cursor, int? limit}) => _api.getPage(
    ApiPaths.monetizationInvoices,
    query: <String, Object?>{'cursor': ?cursor, 'limit': ?limit},
    decodeItem: Invoice.fromJson,
  );

  Future<CursorPage<Payment>> payments({String? cursor, int? limit}) => _api.getPage(
    ApiPaths.monetizationPayments,
    query: <String, Object?>{'cursor': ?cursor, 'limit': ?limit},
    decodeItem: Payment.fromJson,
  );

  Future<CursorPage<Purchase>> purchases({String? cursor, int? limit}) => _api.getPage(
    ApiPaths.monetizationPurchases,
    query: <String, Object?>{'cursor': ?cursor, 'limit': ?limit},
    decodeItem: Purchase.fromJson,
  );

  Future<RestoreResult> restore({required String provider, required String receipt}) => _api.post(
    ApiPaths.monetizationPurchasesRestore,
    body: <String, Object?>{'provider': provider, 'receipt': receipt},
    decode: RestoreResult.fromJson,
  );

  Future<CouponValidation> validateCoupon({
    required String code,
    String? tier,
    String? interval,
  }) => _api.post(
    ApiPaths.monetizationCouponsValidate,
    body: <String, Object?>{
      'code': code,
      'tier': ?tier,
      'interval': ?interval,
    },
    decode: CouponValidation.fromJson,
  );
}
