# Testing Guide

Runner: **`flutter_test`** + **`mocktail`**. Tests mirror `lib/` under `test/`
(`docs/40` §38). Mock at the boundary you own; behavior-first; AAA; deterministic
(inject time/uuid, never call `DateTime.now()` in testable logic).

## What is tested (M1)

| Area | File | Kind |
| --- | --- | --- |
| Enum wire parity + fallback | `test/shared/domain/enums_test.dart` | unit |
| Status/code → Failure mapping | `test/core/error/error_mapper_test.dart` | unit (table) |
| Cache store (read/write/staleness/evict) | `test/core/storage/cache_store_test.dart` | repository/storage |
| ApiClient (envelope, paging, offline, error) | `test/core/network/api_client_test.dart` | unit (mock Dio) |
| Single-flight refresh | `test/core/network/auth_gateway_test.dart` | unit (mock Dio) |
| Route guards + returnTo | `test/app/router/guards_test.dart` | navigation (unit) |
| QButton behavior | `test/shared/widgets/q_button_test.dart` | widget |
| QButton appearance | `test/shared/widgets/q_button_golden_test.dart` | golden |
| App launch + nav + offline banner | `test/app/router/app_launch_test.dart` | widget / riverpod / navigation |

## The harness (`test/support/harness.dart`)

`buildTestApp({online, tokens})` returns a `ProviderScope`-wrapped `QalamApp` with
every platform-channel dependency faked:
- secure storage → in-memory (`MockFlutterSecureStorage`),
- connectivity → fixed status (`MockConnectivity`),
- Hive → throwaway temp-dir boxes,
- config / logger / env → test values.

`buildFakeSecureStorage(seed)` and `buildFakeConnectivity(online:)` are reusable for
provider-level tests.

## Golden tests

Deterministic in the test environment (the runner substitutes a fixed font).
Regenerate after an intentional visual change:

```
flutter test --update-goldens
```

Golden files live in `test/**/goldens/`. A render regression (incl. RTL/Nastaliq in
later epics) is a build-blocker.

## Running

```
flutter test                 # all tests
flutter test --coverage      # with coverage
flutter test test/core       # a subtree
```

## Conventions

- One behavior per test; no logic in tests.
- Build fixtures with factories (add under `test/support/` as features land).
- Mock the layer directly below the unit under test (notifiers mock repositories;
  repositories mock data sources; data sources mock Dio / `qalam_api`).
