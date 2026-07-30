# 52 · Mobile Security & Compliance (P7.2)

Phase **P7.2** hardens the client's security posture on top of the M10 release
baseline (docs/46) and the P7.1 production-build configuration (docs/51). It does
**not** redesign the M1 architecture — the security controls were designed in as
seams (`abstract interface` + inert `Noop` implementation, activated by a single
provider swap in the composition root). This document **verifies** each control is
present and correctly wired, records the current posture, and gives the exact
activation path for production.

The house rule (docs/40 §39.2): the app depends on **our interface**, never on a
vendor SDK or a platform channel directly, so any control is a one-line swap in
`bootstrap.dart` with **no call-site changes**.

---

## 0. Status at a glance

| # | Control | State | Wiring | Activation cost |
| --- | --- | --- | --- | --- |
| 1 | Secure token storage | **EXISTS** (secure backend) · platform options at defaults | `flutter_secure_storage` → `SecureStorage` → `TokenStore` | set explicit `AndroidOptions`/`IOSOptions` |
| 2 | Session / refresh rotation | **EXISTS** | `AuthGateway` (single-flight) + `AuthInterceptor` | — (active) |
| 3 | Certificate pinning | **SEAM** (inert `Noop`) | `CertificatePinning.apply(dio)` in `dio_client.dart` | impl + pin set, swap provider |
| 4 | Biometric app-lock | **SEAM** (inert `Noop`) | `BiometricGate` provider | impl (`local_auth`) + gate route |
| 5 | Device integrity | **SEAM** (inert `Noop`) | `DeviceIntegrityService` provider | impl + consume report |
| 6 | Secure logging / redaction | **EXISTS** | `log_redaction.dart` used by `LoggingInterceptor` | — (active) |
| 7 | Screenshot protection | **SEAM** (inert `Noop`, added P7.2) | `ScreenshotProtectionService` provider + `createScreenshotProtection()` | impl (FLAG_SECURE / iOS) + call `enable()` |
| 8 | Crash-report PII hygiene | **EXISTS** | `NoopCrashReporter` (id-only, DSN-gated) | add `sentry_flutter` (docs/40 §31) |

"SEAM" = the interface and the inert `Noop` are compiled in and wired; the control
is **off by design** until a concrete implementation replaces the `Noop`. This is
intentional — pinning without a rotation plan bricks the app on cert rotation, and
biometric/integrity are optional hardening, not baseline requirements.

---

## 1. Secure token storage

**File:** `lib/core/storage/secure_storage.dart`, `lib/core/security/token_store.dart`

Access + refresh tokens are the only secrets the client holds. They are stored via
`SecureStorage`, a thin wrapper over **`flutter_secure_storage` ^10.3.1** — i.e. the
platform secure enclave, **never** Hive or `SharedPreferences`:

- **iOS** → Keychain.
- **Android** → values encrypted with an Android **Keystore**-backed key
  (default cipher: RSA-OAEP key-wrap + AES-GCM).

Non-secret cache lives in Hive (`cache_store.dart`); secrets never touch it. This
separation is verified — `TokenStore` depends only on `SecureStorage`.

### Custody model (docs/40 §14, §15, §27)

- **Access token** — kept in secure storage **and** cached in memory
  (`TokenStore._accessCache`) for the request hot path; `AuthInterceptor` reads it
  synchronously.
- **Refresh token** — secure storage **only**, never memory-cached.
- **Rotation** replaces **both atomically** (`TokenStore.save`); a stale refresh
  token is never retained, because presenting it would trip the backend's
  family-reuse detection.
- **Logout / revoke** clears both (`TokenStore.clear`).

### Finding — platform options at defaults (hardening path, not a leak)

`SecureStorage` constructs `const FlutterSecureStorage()` with **default** platform
options. Storage is already secure; two explicit options tighten it further and are
the P7.2 hardening path (safe to apply pre-v1; no production data to migrate):

```dart
// lib/core/storage/secure_storage.dart — hardening (not yet applied)
const FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
);
```

- `encryptedSharedPreferences: true` → Jetpack Security `EncryptedSharedPreferences`
  (AES-256) instead of the legacy default (`false`).
- `first_unlock_this_device` → **device-only** Keychain, so tokens are **not** synced
  to iCloud Keychain or included in device backups.

The wrapper already exposes a mockable surface, so this is a one-file change with no
call-site impact. It is left un-applied here to keep P7.2 a verify-and-document pass;
apply it in the storage-hardening step.

---

## 2. Secure session & token handling

**Files:** `lib/core/network/auth_gateway.dart`,
`lib/core/network/interceptors/auth_interceptor.dart`,
`lib/core/session/session_controller.dart`

Refresh rotation is **active** and correctly guarded:

- **Single-flight refresh** — `AuthGateway.refresh()` collapses concurrent callers
  onto one in-flight `Completer`. Critical: the backend rotates refresh tokens with
  family-reuse detection, so a stampede would self-revoke the session.
- **Dedicated bare Dio** for the refresh call (no `AuthInterceptor`), so a refresh
  can never recurse into itself.
- **Replay-once** — `AuthInterceptor` refreshes and replays a request exactly once,
  only on `401 + AUTH_TOKEN_EXPIRED` outside the auth corridor; any other 401 is
  terminal → tokens cleared → session flips to anonymous via `onUnauthorized`.
- **Documented gap (unchanged):** the Google-exchange path yields an access-token-only
  session (the frozen v1 backend returns no body refresh token; it was set as an
  httpOnly cookie unreachable on mobile). Such a session has no silent restore. See
  `TokenStore.save` and docs/40 §14.4.

No change required.

---

## 3. Certificate pinning

**File:** `lib/core/security/certificate_pinning.dart`

- **Interface:** `CertificatePinning { void apply(Dio dio); }`
- **Inert impl:** `NoopCertificatePinning` (no-op `apply`).
- **Wiring — verified:** `buildDioClient` (`dio_client.dart`) calls
  `pinning.apply(dio)`; the `dio` provider passes `certificatePinningProvider`, which
  returns the `Noop` today. Activation is a single provider swap.

**Why still inert:** pinning needs a pin set **and** a rotation plan; shipping a pin
without one bricks the app on the next certificate rotation. Per the task scope, **no
live certs are added here.**

**How to activate:** implement `CertificatePinning.apply` to attach a validating
`HttpClientAdapter` / `badCertificateCallback` (or use a pinning package) with the
SPKI pin set + a backup pin, then override `certificatePinningProvider` in
`bootstrap.dart`. Keep a backup pin and an expiry runbook.

---

## 4. Biometric app-lock

**File:** `lib/core/security/biometric_gate.dart`

- **Interface:** `BiometricGate { Future<bool> isAvailable(); Future<bool> authenticate({required String reason}); }`
- **Inert impl:** `NoopBiometricGate` — `isAvailable()` → `false`,
  `authenticate()` → `true` (bypass), so no screen is ever blocked today.
- **Provider:** `biometricGateProvider` (returns `Noop`). **Consumers:** none yet —
  by design; biometric is optional hardening, not a baseline gate.

**How to activate:** add `local_auth`, implement `BiometricGate` over it, override the
provider, and gate the app-open / sensitive-action routes on `authenticate(...)`. Per
task scope, **biometric is not enabled here.**

---

## 5. Device integrity (root / jailbreak)

**File:** `lib/core/security/device_integrity.dart`

- **Interface:** `DeviceIntegrityService { Future<DeviceIntegrityReport> check(); }`,
  returning `DeviceIntegrityReport { bool isCompromised; List<String> signals; }`.
- **Inert impl:** `NoopDeviceIntegrityService` → always `healthy`.
- **Provider:** `deviceIntegrityServiceProvider`. Consumers: none yet.

**Posture (docs/40 §39.2):** a **soft signal** (warn / limit), never a hard block —
false positives must not lock out legitimate users.

**How to activate:** implement over an attestation/root-detection package, override the
provider, and surface a soft warning where warranted.

---

## 6. Secure logging & redaction

**Files:** `lib/core/logging/log_redaction.dart`, `lib/core/logging/app_logger.dart`,
`lib/core/network/interceptors/logging_interceptor.dart`

Verified **active**:

- **Redaction list** (`log_redaction.dart`) mirrors the backend Pino redact set:
  `authorization`, `cookie`, `set-cookie`, `password`, `currentpassword`,
  `newpassword`, `token`, `accesstoken`, `refreshtoken`, `code`, `email`.
  `redactHeaders` masks header values; `redactValue` deep-masks nested maps/lists;
  `maskEmail` partial-masks (`af***@s***`).
- **The logging interceptor uses it** — `LoggingInterceptor.onRequest` logs
  `redactHeaders(options.headers)`, and it logs **no request/response bodies at all**
  (only method, path, status, and `x-request-id`), so tokens/PII cannot leak through
  the network log.
- **Level gating** — `AppLogger` runs at `Level.warning` in production and
  `Level.debug` otherwise, so verbose request lines are stripped from release builds.
- **No raw `print`** — verified across `lib/` (no `print(` / `debugPrint`); the
  analyzer also enforces `avoid_print` (`analysis_options.yaml`).
- **Crash reports are id-only** — `NoopCrashReporter` (docs/40 §31) keeps a bounded,
  PII-free breadcrumb trail and never uploads tokens/emails/bodies; `setUser` takes an
  opaque id only.

No change required.

---

## 7. Screenshot / screen-recording protection  *(added in P7.2)*

**File:** `lib/core/security/screenshot_protection.dart`

This was the one **missing** control. A seam was added in P7.2, mirroring the
crash-reporter / remote-config seam pattern exactly:

- **Interface:**
  `ScreenshotProtectionService { Future<void> enable(); Future<void> disable(); }`
- **Inert impl:** `NoopScreenshotProtectionService` — both calls are no-ops, so
  screenshots stay allowed (current posture, unchanged behaviour).
- **Provider:** `screenshotProtectionProvider` (`providers.dart`), defaults to the
  `Noop` so tests need no override (mirrors `crashReporterProvider`).
- **Factory + override:** `createScreenshotProtection({config, logger})` in
  `bootstrap.dart` builds the instance and overrides the provider in the root
  `ProviderScope` — one factory line changes when a real impl lands.

**How to activate:** implement `ScreenshotProtectionService` to set Android
`WindowManager.FLAG_SECURE` (blocks screenshots + screen recording + excludes the
window from the recents thumbnail) and hide/blur the view on iOS
(`sceneWillResignActive` / a secured overlay), e.g. via a `screen_protector` package
or a small platform channel. Then return it from `createScreenshotProtection` and call
`enable()` from the sensitive surfaces — auth, payment, and private draft screens —
(or globally in `bootstrap`, a product decision). No call-site change is needed to
introduce the impl; only the screens that opt in call `enable()`/`disable()`.

---

## 8. Production security configuration (activation checklist)

Ordered by risk-reduction per unit of effort. None of these change M1 behaviour until
performed.

1. **Transport** — confirm every `dart_defines/*.json` `QALAM_API_URL` is `https://`
   (docs/51 §1 flags the placeholder hosts). Android: keep `usesCleartextTraffic`
   **unset/false** (default) so no cleartext egress is possible; add a
   `networkSecurityConfig` if pinning is activated (§3).
2. **Secure storage options** — apply the explicit `AndroidOptions` /`IOSOptions`
   hardening (§1) for `EncryptedSharedPreferences` + device-only Keychain.
3. **Screenshot protection** — implement the seam (§7) and `enable()` it on auth,
   payment, and private-draft screens.
4. **Certificate pinning** — implement with a pin set **and** backup pin + rotation
   runbook (§3), then swap the provider.
5. **Crash reporting** — add `sentry_flutter` + a `SentryCrashReporter` behind the
   existing DSN gate (docs/40 §31); redaction contract already enforced (§6).
6. **Biometric app-lock** (§4) and **device-integrity** soft signal (§5) — optional
   hardening; add if the threat model calls for it.

### Seam inventory (single swap point each)

| Control | Interface file | Provider | Factory (bootstrap) |
| --- | --- | --- | --- |
| Certificate pinning | `security/certificate_pinning.dart` | `certificatePinningProvider` | — (default `Noop`) |
| Biometric gate | `security/biometric_gate.dart` | `biometricGateProvider` | — (default `Noop`) |
| Device integrity | `security/device_integrity.dart` | `deviceIntegrityServiceProvider` | — (default `Noop`) |
| Screenshot protection | `security/screenshot_protection.dart` | `screenshotProtectionProvider` | `createScreenshotProtection()` |
| Crash reporter | `observability/crash_reporter.dart` | `crashReporterProvider` | `createCrashReporter()` |
| Remote config | `config/remote_config.dart` | `remoteConfigProvider` | `createRemoteConfig()` |
| Secure storage | `storage/secure_storage.dart` | `secureStorageProvider` | — (options in the wrapper) |

Every activation is provider-scoped: swap in the composition root, run
`dart run build_runner build`, ship. No feature code changes.
