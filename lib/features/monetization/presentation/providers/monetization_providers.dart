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
MonetizationRepository monetizationRepository(Ref ref) => MonetizationRepositoryImpl(
  ref.watch(monetizationRemoteDataSourceProvider),
  ref.watch(entitlementCacheStoreProvider),
);

/// The store-billing gateway (Apple/Google). Inert by default (no SDK bundled);
/// overridden in `bootstrap` when a store integration is wired (docs/40 §41).
@Riverpod(keepAlive: true)
StoreBillingGateway storeBillingGateway(Ref ref) => const NoopStoreBillingGateway();

/// The server-authoritative entitlement snapshot — the SINGLE thing premium UI gates
/// on. Never throws: on a network failure it falls back to the last cached snapshot,
/// then to the free-tier default, so gating always resolves (server re-checks anyway).
@riverpod
Future<EntitlementSnapshot> entitlementSnapshot(Ref ref) async {
  final MonetizationRepository repo = ref.watch(monetizationRepositoryProvider);
  final Result<EntitlementSnapshot> result = await repo.entitlements();
  return switch (result) {
    Ok<EntitlementSnapshot>(:final EntitlementSnapshot value) => value,
    Err<EntitlementSnapshot>() =>
      repo.cachedEntitlements() ?? EntitlementSnapshot.free,
  };
}

/// Whether the current user may use a premium [feature] (the gate widgets read this).
@riverpod
Future<bool> premiumFeatureAllowed(Ref ref, String feature) async {
  final EntitlementSnapshot snapshot = await ref.watch(entitlementSnapshotProvider.future);
  return snapshot.allows(feature);
}

/// The current subscription, or null when the user has none (free).
@riverpod
Future<Subscription?> currentSubscription(Ref ref) async {
  final Result<Subscription> result =
      await ref.watch(monetizationRepositoryProvider).subscription();
  return switch (result) {
    Ok<Subscription>(:final Subscription value) => value,
    Err<Subscription>(:final Failure failure) =>
      failure.code == ErrorCodes.subscriptionNotFound ? null : throw failure,
  };
}

@riverpod
Future<PlanCatalogue> plans(Ref ref) async {
  final Result<PlanCatalogue> result =
      await ref.watch(monetizationRepositoryProvider).plans();
  return switch (result) {
    Ok<PlanCatalogue>(:final PlanCatalogue value) => value,
    Err<PlanCatalogue>(:final Failure failure) => throw failure,
  };
}

@riverpod
Future<MonetizationUsageSummary> monetizationUsage(Ref ref) async {
  final Result<MonetizationUsageSummary> result =
      await ref.watch(monetizationRepositoryProvider).usage();
  return switch (result) {
    Ok<MonetizationUsageSummary>(:final MonetizationUsageSummary value) => value,
    Err<MonetizationUsageSummary>(:final Failure failure) => throw failure,
  };
}

@riverpod
Future<CreditBalance> creditBalance(Ref ref) async {
  final Result<CreditBalance> result =
      await ref.watch(monetizationRepositoryProvider).credits();
  return switch (result) {
    Ok<CreditBalance>(:final CreditBalance value) => value,
    Err<CreditBalance>(:final Failure failure) => throw failure,
  };
}

/// The recent credit ledger (first page) for the credit dashboard.
@riverpod
Future<List<CreditTransaction>> creditLedger(Ref ref) async {
  final Result<CursorPage<CreditTransaction>> result =
      await ref.watch(monetizationRepositoryProvider).creditTransactions();
  return switch (result) {
    Ok<CursorPage<CreditTransaction>>(:final CursorPage<CreditTransaction> value) => value.items,
    Err<CursorPage<CreditTransaction>>(:final Failure failure) => throw failure,
  };
}

/// Recent invoices (first page) for billing history.
@riverpod
Future<List<Invoice>> invoiceHistory(Ref ref) async {
  final Result<CursorPage<Invoice>> result =
      await ref.watch(monetizationRepositoryProvider).invoices();
  return switch (result) {
    Ok<CursorPage<Invoice>>(:final CursorPage<Invoice> value) => value.items,
    Err<CursorPage<Invoice>>(:final Failure failure) => throw failure,
  };
}

/// Recent payments (first page) for billing history.
@riverpod
Future<List<Payment>> paymentHistory(Ref ref) async {
  final Result<CursorPage<Payment>> result =
      await ref.watch(monetizationRepositoryProvider).payments();
  return switch (result) {
    Ok<CursorPage<Payment>>(:final CursorPage<Payment> value) => value.items,
    Err<CursorPage<Payment>>(:final Failure failure) => throw failure,
  };
}
