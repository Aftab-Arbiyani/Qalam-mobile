# 51 · Mobile Production Build Configuration (P7.1)

Phase P7.1 hardens the M10 release baseline (docs/46) with **build flavors**, a
**flavor ↔ config bridge**, **store-specific build configuration**, and the
**release-configuration seams** (remote config + crash reporting). It extends the
existing conventions (docs/40 §28 Environment Configuration, §31 Firebase
Integration) — it does not redesign them. There is still no runtime environment
switching in release builds; the flavor is fixed at build time.

---

## 1. Environment / flavor matrix

Four environments, each a native build flavor + a `dart_defines/<flavor>.json`
file. `AppFlavor` (`lib/core/config/app_flavor.dart`) is the typed enum; its
`wire` string is the exact `QALAM_ENV` value in the JSON and the native flavor
name.

| Flavor | `wire` | Android appId | iOS bundle id | Label | API URL |
| --- | --- | --- | --- | --- | --- |
| `development` | `development` | `com.qalam.qalam_mobile.dev` | `com.qalam.qalam_mobile.dev` | Qalam Dev | `http://localhost:4000` |
| `qa` | `qa` | `com.qalam.qalam_mobile.qa` | `com.qalam.qalam_mobile.qa` | Qalam QA | `https://qa-api.qalam.app` |
| `staging` | `staging` | `com.qalam.qalam_mobile.staging` | `com.qalam.qalam_mobile.staging` | Qalam Staging | `https://staging-api.qalam.app` |
| `production` | `production` | `com.qalam.qalam_mobile` | `com.qalam.qalam_mobile` | Qalam | `https://api.qalam.app` |

The distinct application ids let all four flavors install side by side on one
device. **Production carries the canonical id (no suffix)** — it is the Play /
App Store listing identity and must never change.

> The `https://…qalam.app` hosts are **placeholders**. Replace them with the real
> per-environment origins before shipping (edit the `dart_defines/*.json` files).

### Feature-flag posture

Feature flags are **compile-time kill switches**; the server-side flags
(`feature.ai.*`, `feature.payments.enabled`, the policy engine, etc.) remain the
runtime source of truth. Client flags only un-gate the routes/affordances.

| Flag | dev | qa | staging | production |
| --- | --- | --- | --- | --- |
| `QALAM_ENABLE_PUSH` | on | off | off | off |
| `QALAM_ENABLE_AI` | on | on | on | **off** |
| `QALAM_ENABLE_MONETIZATION` | on | on | on | **off** |
| `QALAM_ENABLE_COLLABORATION` | on | on | on | **off** |

- **dev** is all-on for local exercise of every surface.
- **qa/staging** enable the Phase-2 surfaces so they can be validated pre-prod;
  push stays off (there is still no backend token endpoint — docs/40 §32.2).
- **production is conservative**: every Phase-2 kill switch defaults **off** and
  is flipped on in a later build once the matching server-side flag is live.

---

## 2. How `--dart-define-from-file` + native flavors combine

Two independent mechanisms are joined by one build command:

1. **Native flavor** (`--flavor <name>`) selects the Android product flavor /
   iOS scheme — it sets the application id, launcher label, and (on iOS) the
   xcconfig. It does **not** touch Dart-visible config.
2. **`--dart-define-from-file=dart_defines/<name>.json`** injects the `QALAM_*`
   values that `AppConfig.fromEnvironment()` reads via `String.fromEnvironment` /
   `bool.fromEnvironment`. JSON `true`/`false` map to `bool.fromEnvironment`.

`tool/build_flavor.sh` is the single bridge that always passes the **matching**
pair, so the native identity and the Dart config can never drift:

```bash
tool/build_flavor.sh production appbundle
# → flutter build appbundle --release --flavor production \
#     --dart-define-from-file=dart_defines/production.json \
#     --obfuscate --split-debug-info=build/symbols/production \
#     --build-number=<BUILD_NUMBER|UTC timestamp>
```

`AppConfig.validate()` still runs first thing in `bootstrap` (fail-fast), so a
misconfigured `dart_defines` file dies at launch, not on the first API call.

> **Behaviour change:** once product flavors exist, `--flavor` is **required** for
> `flutter run`/`flutter build`. Use `tool/build_flavor.sh`, or for a debug run:
> `flutter run --flavor development --dart-define-from-file=dart_defines/development.json`.

---

## 3. Build, signing & obfuscation

### Android

- **Signing** (unchanged from M10): release signing reads `android/key.properties`
  (git-ignored; template `key.properties.example`). Absent → falls back to debug
  signing so `flutter run --release` works without secrets.
- **R8 / resource shrinking: OFF** (M10 decision, docs/46 §13). Dart tree-shaking
  + `--obfuscate` cover code size; R8 can strip reflection-driven plugin code.
  Curated keep rules are staged in `android/app/proguard-rules.pro` with the exact
  enable steps (`isMinifyEnabled=true`, `isShrinkResources=true`, `proguardFiles(...)`).
  Enabling is a checklist item gated on device QA — **do not flip it silently**.
- **Obfuscation**: `--obfuscate --split-debug-info=build/symbols/<flavor>` is
  applied by the build script. **Archive `build/symbols/<flavor>` per release** —
  it is required to de-obfuscate crash stack traces.

### iOS

- One `Runner` scheme historically; per-flavor xcconfigs now live in
  `ios/Flutter/flavors/{Development,Qa,Staging,Production}.xcconfig`. Each
  `#include "../Generated.xcconfig"` then sets `PRODUCT_BUNDLE_IDENTIFIER`,
  `PRODUCT_NAME`, `DISPLAY_NAME`, and `FLUTTER_TARGET`.
- Same `--obfuscate --split-debug-info` flow via `tool/build_flavor.sh … ipa`.

#### iOS scheme wiring (manual, one-time — do NOT hand-edit `project.pbxproj`)

The xcconfig files are staged but not yet referenced by Xcode. To activate, in
Xcode (Runner project):

1. Add build configurations (e.g. `Debug-development`, `Release-qa`,
   `Release-staging`, `Release-production`) under **Project → Info →
   Configurations**.
2. Set each configuration's **Based on configuration file** to the matching file
   in `ios/Flutter/flavors/`.
3. Duplicate the `Runner` scheme per flavor (**Product → Scheme → Manage
   Schemes**) and point each scheme's Run/Archive step at its configuration.
4. In `ios/Runner/Info.plist`, set
   `<key>CFBundleDisplayName</key><string>$(DISPLAY_NAME)</string>` so the label
   follows the flavor.

Flutter then matches `--flavor qa` to the `Qa`/`qa`-named scheme.

---

## 4. Release-configuration seams

Both follow the established seam pattern (`abstract interface class` + inert
`Noop*` impl, activated by a single factory swap in `bootstrap.dart` — exactly
like `CrashReporter`, `PushMessagingService`, `CertificatePinning`).

### 4.1 Crash reporting (`lib/core/observability/crash_reporter.dart`)

- Interface `CrashReporter` + inert `NoopCrashReporter` (keeps a bounded, PII-free
  breadcrumb trail; flushes to the logger on a fatal error).
- **DSN-gated**: enabled only when `AppConfig.sentryDsn` is non-empty.
- **Activation**: add `sentry_flutter`, return a `SentryCrashReporter` from
  `createCrashReporter()` in `bootstrap.dart` — the only line that changes.
- Wired to `FlutterError.onError`, `PlatformDispatcher.onError`, and the
  `runZonedGuarded` handler, with release + environment metadata attached.

### 4.2 Remote configuration (`lib/core/config/remote_config.dart`) — NEW

- Interface `RemoteConfigService` (`initialize`, `refresh`, `getBool`,
  `getString`, `getInt`, `getDouble`) + inert `NoopRemoteConfigService` that
  returns the caller's `fallback` for every lookup.
- Every getter **requires a `fallback`**, so an un-activated (or unreachable) seam
  is always well-defined; effective behaviour stays driven by `AppConfig` flags +
  server-side toggles.
- **Wiring**: `createRemoteConfig()` factory in `bootstrap.dart`, initialized then
  provided via `remoteConfigProvider.overrideWithValue(...)`. The
  `@Riverpod(keepAlive: true) remoteConfig` provider in
  `lib/core/di/providers.dart` **throws until overridden** (mirrors
  `appConfigProvider`); tests override it with `const NoopRemoteConfigService()`.
- **Activation**: add `firebase_remote_config`, return a
  `FirebaseRemoteConfigService` from `createRemoteConfig()` — the only line that
  changes. No call site touches a vendor SDK.

> DSNs and other per-environment secrets are **not committed** in
> `dart_defines/*.json` (kept empty). CI injects them by appending an extra define,
> e.g. `--dart-define=QALAM_SENTRY_DSN=<dsn>` (a later `--dart-define` overrides
> the file value). See docs/40 §28.3.

---

## 5. Store build steps

Use `tool/build_flavor.sh` for every store artifact; CI sets `BUILD_NUMBER`.

### Google Play (App Bundle)

```bash
BUILD_NUMBER=<ci-number> tool/build_flavor.sh production appbundle
```

- Upload the printed `.aab` to Play Console (Internal testing → Closed → Prod).
- **Data safety form**: Qalam collects account data (email/profile) and
  user-created content; auth tokens live in Keystore-backed secure storage; no
  advertising id; crash diagnostics only when a DSN is configured.
- Play App Signing re-signs with the app key; you upload with the upload key
  (`android/key.properties`).

### Apple App Store (IPA)

```bash
BUILD_NUMBER=<ci-number> tool/build_flavor.sh production ipa
```

- Upload via Xcode Organizer or Transporter/`xcrun altool`.
- **App Privacy**: contact info (email), user content, identifiers (user id),
  diagnostics (crash data, only when a DSN is configured).
- Production bundle id `com.qalam.qalam_mobile` (`ios/Flutter/flavors/Production.xcconfig`).

### Per-release checklist

- [ ] Real per-environment URLs set in `dart_defines/*.json` (no placeholders).
- [ ] `android/key.properties` populated (release signing, not debug fallback).
- [ ] Build with `tool/build_flavor.sh <flavor> <artifact>` (obfuscation on).
- [ ] Archive `build/symbols/<flavor>` for crash de-obfuscation.
- [ ] Crash DSN injected by CI (`--dart-define=QALAM_SENTRY_DSN=…`) if reporting on.
- [ ] (Optional, needs device QA) enable R8 per `android/app/proguard-rules.pro`.

---

## 6. Files (P7.1)

| File | Role |
| --- | --- |
| `lib/core/config/app_flavor.dart` | `AppFlavor` enum + `qa`; `isQa`/`isStaging` |
| `lib/core/config/remote_config.dart` | Remote-config seam (interface + Noop) |
| `lib/core/di/providers.dart` | `remoteConfigProvider` (throws until overridden) |
| `lib/bootstrap.dart` | `createRemoteConfig()` factory + init + override |
| `dart_defines/{development,qa,staging,production}.json` | Per-flavor `QALAM_*` config |
| `android/app/build.gradle.kts` | `flavorDimensions` + `productFlavors` |
| `android/app/src/main/AndroidManifest.xml` | Label → `${appName}` placeholder |
| `android/app/proguard-rules.pro` | Staged R8 keep rules (minify still OFF) |
| `ios/Flutter/flavors/*.xcconfig` | Per-flavor bundle id / name / target |
| `tool/build_flavor.sh` | Flavor ↔ config build bridge |
