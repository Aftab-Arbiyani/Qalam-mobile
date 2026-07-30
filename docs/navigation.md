# Navigation Guide

Navigation is **GoRouter**, exposed as a keep-alive provider
(`lib/app/router/app_router.dart`). Route paths + names are constants in
`lib/app/router/routes.dart` — never stringly-typed paths (`docs/40` §10–§12).

## Structure

- **`StatefulShellRoute.indexedStack`** hosts the bottom-nav shell — one navigator
  branch per tab (Feed · Search · Write · Notifications · Profile), so each tab keeps
  its own stack + scroll. The **Write** destination is accented (primary CTA).
- **Full-screen routes outside the shell** (settings, login, gallery, splash) render
  without the bottom nav.
- **Page transitions are fades** (`_fade` builder) — "a book doesn't slide."
- **Unknown routes** render `UnknownRoutePage` via `errorBuilder`.

## Guards (`lib/app/router/guards.dart`)

`guardRedirect({session, location})` is a **pure function** (unit-tested in
`test/app/router/guards_test.dart`):

- `session.unknown` → hold on `/splash` (never flash a redirect on cold start).
- protected location + not authenticated → `/auth/login?returnTo=<path>`.
- auth corridor + authenticated → `/feed`.

The router re-runs the redirect whenever the session changes (a `ValueNotifier`
bumped by `ref.listen(sessionControllerProvider)` as `refreshListenable`).

`Routes.isProtected(location)` defines the protected set. `safeReturnTo` validates a
`returnTo` (same-origin relative paths only).

## Deep links

Universal/App Links map `https://app.qalam.example/<path>` to the same in-app route —
GoRouter's path table is the resolver. Push payloads (Phase 2) carry a `route` +
identifiers and are pushed through the same guarded router. See `docs/40` §12 for the
slug-cold-load caveat (no `GET /pieces/by-slug` in `v1` yet).

## Navigating in code

```
context.go(Routes.feed);        // replace
context.push(Routes.settings);  // push (protected → bounces to login in M1)
```

Never push a widget instance directly — that would violate the no-cross-feature-import
rule. Navigate by route path/name.
