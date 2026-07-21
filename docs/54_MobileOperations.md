# 54 — Mobile Operations (P7.4)

**Status:** ✅ Complete · **Scope:** the Flutter side of the Operations Platform — crash reporting, performance monitoring, network diagnostics, operational logging, release diagnostics, remote feature-flag integration, and production telemetry. **No new product features. No UI redesign.** Every capability follows the app's established **inert-seam** pattern, so nothing phones home until a concrete backend is wired — the same discipline as the P7.2 security seams and the existing crash-reporter / remote-config seams.

Backend counterpart: **[platfrom/docs/44](../../platfrom/docs/44_OperationsPlatform.md)**.

---

## 1. Architecture — the inert-seam pattern

Each operational capability is an `abstract interface class` in `lib/core/observability/` with an inert `Noop…` default, chosen once in `lib/bootstrap.dart` via a `create…()` factory, injected as a Riverpod provider (defaulting to the Noop so tests need no override), and reconstructable for a real backend (Sentry / Firebase / a custom collector) with **no call-site change**. This mirrors the existing `CrashReporter` and `RemoteConfigService` seams exactly. No new pub dependencies are added (Firebase/Sentry remain Phase-2 seams per the pubspec).

The seams are designed to compose the hooks the app already has (each hook feeds its seam when a concrete backend is activated — inert by default, exactly like the existing push / cert-pinning seams):

- **Global error capture** — `runZonedGuarded`, `FlutterError.onError`, and `PlatformDispatcher.instance.onError` (in `bootstrap.dart`) already forward to the crash reporter; `OperationalLogger.recordError` + `ProductionTelemetry` compose that same reporter, so errors flow into the telemetry stack.
- **Correlation** — the `x-request-id` response header the Dio `LoggingInterceptor` reads is the correlation id `NetworkDiagnostics.recordRequest` carries (path + id only, never bodies/PII).
- **Cold start** — the `startupWatch` / `bootstrapMs` timer is recorded into `PerformanceMonitor` (`PerfMetric.coldStartMs`) at activation.
- **Redaction** — `lib/core/logging/log_redaction.dart` (the backend Pino redaction mirror) is reused for every operational log; telemetry is **id-only, never PII**.
- **Release metadata** — `AppEnvironmentInfo` (version / buildNumber / flavor / platform / device) is the release-diagnostics source.

---

## 2. Capabilities

| Capability | Seam | Behavior (inert default) |
| --- | --- | --- |
| **Crash reporting** | `CrashReporter` (existing) | Bounded PII-free breadcrumb ring; fatal-error capture from the global handlers; release/environment context. Drop-in `SentryCrashReporter` later. |
| **Performance monitoring** | `PerformanceMonitor` | Traces + metrics (cold start `bootstrapMs`, frame + network timings); bounded in-memory ring for a debug view. |
| **Network diagnostics** | `NetworkDiagnostics` | Per-request outcome (method, path, status, duration, `x-request-id`, ok) fed from the Dio funnel — id + path only; error-rate + latency read model. |
| **Operational logging** | `OperationalLogger` | Classification wrapper over `AppLogger` (error / audit / access / application), always through `log_redaction`; errors forwarded to the crash reporter. |
| **Release diagnostics** | `ReleaseDiagnostics` | `AppEnvironmentInfo` + a `diagnostics()` map for support; attaches release + channel context to crash reports. |
| **Remote feature flags** | `RemoteConfigService` (existing) + reconciliation helper | Reconciles the three flag layers: compile-time `AppConfig.enable*` kill switches (outer gate) → `RemoteConfigService` (runtime remote, inert) → server flags. `isEnabled(key, {fallback})`. |
| **Production telemetry** | `ProductionTelemetry` | Umbrella facade composing all of the above behind one `initialize()` + `snapshot()`/`diagnostics()`. Inert by default. |

---

## 3. Files & wiring

New seams (`lib/core/observability/`): `performance_monitor.dart`, `network_diagnostics.dart`, `operational_logger.dart`, `release_diagnostics.dart`, `production_telemetry.dart` (umbrella), `operations_feature_flags.dart` (flag reconciler) — alongside the existing `crash_reporter.dart`.

- **DI** (`lib/core/di/providers.dart`) — a `@Riverpod(keepAlive: true)` provider per seam, each defaulting to its inert Noop (mirroring `crashReporterProvider`) so they are injectable app-wide and **no `test/support/harness.dart` override is needed** (they derive from already-overridden `appConfig` / `appEnvironmentInfo` / `appLogger`). Regenerated with `dart run build_runner build`.
- **Activation** (the one-swap step) — swap a Noop for a concrete impl in `bootstrap.dart` via a `create…()` factory + `ProviderScope` override (exactly like `createCrashReporter` / `createRemoteConfig`), and feed the live hooks (interceptor → `NetworkDiagnostics`, `bootstrapMs` → `PerformanceMonitor`). Until then the seams ship inert, so the release build emits no telemetry — safe to ship, consistent with the app's push / cert-pinning / screenshot-protection seams.
- **Tests** (`test/core/observability/`) — one `_test.dart` per seam (23 tests), mirroring `crash_reporter_test.dart`: `isEnabled` false for the Noop, `initialize()`/`record…()` never throw, bounded-ring/cap behavior, PII redaction, release/environment metadata, and the feature-flag precedence (compile-time kill switch › remote › fallback).

---

## 4. Production compatibility

Because every capability is a seam, production telemetry activates by swapping the Noop for a concrete implementation (a config/factory change, no call-site edits): `SentryCrashReporter` (add `sentry_flutter`), Firebase Performance / Remote Config, or a custom collector posting to the backend Operations Platform. The correlation id (`x-request-id`) stitches a mobile request to its backend trace/logs, so the Flutter app and the server share one operational view.

---

## 5. Verification

`flutter analyze` clean (zero issues); `flutter test test/core/observability` green; `dart run build_runner build` regenerates the providers. All seams are inert-by-default, so the release build emits no telemetry until a concrete backend is wired — safe to ship.
