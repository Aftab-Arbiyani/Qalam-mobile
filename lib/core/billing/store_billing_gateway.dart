/// The store-billing seam (AF5, docs/40 §41). Apple StoreKit / Google Play Billing
/// (or an abstraction like RevenueCat) sit BEHIND this interface — the app never
/// couples UI or repositories to a billing SDK. A purchase completes on-device via
/// the platform store; this gateway returns the opaque RECEIPT / purchase token,
/// which the app sends to the backend for SERVER-SIDE validation (the server is the
/// authority on entitlement; the client purchase is never trusted).
///
/// Phase-1/AF5 ships the seam + a [NoopStoreBillingGateway] (no store SDK dependency
/// added). When a store integration lands, it implements this interface and is bound
/// via a provider override in `bootstrap` — zero change to the feature/UI. This
/// mirrors how the crash-reporter + cert-pinning seams stay inert until configured.
library;

/// A purchasable store product (subscription or consumable credit pack).
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.priceLabel,
    required this.rawPriceMinor,
    required this.currency,
    required this.isSubscription,
  });

  /// Store product id (e.g. `com.qalam.pro.monthly`, `com.qalam.credits.5000`).
  final String id;
  final String title;
  final String description;

  /// Localized display price (e.g. "$14.99") from the store.
  final String priceLabel;

  /// Price in minor units (cents), when the store exposes it.
  final int rawPriceMinor;
  final String currency;
  final bool isSubscription;
}

/// The outcome of a completed on-device store purchase.
class StorePurchaseResult {
  const StorePurchaseResult({
    required this.productId,
    required this.receipt,
    required this.purchaseId,
  });

  final String productId;

  /// The opaque receipt / purchase token to send to the backend for validation.
  /// Apple: the base64 app receipt. Google: a JSON `{ productId, purchaseToken }`.
  final String receipt;

  /// Provider transaction id (for local correlation only; server re-verifies).
  final String purchaseId;
}

/// Raised when the store SDK is unavailable (not configured / unsupported platform).
class StoreBillingUnavailable implements Exception {
  const StoreBillingUnavailable([this.message = 'In-app purchases are not available.']);
  final String message;
  @override
  String toString() => 'StoreBillingUnavailable: $message';
}

/// Raised when the user cancels the store purchase sheet.
class StorePurchaseCancelled implements Exception {
  const StorePurchaseCancelled();
  @override
  String toString() => 'StorePurchaseCancelled';
}

/// The billing gateway the app depends on (never a concrete SDK).
abstract interface class StoreBillingGateway {
  /// Whether a store billing backend is wired on this build/platform.
  bool get isAvailable;

  /// The store's product catalogue for the given product ids.
  Future<List<StoreProduct>> queryProducts(List<String> productIds);

  /// Drive the platform purchase sheet; resolves with the receipt on success.
  /// Throws [StorePurchaseCancelled] if the user backs out, [StoreBillingUnavailable]
  /// if no store is wired.
  Future<StorePurchaseResult> purchase(String productId);

  /// Restore prior purchases (Apple/Google "restore"); returns their receipts.
  Future<List<StorePurchaseResult>> restorePurchases();
}

/// The inert default (AF5) — no store SDK is bundled, so every call reports the
/// store is unavailable. Purchases route through the backend (Stripe checkout URL)
/// until a store gateway is bound. Tests need no override (this is the default).
class NoopStoreBillingGateway implements StoreBillingGateway {
  const NoopStoreBillingGateway();

  @override
  bool get isAvailable => false;

  @override
  Future<List<StoreProduct>> queryProducts(List<String> productIds) async =>
      const <StoreProduct>[];

  @override
  Future<StorePurchaseResult> purchase(String productId) async =>
      throw const StoreBillingUnavailable();

  @override
  Future<List<StorePurchaseResult>> restorePurchases() async =>
      throw const StoreBillingUnavailable();
}
