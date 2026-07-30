# State Management Guide

**Riverpod is the only state-management and DI mechanism** (code-gen `@riverpod`).
No `provider`, no `Bloc`, no `GetIt`, no `ChangeNotifier` singletons, no global
mutable state (`docs/40` §8).

## Classify every piece of state first

| Kind | Owner | Example in this repo |
| --- | --- | --- |
| Server state | repository-backed `AsyncNotifier`/`FutureProvider` | (M2+) feed, piece, profile |
| Client / UI state | `Notifier` / `StateProvider` | `themeModeControllerProvider` |
| Session state | `SessionController` (`AsyncNotifier`, tri-state) | `sessionControllerProvider` |
| Form state | form controllers + provider | (M2+) register, publish |
| "URL" state | route path/params via GoRouter | (M4+) feed tab, search filters |

**Golden rule:** server state is never mirrored into a client-state notifier.

## Provider conventions

- **`@Riverpod(keepAlive: true)`** for cross-cutting singletons (config, Dio, token
  store, session, theme). **`@riverpod`** (autoDispose) for screen/feature state —
  it frees state and cancels in-flight work when the screen leaves.
- **Families** carry parameters into provider identity (e.g. `profile(username)`),
  the equivalent of a TanStack query key. Use value-type args (freezed) so equal
  args reuse state.
- **Async reads** are exposed as `AsyncValue<T>` → the UI maps loading/error/data to
  skeleton / error / content widgets. See `SessionController` for the pattern.
- **Subscribe narrowly:** `ref.watch(p.select((s) => s.field))` in leaf widgets.

## Example — the session controller

`lib/core/session/session_controller.dart` is the reference `AsyncNotifier`:
`build()` performs silent restore and returns a `SessionState`; `signOut()` mutates
`state`; a gateway callback flips the session to anonymous on a terminal 401. The
router watches it via `ref.listen` and re-runs guards on change.

## Example — the theme controller

`lib/shared/theme/theme_mode_controller.dart` is the reference client-state
`Notifier`: it reads the persisted `ThemeMode` from the prefs box in `build()` and
writes back in `set()`. The profile placeholder screen cycles it live.

## Testing

Build a `ProviderContainer` (or pump the app via `test/support/harness.dart`) and
override exactly the providers under test. See
`test/core/network/*` and `test/app/router/app_launch_test.dart`.
