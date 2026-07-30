# 53 — Mobile Performance (P7.3)

> **Qalam Mobile** — the Flutter client's contribution to the Performance &
> Scalability phase (P7.3). Companion to the backend
> **[platfrom/docs/43 — Performance & Scalability Platform](../../platfrom/docs/43_PerformanceScalabilityPlatform.md)**,
> which owns the server-side platform and the canonical budget catalogue.
>
> **Scope:** optimize startup, memory, rendering, and release-build size **without
> redesigning any UI** and **without adding dependencies**. The app was already
> well-architected for performance (docs 40 §36–37): `ListView.builder` + cursor
> pagination everywhere, keep-alive tabs, `cached_network_image`, request
> de-duplication, a reduced-motion gate, and `--obfuscate --split-debug-info`
> release builds. P7.3 closes the concrete gaps the audit found.

---

## 1. What changed

| Area | Change | File | Why |
| --- | --- | --- | --- |
| **Image memory** | `memCacheWidth`/`memCacheHeight` sized to the layout box × devicePixelRatio | `lib/shared/widgets/media/q_network_image.dart` | Decode at display size, not source size — the single biggest image-memory win (a 2000px cover no longer sits full-res in the cache). |
| **Image memory** | Global image cache capped at **100 MiB** | `lib/bootstrap.dart` | A long feed scroll cannot grow decoded-bitmap memory unbounded (docs 40 §37). |
| **Startup** | Hive (4 boxes), connectivity, and env resolution now init **in parallel** (was serial awaits) | `lib/bootstrap.dart` | Overlapping independent I/O shortens cold start. |
| **Startup** | Startup-budget timer logs `bootstrapMs` before the first frame | `lib/bootstrap.dart` | Makes `flutter.startup.cold` measurable (target 2.5 s). |
| **Rendering** | `RepaintBoundary` around every paginated list row | `lib/shared/widgets/list/q_paged_list_view.dart` | A card repainting (cached image resolving, clap animating) no longer dirties the whole list layer. |
| **Build size** | **R8 minify + `shrinkResources` ENABLED** with the curated `proguard-rules.pro` | `android/app/build.gradle.kts` | Primary APK/AAB size + native-code-strip win; rules were pre-written for exactly this. |
| **Build size** | `--split-per-abi` for the `apk` artifact | `tool/build_flavor.sh` | Arch-specific APKs for sideload/QA instead of one fat universal binary (App Bundle already splits at the Play Store). |

All changes are dependency-free (every package already present) and `flutter
analyze` is clean.

---

## 2. Release-build R8 gate (important)

R8 minification + resource shrinking are now **on** for the `release` build type,
using the curated keep rules in `android/app/proguard-rules.pro` (Flutter,
`flutter_local_notifications`/Gson, `flutter_secure_storage`, `plus_plugins`,
firebase, launcher). Because R8 can strip un-vetted plugin code, the **docs/51
device-QA smoke MUST pass before a store submission**: install a `--release`
build and exercise notifications, secure-storage token round-trip, and deep
links. A newly added plugin needs its keep rule added to `proguard-rules.pro`
first. This is the M10-deferred activation, now taken with the rules in place.

---

## 3. Budgets (mirror the backend catalogue)

The client budgets are declared canonically in the backend catalogue
(`platfrom/docs/43` §14, ids `flutter.*`) and checked out-of-band here:

| Budget | Target | How to measure |
| --- | --- | --- |
| `flutter.startup.cold` | ≤ 2.5 s | `bootstrapMs` log line + DevTools app-start timeline |
| `flutter.frame.build_p95` | ≤ 16 ms (60fps) | DevTools Performance timeline (feed/reader scroll) |
| Image cache | ≤ 100 MiB | DevTools Memory (image cache) — capped in bootstrap |

`PerformanceVerificationService.verifyExternal({...})` on the backend accepts these
measurements against the same targets, so a CI job that captures them can gate on
the identical budgets the server uses.

---

## 4. Already-optimized (verified, unchanged)

- **Lists** — `ListView.builder` + one shared `CursorPaginator`; keep-alive tabs preserve scroll; refresh keeps content painted.
- **Networking** — single Dio; in-flight GET de-duplication; GET-only retry + backoff; offline short-circuit; 20 s timeouts; `X-Client: mobile`.
- **Caching** — Hive cache-then-network with TTL tiers mirroring the web; launch-time expired-entry eviction; bounded (300-entry) reading history; secure-storage tokens.
- **Rendering / rebuilds** — broad `const`; Riverpod `.select()` on input-heavy screens; `autoDispose` feed controllers; immutable state.
- **Animations** — single reduced-motion gate; fade-only route transitions; few controllers, all disposed.
- **Release** — `--obfuscate` + `--split-debug-info`; per-flavor app IDs; feature flags off in prod.

---

## 5. Prescribed next levers (not applied — dependency/QA-gated)

- **CDN-side image transforms** — append resize/format params in `MediaUrlBuilder` once the CDN's transform API is confirmed (pairs with `memCacheWidth` for a network-bytes win).
- **Hive `TypeAdapter`s** — replace JSON-string cache encoding to cut per-hit CPU; move `CacheManager.stats()`/`cleanupExpired()` full scans off the main isolate (`compute`).
- **`keepAlive` audit** — several feature controllers stay resident for the app lifetime; audit which truly need it to reduce steady-state memory.
- **Deferred components** — split the editor/analytics islands via Dart deferred imports if their route chunks grow.

---

## 6. Verification

- `flutter analyze` — **clean** (no issues).
- `dart format` — conformant.
- Existing unit/widget/golden tests unaffected (no behavior change; image sizing + repaint isolation + startup ordering are transparent).
- Manual: a `--release` build logs `bootstrapMs`; `flutter build apk --split-per-abi` produces per-ABI APKs; R8 output is present in the release mapping.
