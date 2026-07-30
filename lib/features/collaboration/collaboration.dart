/// Collaboration / Publishing / Trust feature (AF6) public surface — the capability
/// map + gating widgets other features compose, plus the domain vocabulary. Screens
/// are reached by route name (the cross-feature contract); features never import each
/// other's screens.
library;

export 'domain/entities/collaboration_enums.dart';
export 'domain/entities/policy_capability.dart'
    show PolicyCapability, StoryCapabilities;
export 'domain/entities/trust_summary.dart' show TrustSummary, UserRestriction;
export 'presentation/providers/collaboration_providers.dart'
    show storyCapabilitiesProvider, trustSummaryProvider;
export 'presentation/widgets/capability_gate.dart' show CapabilityGate;
export 'presentation/widgets/presence_bar.dart' show PresenceBar;
export 'presentation/widgets/restricted_banner.dart' show RestrictedBanner;
export 'presentation/widgets/role_badge.dart' show RoleBadge;
