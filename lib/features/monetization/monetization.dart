/// Monetization feature (AF5) public surface — the entitlement snapshot + gating
/// widgets other features compose, plus the domain entities. Screens are reached by
/// route name (the cross-feature contract); features never import each other's widgets.
library;

export 'domain/entities/entitlement.dart';
export 'domain/entities/monetization_enums.dart';
export 'presentation/providers/monetization_providers.dart'
    show entitlementSnapshotProvider;
export 'presentation/widgets/premium_gate.dart' show PremiumBadge, PremiumGate;
