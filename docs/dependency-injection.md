# Dependency Injection Guide

**DI is Riverpod. There is no service locator** (no `GetIt`, no global singletons,
no `static` mutable instances) — `docs/40` §9.

## How wiring works

Every dependency is a provider in `lib/core/di/providers.dart` (or its feature's
providers file). The domain declares an **interface**; a provider produces the
**implementation**; consumers depend on the provider typed as the interface.
Binding an interface to an impl is a one-line provider.

```
CacheStore  (interface, core/storage/cache_store.dart)
  └─ cacheStoreProvider → HiveCacheStore(ref.watch(cacheBoxProvider))
```

## Composition root

`main.dart → bootstrap()` performs async init and injects the results via
**provider overrides** into the single root `ProviderScope`. This is the ONLY place
concrete infrastructure is chosen:

- `appConfigProvider`, `appLoggerProvider`, `appEnvironmentInfoProvider`,
  `cacheBoxProvider`, `prefsBoxProvider`, `connectivityServiceProvider` are declared
  as `throw UnimplementedError` bodies (they need bootstrapped values) and are
  overridden in `bootstrap.dart`.
- Everything else (`tokenStoreProvider`, `authGatewayProvider`, `dioProvider`,
  `apiClientProvider`, `cacheStoreProvider`, `mediaUrlBuilderProvider`, the
  placeholder services) derives via `ref.watch`.

## Lifetimes

| Kind | Annotation | Why |
| --- | --- | --- |
| cross-cutting singletons | `@Riverpod(keepAlive: true)` | created once (Dio, token store, session, theme, config) |
| screen/feature state | `@riverpod` (autoDispose) | freed with the screen; cancels in-flight work |

Providers that own disposables call `ref.onDispose(...)` (e.g. `dioProvider` closes
Dio; `appLoggerProvider` closes the logger).

## Placeholder services (swapped in their epic, zero refactor)

`pushMessagingServiceProvider`, `localNotificationServiceProvider`,
`biometricGateProvider`, `certificatePinningProvider`, `deviceIntegrityServiceProvider`
return no-op implementations behind interfaces. Their real implementations drop in
by overriding the provider — no call site changes.

## Testing

Because everything is a provider, tests override exactly what they fake. See
`test/support/harness.dart` (`buildTestApp`) and the provider/widget tests. No test
reaches into a global — there are none.
