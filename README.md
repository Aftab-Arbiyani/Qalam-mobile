# Qalam Mobile (Flutter)

The Qalam mobile client — a reader/writer app for the Hindi/Urdu writing sanctuary,
consuming the **frozen `v1`** backend API. This is the **M1 foundation**
(infrastructure only); business features arrive in M2–M10.

> Governing source of truth: `docs/40_MobileArchitecture.md` and
> `docs/41_MobileDesignSystem.md`. Do not deviate without amending those.

## Stack

Flutter 3.44 · Dart 3.12 · Riverpod (code-gen) · GoRouter · Dio · Freezed +
json_serializable · Hive CE · flutter_secure_storage · cached_network_image ·
connectivity_plus · dynamic_color · logger · intl · package_info_plus ·
device_info_plus.

## Getting started

```bash
flutter pub get
dart run build_runner build            # generate freezed / json / riverpod
flutter gen-l10n                        # generate localizations
flutter run --dart-define=QALAM_API_URL=http://localhost:4000
```

Config is injected via `--dart-define` (`QALAM_ENV`, `QALAM_API_URL`,
`QALAM_CDN_URL`, `QALAM_SENTRY_DSN`, `QALAM_ENABLE_PUSH`). See
`lib/core/config/app_config.dart`.

## Quality gates

```bash
flutter analyze                         # zero issues
flutter test                            # all pass
flutter test --update-goldens           # regenerate goldens after a visual change
```

## Guides

- [Folder structure](docs/folder-structure.md)
- [State management](docs/state-management.md)
- [Navigation](docs/navigation.md)
- [Networking](docs/networking.md)
- [Dependency injection](docs/dependency-injection.md)
- [Testing](docs/testing.md)
- [M1 readiness report](docs/42_MobileReadinessReport.md)

## Architecture in one line

Feature-first Clean Architecture (presentation → domain ← data) with Riverpod DI,
a single Dio choke point, Hive cache + secure-storage secrets, and a token-driven
Material 3 design system — every layer independently testable, every feature
deletable, additive to the frozen `v1` contract.
