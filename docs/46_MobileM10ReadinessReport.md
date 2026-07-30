# Mobile M10 — Production Readiness Report

Epic **M10 — Production Hardening & Release Readiness**. No new product features;
audit, verify, close real gaps, document. Scope: `mobile/` only. Backend, web, and
admin untouched.

- **Flutter analyze:** 0 issues (lib + test).
- **Tests:** 400 passing (unit, widget, golden), incl. 6 new hardening tests.
- **Release build:** `flutter build apk --release` succeeds (see §10).
- **Version:** `1.0.0+1` (`pubspec.yaml`).
- Hand-written Dart: ~420 files; test files: 81.

---

## 1. What changed in M10 (hardening only)

| Area | Change | Files |
| --- | --- | --- |
| Crash reporting | New DSN-gated `CrashReporter` seam (`NoopCrashReporter` + breadcrumbs + release/env metadata); `FlutterError.onError`, `PlatformDispatcher.onError` and a new `runZonedGuarded` all forward to it; navigation breadcrumbs | `core/observability/crash_reporter.dart`, `bootstrap.dart`, `app/observers/app_navigator_observer.dart`, `core/di/providers.dart` |
| Logging | Added `critical` level (`AppLogger.c`); `recordError` now vendor-agnostic; production gating verified | `core/logging/app_logger.dart` |
| Security | Certificate-pinning **hook wired** into the Dio builder (inert Noop, one-swap activation) | `core/network/dio_client.dart`, `core/di/providers.dart` |
| Build config | Real Android release **signing placeholders** via `key.properties` (falls back to debug locally); removed template TODOs | `android/app/build.gradle.kts`, `android/key.properties.example` |
| Dependencies | `connectivity_plus` 7.2.0→7.3.0, `package_info_plus` 10.2.0→10.2.1 (in-range) | `pubspec.lock` |

No product behavior changed. The existing 394-test suite still passes unchanged.

---

## 2. Architecture validation report

Reviewed the whole `lib/` tree. **No architectural regressions.**

- **Feature isolation:** 0 cross-feature imports (verified: no `features/<a>` file imports `features/<b>`, package- or relative-path). Shared code lives in `lib/shared/` and `lib/core/`.
- **Shared synchronization engine:** exactly ONE engine (`core/sync/SyncEngine`). The three former bespoke engines were removed in M9 and remain gone (only accurate migration prose references them in handler doc comments). Every offline action (like/bookmark/follow, notification actions, comments, profile, settings) registers a `SyncHandler`; the offline-draft state machine runs as a background task on the same connectivity signal.
- **Repository consistency:** each domain repository interface is declared exactly once (no duplicates); all bound through Riverpod providers.
- **Riverpod consistency:** DI is 100% Riverpod, no service locator. Bootstrapped singletons are overridden once in `bootstrap.dart`; everything else derives.
- **Navigation consistency:** single `GoRouter` (`app/router/`), path constants centralized in `Routes`, full-screen vs. shell routes consistent.
- **Notification / search architecture:** unchanged, consistent with M6–M8.
- **No duplicated widgets/providers/repositories** (analyzer + manual review).

## 3. Performance optimization summary

Audited; the codebase was already built to the perf rules (docs/40 §36). Findings:

- **Widget & provider rebuilds:** `@riverpod` autoDispose controllers scope rebuilds; `select`/`AsyncValue` used to avoid over-watching; `const` constructors used pervasively (analyzer `prefer_const_*` clean).
- **List virtualization:** 11 lazy builders (`ListView.builder`/`.separated`/`SliverList`) across feed/search/social/notifications; cursor pagination via the shared `CursorPaginator`.
- **Image loading:** single `cached_network_image` wrapper (one file, reused) — memory + disk cache, no duplicate image code; covers downscaled via `MediaUrlBuilder`.
- **Startup:** async init is minimal and parallel-friendly in `bootstrap`; splash paints immediately; cache maintenance runs off the critical path.
- **Charts:** dependency-free `CustomPainter`s (no chart lib), `shouldRepaint` guarded; lazy-built in `ListView`.
- **Network/cache:** one shared Dio with request coalescing + retry; tiered `CacheStore` (live/identity/content/taxonomy) with cache-then-network; analytics repo adds offline cache-fallback.
- **DB queries:** Hive is key/value; reading-history + outbox reads are bounded (capped entries, single-pass).
- **Allocations:** no per-frame allocations in painters beyond `Paint`; breadcrumb buffer bounded (50).

Deferred (documented, not regressions): Android R8/resource shrinking is left OFF to avoid un-vetted plugin stripping — Dart tree-shaking + `--obfuscate` cover code size; enabling R8 is a checklist item requiring device QA (§13).

## 4. Security review summary

Verified against docs/40 §39 and docs/13.

- **Secure storage:** tokens only in `flutter_secure_storage` via `SecureStorage`/`TokenStore`; non-secret prefs/cache in Hive. No secrets in Hive.
- **Token lifecycle:** access+refresh with rotation in `AuthGateway`/`AuthInterceptor`; refresh corridor exempt from the 401→refresh loop; `X-Client: mobile` returns refresh in body.
- **No secrets in source:** grep clean — only password-field UI identifiers; DSN/keys come from `--dart-define` and git-ignored `key.properties`.
- **Safe logging:** `log_redaction.dart` redacts tokens/passwords/OAuth codes/cookies/emails; release logs ≥ warning; crash reports + breadcrumbs are id-only.
- **Clipboard:** only writes a public share URL (no sensitive data).
- **Certificate pinning:** hook now applied to the Dio client (`pinning.apply(dio)`); inert `NoopCertificatePinning` until a pin set + rotation plan exist — activation is a single provider swap.
- **Input validation:** DTO/form validators (`features/*/validators`, `AuthValidators`) + server error mapping.
- **Debug endpoints:** none. Design-gallery route is dev-only content, not an endpoint.
- **Background privacy:** see Known Limitations (§14) — recommended as a native follow-up.

## 5. Crash reporting configuration

- **Seam:** `CrashReporter` interface + `NoopCrashReporter` (DSN-gated). Activated by setting `QALAM_SENTRY_DSN` and dropping in a `SentryCrashReporter` (add `sentry_flutter`, forward `recordError`/`addBreadcrumb`/`setUser`) — no call-site changes. Mirrors the FCM-push and pinning seams.
- **Error channels wired (`bootstrap.dart`):** `FlutterError.onError` (fatal), `PlatformDispatcher.instance.onError`, and a top-level `runZonedGuarded`. All forward to the console logger **and** the reporter.
- **Breadcrumbs:** navigation transitions (route names only) + a bounded 50-entry trail; on a fatal error the Noop flushes the trail to the log for local/staging diagnosis.
- **Metadata:** release = `env.fullVersion` (`version+build`), environment = flavor (`development/staging/production`), platform from `AppEnvironmentInfo`.
- **Privacy:** reports/breadcrumbs are id-only; redaction list shared with logging; `setUser` takes an opaque id, never PII.
- **Verified by:** `test/core/observability/crash_reporter_test.dart`.

## 6. Logging architecture

- `AppLogger` wraps `package:logger`; the app depends on our interface, not the vendor.
- **Levels:** trace `t` · debug `d` · info `i` · warning `w` · error `e` · **critical `c`** (fatal). Maps to the epic's Debug/Info/Warning/Error/Critical.
- **Production gating:** `flavor.isProduction ? Level.warning : Level.debug` — verbose logging is compiled out of release behavior; `ProductionFilter` applied.
- **Structured + redacted:** the logging interceptor passes structured request data through `log_redaction.dart`.
- **Crash forwarding:** `recordError` logs to console; the `CrashReporter` handles upload (separation of concerns).

## 7. Accessibility audit summary

Audited against docs/28 + docs/41.

- **Screen readers / semantic labels:** 43 files use `Semantics`/`semanticLabel`/`Merge`/`Exclude`; charts, metric cards, sync indicator, storage rows expose merged, human labels; decorative visuals use `ExcludeSemantics`.
- **Dynamic text scaling:** **no** `textScaleFactor`/`textScaler` overrides anywhere → OS font-size scaling is fully respected (nothing clamps it). Layouts use flexible widgets + `maxLines`/`ellipsis`.
- **Touch targets:** interactive controls use `QButton` (≥32/40/48 dp) and Material `IconButton`/`InkWell` (48 dp min).
- **Focus traversal:** standard Flutter focus order preserved; dialogs/sheets use Material components with built-in focus handling.
- **Colour contrast:** design-system tokens (`color_tokens.dart`) are the byte-identical web palette meeting the documented contrast; light + dark verified in goldens.
- **Landscape/tablet:** responsive grids (`MetricGrid` 2/3-up), `Wrap`, scrollable bodies; no fixed-height overflow.

## 8. Dependency audit report

23 direct deps; all in use and maintained. No deprecated/unmaintained/duplicate packages.

- **Kept intentionally despite 0 direct imports:** `cupertino_icons` (standard iOS icon font asset) and `json_annotation` (runtime companion of the active `json_serializable` codegen; removing it makes generated code fragile to any future `@JsonKey`/`@JsonValue` for negligible size gain).
- **Storage:** uses the maintained `hive_ce`/`hive_ce_flutter` community fork (not the abandoned `hive`).
- **Upgraded (in-range, verified by full suite + build):** `connectivity_plus` 7.3.0, `package_info_plus` 10.2.1.
- **Not upgraded (constraint-locked or risky):** `intl` (pinned by `flutter_localizations`), `freezed`/`build_runner` (dev tooling on a dev channel — upgrading is a separate, tested chore), major bumps of transitives (`xml`, `analyzer`) — deferred to avoid codegen churn.
- **No native FCM/Sentry SDKs added** — both are gated seams (activate when configured).

## 9. Test coverage summary

400 tests across 81 files.

- **Unit:** sync engine (drain/retry/backoff/conflict/self-cancel/no-handler/tasks), outbox, handlers, cache manager, analytics value objects, crash reporter, Dio pinning hook, repositories, mappers, validators, enums.
- **Widget:** auth, feed, reading, writing/editor, profile, search, social, notifications, analytics screens/controllers.
- **Golden:** buttons, brand mark, comment tiles, charts (light).
- **Critical journeys covered:** authentication, reading, writing, publishing, profile, search, social, notifications, offline synchronization, analytics — each has controller/widget coverage; offline sync verified end-to-end (optimistic apply → queue → reconnect drain).

## 10. Release readiness checklist

- [x] `flutter analyze` — 0 issues
- [x] `flutter test` — 400 pass
- [x] Zero TODOs / dead code (Dart) ; template TODOs removed from Gradle
- [x] Zero duplicated repositories / providers / widgets
- [x] Debug release build succeeds (debug-signed fallback)
- [x] Crash-reporting seam wired + verified
- [x] Logging gated for production
- [x] Accessibility + performance audits complete
- [ ] **Store build (requires secrets, per environment):** populate `android/key.properties`, then:
  `flutter build appbundle --release --dart-define=QALAM_ENV=production --dart-define=QALAM_API_URL=https://api.qalam.app --dart-define=QALAM_SENTRY_DSN=… --obfuscate --split-debug-info=build/symbols`

## 11. Android release checklist

- [ ] Copy `android/key.properties.example` → `android/key.properties`; generate an upload keystore; fill values (git-ignored).
- [ ] Confirm `applicationId = com.qalam.qalam_mobile`, bump `version:` in `pubspec.yaml`.
- [ ] Build App Bundle with `--obfuscate --split-debug-info` (above); archive the `build/symbols` for de-obfuscating stack traces.
- [ ] (Optional, needs device QA) enable R8/`isMinifyEnabled` + `isShrinkResources` with a curated `proguard-rules.pro`.
- [ ] Play Console: data-safety form, permissions (INTERNET only; no runtime-dangerous perms unless push added), target-API compliance, store listing assets.
- [ ] Verify deep links / app links intent filters if enabling universal links.

## 12. iOS release checklist

- [ ] Xcode: set the release signing team + provisioning profile (Runner target) — signing lives in the Xcode project, not in Dart.
- [ ] Bump `CFBundleShortVersionString`/build (driven by `pubspec.yaml`).
- [ ] `flutter build ipa --release --obfuscate --split-debug-info=build/symbols` with the same `--dart-define`s.
- [ ] Info.plist: usage strings for any accessed capability (photo library for cover picker), ATS (HTTPS only in production — pair with certificate pinning when activated).
- [ ] App Store Connect: privacy nutrition labels, screenshots, review notes.
- [ ] If push is later enabled: APNs key + entitlement (currently a gated seam, not shipped).

## 13. Technical debt report

- **Crash reporting is a seam, not a live integration** — intentional (no DSN/SDK configured). Activation is documented and one swap.
- **Certificate pinning is inert** — needs a pin set + rotation plan before enabling; hook is wired.
- **Android R8 shrinking off** — deferred pending plugin-safe proguard rules + device QA.
- **`intl` constraint-locked** to the Flutter-pinned version.
- **Background-privacy screen** not implemented (see §14).
- No `TODO`s in Dart; no dead code.

## 14. Known limitations

- **Push (FCM):** gated Phase-2 seam; in-app polling only (M8). No backend token endpoint.
- **Background privacy (app-switcher redaction):** not implemented. A Flutter overlay on `AppLifecycleState.inactive/paused` covers Android snapshots but iOS screenshot suppression needs native code; recommended as a small native follow-up. Documented, not a regression.
- **Analytics growth series** is frequently empty by design (server snapshots are on-demand) — surfaced as a calm empty state, not an error.
- **Reader analytics range** is lifetime-only on `/analytics/me` (backend contract); the range selector scopes the growth series.

## 15. Production-readiness confirmation

The mobile application is **production-ready** for a store submission once environment
secrets (API URL, signing keystore, optional Sentry DSN) are supplied. All M10 quality
gates pass: analyze clean, 400 tests green, release build succeeds, crash-reporting and
offline-sync verified, accessibility and performance audits complete. **No architectural
regressions were introduced** — feature isolation, the single shared synchronization
engine, repository/Riverpod/navigation consistency, and DI discipline are all intact.
