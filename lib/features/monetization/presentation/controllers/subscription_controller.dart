/// Subscription + purchase actions (AF5) — the write-side controller. Each action
/// drives the repository (and the store-billing gateway for store purchases), reflects
/// a busy/error state via [AsyncValue], and invalidates the affected read providers on
/// success so the entitlement snapshot + subscription views refresh immediately. The
/// server is authoritative: a store purchase's receipt is validated server-side.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/billing/store_billing_gateway.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/billing.dart';
import '../../domain/entities/monetization_enums.dart';
import '../../domain/repositories/monetization_repository.dart';
import '../providers/monetization_providers.dart';

part 'subscription_controller.g.dart';

@riverpod
class SubscriptionController extends _$SubscriptionController {
  @override
  Future<void> build() async {}

  MonetizationRepository get _repo => ref.read(monetizationRepositoryProvider);

  /// Start a checkout. For a store provider with a wired gateway the purchase happens
  /// on-device and the receipt is sent for server validation; otherwise the backend
  /// returns a checkout URL (Stripe) for the UI to open. Returns the checkout result
  /// (with an optional URL), or null on failure (state carries the error).
  Future<CheckoutResult?> subscribe({
    required String tier,
    required String interval,
    required String provider,
    String? couponCode,
  }) async {
    return _run(() async {
      String? receipt;
      if (_isStore(provider)) {
        final StoreBillingGateway gateway = ref.read(storeBillingGatewayProvider);
        if (gateway.isAvailable) {
          final StorePurchaseResult purchase =
              await gateway.purchase(_storeProductId(tier, interval));
          receipt = purchase.receipt;
        }
      }
      return _unwrap(
        await _repo.subscribe(
          tier: tier,
          interval: interval,
          provider: provider,
          couponCode: couponCode,
          receipt: receipt,
        ),
      );
    });
  }

  Future<bool> changePlan({
    required String tier,
    required String interval,
    bool atPeriodEnd = false,
  }) => _mutate(() => _repo.changePlan(tier: tier, interval: interval, atPeriodEnd: atPeriodEnd));

  Future<bool> cancel({bool immediate = false}) =>
      _mutate(() => _repo.cancel(immediate: immediate));

  Future<bool> reactivate() => _mutate(_repo.reactivate);
  Future<bool> pause() => _mutate(_repo.pause);
  Future<bool> resume() => _mutate(_repo.resume);

  /// Restore store purchases from a receipt obtained via the store gateway.
  Future<RestoreResult?> restore({required String provider}) async {
    return _run(() async {
      final StoreBillingGateway gateway = ref.read(storeBillingGatewayProvider);
      if (!gateway.isAvailable) {
        throw const StoreBillingUnavailable();
      }
      final List<StorePurchaseResult> purchases = await gateway.restorePurchases();
      if (purchases.isEmpty) {
        return null;
      }
      return _unwrap(
        await _repo.restore(provider: provider, receipt: purchases.first.receipt),
      );
    });
  }

  /// Buy a credit pack via a store receipt.
  Future<Purchase?> purchaseCredits({
    required int credits,
    required String provider,
    required String productId,
  }) async {
    return _run(() async {
      final StoreBillingGateway gateway = ref.read(storeBillingGatewayProvider);
      if (!gateway.isAvailable) {
        throw const StoreBillingUnavailable();
      }
      final StorePurchaseResult purchase = await gateway.purchase(productId);
      return _unwrap(
        await _repo.purchaseCredits(
          credits: credits,
          provider: provider,
          receipt: purchase.receipt,
        ),
      );
    });
  }

  // ── Internals ────────────────────────────────────────────────────────────────

  /// Run an action that returns a value, tracking busy/error state + refreshing reads.
  Future<T?> _run<T>(Future<T?> Function() op) async {
    state = const AsyncValue<void>.loading();
    try {
      final T? value = await op();
      state = const AsyncValue<void>.data(null);
      _refreshReads();
      return value;
    } catch (error, stack) {
      state = AsyncValue<void>.error(error, stack);
      return null;
    }
  }

  /// Run a void mutation; returns true on success.
  Future<bool> _mutate(Future<Result<Object?>> Function() op) async {
    state = const AsyncValue<void>.loading();
    final Result<Object?> result = await op();
    switch (result) {
      case Ok<Object?>():
        state = const AsyncValue<void>.data(null);
        _refreshReads();
        return true;
      case Err<Object?>(:final Failure failure):
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return false;
    }
  }

  T _unwrap<T>(Result<T> result) => switch (result) {
    Ok<T>(:final T value) => value,
    Err<T>(:final Failure failure) => throw failure,
  };

  void _refreshReads() {
    ref.invalidate(entitlementSnapshotProvider);
    ref.invalidate(currentSubscriptionProvider);
    ref.invalidate(creditBalanceProvider);
    ref.invalidate(monetizationUsageProvider);
  }

  bool _isStore(String provider) =>
      provider == PaymentProvider.appleAppStore || provider == PaymentProvider.googlePlay;

  /// Map a plan+interval to a store product id (convention `com.qalam.<tier>.<interval>`).
  String _storeProductId(String tier, String interval) => 'com.qalam.$tier.$interval';
}
