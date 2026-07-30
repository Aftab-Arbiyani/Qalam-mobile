# Mobile Folder Structure Guide

The Qalam Flutter app is **feature-first Clean Architecture** (governed by
`docs/40_MobileArchitecture.md` §3–§7 in the monorepo). Code is organized by
**product capability first**, then by clean-architecture **layer** within.

## Top level (`lib/`)

```
lib/
├── main.dart              # entry point → bootstrap()
├── bootstrap.dart         # composition root: async init + ProviderScope overrides
├── app/                   # app-wide composition (knows about all features)
│   ├── app.dart           # QalamApp — MaterialApp.router + theme + l10n
│   ├── observers/         # NavigatorObserver, ProviderObserver
│   └── router/            # GoRouter, routes, guards
├── core/                  # cross-cutting infrastructure (no feature knowledge)
│   ├── config/            # AppConfig, AppFlavor, AppEnvironmentInfo
│   ├── connectivity/      # ConnectivityService + providers
│   ├── di/                # providers.dart — the DI graph
│   ├── error/             # Failure, ApiException, error_mapper, error catalog
│   ├── logging/           # AppLogger + redaction
│   ├── media/             # storage-key → CDN URL builder
│   ├── network/           # Dio, interceptors, ApiClient, dedup, error converter
│   ├── notifications/     # push + local notification placeholders
│   ├── security/          # token store + cert-pinning/biometric/root placeholders
│   ├── session/           # session tri-state + controller
│   ├── storage/           # Hive init, cache store, secure storage, preferences
│   └── utils/             # Result, jwt, typedefs
├── shared/                # reusable domain vocabulary + design system
│   ├── api/               # envelope + pagination wire models
│   ├── domain/            # enums, error codes, limits, permissions (mirror @qalam/shared)
│   ├── motion/            # reduced-motion helpers
│   ├── theme/             # tokens/, QTokens extension, app_theme, theme controller
│   └── widgets/           # the component catalog (Q-prefixed primitives)
├── features/              # one folder per capability
│   ├── shell/             # bottom-nav placeholder screens (M1)
│   ├── splash/            # boot splash
│   └── gallery/           # design-system showcase (debug)
└── l10n/                  # app_en.arb + generated delegates
```

## Feature layout (every feature is identical)

```
features/<name>/
├── domain/          # pure Dart — entities, repository INTERFACES, use cases
├── data/            # repository IMPLS, datasources (remote/local), DTO⇄entity mappers
├── presentation/    # screens, widgets, Riverpod providers
└── <name>.dart      # barrel: the feature's public surface (route + shared entities)
```

M1 ships infrastructure only, so the M1 features (`shell`, `splash`, `gallery`)
have only a `presentation/` layer. M2–M10 add full `domain/` + `data/` layers as
they consume real endpoints.

## Rules (enforced by review — `docs/40` §7, §44)

- **Features never import other features.** Shared code moves *down* into `core/`
  (logic) or `shared/` (look). Cross-feature navigation goes through the router by
  route name; cross-feature reactions go through cache-key invalidation.
- **`app/` composes features; features never import `app/`.**
- **The domain layer imports nothing outward** — no Flutter, Dio, Hive, or
  generated code.
- **`packages/qalam_api` (generated DTOs, added in M2) is imported only by `data/`.**
- **Deletion test:** `rm -rf features/<name>` + removing its route must leave the
  app compiling.
