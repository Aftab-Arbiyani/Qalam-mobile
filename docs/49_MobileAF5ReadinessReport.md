# 49 — Mobile AF5 Readiness Report (Monetization Platform)

> The Flutter client for AF5 (Monetization). Backend architecture + the full 13-point
> deliverable set live in `platfrom/docs/37_MonetizationPlatformArchitecture.md`; this is
> the mobile-specific readiness note (mirrors docs/47/48).

## Scope delivered

- **`lib/core/billing/store_billing_gateway.dart`** — the store-SDK seam (docs/40 §41):
  `StoreBillingGateway` interface + inert `NoopStoreBillingGateway` default (no store SDK
  dependency added). A real StoreKit/Play/RevenueCat integration is a `bootstrap` provider
  override — zero change to the feature/UI. The server validates receipts; the client never
  trusts a local purchase.
- **`lib/features/monetization/`** — clean-architecture slice:
  - domain: `entitlement`, `subscription`, `plan`, `usage_summary`, `credit`, `billing`,
    `coupon_validation` entities + `monetization_enums` (Dart mirror of `@qalam/shared`).
  - data: `monetization_remote_data_source` (over the reused `ApiClient`), the
    `entitlement_cache_store` (Hive, offline-tolerant), `monetization_repository_impl`
    (wraps `guardResult`; caches the snapshot on each successful read).
  - presentation: providers (entitlement snapshot, subscription, plans, usage, credits,
    ledger/invoices/payments), the `SubscriptionController` (subscribe/change/cancel/
    reactivate/pause/resume/restore/buy-credits), `PremiumGate`/`PremiumBadge`/lock card,
    and five screens — **plan comparison, subscription management (trial/grace/expired/
    paused experiences + cancel/reactivate/pause/resume/restore), usage dashboard, credit
    dashboard, billing history**.
- **Gating:** `PremiumGate(feature:)` / `premiumFeatureAllowedProvider` read the
  server-authoritative entitlement snapshot as a UX hint (the AF1 PBAC "capability as hint,
  server authoritative" pattern). No scattered plan checks.
- **Wiring:** `AppConfig.enableMonetization` (compile kill-switch, mirrors `enableAi`) +
  `ApiPaths.monetization*` + `ErrorCodes` monetization codes + `/billing/*` routes
  (session-gated) + a gated **Settings → Premium** entry.

## Verification

- `flutter analyze` → **0 issues** (whole app).
- `flutter test` → **467 pass** (+12 AF5: entitlement logic, formatting, repository-cache
  behavior, PremiumGate widget). The only 2 failures are the pre-existing
  `comment_tile` golden diffs unrelated to AF5 (see docs/47).
- `flutter build apk --release` → **succeeds** (67 MB).

## Contract-bound seams (documented, inert)

- **Store billing** is inert (`NoopStoreBillingGateway`) — real purchases need a store SDK
  bound in `bootstrap`. Store-provider checkout on this build reports "in-app purchases not
  available"; Stripe checkout returns a URL surfaced in a sheet (a `url_launcher` open is a
  one-line seam — no new dependency added this epic).
- Credit purchases require a store receipt (mobile-primary IAP path); Stripe credit-pack
  fulfilment via `checkout.session.completed` is a backend seam.

## Known limits

Store IAP, `url_launcher`, and full App Store JWS verification are activation seams, not
gaps — the architecture accommodates them additively. React frontend/admin monetization UI
are deferred (backend admin API shipped), matching the AF4 client-scope precedent.
