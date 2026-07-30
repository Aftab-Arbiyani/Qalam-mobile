# 42 — Mobile Readiness Report (Epic M1: Foundation)

> **Scope:** M1 — the production-ready Flutter **foundation** (infrastructure only).
> No business features (auth, feed, writing, profile, search, notifications,
> analytics) are implemented. This report is the deliverable summary for M1.
>
> **Governing docs:** `docs/40_MobileArchitecture.md`, `docs/41_MobileDesignSystem.md`.
> **Code location:** `mobile/` (a self-contained Flutter app, extractable to its own
> repository per the ADR "separate repo" intent).
> **Toolchain:** Flutter 3.44 · Dart 3.12.

---

## 1. Folder tree (as built)

```
mobile/
├── pubspec.yaml · analysis_options.yaml · l10n.yaml
├── lib/
│   ├── main.dart · bootstrap.dart
│   ├── app/            app.dart · observers/ · router/(routes, guards, app_router)
│   ├── core/
│   │   ├── config/     app_config · app_flavor · app_environment_info
│   │   ├── connectivity/ connectivity_service · connectivity_providers
│   │   ├── di/         providers            (the DI graph)
│   │   ├── error/      failure · api_exception · error_mapper · error_messages
│   │   ├── logging/    app_logger · log_redaction
│   │   ├── media/      media_url_builder
│   │   ├── network/    dio_client · api_client · auth_gateway · request_deduplicator
│   │   │               · dio_error_converter · api_paths · request_keys
│   │   │               · interceptors/(auth, retry, logging)
│   │   ├── notifications/ push_messaging_service · local_notification_service (placeholders)
│   │   ├── security/   token_store · certificate_pinning · biometric_gate · device_integrity
│   │   ├── session/    session_state · session_controller
│   │   ├── storage/    hive_boxes · cache_store · cache_policy · secure_storage · preferences_store
│   │   └── utils/      result · jwt · typedefs
│   ├── shared/
│   │   ├── api/        api_envelope (error payload, cursor/offset meta, CursorPage)
│   │   ├── domain/     enums · error_codes · limits · permissions  (mirror @qalam/shared)
│   │   ├── motion/     motion
│   │   ├── theme/      tokens/(color, typography, spacing, radius, elevation, motion)
│   │   │               · q_tokens · app_theme · theme_mode_controller
│   │   └── widgets/    buttons · inputs · cards · feedback · loading · states
│   │                   · app_bar · navigation · media · layout · list · haptics
│   ├── features/       shell/ · splash/ · gallery/   (M1 placeholders)
│   └── l10n/           app_en.arb (+ generated)
└── test/               core/ · shared/ · app/ · support/ (harness + goldens)
```

## 2. Dependency graph (layer rule)

```
        ┌───────────────┐
        │ presentation  │  widgets + Riverpod providers (features/*/presentation, app/)
        └──────┬────────┘
               │ depends on interfaces + entities
        ┌──────▼────────┐
        │    domain     │  entities · repository INTERFACES · use cases (pure Dart)
        └──────▲────────┘
               │ implemented by
        ┌──────┴────────┐
        │     data      │  repository impls · datasources · DTO⇄entity mappers
        └──────┬────────┘
               │ uses
        ┌──────▼────────┐
        │ core + shared │  Dio/interceptors · storage · session · error · design system
        └───────────────┘
```

- Dependencies point **inward**; the domain depends on nothing outward.
- **Features never depend on features.** `app/` composes; features never import `app/`.
- No circular dependencies (the import graph is a DAG rooted at `main.dart`).
- DI is Riverpod only — no service locator, no global mutable state.

## 3. Navigation architecture

GoRouter (`app/router/app_router.dart`), keep-alive provider. A
`StatefulShellRoute.indexedStack` hosts the 5-tab bottom nav (Feed · Search ·
**Write** (accented) · Notifications · Profile), each branch keeping its own stack.
Full-screen routes (splash, settings, login, gallery) sit outside the shell.
Redirect-based guards read the session tri-state (`guardRedirect`, pure + unit-tested);
protected + anonymous → login with `returnTo`; unknown → splash on cold start.
Fade page transitions; `errorBuilder` → unknown-route surface. Deep-link-native
(the path table is the resolver); push-payload deep links wired for Phase 2.

## 4. State-management architecture

Riverpod (`@riverpod` code-gen). Four buckets: server state (repository-backed
`AsyncNotifier`, M2+), client/UI state (`Notifier` — `themeModeController`), session
(`SessionController` tri-state), and "URL" state (GoRouter). Singletons are
`keepAlive`; screen state is `autoDispose`. `ProviderObserver` logs provider failures.

## 5. Network architecture

Single choke point `core/network`. `ApiClient` unwraps the frozen `{success,data,meta}`
envelope, reads cursor meta at `meta.pagination`, applies query conventions,
de-duplicates GETs, detects offline up front, and converts `DioException` →
`ApiException`. Interceptors: Auth (Bearer + **single-flight refresh** + retry-once on
`AUTH_TOKEN_EXPIRED`) → Retry (GET 5xx/transport) → Logging (redacted). `X-Client:
mobile` globally. Repositories map `ApiException` → domain `Failure`. DTOs are
generated from `openapi.json` in M2 (never hand-written).

## 6. Storage architecture

- **Secrets → `flutter_secure_storage`** only (`TokenStore`: access in memory +
  secure storage, refresh in secure storage; atomic rotation).
- **Non-secret cache → Hive CE** (`CacheStore` abstraction + `HiveCacheStore`), with
  TTL tiers (`CachePolicy`: live/identity/content/taxonomy) mirroring the web
  staleTime policy; cache-schema bump clears the box (never migrated).
- **Device prefs → Hive `prefs` box** (`PreferencesStore`: theme, reading size,
  reduced-motion, remember-me).

## 7. Theme architecture

Material 3 built entirely from Qalam tokens (`app_theme.dart`), with tonal elevation
suppressed (warm shadows in light, border+surface in dark), static input labels, and
the `QTokens` `ThemeExtension` carrying the non-Material palette + shadows. Light +
dark themes; `themeMode` persisted (System default). Dynamic color is plumbed via
`DynamicColorBuilder` but **off by default** (brand palette wins). Tokens: colors
(exact ADR §7 hexes), 1.25 type scale, 4px spacing, 6/10/16/full radii, 3 elevation
levels, 150/250/400ms motion.

## 8. Reusable component inventory

Buttons (`QButton`) · Inputs (`QTextField`, `QSearchField`) · Cards (`QCard`) · Chips
(`QChip`) · Badges (`QBadge`) · Dialogs (`QDialog`) · Bottom sheets (`QBottomSheet`) ·
Snackbars (`QSnackbar`) · Loading (`QLoadingIndicator`) · Skeletons (`QSkeleton`,
`QPieceCardSkeleton`) · Empty states (`QEmptyState`) · Error view (`QErrorView`) · App
bar (`QAppBar`) · Navigation (`QNavScaffold`, `QNavDestination`) · Avatar (`QAvatar`) ·
Network image (`QNetworkImage`) · Layout (`QScaffold` + offline banner, breakpoints /
`QAdaptiveLayout`) · List (`QPagedListView` infinite scroll, `QRefresh` pull-to-refresh)
· Haptics (`QHaptics`). All exercised in the debug **design gallery**
(`features/gallery`).

## 9. Documentation index

| Doc | Location |
| --- | --- |
| Mobile Architecture (source of truth) | `docs/40_MobileArchitecture.md` |
| Mobile Design System (source of truth) | `docs/41_MobileDesignSystem.md` |
| Mobile Readiness Report (this) | `docs/42_MobileReadinessReport.md` |
| Folder Structure Guide | `docs/folder-structure.md` |
| State Management Guide | `docs/state-management.md` |
| Navigation Guide | `docs/navigation.md` |
| Networking Guide | `docs/networking.md` |
| Dependency Injection Guide | `docs/dependency-injection.md` |
| Testing Guide | `docs/testing.md` |

## 10. Quality gates

| Gate | Status |
| --- | --- |
| `flutter analyze` — zero issues | ✅ `No issues found!` |
| `flutter test` — all pass | ✅ (see §11) |
| No warnings | ✅ |
| No `TODO`s / dead code / duplicated components/repositories/providers | ✅ |
| Strict analysis (strict-casts/inference/raw-types + curated lints) | ✅ |
| Architecture + design-system docs complete | ✅ (`docs/40`, `docs/41`) |
| App launches successfully | ✅ (launch widget test lands on the feed) |

## 11. Test coverage (M1)

Unit: enums (wire parity), error mapping, guards, cache store, ApiClient, auth-gateway
single-flight refresh. Widget: `QButton`. Golden: `QButton` variants. Navigation +
Riverpod + launch: `app_launch_test` (feed landing, branch switching, offline banner).
Harness fakes every platform channel (secure storage, connectivity, Hive) so tests run
on the Dart VM.

## 12. Explicit M1 decisions & deferrals

- **Separate-repo intent honored:** the app is a self-contained `mobile/` tree.
- **Firebase Messaging & flutter_local_notifications are placeholder *architectures***
  (interfaces + no-op impls in `core/notifications`), **not added as packages**, to
  keep the foundation build-green and un-gated on Firebase config. Their concrete
  implementations drop in behind the existing interfaces in the notifications/push
  epic with zero refactor (`docs/40` §32–§33).
- **Security placeholders** (certificate pinning, biometric gate, root/jailbreak
  detection) are interfaces + no-op impls, swapped in the hardening epic.
- **Dynamic color** is plumbed but off (brand palette wins).
- **Custom fonts** (Inter/Lora/Noto) are not yet bundled — the theme uses system
  fallbacks (keeps goldens deterministic); font assets land in the design-system
  polish. Icons use Material Icons in M1; Lucide is wired later (`docs/41` §10).
- **`riverpod_lint`/`custom_lint`** were omitted (incompatible with the latest
  Riverpod 3.3 + Freezed 3 analyzer constraints); static analysis relies on the
  analyzer + `flutter_lints` + curated rules.
- **No offline write store** (permanent Non-Goal until a product re-decision) — M1
  ships cache-read degradation + connectivity UX only.

## 13. Readiness verdict

**M1 is complete and production-ready as a foundation.** The architecture supports
every planned epic M2–M10 as additive feature modules requiring **no refactor**:
each adds a `features/<name>/{domain,data,presentation}` slice, its routes, and
(from M2) generated DTOs — over the frozen `v1` contract. **Stop here; do not begin
M2 until this foundation is approved.**
