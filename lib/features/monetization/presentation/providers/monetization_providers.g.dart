// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monetization_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(monetizationRemoteDataSource)
final monetizationRemoteDataSourceProvider =
    MonetizationRemoteDataSourceProvider._();

final class MonetizationRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          MonetizationRemoteDataSource,
          MonetizationRemoteDataSource,
          MonetizationRemoteDataSource
        >
    with $Provider<MonetizationRemoteDataSource> {
  MonetizationRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monetizationRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monetizationRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<MonetizationRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MonetizationRemoteDataSource create(Ref ref) {
    return monetizationRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonetizationRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonetizationRemoteDataSource>(value),
    );
  }
}

String _$monetizationRemoteDataSourceHash() =>
    r'08567d4a818b70602922636ffac395170cfe2686';

@ProviderFor(entitlementCacheStore)
final entitlementCacheStoreProvider = EntitlementCacheStoreProvider._();

final class EntitlementCacheStoreProvider
    extends
        $FunctionalProvider<
          EntitlementCacheStore,
          EntitlementCacheStore,
          EntitlementCacheStore
        >
    with $Provider<EntitlementCacheStore> {
  EntitlementCacheStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitlementCacheStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitlementCacheStoreHash();

  @$internal
  @override
  $ProviderElement<EntitlementCacheStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EntitlementCacheStore create(Ref ref) {
    return entitlementCacheStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntitlementCacheStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntitlementCacheStore>(value),
    );
  }
}

String _$entitlementCacheStoreHash() =>
    r'7745fa740fbaf82c76b87ddc4b0a58ae6b7b6e66';

@ProviderFor(monetizationRepository)
final monetizationRepositoryProvider = MonetizationRepositoryProvider._();

final class MonetizationRepositoryProvider
    extends
        $FunctionalProvider<
          MonetizationRepository,
          MonetizationRepository,
          MonetizationRepository
        >
    with $Provider<MonetizationRepository> {
  MonetizationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monetizationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monetizationRepositoryHash();

  @$internal
  @override
  $ProviderElement<MonetizationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MonetizationRepository create(Ref ref) {
    return monetizationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonetizationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonetizationRepository>(value),
    );
  }
}

String _$monetizationRepositoryHash() =>
    r'3fe4b28ca18c9e4685d23713da74db3b099c2eac';

/// The store-billing gateway (Apple/Google). Inert by default (no SDK bundled);
/// overridden in `bootstrap` when a store integration is wired (docs/40 §41).

@ProviderFor(storeBillingGateway)
final storeBillingGatewayProvider = StoreBillingGatewayProvider._();

/// The store-billing gateway (Apple/Google). Inert by default (no SDK bundled);
/// overridden in `bootstrap` when a store integration is wired (docs/40 §41).

final class StoreBillingGatewayProvider
    extends
        $FunctionalProvider<
          StoreBillingGateway,
          StoreBillingGateway,
          StoreBillingGateway
        >
    with $Provider<StoreBillingGateway> {
  /// The store-billing gateway (Apple/Google). Inert by default (no SDK bundled);
  /// overridden in `bootstrap` when a store integration is wired (docs/40 §41).
  StoreBillingGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeBillingGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeBillingGatewayHash();

  @$internal
  @override
  $ProviderElement<StoreBillingGateway> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StoreBillingGateway create(Ref ref) {
    return storeBillingGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreBillingGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreBillingGateway>(value),
    );
  }
}

String _$storeBillingGatewayHash() =>
    r'b537e817654765d026cb041b3951e958b48f21d8';

/// The server-authoritative entitlement snapshot — the SINGLE thing premium UI gates
/// on. Never throws: on a network failure it falls back to the last cached snapshot,
/// then to the free-tier default, so gating always resolves (server re-checks anyway).

@ProviderFor(entitlementSnapshot)
final entitlementSnapshotProvider = EntitlementSnapshotProvider._();

/// The server-authoritative entitlement snapshot — the SINGLE thing premium UI gates
/// on. Never throws: on a network failure it falls back to the last cached snapshot,
/// then to the free-tier default, so gating always resolves (server re-checks anyway).

final class EntitlementSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<EntitlementSnapshot>,
          EntitlementSnapshot,
          FutureOr<EntitlementSnapshot>
        >
    with
        $FutureModifier<EntitlementSnapshot>,
        $FutureProvider<EntitlementSnapshot> {
  /// The server-authoritative entitlement snapshot — the SINGLE thing premium UI gates
  /// on. Never throws: on a network failure it falls back to the last cached snapshot,
  /// then to the free-tier default, so gating always resolves (server re-checks anyway).
  EntitlementSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitlementSnapshotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitlementSnapshotHash();

  @$internal
  @override
  $FutureProviderElement<EntitlementSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EntitlementSnapshot> create(Ref ref) {
    return entitlementSnapshot(ref);
  }
}

String _$entitlementSnapshotHash() =>
    r'ab53517630f91d3ec05c439de97b29f68ea93bd9';

/// Whether the current user may use a premium [feature] (the gate widgets read this).

@ProviderFor(premiumFeatureAllowed)
final premiumFeatureAllowedProvider = PremiumFeatureAllowedFamily._();

/// Whether the current user may use a premium [feature] (the gate widgets read this).

final class PremiumFeatureAllowedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the current user may use a premium [feature] (the gate widgets read this).
  PremiumFeatureAllowedProvider._({
    required PremiumFeatureAllowedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'premiumFeatureAllowedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$premiumFeatureAllowedHash();

  @override
  String toString() {
    return r'premiumFeatureAllowedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return premiumFeatureAllowed(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PremiumFeatureAllowedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$premiumFeatureAllowedHash() =>
    r'2f264e715b4cf2b2387e57c1a1fb6d6217964331';

/// Whether the current user may use a premium [feature] (the gate widgets read this).

final class PremiumFeatureAllowedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  PremiumFeatureAllowedFamily._()
    : super(
        retry: null,
        name: r'premiumFeatureAllowedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the current user may use a premium [feature] (the gate widgets read this).

  PremiumFeatureAllowedProvider call(String feature) =>
      PremiumFeatureAllowedProvider._(argument: feature, from: this);

  @override
  String toString() => r'premiumFeatureAllowedProvider';
}

/// The current subscription, or null when the user has none (free).

@ProviderFor(currentSubscription)
final currentSubscriptionProvider = CurrentSubscriptionProvider._();

/// The current subscription, or null when the user has none (free).

final class CurrentSubscriptionProvider
    extends
        $FunctionalProvider<
          AsyncValue<Subscription?>,
          Subscription?,
          FutureOr<Subscription?>
        >
    with $FutureModifier<Subscription?>, $FutureProvider<Subscription?> {
  /// The current subscription, or null when the user has none (free).
  CurrentSubscriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSubscriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSubscriptionHash();

  @$internal
  @override
  $FutureProviderElement<Subscription?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Subscription?> create(Ref ref) {
    return currentSubscription(ref);
  }
}

String _$currentSubscriptionHash() =>
    r'f7f66478981f33b8daed2c5fc14dff2ecbb7f1db';

@ProviderFor(plans)
final plansProvider = PlansProvider._();

final class PlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlanCatalogue>,
          PlanCatalogue,
          FutureOr<PlanCatalogue>
        >
    with $FutureModifier<PlanCatalogue>, $FutureProvider<PlanCatalogue> {
  PlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plansHash();

  @$internal
  @override
  $FutureProviderElement<PlanCatalogue> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlanCatalogue> create(Ref ref) {
    return plans(ref);
  }
}

String _$plansHash() => r'b147f7c408539b346b03d43106a0ee799fd71c93';

@ProviderFor(monetizationUsage)
final monetizationUsageProvider = MonetizationUsageProvider._();

final class MonetizationUsageProvider
    extends
        $FunctionalProvider<
          AsyncValue<MonetizationUsageSummary>,
          MonetizationUsageSummary,
          FutureOr<MonetizationUsageSummary>
        >
    with
        $FutureModifier<MonetizationUsageSummary>,
        $FutureProvider<MonetizationUsageSummary> {
  MonetizationUsageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monetizationUsageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monetizationUsageHash();

  @$internal
  @override
  $FutureProviderElement<MonetizationUsageSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MonetizationUsageSummary> create(Ref ref) {
    return monetizationUsage(ref);
  }
}

String _$monetizationUsageHash() => r'356ac6cbc05934664a9cb0f1337fdf65d8a5e112';

@ProviderFor(creditBalance)
final creditBalanceProvider = CreditBalanceProvider._();

final class CreditBalanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreditBalance>,
          CreditBalance,
          FutureOr<CreditBalance>
        >
    with $FutureModifier<CreditBalance>, $FutureProvider<CreditBalance> {
  CreditBalanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditBalanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditBalanceHash();

  @$internal
  @override
  $FutureProviderElement<CreditBalance> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreditBalance> create(Ref ref) {
    return creditBalance(ref);
  }
}

String _$creditBalanceHash() => r'ef9e9e098c702fac35dabdbe65acf3aa0085ed40';

/// The recent credit ledger (first page) for the credit dashboard.

@ProviderFor(creditLedger)
final creditLedgerProvider = CreditLedgerProvider._();

/// The recent credit ledger (first page) for the credit dashboard.

final class CreditLedgerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CreditTransaction>>,
          List<CreditTransaction>,
          FutureOr<List<CreditTransaction>>
        >
    with
        $FutureModifier<List<CreditTransaction>>,
        $FutureProvider<List<CreditTransaction>> {
  /// The recent credit ledger (first page) for the credit dashboard.
  CreditLedgerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditLedgerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditLedgerHash();

  @$internal
  @override
  $FutureProviderElement<List<CreditTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CreditTransaction>> create(Ref ref) {
    return creditLedger(ref);
  }
}

String _$creditLedgerHash() => r'75bcfb17024b3b557f37b7f1ab20267ecbd723bc';

/// Recent invoices (first page) for billing history.

@ProviderFor(invoiceHistory)
final invoiceHistoryProvider = InvoiceHistoryProvider._();

/// Recent invoices (first page) for billing history.

final class InvoiceHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Invoice>>,
          List<Invoice>,
          FutureOr<List<Invoice>>
        >
    with $FutureModifier<List<Invoice>>, $FutureProvider<List<Invoice>> {
  /// Recent invoices (first page) for billing history.
  InvoiceHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invoiceHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invoiceHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<Invoice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Invoice>> create(Ref ref) {
    return invoiceHistory(ref);
  }
}

String _$invoiceHistoryHash() => r'2c9fa9fbd4c16f459545aaa4842bb8e9fb09502b';

/// Recent payments (first page) for billing history.

@ProviderFor(paymentHistory)
final paymentHistoryProvider = PaymentHistoryProvider._();

/// Recent payments (first page) for billing history.

final class PaymentHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Payment>>,
          List<Payment>,
          FutureOr<List<Payment>>
        >
    with $FutureModifier<List<Payment>>, $FutureProvider<List<Payment>> {
  /// Recent payments (first page) for billing history.
  PaymentHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<Payment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Payment>> create(Ref ref) {
    return paymentHistory(ref);
  }
}

String _$paymentHistoryHash() => r'93107d2c086eb5c57847771d267ef0e3eedbcdb6';
