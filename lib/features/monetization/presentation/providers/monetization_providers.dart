/// The Monetization feature's composition root (AF5, docs/40 §9). Binds the repository
/// to its data + local-cache implementation, exposes the server-authoritative
/// entitlement snapshot (the premium-gating source of truth), and the read models for
/// subscription/usage/credits/plans. Repo + gateway are kept alive (cross-cutting);
/// screen reads are autoDispose.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/billing/store_billing_gateway.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../data/datasources/monetization_remote_data_source.dart';
import '../../data/local/entitlement_cache_store.dart';
import '../../data/repositories/monetization_repository_impl.dart';
import '../../domain/entities/billing.dart';
import '../../domain/entities/credit.dart';
import '../../domain/entities/entitlement.dart';
import '../../domain/entities/plan.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/usage_summary.dart';
import '../../domain/repositories/monetization_repository.dart';

part 'monetization_providers.g.dart';

@Riverpod(keepAlive: true)
MonetizationRemoteDataSource monetizationRemoteDataSource(Ref ref) =>
    MonetizationRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
EntitlementCacheStore entitlementCacheStore(Ref ref) =>
    EntitlementCacheStore(ref.watch(prefsBoxProvider));

@Riverpod(keepAlive: true)
MonetizationRepository monetizationRepository(Ref ref) =>
    MonetizationRepositoryImpl(
      ref.watch(monetizationRemoteDataSourceProvider),
      ref.watch(entitlementCacheStoreProvider),
    );

/// The store-billing gateway (Apple/Google). Inert by default (no SDK bundled);
/// overridden in `bootstrap` when a store integration is wired (docs/40 §41).
@Riverpod(keepAlive: true)
StoreBillingGateway storeBillingGateway(Ref ref) =>
    const NoopStoreBillingGateway();

/// The server-authoritative entitlement snapshot — the SINGLE thing premium UI gates
/// on. Never throws: on a network failure it falls back to the last cached snapshot,
/// then to the free-tier default, so gating always resolves (server re-checks anyway).
///
/// **A dark build answers the free-tier default without asking.** With
/// `QALAM_ENABLE_MONETIZATION` down there is no premium surface to gate and no plan to
/// report, so issuing the request would spend a round trip on an answer nothing reads —
/// the same reasoning behind web's `enabled: isMonetizationEnabled()` (W4). The default
/// denies every feature, which is the correct reading of "monetization is off" for a
/// gate and, for the one feature the server enforces, matches what the meter does:
/// `checkQuota` returns early when the platform flag is down, so nothing is withheld
/// that the server would have granted.
@riverpod
Future<EntitlementSnapshot> entitlementSnapshot(Ref ref) async {
  if (!ref.watch(appConfigProvider).enableMonetization) {
    return EntitlementSnapshot.free;
  }
  final MonetizationRepository repo = ref.watch(monetizationRepositoryProvider);
  final Result<EntitlementSnapshot> result = await repo.entitlements();
  return switch (result) {
    Ok<EntitlementSnapshot>(:final EntitlementSnapshot value) => value,
    Err<EntitlementSnapshot>() =>
      repo.cachedEntitlements() ?? EntitlementSnapshot.free,
  };
}

// `premiumFeatureAllowed` used to live here — a per-feature boolean over the snapshot,
// exported from the feature barrel and called by nothing. Deleted rather than given a
// caller: a gate needs the whole decision, not just the verdict, because the `reason` is
// what decides whether the remedy is a plan or a wait (docs/48 §5.2, M5-5). Read
// `entitlementSnapshotProvider` and ask the snapshot for a decision.

/// The current subscription, or null when the user has none (free).
@riverpod
Future<Subscription?> currentSubscription(Ref ref) async {
  final Result<Subscription> result = await ref
      .watch(monetizationRepositoryProvider)
      .subscription();
  return switch (result) {
    Ok<Subscription>(:final Subscription value) => value,
    Err<Subscription>(:final Failure failure) =>
      failure.code == ErrorCodes.subscriptionNotFound ? null : throw failure,
  };
}

@riverpod
Future<PlanCatalogue> plans(Ref ref) async {
  final Result<PlanCatalogue> result = await ref
      .watch(monetizationRepositoryProvider)
      .plans();
  return switch (result) {
    Ok<PlanCatalogue>(:final PlanCatalogue value) => value,
    Err<PlanCatalogue>(:final Failure failure) => throw failure,
  };
}

@riverpod
Future<MonetizationUsageSummary> monetizationUsage(Ref ref) async {
  final Result<MonetizationUsageSummary> result = await ref
      .watch(monetizationRepositoryProvider)
      .usage();
  return switch (result) {
    Ok<MonetizationUsageSummary>(:final MonetizationUsageSummary value) =>
      value,
    Err<MonetizationUsageSummary>(:final Failure failure) => throw failure,
  };
}

@riverpod
Future<CreditBalance> creditBalance(Ref ref) async {
  final Result<CreditBalance> result = await ref
      .watch(monetizationRepositoryProvider)
      .credits();
  return switch (result) {
    Ok<CreditBalance>(:final CreditBalance value) => value,
    Err<CreditBalance>(:final Failure failure) => throw failure,
  };
}

/// The recent credit ledger (first page) for the credit dashboard.
@riverpod
Future<List<CreditTransaction>> creditLedger(Ref ref) async {
  final Result<CursorPage<CreditTransaction>> result = await ref
      .watch(monetizationRepositoryProvider)
      .creditTransactions();
  return switch (result) {
    Ok<CursorPage<CreditTransaction>>(
      :final CursorPage<CreditTransaction> value,
    ) =>
      value.items,
    Err<CursorPage<CreditTransaction>>(:final Failure failure) => throw failure,
  };
}

/// Recent invoices (first page) for billing history.
@riverpod
Future<List<Invoice>> invoiceHistory(Ref ref) async {
  final Result<CursorPage<Invoice>> result = await ref
      .watch(monetizationRepositoryProvider)
      .invoices();
  return switch (result) {
    Ok<CursorPage<Invoice>>(:final CursorPage<Invoice> value) => value.items,
    Err<CursorPage<Invoice>>(:final Failure failure) => throw failure,
  };
}

/// Recent payments (first page) for billing history.
@riverpod
Future<List<Payment>> paymentHistory(Ref ref) async {
  final Result<CursorPage<Payment>> result = await ref
      .watch(monetizationRepositoryProvider)
      .payments();
  return switch (result) {
    Ok<CursorPage<Payment>>(:final CursorPage<Payment> value) => value.items,
    Err<CursorPage<Payment>>(:final Failure failure) => throw failure,
  };
}

/// Recent purchases (first page) — credit packs and one-off buys, which are neither
/// invoices nor payments and had no surface until the fourth billing tab existed.
@riverpod
Future<List<Purchase>> purchaseHistory(Ref ref) async {
  final Result<CursorPage<Purchase>> result = await ref
      .watch(monetizationRepositoryProvider)
      .purchases();
  return switch (result) {
    Ok<CursorPage<Purchase>>(:final CursorPage<Purchase> value) => value.items,
    Err<CursorPage<Purchase>>(:final Failure failure) => throw failure,
  };
}

/// The subscription event log (first page) — plan changes, pauses, cancellations.
///
/// This endpoint used to answer 404 `SUBSCRIPTION_NOT_FOUND` for a viewer with no
/// subscription, where its three sibling ledgers answer an empty page. It was fixed at
/// the endpoint (owner-scoped by `user_id`, W4-1) and web's compensating client-side
/// mapping was deleted with it — so a 404 here is now a real error and surfaces as one
/// rather than being absorbed into an empty list.
@riverpod
Future<List<SubscriptionEvent>> subscriptionEvents(Ref ref) async {
  final Result<CursorPage<SubscriptionEvent>> result = await ref
      .watch(monetizationRepositoryProvider)
      .history();
  return switch (result) {
    Ok<CursorPage<SubscriptionEvent>>(
      :final CursorPage<SubscriptionEvent> value,
    ) =>
      value.items,
    Err<CursorPage<SubscriptionEvent>>(:final Failure failure) => throw failure,
  };
}
