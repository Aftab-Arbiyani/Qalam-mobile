# 40 — Mobile Architecture (Flutter)

> **Qalam** (قلم / क़लम — "the pen") — the mobile client architecture handbook.
> This document is the **permanent source of truth** for every Flutter implementation
> decision. Every mobile epic (**M1–M10**) MUST comply with it. Where it conflicts with a
> whim, this document and the master ADR (`docs/00_ArchitectureDecisions.md`) win.
>
> **Companion:** `docs/41_MobileDesignSystem.md` (visual/UX system). Read both before writing code.
>
> **Status:** Architecture approved as the baseline for M1. No Flutter code has been written yet.
> Wait for explicit approval before beginning M1.

---

## 0. How to read this document

The backend API, the React reader web app, and the Admin app are **complete and frozen**. The
Flutter app is a **new, additive consumer** of the same contract. It does **not** get to redesign
APIs, invent business rules, or duplicate backend DTOs. It **adapts** to what already exists.

Three hard anchors constrain everything below:

1. **Backend `v1` is frozen** (`docs/25_BackendFreeze.md`, effective 2026-07-09). All work is
   **additive-only**. 19 controllers · 102 OpenAPI paths · 69 error codes · 26 permissions ·
   11 rate-limit tiers. A breaking change is a `/api/v2`, never a mutation of `v1`.
2. **One contract, three consumers** (ADR §2). Web + Admin generate `@qalam/api-types` from
   `openapi.json`; **Flutter generates Dart models from the same `openapi.json`** via
   `openapi-generator` (`dart-dio`). The wire shape is not ours to define — it is generated.
3. **The API was mobile-shaped from day one** (roadmap Phase 3, ADR §3): refresh-token-in-body
   for mobile, cursor pagination, `X-Client` channel header. We are walking a paved path.

> **Repository placement.** The Flutter app lives in a **separate repository** (CLAUDE.md:
> "Mobile (Flutter) lives in a separate repository — never add it here"). Docs 40 and 41 live in
> this monorepo as the governing specification; the code they govern does not. Wherever this
> document says "the repo," it means the separate Flutter repo unless stated otherwise.

---

## Table of contents

1. Mobile Architecture Overview
2. Design Principles
3. Project Folder Structure
4. Feature-first Clean Architecture
5. Layer Responsibilities
6. Feature Module Structure
7. Dependency Rules
8. Riverpod Architecture
9. Dependency Injection Strategy
10. GoRouter Navigation Architecture
11. Route Guards
12. Deep Link Architecture
13. Dio Networking Layer
14. Authentication Flow
15. Refresh Token Flow
16. Repository Pattern
17. Data Sources
18. DTO Mapping
19. Domain Entities
20. Use Case Layer
21. Error Handling Strategy
22. Exception Mapping
23. Offline Architecture
24. Connectivity Handling
25. Local Cache Strategy
26. Hive Architecture
27. Secure Storage Strategy
28. Environment Configuration
29. Logging Strategy
30. Analytics Integration Strategy
31. Firebase Integration Strategy
32. Push Notification Architecture
33. Local Notification Architecture
34. File Upload Architecture
35. Image Loading Strategy
36. Performance Guidelines
37. Memory Management
38. Testing Strategy
39. Security Architecture
40. Future AI Integration Strategy
41. Future Creator Economy Integration Strategy
42. Future Offline Writing Architecture
43. Code Review Checklist
44. Architecture Constraints
45. Technical Debt Rules
46. Quality Gates
47. Mobile Epic Roadmap (M1–M10)

---

## 1. Mobile Architecture Overview

Qalam Mobile is a **native Flutter application for Android and iOS**, treated as equal first-class
targets. It is a **reader-and-writer client** — the same product surface as the React reader web
app (feed, reading, writing, profiles, social, search, notifications, writer analytics), **not**
the admin surface. Admin/moderation lives only on the web `admin.qalam.*` origin and is out of scope
for mobile.

The app is a **thin, offline-tolerant, cache-first client over a frozen REST API**. It holds no
business rules the server does not already own; it renders server truth, gates UI optimistically for
snappiness, and always defers final authority to the server response.

### 1.1 The stack (fixed)

| Concern | Choice | Rationale |
| --- | --- | --- |
| Language | Dart 3 (sound null-safety, records, sealed classes, patterns) | Modern Dart maps cleanly to the discriminated-union / sealed error model the backend uses. |
| UI toolkit | Flutter (Material 3, custom design system) | See `docs/41`. |
| State management | **Riverpod** (v2, code-gen `@riverpod`) — the ONLY solution | Compile-safe DI + reactive state without service locators. |
| Navigation | **GoRouter** | Declarative, deep-link-native, redirect-based guards. |
| Networking | **Dio** + interceptors | Interceptor pipeline for auth, refresh, errors, logging, retry. |
| Generated API | `openapi-generator` (`dart-dio`) from `openapi.json` | DTOs are generated, never hand-written (ADR §2). |
| Local persistence | **Hive** (non-secret cache) | Fast, typed, no-SQL local cache mirroring server reads. |
| Secure storage | **flutter_secure_storage** (Keychain / EncryptedSharedPreferences) | Tokens only. |
| Immutable models | `freezed` + `json_serializable` (domain entities) | Value equality, `copyWith`, exhaustive sealed unions. |
| Rich content | Custom TipTap-JSON renderer | `pieces.content` is TipTap JSON; the API never serves HTML. |

### 1.2 The shape at a glance

```
┌───────────────────────────────────────────────────────────────────────┐
│                          PRESENTATION (per feature)                     │
│   Widgets / Screens  ─▶  Riverpod Notifiers & Providers  ─▶  UI State   │
└───────────────────────────────┬───────────────────────────────────────┘
                                 │  depends on (interfaces + entities)
┌───────────────────────────────▼───────────────────────────────────────┐
│                            DOMAIN (per feature)                         │
│   Entities (freezed)   Repository *interfaces*   Use cases   Failures   │
│                    (pure Dart — zero Flutter, zero Dio, zero Hive)      │
└───────────────────────────────┬───────────────────────────────────────┘
                                 │  implemented by
┌───────────────────────────────▼───────────────────────────────────────┐
│                             DATA (per feature)                          │
│   Repository impls  ─▶  Remote data source (Dio/generated client)       │
│                     └▶  Local data source (Hive cache)                  │
│   DTO ⇄ Entity mappers   ·   response-envelope unwrapping               │
└───────────────────────────────┬───────────────────────────────────────┘
                                 │  uses
┌───────────────────────────────▼───────────────────────────────────────┐
│  CORE (cross-cutting): Dio client + interceptors · secure storage ·     │
│  Hive setup · env/config · router · logging · error model · DI roots ·  │
│  design system (see docs/41) · shared domain vocabulary (qalam_shared)  │
└─────────────────────────────────────────────────────────────────────────┘
```

Data flows **down through interfaces, up through entities**. The presentation layer never touches
Dio, Hive, secure storage, or a generated DTO. The domain layer never imports Flutter or any
package with I/O. Only the data layer knows the wire exists.

### 1.3 What the app must be

- **Scalable to millions of users** — the client contributes to scale by being cache-first
  (reduces read pressure), respecting cursor pagination, honoring `Retry-After`, and never
  hammering the server (single-flight refresh, debounced autosave, coalesced analytics beacons).
- **Testable** — every layer is unit-testable in isolation; the domain layer has no framework
  dependency; repositories are mocked at their interface.
- **Modular** — a feature is a folder deletable in one `rm -rf` plus removing its route.
- **Maintainable** — one obvious place for each responsibility; no god-objects; no singletons.
- **Performant** — 60/120fps scroll, sub-second cold reads from cache, lazy heavy islands.

---

## 2. Design Principles

These are the non-negotiable principles the whole architecture serves. They are the "why" behind
every rule that follows.

1. **The server is the single source of truth.** The client mirrors and caches; it never invents
   domain state. Every domain invariant (username permanence, one pen name, one language per piece,
   claps cap of 50) is enforced server-side; the client enforces the *same* rules only for UX
   (instant feedback), never as authority. A 422/409 from the server always wins over an optimistic
   guess.
2. **Additive-only compatibility.** The app targets frozen `v1`. It **ignores unknown response
   fields** (forward-compatible), sends only declared request params, and never depends on
   undocumented behavior. When Phase 2 additive endpoints appear (AI, payments, Apple login), they
   slot in as *new* feature modules with zero refactor.
3. **Feature-first, layer-second.** Code is organized by product capability first (`features/feed`),
   then by clean-architecture layer within (`presentation/domain/data`). A feature is independently
   buildable, testable, and deletable.
4. **Dependencies point inward.** Presentation → Domain ← Data. The domain is the stable core with
   no outward dependencies. Nothing depends on a concretion it could depend on an abstraction for.
5. **No singletons, no service locators.** All wiring is Riverpod providers. There is no
   `GetIt`, no global `Instance`, no `static final foo = Foo()`. Lifetime and disposal are explicit
   and testable.
6. **No I/O in widgets, no business logic in widgets.** Widgets read providers and render. They
   call notifier methods. They never call Dio, never map DTOs, never branch on HTTP status.
7. **Two scripts, one dignity.** RTL (Urdu / Nastaliq) and Devanagari (Hindi) are day-one, not a
   retrofit. Directionality is derived *per content language*, independent of UI-chrome direction.
   (Full rules: `docs/41`.)
8. **Fail visibly and honestly.** Errors are typed, mapped from `error.code`, and surfaced with
   literary, human copy — never a raw exception, never a swallowed catch, never a misleading zero.
9. **Offline is graceful degradation, not a feature.** Per ADR §10, offline *authoring/sync* is a
   permanent Non-Goal until re-decided. The app degrades to **cached reads** when disconnected; it
   does not build a local-first write store in Phase 1. (See §23, §42.)
10. **Every await has a decided failure mode.** No fire-and-forget that swallows errors silently
    (except explicitly fire-and-forget analytics beacons, which are designed to be lossy).

---

## 3. Project Folder Structure

The repo is a single Flutter application package plus internal Dart packages for the shared domain
vocabulary and the generated API client.

```
qalam_mobile/                         # the separate Flutter repository
├── pubspec.yaml
├── analysis_options.yaml             # strict lints (see §44)
├── build.yaml                        # freezed / json_serializable / riverpod_generator config
├── .env.example                      # documents required --dart-define keys (no secrets committed)
├── openapi/
│   └── openapi.json                  # a pinned copy of the frozen v1 spec (source for codegen)
├── tool/
│   └── generate_api.sh               # openapi-generator (dart-dio) invocation, pinned version
├── packages/
│   ├── qalam_api/                    # GENERATED dart-dio client + DTO models (do not hand-edit)
│   └── qalam_shared/                 # hand-mirrored @qalam/shared vocabulary (enums, codes, limits)
├── lib/
│   ├── main.dart                     # thin: runApp(ProviderScope(...)) after bootstrap
│   ├── bootstrap.dart                # env load, Hive init, error zone, DI overrides
│   ├── app/
│   │   ├── app.dart                  # MaterialApp.router + theme + localization + directionality
│   │   ├── router/
│   │   │   ├── app_router.dart        # GoRouter provider
│   │   │   ├── routes.dart            # route-name + path constants (mirror of web ROUTES)
│   │   │   ├── guards.dart            # redirect logic (auth/guest/verified)
│   │   │   └── shell/                 # bottom-nav ShellRoute scaffolding
│   │   └── observers/                 # NavigatorObserver, ProviderObserver (logging/analytics)
│   ├── core/                          # cross-cutting; imported by any feature's data/domain
│   │   ├── config/                    # AppConfig, Flavor, EnvKeys
│   │   ├── network/                   # Dio factory, interceptors, ApiException, envelope, paging
│   │   ├── storage/                   # secure storage, Hive registrar, box names, TTL policy
│   │   ├── auth/                      # session model + token store (used by network + guards)
│   │   ├── error/                     # Failure sealed types, error→failure mapping, error catalog
│   │   ├── connectivity/              # connectivity provider + online/offline state
│   │   ├── analytics/                 # beacon service + event contracts
│   │   ├── logging/                   # logger + redaction
│   │   ├── media/                     # key→CDN URL builder, image cache config
│   │   └── utils/                     # pure helpers (pagination, debounce, result types)
│   ├── design_system/                 # tokens, theme, primitives, motion (see docs/41)
│   └── features/
│       ├── auth/
│       ├── feed/
│       ├── reading/
│       ├── writing/
│       ├── profile/
│       ├── search/
│       ├── engagement/
│       ├── notifications/
│       ├── analytics/
│       └── settings/
├── test/                              # unit + widget tests mirror lib/ structure
├── integration_test/                  # end-to-end flows (integration_test / patrol)
└── test_goldens/                      # golden files incl. RTL/Nastaliq render QA (see §38)
```

**Rules for the top level:**

- `core/` and `design_system/` are the only cross-feature shared code. Anything reused by two
  features moves *down* into `core/` (logic) or `design_system/` (look) — never sideways between
  features.
- `app/` is the only place that knows about *all* features (it composes the router). Features never
  import `app/`.
- `packages/qalam_api` is **generated output**: never hand-edited; regenerated whenever a new
  `openapi.json` lands. `packages/qalam_shared` is **hand-maintained** to mirror `@qalam/shared`
  (there is no cross-language codegen for it) and is kept byte-identical in value.

---

## 4. Feature-first Clean Architecture

Every feature is a self-contained slice of the three clean-architecture layers. The layering is
identical in every feature so a developer who knows one knows all of them.

```
features/<name>/
├── domain/                 # pure Dart — the feature's contract & rules
│   ├── entities/           # immutable freezed value objects (mirror API read shape)
│   ├── repositories/       # abstract repository interfaces (the boundary)
│   ├── value_objects/      # small typed wrappers (Cursor, Slug, Username) where useful
│   └── usecases/           # one class per meaningful operation (optional per §20)
├── data/                   # implements the domain, talks to the wire & cache
│   ├── dtos/               # thin wrappers / re-exports of generated qalam_api models (if needed)
│   ├── mappers/            # DTO ⇄ entity translation (the only place both types are known)
│   ├── datasources/
│   │   ├── <name>_remote_data_source.dart   # uses qalam_api / Dio
│   │   └── <name>_local_data_source.dart    # uses Hive (cache)
│   └── repositories/       # concrete repository implementations
├── presentation/
│   ├── providers/          # Riverpod notifiers/providers (feature state)
│   ├── screens/            # route-level pages
│   ├── widgets/            # feature-private widgets
│   └── controllers/        # form controllers, input state (where not a full notifier)
└── <name>.dart             # barrel: exports the feature's public surface (routes, entities)
```

### 4.1 Why clean architecture here

- The **frozen wire shape changes independently of our UI**. Isolating it in `data/` with mappers
  means an additive field, a renamed generated class, or a spec regeneration touches one layer.
- The **domain is the contract with the product**, not with the network. It survives replacing Dio,
  Hive, or even the transport.
- **Testability**: the domain layer runs in a plain Dart VM test with no Flutter binding; the
  presentation layer is tested with `ProviderContainer` overrides swapping repositories for fakes.

### 4.2 The React → Flutter mapping (for continuity)

The web app is feature-first too. The mapping keeps the two clients conceptually aligned so a
feature behaves the same on both:

| React (web) | Flutter (mobile) | Notes |
| --- | --- | --- |
| `features/<name>/api/*` (TanStack hooks) | `data/` (remote data source + repository) | The web's api layer is the only place endpoints are called; ours is `data/datasources`. |
| `features/<name>/hooks/*` | `presentation/providers/*` (Riverpod) | Server-state hooks → repository-backed providers. |
| `features/<name>/stores/*` (Zustand, client-state) | `presentation/providers/*` (UI-state notifiers) | Client-only UI state. |
| `features/<name>/components|pages/*` | `presentation/widgets|screens/*` | Same split. |
| `features/<name>/schemas/*` (Zod) | `presentation/controllers` + `qalam_shared` limits | Form validation reusing shared constants. |
| `features/<name>/types/*` | `domain/entities/*` | Domain entities. |
| `lib/query-keys.ts` | cache keys in `local_data_source` + provider families | See §25. |
| `lib/api-client.ts` | `core/network` (Dio + interceptors) | Single choke point. |

The actual web feature set (authoritative) is: `auth, feed, writing, profile, search, notifications,
analytics, settings`, with `discover` living inside `feed`/`search` and `reading`/`engagement`/
`collections` deferred. Mobile mirrors these boundaries; `reading` and `engagement` are named
explicitly here because mobile *will* build them (M-track sequencing in §47) even though the web app
deferred a standalone reader.

---

## 5. Layer Responsibilities

A precise contract for what each layer may and may not do. Reviewers block on violations.

### 5.1 Presentation layer

**May:** build widgets; read providers; call notifier/use-case methods; hold ephemeral view state
(scroll position, expanded/collapsed, text-field controllers); map a domain `Failure` to a design-
system error/empty/loading widget; format entities for display (via `core/utils` or design-system
formatters).

**Must not:** import Dio, Hive, `flutter_secure_storage`, `qalam_api`, or any DTO/mapper; branch on
HTTP status codes or `error.code` directly (that mapping lives in `core/error`); contain business
rules; perform I/O; construct repositories directly (they arrive via providers).

**Owns:** the four UI-state concerns — which screen, which tab/filter (mirrors URL-as-source-of-truth
where a query param would exist on web), transient interaction state, and the *presentation* of
async server state (loading/error/data) via `AsyncValue`.

### 5.2 Domain layer

**May:** define immutable entities; define abstract repository interfaces; define `Failure` types
(or import them from `core/error`); define use cases; hold pure business logic that is genuinely
client-side (e.g. computing a clap batch delta clamped to 50 before sending).

**Must not:** import Flutter (`package:flutter/*`), Dio, Hive, `qalam_api`, `json_serializable`
annotations that require code-gen tied to the wire, or anything with I/O. The domain is a **pure Dart
library** — it could be published standalone.

**Owns:** the vocabulary of the feature and the shape of the contract between presentation and data.

### 5.3 Data layer

**May:** import `qalam_api` (generated), Dio, Hive, `core/network`, `core/storage`; unwrap the API
envelope; translate DTOs to entities via mappers; implement caching; catch Dio/transport exceptions
and translate them to domain `Failure`s.

**Must not:** leak a DTO or a `DioException` upward — the repository's public methods return domain
entities or `Failure`s only; contain UI concerns; know about widgets or providers.

**Owns:** everything about the wire and the cache. It is the *only* layer that changes when the spec
is regenerated or the cache strategy changes.

### 5.4 Core layer

Cross-cutting infrastructure shared by all features' data layers (and, for the router/session/error
model, by presentation). Core has no feature knowledge. It provides: the configured Dio instance,
interceptors, the `ApiException`/`Failure` model and mapping, the token store, Hive registration and
TTL policy, the connectivity provider, the analytics beacon service, the logger, the media-URL
builder, and the environment config.

---

## 6. Feature Module Structure

A worked example — the **feed** feature — makes the layering concrete without code.

```
features/feed/
├── domain/
│   ├── entities/
│   │   ├── feed_item.dart              # FeedItem entity (a piece card summary)
│   │   └── feed_page.dart              # CursorPage<FeedItem> — items + PageMeta
│   ├── repositories/
│   │   └── feed_repository.dart        # abstract: fetchFeed(tab, filters, cursor) → FeedPage
│   └── value_objects/
│       └── feed_query.dart             # tab + filters value object (sort, language, genre, tag)
├── data/
│   ├── mappers/
│   │   └── feed_item_mapper.dart       # PieceSummaryDto → FeedItem
│   ├── datasources/
│   │   ├── feed_remote_data_source.dart # GET /feed/{tab} via qalam_api, reads meta.pagination
│   │   └── feed_local_data_source.dart  # Hive box: cache first page per (tab,filters)
│   └── repositories/
│       └── feed_repository_impl.dart    # cache-then-network; maps failures
├── presentation/
│   ├── providers/
│   │   ├── feed_query_provider.dart     # holds selected tab + filters (UI state)
│   │   └── feed_list_provider.dart      # paginated AsyncNotifier over the repository
│   ├── screens/
│   │   └── feed_screen.dart
│   └── widgets/
│       ├── feed_tabs.dart
│       ├── feed_filter_bar.dart
│       └── piece_card.dart              # composes design-system PieceCard
└── feed.dart                            # barrel export (route builder + public entities)
```

**Conventions inside a feature:**

- One repository interface per feature aggregate; large features may have more than one (e.g.
  `engagement` has `ReactionRepository`, `CommentRepository`, `CollectionRepository`).
- One paginated provider per timeline (feed, search results, comments, notifications, followers).
- The barrel (`<name>.dart`) exports only the feature's public surface: its route(s) and any entity
  another feature legitimately references *through the domain* (see §7 for the escape hatch).
- Feature-private widgets/providers are not exported and not imported elsewhere.

---

## 7. Dependency Rules

The rules that keep the graph acyclic and the features independent. These are enforced by lint
(import boundary rules) and by review.

1. **Presentation → Domain → (implemented by) Data.** The domain declares interfaces; the data layer
   implements them; the presentation layer depends on the interfaces and entities, never on the data
   layer's concretions. The concrete repository is bound to its interface *only* in the DI layer
   (§9) via a provider override.
2. **Domain depends on nothing outward.** No Flutter, no Dio, no Hive, no generated code. If the
   domain needs a capability (e.g. "current time," "uuid"), it declares an interface and the data/
   core layer provides it.
3. **Features never import other features.** Not their widgets, not their providers, not their data.
   The only legal cross-feature coupling:
   - **Shared entities** that are genuinely cross-cutting (e.g. a `PieceRef`, an `Author` summary)
     live in a small shared domain module (`core/domain` or `qalam_shared` types), imported by both.
   - **Navigation** between features goes through the router by route name (§10) — feature A pushes
     a route owned by feature B; it does not import B's screen widget.
   - **Cross-feature reactions to events** (e.g. "a follow happened, refresh the following feed") go
     through cache invalidation keyed on shared cache keys (§25), not through direct calls.
4. **`app/` composes features; features never import `app/`.**
5. **`core/` and `design_system/` may be imported by any feature** (data/presentation respectively);
   they never import a feature.
6. **`qalam_api` is imported only by `data/` layers and `core/network`.** Never by domain,
   presentation, or another package.
7. **No circular dependencies, ever.** If two features need each other, the shared piece is wrong-
   placed and must move down. The import graph is a DAG rooted at `main.dart`.

**Deletion test (the litmus for modularity):** deleting `features/<name>/` plus removing its route
registration in `app/router` must leave the app compiling. If it does not, a dependency rule was
violated.

---

## 8. Riverpod Architecture

Riverpod is the **only** state-management and dependency-injection mechanism. There is no `Provider`
(package:provider), no `Bloc`, no `GetIt`, no `ChangeNotifier` singletons, no `setState`-driven
cross-widget state.

### 8.1 Provider taxonomy

Every piece of state is classified into exactly one bucket before coding — mirroring the web's
four-quadrant discipline (`docs/12`), translated to Riverpod:

| State kind | Web owner | Mobile owner | Examples |
| --- | --- | --- | --- |
| **Server state** | TanStack Query | Repository-backed `AsyncNotifier` / `FutureProvider` | feed pages, piece detail, profile, notifications, `me`, taxonomy, analytics |
| **Client / UI state** | Zustand slices | `Notifier` / `StateProvider` (UI-only) | theme mode, editor chrome (focus mode, save status), active modal, selected tab/filter |
| **Session state** | Zustand `useAuthStore` status machine | `SessionNotifier` (`AsyncNotifier`), tri-state | `unknown / authenticated / anonymous` + `role` + `isEmailVerified` |
| **Form / input state** | React Hook Form + Zod | form controllers + provider | register, publish, edit-profile, settings, password |
| **"URL" state** | React Router | route path/params via GoRouter + a query provider | feed tab, search filters, analytics range |

> **The golden rule (ported verbatim):** *server state is never mirrored into a client-state
> notifier.* If the API knows it, it lives in a repository-backed async provider. If it is purely
> "which view / which toggle," it is a UI-state notifier. A single value used by one widget is plain
> local state (`useState`-equivalent), not a global provider.

### 8.2 Code generation

Use **`@riverpod` (riverpod_generator)** for all providers. Benefits: compile-time-safe provider
references, automatic `autoDispose` by default, typed families, and no manual `Provider` boilerplate.

- **`autoDispose` is the default.** A provider that backs a screen disposes when the screen is gone
  (frees memory, cancels in-flight requests). Providers that must survive navigation (session, theme,
  connectivity, the Dio client) are explicitly marked `keepAlive`.
- **Families** carry parameters into the provider identity: `pieceDetail(pieceId)`,
  `profile(username)`, `feedList(query)`. The family argument is the equivalent of a TanStack query
  key — it must be a value type with correct equality (freezed) so identical args reuse state.

### 8.3 Async server state

Server reads are exposed as `AsyncValue<T>` from an `AsyncNotifier` (mutations) or `FutureProvider`
(pure reads). This gives the UI a uniform `loading / error / data` tri-state that maps directly to
design-system skeleton / error / content widgets — no manual boolean flags.

**Pagination** is an `AsyncNotifier` holding an accumulated list plus the current `PageMeta`
(`nextCursor`, `hasMore`). `loadMore()` appends the next page; the cursor is opaque and never stored
in navigation state. (Full cursor rules: §13.7, §25.)

**Staleness / refetch tiers** mirror the web's `staleTime` policy so both clients feel the same. The
tier is a property of the repository/provider, not passed in by widgets:

| Tier | Freshness | Applies to |
| --- | --- | --- |
| Live | ~30s | feed lists, notifications list + unread count |
| Content | ~5min | piece detail, responses, comments |
| Identity | ~1min | profiles, `me`, `me/*` |
| Taxonomy | ~1h | tags, genres, languages |

The cache TTL in Hive (§25) uses these same tiers. "Refetch on reconnect" is global; "refetch on
app-resume" applies to the Live tier only.

### 8.4 Client / UI state

UI-only state is a `Notifier<T>` with a small typed state class (freezed). Rules ported from the web
Zustand discipline:

- **One notifier per concern.** No god-notifier. Examples: `themeModeNotifier`,
  `editorChromeNotifier` (focus mode, save status, publish-sheet step — never document content),
  `connectivityNotifier`, `feedQueryNotifier`.
- **Notifiers never depend on each other.** Cross-concern coordination happens at the presentation
  layer by watching multiple providers, or via the router.
- **No async work inside a UI-state notifier** beyond reading a repository through a provider; UI
  notifiers hold state and expose synchronous actions.
- **Subscribe narrowly.** Widgets `ref.watch(provider.select((s) => s.field))` to avoid rebuilding on
  unrelated state changes — the equivalent of the web's narrow-selector rule.

### 8.5 Session state

Session is its own `AsyncNotifier` (`SessionNotifier`) exposing a **tri-state**:
`unknown | authenticated(role, isEmailVerified) | anonymous`. This deliberately mirrors the web
`useAuthStore` status machine (a documented, intentional divergence from the older "session is a
query" doc). The session notifier:

- Holds only *session UI facts* (status, role hint, email-verified flag), **not** the full user
  profile object. The profile is a separate server-state provider keyed by the current user.
- Is `keepAlive` (survives navigation) and is the single source guards read.
- Drives router redirects (§11) reactively: when status flips to `anonymous` (e.g. refresh failure),
  the router re-evaluates and bounces to login.

### 8.6 Provider observers

A `ProviderObserver` in `app/observers` logs provider lifecycle and errors in debug builds and feeds
non-PII telemetry (see §29) — the mobile equivalent of the web's devtools + error reporting.

---

## 9. Dependency Injection Strategy

**DI is Riverpod. There are no other DI mechanisms. No service locator, no `GetIt`, no global
singletons.**

### 9.1 How wiring works

- Every dependency (Dio client, token store, each data source, each repository, each use case) is
  exposed as a provider.
- **The domain declares the interface; a provider produces the concrete implementation; consumers
  depend on the provider typed as the interface.** Binding an interface to an implementation is a
  one-line provider that returns the impl — this is the whole of "DI registration."
- Cross-cutting singletons (Dio, secure storage, Hive boxes, connectivity, logger, config) are
  `keepAlive` providers created once. They are *not* Dart singletons — they are provider-scoped and
  overridable.

### 9.2 Composition root

`main.dart` wraps the app in a single `ProviderScope`. `bootstrap.dart` performs async
initialization (load env/config, init Hive + register adapters, open the secure store, build the
initial config) and passes the results into the scope via **provider overrides**. This is the only
place concrete infrastructure is chosen:

```
runApp(
  ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(loadedConfig),
      hiveRegistrarProvider.overrideWithValue(openedHive),
      // ... other bootstrapped infra
    ],
    child: const QalamApp(),
  ),
)
```

### 9.3 Testability

Because everything is a provider, any test builds a `ProviderContainer` and overrides exactly the
providers it wants to fake:

- A notifier test overrides the repository provider with a fake returning canned entities/failures.
- A repository test overrides the data-source providers with fakes.
- A widget test overrides the providers the widget reads.

No test ever needs to reach into a global to substitute a dependency — there are no globals.

### 9.4 Lifetime rules

| Provider | Lifetime | Rationale |
| --- | --- | --- |
| `appConfigProvider`, `dioProvider`, `tokenStoreProvider`, `hive*`, `connectivityProvider`, `sessionNotifier`, `themeModeNotifier`, `loggerProvider` | `keepAlive` | Cross-cutting; created once. |
| feature screen providers (feed list, piece detail, profile) | `autoDispose` (default) | Freed with the screen; cancels in-flight work. |
| `family` providers | `autoDispose` keyed by arg | Distinct state per arg; freed when unused. |

---

## 10. GoRouter Navigation Architecture

Navigation is **GoRouter**, exposed as a `keepAlive` provider (`app/router/app_router.dart`). Routes
are declarative, deep-link-native, and guarded by redirects (§11). Route paths are constants in
`app/router/routes.dart`, mirroring the web `lib/routes.ts` `ROUTES` object so the two clients share
a URL vocabulary (important for shared links / deep links, §12).

### 10.1 Shell + branches

The authenticated app is a **`StatefulShellRoute`** with one branch per bottom-tab destination, so
each tab keeps its own navigation stack and scroll position (the mobile analogue of the web's
per-tab page stacks). The five destinations mirror `docs/41`'s bottom navigation:

```
StatefulShellRoute (bottom nav: Feed · Search · Write · Notifications · Profile)
├── branch: /feed         → FeedScreen         (+ /discover as a feed surface)
├── branch: /search       → SearchScreen
├── branch: /write        → editor entry (Write tab is the accented primary CTA)
├── branch: /notifications→ NotificationsScreen
└── branch: /me           → own profile (resolves current user's @handle)
```

Full-screen flows that should not show the bottom nav (the **editor**, the **reading view**, the
**auth corridor**, settings sub-pages) are **top-level routes outside the shell** — matching the
web's decision that "writing is the hero" and the reader/editor render without app chrome.

### 10.2 Route map (mirrors the frozen web routes + reader/editor)

| Path | Screen | Guard | Notes |
| --- | --- | --- | --- |
| `/` | launch / redirect | — | authenticated → `/feed`; else onboarding/landing |
| `/feed` | Feed | auth-aware | tab via provider (not a path segment); default `following` if authed else `discover` |
| `/discover` | Discover | public | top-level (as on web) |
| `/search` | Search | public | filters in a query provider (`q`, `type`, `language`, `genre`, `tag`, `sort`) |
| `/p/:idOrSlug` | Reading view | public | slug preferred; see §12 for the slug cold-load caveat |
| `/write` | Editor (new draft) | auth | no bottom nav; own minimal chrome |
| `/write/:draftId` | Editor (existing draft) | auth | autosave; no bottom nav |
| `/me` | Own profile | auth | resolves signed-in user's handle |
| `/me/drafts` | Drafts | auth | infinite list |
| `/me/follow-requests` | Follow requests | auth | private-account approvals |
| `/me/stats` | Writer analytics dashboard | auth | range via query provider |
| `/me/stats/pieces/:id` | Per-piece analytics | auth | keyed by UUID |
| `/notifications` | Notifications inbox | auth | polling (see §32) |
| `/settings` | Settings index | auth | redirects to `/settings/profile` |
| `/settings/profile` | Edit profile | auth | |
| `/settings/account` | Account | auth | change password, email state, sign-out-everywhere |
| `/settings/appearance` | Appearance | auth | theme, reading size, reduced motion |
| `/settings/notifications` | Notification preferences | auth | |
| `/@:handle` | Writer profile | public | validate `@`, reject reserved handles, else 404 |
| `/auth/login` | Login | guest | |
| `/auth/register` | Register wizard | guest | sets permanent username (one-time confirm) |
| `/auth/forgot-password` | Forgot password | guest | |
| `/auth/reset-password` | Reset password | guest | token param |
| `/auth/verify-email` | Verify email | none | neutral corridor: reachable signed-out AND freshly-registered |
| `/auth/callback` | Google OAuth callback | guest | exchanges one-time code |
| `/401`, `/403`, `/404`, `/offline` | Error surfaces | — | dedicated screens |

**Reserved handles** (cannot be a username, matching web): `feed, search, discover, me, settings,
auth, write, p, tag, genre, notifications`. The `/@:handle` route validates the `@` prefix and
rejects reserved words before firing any request.

### 10.3 Navigation rules

- Navigate by **route name/path constant**, never by pushing a widget instance — this preserves the
  no-cross-feature-import rule (§7).
- Tab switches change the active shell branch; they do **not** reset the branch's stack.
- Cursors are never in the route path or query (opaque, per-viewer, meaningless to share).
- Query-carried view state (search filters, feed tab, analytics range) is read through validated
  providers that coerce garbage to a default — never crash on a bad param.
- The reading view and editor own their own error boundaries; a failure there does not take down app
  chrome (mirrors the web's per-route-group error boundaries).

---

## 11. Route Guards

Guards are **GoRouter `redirect` functions** reading the **session notifier** (§8.5) — not
imperative checks scattered in screens. There are three guard behaviors.

### 11.1 The three guards

| Guard | Passes when | Fails to |
| --- | --- | --- |
| **RequireAuth** | session is `authenticated` | `/auth/login?returnTo=<path>` |
| **RequireGuest** | session is `anonymous` | `returnTo` if safe, else `/feed` |
| **RequireVerified** (action-level, not route-level) | `isEmailVerified` | inline banner + resend, not a redirect |

### 11.2 Boot / unknown handling (critical)

While the session is `unknown` (app just launched, silent token restore in flight), guards render the
**route-group loading skeleton** and do **not** redirect. This prevents the "false bounce on cold
start" bug: a logged-in user must never flash the login screen because the token restore had not
completed. Only once the session resolves to `authenticated` or `anonymous` does a redirect fire.

### 11.3 returnTo contract

- `returnTo` captures **path + query only** (never a full origin), at the moment of denial.
- It is consumed **once** after successful login, using a **replace** navigation so Back never
  re-enters the auth corridor.
- Only same-origin relative paths starting with `/` are honored; anything else falls back to `/feed`
  (open-redirect defense — even though a native app is less exposed, we keep the discipline).
- A mid-session expiry (refresh failure → session flips to `anonymous`) re-captures the current
  location so re-login round-trips the user back.

### 11.4 Authorization gating (PBAC as a UX hint)

The JWT carries `role` (`user | moderator | admin | super_admin`) and nothing sensitive. The client
decodes it **as a UX hint only** — to show/hide affordances — and derives capabilities from the
shared permission mapping (`DEFAULT_ROLE_PERMISSIONS` + `permissionSatisfies`, mirrored in
`qalam_shared`). **The server is always authoritative**: every mutation is re-checked server-side and
may return `AUTH_PERMISSION_DENIED` (403) or `FORBIDDEN` regardless of what the client rendered.

Because the mobile app is the *reader/writer* surface, it needs almost none of this: a standard
`user` sees the full app. Moderator/admin affordances are not built into mobile (admin is web-only).
The mechanism exists so that *if* a moderation affordance is ever added, it gates correctly.

### 11.5 Onboarding gating

Username is set **once at registration** and is **permanent** (`USER_USERNAME_IMMUTABLE`). The app
must **never render a username-edit path**. There is **no live username-availability endpoint** — the
register form validates *format* client-side against the shared `USERNAME_REGEX`
(`^[a-z0-9_]{3,30}$`) and surfaces *taken* only on submit (`USER_USERNAME_TAKEN` → username field).
Email verification is a **state, not a wall**: unverified users read and browse; only server-gated
actions are blocked (`AUTH_EMAIL_UNVERIFIED`, 403) with a dismissible banner + resend.

---

## 12. Deep Link Architecture

Deep links let a URL open the right screen — from a shared link, a push notification, or the OS. The
scheme mirrors the web URL contract so a single link works across web and mobile.

### 12.1 Link → route resolution

- **Universal Links (iOS) / App Links (Android)** map `https://app.qalam.example/<path>` to the
  in-app route of the same path. GoRouter's path table (§10.2) is the resolver; there is no separate
  deep-link parser — the router *is* the parser.
- A **custom scheme** (`qalam://`) is registered as a fallback for internal use (push payloads),
  but public shareable links are always `https` universal links.
- Deep links respect guards: a link to an auth-only route while signed out redirects through
  `/auth/login?returnTo=<path>` and lands the user on the target after login.

### 12.2 Shareable surfaces

| Surface | Link | Resolves |
| --- | --- | --- |
| Piece | `/p/:slug` | reading view |
| Profile | `/@:username` | writer profile |
| Search | `/search?q=…&type=…` | search with state (state fully in query) |
| Feed tab | `/feed` (+ future tab query) | feed |

### 12.3 The slug cold-load caveat (frozen-contract reality)

`GET /pieces/:id` takes a **UUID**; there is **no public `slug → piece` endpoint in `v1`**. When the
user navigates *from a list* (feed, search, profile), the app already holds the piece **id** and
passes it — the `/p/:slug` link is cosmetic. But a **cold** deep link that carries only a slug
(shared link, push into a not-yet-loaded piece) **cannot be resolved today**.

**Architecture stance:** the reading-view provider accepts *either* an id or a slug. Given an id it
loads directly. Given only a slug with no id in hand, it renders a graceful "open in browser / not
yet available on mobile" fallback rather than guessing — **never decode an id from a slug**. When the
backend later ships the additive `GET /pieces/by-slug/:slug`, the data source gains one method and the
fallback disappears with zero architectural change. This is documented as a known, contract-bound gap.

### 12.4 Push-notification deep links

A push payload (Phase 2, §32) carries a `route` (a path from §10.2) and the entity identifiers needed
to resolve without a slug (e.g. a piece **id**, an actor username). Tapping the notification pushes
that route through the same guarded router. Notification `data` payloads from the backend already
carry denormalized render fields (piece id/slug, actor username), so the deep link has what it needs.

---

## 13. Dio Networking Layer

`core/network` is the **single choke point** for all HTTP — the mobile equivalent of the web's
`lib/api-client.ts`. No feature ever constructs a Dio call or touches the generated `qalam_api`
client directly except inside its `data/datasources`.

### 13.1 The Dio instance

One configured Dio, provided as a `keepAlive` provider, used both directly by data sources and as the
transport the generated `qalam_api` client is built on. Base config:

- `baseUrl` = `{apiUrl}/api/v1` from `AppConfig` (§28).
- `connectTimeout` / `receiveTimeout` / `sendTimeout` = **20s** (matches the web's
  `DEFAULT_TIMEOUT_MS = 20_000`).
- Default headers: `Accept: application/json`; `Content-Type: application/json` is set **only when a
  JSON body is present** (never for multipart — the platform sets `multipart/form-data; boundary=…`).
- **`X-Client: mobile` on every request** — this is load-bearing: it tells the backend to return the
  refresh token in the response body (mobile channel) rather than as a cookie.

### 13.2 Interceptor pipeline (order matters)

```
Request  ─▶ [1] HeadersInterceptor  (X-Client, Accept, Idempotency-Key on publish)
         ─▶ [2] AuthInterceptor     (attach Bearer access token from in-memory cache)
         ─▶ [3] LoggingInterceptor   (redacted; debug/verbose only)
                              │
                         (network)
                              │
Response ◀─ [3] LoggingInterceptor   (status, timing, x-request-id)
         ◀─ [2] AuthInterceptor      (401 + AUTH_TOKEN_EXPIRED → single-flight refresh → retry once)
         ◀─ [4] ErrorInterceptor     (envelope → ApiException; rate-limit; transport → synthetic codes)
```

- **HeadersInterceptor** — sets `X-Client: mobile`, `Accept`; adds `Idempotency-Key` (a per-intent
  UUID) **only** on `POST /pieces/:id/publish`.
- **AuthInterceptor** — injects `Authorization: Bearer <access>` from the in-memory token cache when
  present; owns the 401→refresh→retry-once logic (§15).
- **ErrorInterceptor** — converts every failure into a typed `ApiException` (§21, §22) so the rest of
  the app never sees a `DioException`. Reads `Retry-After` / `x-ratelimit-*` on 429.
- **LoggingInterceptor** — structured, redacted, debug-only (§29).

### 13.3 Envelope unwrapping

Every response body is `{ success, data, meta? }` or `{ success:false, error:{...} }`. The network
layer:

- On `success == true`: returns **`data`** to the data source (the envelope is unwrapped; data
  sources see payloads, not envelopes). List endpoints also expose `meta`.
- On `success == false`: throws `ApiException(code, message, status, details, requestId)`.
- On **204**: no body — returns a unit/void result.
- On a non-JSON or shapeless body: throws `ApiException` with synthetic code `API_MALFORMED_RESPONSE`.

### 13.4 Typed error model

A single `ApiException` type carries `{ code, message, status, details, requestId }`. **Consumers
branch on `code`, never on `message`** (messages are human-facing, may be localized, and can change).
`status == 0` denotes a transport failure (offline / network). (Full model: §21.)

### 13.5 Retry policy

- **GET reads:** up to 2 retries with exponential backoff (≈1s, 3s) **only for 5xx / transport
  errors**; never retry 4xx (matches web `retry: (n, err) => n < 2 && !(4xx)`).
- **Mutations:** **0 retries by default.** The **only** retriable mutation is
  `POST /pieces/:id/publish`, which carries an `Idempotency-Key` so a replay is safe.
- **429:** never auto-retry. Honor `Retry-After` and surface a quiet "slow down" state; the UI may
  re-enable the action after the window.
- **401:** handled by the refresh flow (§15), not the retry policy. A 401 after a fresh token is a
  genuine authz failure, not expiry — do not loop.
- **403:** never retried.

### 13.6 Query-string conventions (must match backend DTO expectations)

Mirror the web's `buildQueryString`:

- Omit `null` / undefined params entirely.
- Arrays are **comma-joined** (OR semantics): `?language=hi,ur`.
- Booleans are **literal `true`/`false` strings**.
- Sort is `?sort=field` or `?sort=-field`.
- **Send only declared params** — the backend rejects unknown query params
  (`forbidNonWhitelisted`), so never send speculative keys.
- Enum-valued params (`tab`, `type`, `status`, `sort`, `kind`, `period`) use the exact wire strings
  from `qalam_shared` enums.

### 13.7 Pagination on the wire (byte-for-byte)

Cursor pagination nests the meta **under `meta.pagination`**, not flat on `meta` — a critical trap:

```
{ "success": true,
  "data": [ /* items */ ],
  "meta": { "pagination": { "nextCursor": "eyJ…", "hasMore": true, "limit": 20 } } }
```

The paging helper reads `meta.pagination.{nextCursor, hasMore, limit}`. `limit` default **20**, max
**50** (clamp client-side). A cursor is **opaque** — never decoded, constructed, persisted, or put in
a route. A stale/invalid cursor returns `400 FEED_INVALID_CURSOR` → the provider resets to page one.
Some list-shaped endpoints (`GET /search` grouped, `/search/autocomplete|trending|recent`, all
`/analytics/*`, `/notification-preferences`) return a `data` array with **no `meta`** — the data
source treats these as non-paginated. Offset pagination (`{page, limit, total, totalPages}`) is
admin-only and unused on mobile.

### 13.8 Headers to read

Response headers are **lowercase**: `x-request-id` (surface in support "details"), `x-ratelimit-limit
/ -remaining / -reset`, and `Retry-After` on 429.

---

## 14. Authentication Flow

Auth adapts to the **mobile channel** of the frozen contract. The pivotal facts:

- **`X-Client: mobile`** on auth requests makes the backend return `refreshToken` **in the response
  body** (web gets an httpOnly cookie instead; there are no cookies on mobile).
- **Both tokens are stored in secure storage** (Keychain / EncryptedSharedPreferences). The access
  token is also cached in memory for the hot path; the refresh token never leaves secure storage
  except to be sent on `POST /auth/refresh`.
- Access JWT lifetime **15 min**; refresh **30 days, rotating**.

### 14.1 Endpoints (frozen `v1`)

`POST /auth/register` (201) · `POST /auth/login` · `POST /auth/refresh` · `POST /auth/logout` ·
`POST /auth/logout-all` · `POST /auth/verify-email` · `POST /auth/resend-verification` ·
`POST /auth/forgot-password` · `POST /auth/reset-password` · `POST /auth/change-password` ·
`GET /auth/google` · `GET /auth/google/callback` · `POST /auth/google/exchange`.

### 14.2 Auth response shape

`data` from login/register: `{ user: { id, email, username, isEmailVerified }, accessToken,
refreshToken }` (refreshToken present because `X-Client: mobile`). Refresh returns `{ accessToken,
refreshToken }` (rotation → a new refresh token every time). Google exchange returns `{ accessToken }`
(and, for mobile channel, a refresh token in body).

### 14.3 Email + password login/register

```
User submits creds
   │  (X-Client: mobile)
   ▼
POST /auth/login  or  /auth/register
   │  200/201 → { user, accessToken, refreshToken }
   ▼
TokenStore.save(access, refresh)          # refresh → secure storage; access → secure + in-memory
   ▼
SessionNotifier → authenticated(role, isEmailVerified)  # decoded from access JWT
   ▼
Router redirect resolves returnTo → target screen
```

Register is a **single logical submission** even if presented as a wizard — the final step fires
once, atomically. The username step carries the one deliberate confirmation ("write it in ink") — it
is permanent.

### 14.4 Google OAuth (Authorization Code + PKCE)

The server runs Authorization Code + PKCE (`S256`); the mobile client uses a native OAuth flow
(`flutter_appauth` / platform SDK) or the server-mediated redirect the web uses, landing on
`/auth/callback?code=<oneTimeCode>` and calling `POST /auth/google/exchange { code }` to obtain
tokens. `state` is a server-side CSRF nonce (10-min TTL). Apple Sign-In is **Phase 2** (the backend
`auth_identities` seam is ready) — build the identity flow provider-agnostically so Apple slots in
without refactor.

### 14.5 Boot / silent restore

On launch, `bootstrap` asks the token store whether a refresh token exists (gated by a "remember me"
preference, mirroring the web). If yes → `SessionNotifier` attempts a silent `POST /auth/refresh`; on
success the session is `authenticated`, on failure it becomes `anonymous` with **no error UI** (an
expired session is normal). If no stored token → straight to `anonymous`. During this the session is
`unknown` and guards show skeletons (§11.2). The boot refresh fires **once** (guarded against double
invocation) — a double refresh would rotate the token twice and trip reuse detection.

### 14.6 Logout

`POST /auth/logout` → clear in-memory + secure-storage tokens → clear the query/cache layer → reset
non-persistent providers → session `anonymous`. Theme and reading-size preferences survive (device
prefs). `POST /auth/logout-all` ("sign out everywhere") bumps the server session version, invalidating
all sessions; the app treats the resulting `AUTH_SESSION_REVOKED` on next call as a logout.

---

## 15. Refresh Token Flow

The refresh flow is the most safety-critical piece of the networking layer because the backend uses
**rotating refresh tokens with token-family reuse detection**: if the same refresh token is presented
twice, the **entire family is revoked** and every session using it is forced to re-authenticate.
Therefore refresh **must be single-flight**.

### 15.1 The rule

```
Response 401
   │
   ├─ code == AUTH_TOKEN_EXPIRED  AND  path is not /auth/*  AND  not already a retry
   │        │
   │        ▼
   │   refresh (single-flight):
   │        if a refresh is already in flight → await it (do NOT start a second)
   │        else → POST /auth/refresh  { refreshToken }  with X-Client: mobile
   │                 ├─ success → store new { access, refresh }; replay original request ONCE
   │                 └─ failure → clear session → anonymous → surface as terminal 401
   │
   └─ any other 401 (AUTH_TOKEN_INVALID / AUTH_REFRESH_REUSED / AUTH_SESSION_REVOKED),
      or a still-401 after replay → clear session → route to login
```

### 15.2 Single-flight implementation contract

- A single shared `Future`/`Completer` represents the in-flight refresh. Concurrent 401s **await the
  same future**; they never each start a refresh. The future is cleared in a `finally` so the next
  genuine expiry can refresh again.
- The refresh request itself is **exempt** from the AuthInterceptor's 401-handling (it starts with
  `/auth/`), so a failed refresh does not recurse.
- The replayed original request is marked as a retry so a second 401 does not loop — it is treated as
  a terminal authz failure.

### 15.3 Why the single-flight discipline is non-negotiable

Legit clients refresh ~4×/hour; the backend allows 30/hour. A stampede of parallel requests each
firing its own refresh would present the *same* rotating token multiple times, trip **family reuse
detection**, get `AUTH_REFRESH_REUSED`, and **log the user out**. Single-flight is what prevents the
app from logging itself out under concurrency.

### 15.4 Storage during rotation

Every successful refresh returns a **new** refresh token; the token store must **atomically replace**
both tokens (never keep the old refresh token around — presenting it later is exactly the reuse the
backend punishes). The in-memory access token is updated for the hot path; the new refresh token goes
to secure storage.

### 15.5 Uploads bypass refresh

Multipart uploads (§34) run mid-session with a fresh access token and **do not** go through the
401→refresh interceptor (matching the web `uploadWithProgress`). A 401 during upload surfaces to the
caller, which can refresh via a normal request and retry the upload.

---

## 16. Repository Pattern

Repositories are the boundary between the domain and the outside world. **Nothing bypasses a
repository** — presentation never calls a data source, Dio, or the generated client.

### 16.1 Contract

- The repository **interface** lives in `domain/repositories`. Its methods speak **entities and
  value objects** only, return domain results, and throw/return domain `Failure`s — never DTOs,
  never `DioException`, never HTTP status.
- The repository **implementation** lives in `data/repositories`. It orchestrates: read cache →
  fetch remote → map DTO → entity → write cache → return. It catches transport/`ApiException` and
  translates to `Failure`.
- A repository method has **one clear responsibility** and a **decided failure mode** for every
  await.

### 16.2 Result convention

Repositories return one of two shapes, chosen per feature for consistency:

- **`Either<Failure, T>`-style result** (e.g. `Result<T>`), where callers pattern-match on
  success/failure. Preferred for use cases and mutations.
- Or throw a typed `Failure` and let the presentation's `AsyncNotifier` capture it as
  `AsyncError` — acceptable for read providers where `AsyncValue` already models the error.

Pick one convention per feature and hold it; do not mix within a feature.

### 16.3 Cache-then-network default

The default read strategy (see §25):

```
fetch(key):
  1. emit cached entity if present and not hard-expired  (instant paint)
  2. if online and cache stale/absent → fetch remote → map → cache → emit fresh
  3. if offline → serve cache (mark as stale) or emit a `Failure.offline` if no cache
```

This makes the app feel instant and keeps it usable offline for previously-seen content, without any
local-first write machinery.

### 16.4 Mutations

Mutations (publish, follow, clap, bookmark, comment, edit profile, settings) call the remote source,
then **invalidate/refresh** the affected cache keys — mirroring the web's mutation→invalidation table
(every new mutation documents which keys it invalidates). Optimistic updates (§8, §21) apply only to
trivially reversible actions (like/unlike, clap, bookmark, follow); publish/schedule/delete are
**never** optimistic because the server mints slug/status/ids.

---

## 17. Data Sources

Each feature's data layer has up to two data sources behind the repository.

### 17.1 Remote data source

- The **only** place `qalam_api` (generated client) or a raw Dio call is used.
- Exposes typed methods per endpoint (`fetchFeed(tab, query, cursor)`, `getPiece(id)`,
  `clap(pieceId, count)`), returning **DTOs** (generated) or already-mapped entities depending on the
  feature's mapper placement.
- Reads pagination from `meta.pagination`; passes query params via the query-string conventions
  (§13.6).
- Knows nothing about caching — it just talks to the wire.

### 17.2 Local data source

- The **only** place Hive is touched for this feature.
- Exposes cache read/write/evict keyed by the feature's cache keys (§25), storing serialized entities
  (or DTOs) with a written-at timestamp for TTL.
- Knows nothing about the network — it just reads/writes the box.

### 17.3 Why the split

Splitting remote and local lets the repository compose them (cache-then-network) and lets tests fake
each independently. It also isolates the two most volatile dependencies (the generated client and the
storage engine) from each other and from the rest of the app.

---

## 18. DTO Mapping

**DTOs are generated, never hand-written** (ADR §2: Flutter generates Dart models from `openapi.json`
via `dart-dio`). This is how the hard rule "never duplicate backend DTOs" is honored: the DTOs are a
*mechanical projection* of the same spec the web app uses, not a hand-copied parallel.

### 18.1 The layers of type

```
openapi.json  ──(openapi-generator dart-dio)──▶  qalam_api DTOs  ──(mapper)──▶  domain Entities
   (frozen v1)                                    (generated)                    (freezed, ours)
```

- **Generated DTOs** live in `packages/qalam_api`. They mirror the wire exactly, including nullability
  and additive fields. They are regenerated when a new spec lands and are never edited by hand.
- **Domain entities** live in each feature's `domain/entities`. They are our stable, ergonomic value
  objects — often a *subset* or *reshaping* of a DTO (e.g. collapsing `author` DTO fields into an
  `Author` value object, converting ISO strings to `DateTime`, resolving image **keys** into a marker
  the presentation resolves to a CDN URL lazily).
- **Mappers** (`data/mappers`) are the **only** code that imports both a DTO and an entity. A mapper
  is a pure function; it is unit-tested with representative payloads (including nulls and unknown-
  field tolerance).

### 18.2 Mapping rules

1. **Ignore unknown fields.** Forward-compatibility with additive `v1` changes: a new response field
   the app does not consume is simply not mapped; it never errors.
2. **Timestamps** cross the wire as ISO-8601 UTC strings; mappers parse to `DateTime` in UTC and the
   presentation localizes for display. Never send/store local time.
3. **Enums** map to the mirrored `qalam_shared` enums by exact wire string; an unknown enum value maps
   to a safe default or an explicit `unknown` member (never crash) — again for additive tolerance.
4. **Image keys** (`avatarKey`, `coverImageKey`) are kept as keys in the entity; the CDN URL is built
   at render time via `core/media` (§35). The entity does not store a full URL.
5. **Content**: `pieces.content` is TipTap JSON; the mapper keeps it as a structured value the
   reading renderer consumes (§19), never as HTML.

### 18.3 Why not map DTOs straight to widgets?

Because the wire shape is frozen by someone else and reshaped by additive changes. A domain entity
insulates the UI from wire churn, lets us add computed/derived fields (relative time, resolved
direction, reading-time formatting) in one place, and gives value equality for Riverpod family keys.

---

## 19. Domain Entities

Domain entities are **immutable value objects** (`freezed`) that mirror the backend's *read-facing*
domain. They are the vocabulary the presentation and use-case layers speak. They mirror
`docs/04_DatabaseDesign.md`'s API-exposed shape and the `@qalam/shared` enums.

### 19.1 The core entities (and their key fields)

| Entity | Key fields (illustrative, camelCase) | Notes |
| --- | --- | --- |
| **User** | `id`, `email`, `username` (permanent), `isEmailVerified`, `status` | `status` ∈ active/suspended/deactivated |
| **Profile** | `userId`, `penName` (single), `bio`, `avatarKey`, `coverKey`, `websiteUrl`, `location`, `isPrivate`, `socialLinks`, `followersCount`, `followingCount`, `piecesCount`, `defaultLanguage` | one pen name; keys not URLs |
| **Author** (summary) | `username`, `penName`, `avatarKey` | embedded in cards/bylines |
| **Piece** | `id`, `authorId`/`author`, `title`, `subtitle`, `slug` (null until publish), `content` (TipTap JSON), `contentText`, `featuredQuote`, `coverImageKey`, `language`, `genre`, `status`, `visibility`, `scheduledAt`, `publishedAt`, `wordCount`, `readingTimeSeconds`, `stats` | draft & published are one entity distinguished by `status` |
| **PieceStats** | `viewsCount`, `readsCount`, `likesCount`, `clapsCount`, `bookmarksCount`, `commentsCount`, `responsesCount`, `sharesCount`, `trendingScore` | analytics read-model |
| **Language** | `code` (BCP-47), `nameEn`, `nativeName`, `direction` (ltr/rtl), `script`, `isActive` | drives dir + reading font |
| **Genre** | `slug`, `name`, `description` | taxonomy |
| **Tag** | `slug`, `name`, `piecesCount` | user-created via #hashtags |
| **Follow** | `followerId`, `followeeId`, `status` (pending/accepted) | pending = request to a private account |
| **Comment** | `id`, `pieceId`, `author`, `parentId`, `depth` (≤3), `body`, `editedAt`, `deletedAt` | threaded, soft-deletable node |
| **Notification** | `id`, `type`, `actor?`, `entityType?`, `entityId?`, `data` (denormalized render payload), `readAt` | in-app only; `data` avoids joins |
| **AnalyticsDaily / Dashboard** | `views`, `reads`, `readSeconds`, `completions`, `shares`, `likes`, `claps`, `followersGained`, `breakdowns` | writer dashboard source |
| **CollectionRef / ReadingListRef** | ids + titles + counts | curation (later M-track) |

### 19.2 Enums (mirror `@qalam/shared` exactly — the wire is authoritative)

`qalam_shared` mirrors these **by exact wire string** (Dart enums or sealed constants). Where the DB
design doc and the shipped `@qalam/shared` differ, **`@qalam/shared` wins** (it is the codegen source
and what the API returns):

- `PieceStatus`: `draft | scheduled | published | archived`
- `Visibility`: `public | unlisted | private`
- `Role`: `user | moderator | admin | super_admin`
- `FeedSort`: `latest | trending | most_clapped | most_discussed`
- `SearchType`: `all | pieces | writers | tags | genres | languages`
- `SearchSort`: `relevance | latest | trending | most_clapped | most_commented`
- `NotificationStatus`: `unread | read | archived`
- `NotificationType`: `follow | follow_request | follow_accepted | comment | comment_reply | like |
  clap | response | mention | repost | featured | collection_follow | system`
- `TextDirection`: `ltr | rtl`
- `FollowStatus`: `pending | accepted`
- `ThemePreference`: `light | dark | system`
- `WriterKind`: `featured | popular | new`
- `DiscoverPieceKind`: `featured | recent | most_clapped | most_discussed`
- `ShareChannel`: `internal | external | copy_link`
- `AnalyticsPeriod`: `daily | weekly | monthly`; `TrendType`: `pieces | writers | genres | tags`

### 19.3 Domain invariants encoded client-side (for UX only)

Mirrored in `qalam_shared` limits; the **server enforces authoritatively**:

- Username permanent, `^[a-z0-9_]{3,30}$`, 3–30 chars → never render an edit path.
- One pen name (1–50 chars). One language per piece (required at publish).
- Claps cap **50/user/piece** (`MAX_CLAPS_PER_USER_PER_PIECE`) → client clamps the batch delta.
- Comment depth ≤ 3; body 1–2000 chars. Title ≤ 200; subtitle ≤ 300; featured quote validated at
  280; ≤ 5 tags/piece. Password 10–128. Bio ≤ 500.
- Avatar ≤ 5MB, cover ≤ 10MB; accepted image types JPEG/PNG/WebP.

### 19.4 Content model

Piece content is **TipTap JSON** (`{ type: "doc", content: [...] }`). The reading renderer (M-track)
walks this tree and maps a **whitelisted** node/mark set to widgets: `doc, paragraph, text, heading
(2–4), blockquote, bulletList, orderedList, listItem, hardBreak, footnote`; marks `bold, italic,
underline`; attrs `paragraph.textAlign`, `footnote.id`, `mention.userId`, `hashtag.tag`. The client
renderer mirrors the server's whitelist as UX (the server is authoritative and rejects anything
outside it). **HTML is never rendered** — no WebView for content.

---

## 20. Use Case Layer

Use cases (interactors) live in `domain/usecases`. Each is a single-responsibility operation
expressed in domain terms (`PublishPiece`, `ToggleFollow`, `ClapPiece`, `LoadFeedPage`).

### 20.1 When a use case is required vs optional

- **Required** when an operation has real domain logic beyond a repository pass-through: multi-step
  orchestration, cross-repository coordination, client-side rule application (e.g. clamping a clap
  batch to the 50 cap, composing an idempotency key per publish intent, validating a piece is
  publish-complete before calling publish).
- **Optional (pass-through allowed, and documented)** when the presentation calls a single repository
  method with no added logic. In that case the provider may call the repository directly; introducing
  a trivial pass-through use case is permitted for symmetry but must not become ceremony. **State the
  choice in the feature's barrel doc comment** so reviewers know it is intentional.

### 20.2 Use case contract

- Pure orchestration; no I/O of its own (delegates to repositories).
- Returns a domain result (`Result<T>` / `Failure`), never a DTO or HTTP concept.
- Independently unit-testable with faked repositories.
- Callable from a Riverpod provider; the provider owns the `AsyncValue` presentation.

### 20.3 Examples of genuine use cases

| Use case | Logic that justifies it |
| --- | --- |
| `ClapPiece` | clamp requested claps to `min(requested, 50 − viewerClaps)`; batch a 600ms burst into one call |
| `PublishPiece` | verify completeness (title/genre/content) client-side; attach a per-intent `Idempotency-Key`; never optimistic |
| `ToggleFollow` | distinguish follow vs request-to-follow (private account → `pending`); optimistic label |
| `LoadFeedPage` | assemble tab+filters into the query; append page; stop at `hasMore == false` |
| `RecordReadProgress` | apply the read-completion definition (≥30s dwell AND ≥50% scroll) before beaconing |

---

## 21. Error Handling Strategy

Errors are **typed, mapped from `error.code`, and surfaced honestly**. The philosophy mirrors the
backend: domain errors carry a stable code; consumers switch on the code, never the message; nothing
is swallowed.

### 21.1 The two error types

- **`ApiException`** (`core/network`) — the transport/wire error the network layer throws:
  `{ code, message, status, details, requestId }`. `code` is a stable string (a server `ErrorCode`
  or a client-synthesized transport code). This type does **not** escape the data layer.
- **`Failure`** (`core/error`) — the **domain-facing sealed error** the repositories return and the
  presentation consumes. A sealed hierarchy the UI can pattern-match exhaustively:

```
sealed Failure
├── NetworkFailure        (offline, timeout, server-unreachable)      ← status 0 / 408 / 503
├── AuthFailure           (sessionExpired, invalidCredentials, ...)   ← 401 + auth codes
├── PermissionFailure     (forbidden, permissionDenied)               ← 403
├── NotFoundFailure       (missing or invisible)                      ← 404
├── ValidationFailure     (fieldErrors: List<FieldError>)             ← 400 VALIDATION_FAILED
├── ConflictFailure       (alreadyExists, alreadyPublished, ...)      ← 409
├── DomainRuleFailure     (scheduleInPast, clapLimit, selfFollow...)  ← 422 + domain codes
├── RateLimitFailure      (retryAfter)                                ← 429
└── UnexpectedFailure     (code, requestId)                           ← 500 / malformed / unknown
```

### 21.2 Flow

```
Dio → ErrorInterceptor → ApiException(code,…) → Repository catch → map to Failure → 
   → provider (AsyncError<Failure>) → widget pattern-matches Failure → design-system state widget
                                                                      → user-facing copy via error catalog
```

### 21.3 User-facing copy

Copy is **keyed by `error.code` / failure type** in a client-side error catalog (`core/error`),
never taken from `error.message` (developer-facing) and never hardcoded per screen. This is
localization-ready (a catalog swap later). Copy is literary and calm (`docs/41` voice): field errors
land inline on forms; code-only errors become a form-level banner; list/read errors become an error
state with a retry action.

### 21.4 Optimistic updates and rollback

For trivially reversible actions (like, clap, bookmark, follow), the provider applies an optimistic
delta immediately, then reconciles with the server response; on failure it **rolls back to the
snapshot** and shows a quiet toast. The recipe mirrors the web `useOptimisticMutation`: snapshot →
apply delta → on error rollback → on settled refresh the affected cache key. Publish/schedule/delete
are **never** optimistic.

### 21.5 What is never done

- Never `catch` and swallow. Catch only to translate to a `Failure` or to compensate (rollback).
- Never surface a raw exception or stack trace to the user.
- Never branch UI on `error.message`.
- Never show a misleading zero for a stat that is actually "unknown/not-yet-loaded" — render only
  real counts, hide or label placeholders (mirrors the web's profile-counter rule).

---

## 22. Exception Mapping

The exact `status`/`code` → `Failure` table. This is the single mapping the ErrorInterceptor +
repositories implement; nowhere else interprets HTTP.

### 22.1 Status → meaning (from the frozen API standards)

| Status | Meaning | Maps to |
| --- | --- | --- |
| 200 | success (GET/PATCH/action POST) | data |
| 201 | created | data |
| 204 | success, no body | void |
| 400 | malformed / validation / bad cursor | `ValidationFailure` (or reset cursor for `FEED_INVALID_CURSOR`) |
| 401 | credentials absent/invalid/expired | refresh (if `AUTH_TOKEN_EXPIRED`) else `AuthFailure` |
| 403 | identity known, answer is no | `PermissionFailure` (never retried) |
| 404 | absent or invisible to viewer | `NotFoundFailure` |
| 409 | state conflict | `ConflictFailure` |
| 410 | permanently gone (expired upload) | `NotFoundFailure`/`ConflictFailure` |
| 413 / 415 | media too large / unsupported | `DomainRuleFailure` (media) |
| 422 | valid shape, domain rule violated | `DomainRuleFailure` |
| 429 | rate limited | `RateLimitFailure(retryAfter)` |
| 500 | unhandled fault | `UnexpectedFailure(requestId)` |
| 503 | dependency down (search/storage) | `NetworkFailure` (retryable w/ backoff) |
| 0 (transport) | offline / network | `NetworkFailure(offline|networkError)` |

### 22.2 Code-level nuances the client must honor

- **401 handling:** only `AUTH_TOKEN_EXPIRED` triggers refresh-and-retry-once; `AUTH_TOKEN_INVALID`,
  `AUTH_REFRESH_REUSED`, `AUTH_SESSION_REVOKED` go straight to login.
- **Clap cap code is `CLAP_LIMIT_REACHED`** (422) — not `PIECE_CLAP_LIMIT` (that is a stale doc name).
- Engagement on a non-published piece is `PIECE_NOT_PUBLISHED` (409), not a 404.
- Private/invisible content returns **404, never 403** (existence not leaked) — the reading and
  profile screens treat 404 as "not found" with an exit, never "forbidden."
- `VALIDATION_FAILED` `details[]` entries are `{ field, rule, message }` with dot/bracket field paths
  (`profile.penName`, `tags[5]`) → map field errors onto the form's fields; a code-only error becomes
  the form banner.

### 22.3 Client-synthesized transport codes (mirror the web)

`API_TIMEOUT` (408), `API_OFFLINE` (status 0, when device offline), `API_NETWORK_ERROR` (status 0),
`API_MALFORMED_RESPONSE`, `API_UNEXPECTED_ERROR`. These are produced by the network layer for non-
enveloped transport failures and map to `NetworkFailure`/`UnexpectedFailure`.

### 22.4 Full server error-code catalogue (authoritative — mirror in `qalam_shared`)

Auth: `AUTH_INVALID_CREDENTIALS`, `AUTH_TOKEN_EXPIRED`, `AUTH_TOKEN_INVALID`, `AUTH_REFRESH_REUSED`,
`AUTH_SESSION_REVOKED`, `AUTH_EMAIL_TAKEN`, `AUTH_EMAIL_UNVERIFIED`, `AUTH_VERIFICATION_INVALID`,
`AUTH_EMAIL_ALREADY_VERIFIED`, `AUTH_RESET_INVALID`, `AUTH_PASSWORD_WEAK`,
`AUTH_CURRENT_PASSWORD_INVALID`, `AUTH_OAUTH_FAILED`, `AUTH_OAUTH_STATE_INVALID`,
`AUTH_ACCOUNT_SUSPENDED`. Users/profiles: `USER_NOT_FOUND`, `USER_USERNAME_TAKEN`,
`USER_USERNAME_IMMUTABLE`, `USER_PRIVATE_ACCOUNT`, `USER_CANNOT_FOLLOW_SELF`, `PROFILE_FORBIDDEN`,
`LANGUAGE_INVALID`, `GENRE_INVALID`. Follow: `FOLLOW_ALREADY_EXISTS`, `FOLLOW_REQUEST_PENDING`,
`FOLLOW_NOT_FOUND`, `FOLLOW_REQUEST_NOT_FOUND`. Pieces: `PIECE_NOT_FOUND`, `PIECE_FORBIDDEN`,
`PIECE_SCHEDULE_IN_PAST`, `PIECE_ALREADY_PUBLISHED`, `PIECE_NOT_PUBLISHED`, `PIECE_INVALID_TRANSITION`,
`PIECE_INCOMPLETE`, `PIECE_CONTENT_INVALID`, `PIECE_TAG_LIMIT_EXCEEDED`. Engagement:
`CLAP_LIMIT_REACHED`. Comments: `COMMENT_NOT_FOUND`, `COMMENT_FORBIDDEN`, `COMMENT_DEPTH_EXCEEDED`,
`COMMENT_DELETED`. Collections: `COLLECTION_NOT_FOUND`, `COLLECTION_NAME_TAKEN`,
`COLLECTION_PIECE_EXISTS`, `COLLECTION_PIECE_NOT_FOUND`, `COLLECTION_DEFAULT_IMMUTABLE`. Responses:
`RESPONSE_TO_SELF`, `RESPONSE_ALREADY_EXISTS`. Feeds: `FEED_INVALID_CURSOR`. Search:
`SEARCH_QUERY_TOO_SHORT`, `SEARCH_UNAVAILABLE`, `SEARCH_RECENT_NOT_FOUND`. Notifications:
`NOTIFICATION_NOT_FOUND`, `SYSTEM_NOTIFICATION_NOT_FOUND`. Moderation: `REPORT_NOT_FOUND`,
`REPORT_ALREADY_RESOLVED`, `REPORT_TARGET_NOT_FOUND`, `REPORT_SELF`, `REPORT_DUPLICATE`,
`REPORT_INVALID_RESOLUTION`, `APPEAL_NOT_ALLOWED`, `APPEAL_NOT_FOUND`, `APPEAL_ALREADY_EXISTS`,
`APPEAL_ALREADY_REVIEWED`. Media: `MEDIA_TYPE_UNSUPPORTED`, `MEDIA_TOO_LARGE`. Settings/flags:
`SETTING_NOT_FOUND`, `SETTING_NOT_EDITABLE`, `SETTING_INVALID_VALUE`, `FEATURE_FLAG_NOT_FOUND`,
`FEATURE_FLAG_ALREADY_EXISTS`. Infra/admin: `QUEUE_NOT_FOUND`, `JOB_NOT_FOUND`, `JOB_NOT_RETRYABLE`.
Cross-cutting: `RATE_LIMITED`, `VALIDATION_FAILED`, `UNAUTHORIZED`, `FORBIDDEN`,
`AUTH_PERMISSION_DENIED`, `NOT_FOUND`, `CONFLICT`, `INTERNAL_SERVER_ERROR`.

> The mobile app only *acts* on the subset relevant to reader/writer flows; the rest are mapped to
> generic failures. The list is kept complete in `qalam_shared` so a new additive code is a one-line
> addition, never a breaking surprise.

---

## 23. Offline Architecture

**Stance (from ADR §10):** offline **authoring / local-first sync is a permanent Non-Goal** until a
future product re-decision. The mobile app therefore implements **offline as graceful degradation of
reads**, not as an offline writing store.

### 23.1 What "offline" means for Qalam Mobile

- **Cached reads work offline.** Anything previously fetched (feed pages, opened pieces, profiles,
  notifications) is served from the Hive cache when the network is unavailable, clearly marked stale.
- **Writes require connectivity.** Publishing, editing a draft's saved state, following, clapping,
  commenting — all require a live connection. When offline, the action is disabled or fails fast with
  a `NetworkFailure` and an honest "you're offline" message; it is **not** queued for later sync in
  Phase 1.
- **Draft editing** is live-server-backed (autosave to `PATCH /pieces/:id`); it does **not** persist a
  local offline draft store in Phase 1. (The seam for a future local draft store is §42.)

### 23.2 The architecture

```
Repository.fetch(key):
   online?  ──yes──▶ network (cache-then-network) ─▶ update cache ─▶ fresh data (isStale=false)
      │
      └──no──▶ cache present?  ──yes──▶ cached data (isStale=true, offline banner)
                              └──no──▶ NetworkFailure(offline) → offline empty/error state
```

`isStale` / `isOffline` flags flow up as part of the read result so the presentation can show the
connectivity banner (`docs/41` offline UX) without the widget doing any network reasoning.

### 23.3 Why not offline writing now

The backend is not built for conflict-heavy offline sync (there is no sync protocol; drafts use
`updated_at` optimistic-concurrency with `PIECE_STALE_WRITE`, designed for a live client). Building a
local-first store now would be speculative complexity against a Non-Goal. The architecture instead
**leaves a clean seam** (§42) so offline writing can be added later as an additive capability without
reworking the layers.

---

## 24. Connectivity Handling

Connectivity is a first-class, observable piece of state.

- **`connectivityProvider`** (`core/connectivity`, `keepAlive`) wraps `connectivity_plus` and exposes
  an `online | offline` stream. It is *reachability-aware where possible* (connectivity ≠ actual
  server reachability), but treats "no interface" as offline and lets the network layer's transport
  failures (`API_OFFLINE`/`API_NETWORK_ERROR`) confirm true reachability.
- **On reconnect**, the app refetches **Live-tier** providers (feed, notifications, unread count) and
  retries any read that failed with `NetworkFailure` on the current screen. This mirrors the web's
  `refetchOnReconnect`.
- **UI**: a persistent, unobtrusive offline banner (`docs/41`) appears while offline; toasts and
  destructive actions are suppressed or degraded; the offline error screen (`/offline`) is the
  fallback for a cold start with no cache.
- The connectivity state also gates optimistic mutations: offline, an optimistic action fails fast
  rather than showing a success it cannot deliver.

---

## 25. Local Cache Strategy

The cache is a **read mirror of server state**, not a source of truth — the mobile analogue of
TanStack Query's cache. It makes the app instant and offline-tolerant; it never holds authoritative
domain state.

### 25.1 Cache keys

Cache keys mirror the web's hierarchical `query-keys.ts` factory so both clients reason about
invalidation identically. Keys are **data-shaped, not screen-shaped**:

```
feed:list:<tab>:<filtersHash>        pieces:detail:<id>
profiles:detail:<username>           me:drafts
profiles:followers:<username>        me:pieces:<status>
search:results:<type>:<q>:<filters>  notifications:list:<status>:<type>
discover:pieces:<kind>               notifications:unreadCount
analytics:dashboard                  taxonomy:genres | taxonomy:languages
```

A cache key doubles as the Riverpod family argument, so the provider identity and the cache entry
line up.

### 25.2 TTL tiers

Each key belongs to a freshness tier (matching §8.3): Live ~30s, Content ~5min, Identity ~1min,
Taxonomy ~1h. The local data source stamps `writtenAt`; the repository treats an entry older than its
tier as **stale** (still served for instant paint, then refreshed) and older than a **hard-expiry
multiple** as evictable. `gcTime`-equivalent: unused entries are pruned on a schedule / on box-size
pressure.

### 25.3 Invalidation

Every mutation documents which keys it invalidates (a mirror of the web's mutation→invalidation
table). Examples: publish invalidates `me:drafts`, `me:pieces`, `pieces:detail:<id>`, `feed:*`,
`profiles:*(me)`; follow invalidates `profiles:detail:<u>` + `feed:list:following`; notification
read/read-all invalidates `notifications:list:*` + `notifications:unreadCount`. Draft autosave
invalidates **nothing** (it writes back the detail entry directly to avoid thrash). Login/logout/
refresh-failure **clears the whole cache** (it is user-scoped).

### 25.4 What is and isn't cached

- **Cached:** list pages, entity details, taxonomy, profile, notifications, analytics snapshots.
- **Not cached:** cursors (opaque, transient), anything secret (tokens live in secure storage only),
  in-flight optimistic state (lives in the provider, reconciled to cache on settle).
- **Not cached — suggestion & recommendation lists**, which the "list pages" bullet above does _not_
  cover. Every one of them goes straight to the remote and keeps its result for the session only:
  AI recommendations, semantic search, search suggestions (`features/ai`, all `guardResult` with no
  cache write) and the reader's "More like this" (docs/48 §3.1). Two reasons, and they apply to any
  future surface of this kind: a cached suggestion offline is a link to a piece that is _not_ cached,
  so it offers the reader a dead end; and these surfaces are non-critical, so having nothing to show
  is a correct outcome rather than a degradation worth spending disk on.

---

## 26. Hive Architecture

Hive is the non-secret local store behind local data sources. It is registered once in `bootstrap`
and accessed only through `core/storage` + feature local data sources.

### 26.1 Boxes

One box per cache domain (or a small number of well-named boxes), not one giant box:

| Box | Contents |
| --- | --- |
| `cache_feed` | feed/discover pages by key |
| `cache_pieces` | piece detail by id |
| `cache_profiles` | profiles + follower/following pages |
| `cache_search` | search results / recent searches |
| `cache_notifications` | inbox pages + unread count |
| `cache_analytics` | dashboard / piece / trending snapshots |
| `cache_taxonomy` | genres / languages / tags |
| `prefs` | non-secret device preferences (theme mode, reading size, reduced-motion override, remember-me flag) |

### 26.2 What Hive stores and how

- Entries are **serialized entities (or DTOs) + a `writtenAt` timestamp** (for TTL). Prefer storing
  the mapped entity's JSON (via `freezed`/`json_serializable`) over registering many `TypeAdapter`s,
  to avoid adapter churn when entities evolve — the store is a cache, so a schema bump can simply
  clear the box.
- **Cache versioning:** a `cacheSchemaVersion` in `prefs`. On app upgrade with a bumped version,
  clear all `cache_*` boxes (never migrate a cache — refetch is cheap and always correct). `prefs`
  itself is migrated carefully (it holds user-visible device preferences).
- **Never store secrets in Hive.** Tokens go to `flutter_secure_storage` (§27). Hive is not
  encrypted by default; treat it as readable on a rooted device.

### 26.3 Lifecycle

Boxes are opened in `bootstrap` and provided as `keepAlive` providers. Corruption on open is handled
by clearing and recreating the box (cache is disposable). Box compaction runs per Hive defaults; large
list boxes cap the number of retained pages (§37).

---

## 27. Secure Storage Strategy

Secrets live **only** in `flutter_secure_storage` (iOS Keychain, Android EncryptedSharedPreferences).
This is mandated by the security architecture: mobile stores both access and refresh tokens in secure
storage (unlike web, which keeps access in memory + refresh in an httpOnly cookie).

### 27.1 What goes in secure storage

| Key | Value | Notes |
| --- | --- | --- |
| `access_token` | current access JWT | also mirrored in memory for the hot path; 15-min life |
| `refresh_token` | current rotating refresh token | replaced atomically on every refresh |
| `session_meta` (optional) | remember-me flag, last-user id hint | non-sensitive but session-scoped |

### 27.2 Rules

- **Access token in memory + secure storage; refresh token in secure storage only.** The in-memory
  copy is the hot-path source for the AuthInterceptor; secure storage is the durable copy for cold
  start.
- **Atomic rotation:** on refresh success, replace both tokens together; never keep a stale refresh
  token (presenting it later trips reuse detection and logs the user out).
- **Clear on logout / refresh-failure / logout-all** (`AUTH_SESSION_REVOKED`).
- **Never log a token** (§29 redaction). Never put a token in a URL, a Hive box, an analytics event,
  or a crash report.
- **Platform hardening:** Keychain accessibility set to `first_unlock_this_device` (not synced to
  iCloud); Android uses the encrypted implementation. Optional biometric/passcode gating of token
  access is a documented future hardening (§39), not Phase 1.

---

## 28. Environment Configuration

Configuration is typed, validated at boot, and injected via DI — never read ad hoc.

### 28.1 Flavors / environments

Three environments matching the platform: **development, staging, production**. Implemented as
**build flavors** (Android product flavors / iOS schemes) plus `--dart-define` values, resolved into
a typed `AppConfig` at boot. There is no runtime environment switching in release builds.

### 28.2 AppConfig keys

| Key | Meaning | Web analogue |
| --- | --- | --- |
| `apiUrl` | API origin; base becomes `{apiUrl}/api/v1` | `VITE_API_URL` |
| `cdnUrl` | media/CDN base for resolving image keys; empty → derive from `apiUrl` origin | `VITE_CDN_URL` |
| `appEnv` | development / staging / production | `VITE_APP_ENV` |
| `sentryDsn` | crash/error reporting DSN; empty → disabled | `VITE_SENTRY_DSN` |
| `enablePush` | feature flag: FCM/push (Phase 2 seam, default off) | — (new) |
| `xClient` | fixed `mobile` | (implicit) |

### 28.3 Rules

- `AppConfig` is loaded and **validated fail-fast in `bootstrap`** — a misconfigured build dies at
  launch with a readable error, not on the first API call (mirrors the web `env.ts` Zod validation).
- **No secrets in the app bundle** beyond public config (client ids, DSNs). API secrets never ship in
  a mobile app — the OAuth flow uses PKCE precisely because a mobile client cannot hold a secret.
- `.env.example` documents the required `--dart-define` keys; real values are injected by CI per
  environment, never committed.

---

## 29. Logging Strategy

Structured, leveled, **PII-redacted** logging — mirroring the backend's Pino redaction discipline.

### 29.1 Logger

A single `loggerProvider` (`core/logging`) wrapping a structured logger. Levels: `trace/debug/info/
warn/error`. **Verbose network/body logging is debug-only** and stripped from release builds.

### 29.2 Redaction (non-negotiable — mirror the backend redact list)

Never log: `authorization` header, any `token`/`accessToken`/`refreshToken`, `password`/
`currentPassword`/`newPassword`, OAuth `code`, and **emails** (partial-mask if ever needed:
`af***@s***`). Redaction is applied centrally in the logging interceptor and the logger's formatter,
not left to call sites.

### 29.3 Correlation

Log the `x-request-id` from each response so a mobile-side log line correlates with a backend log/
Sentry event. Surface the `requestId` in a support "details" affordance on error screens (matches the
web).

### 29.4 What to log

- Network: method, path (not query values that may carry PII), status, duration, `x-request-id`.
- Provider lifecycle + errors (via `ProviderObserver`) in debug.
- Navigation (route names) in debug.
- Handled `Failure`s at `warn`; unexpected exceptions at `error` (also routed to crash reporting).

---

## 30. Analytics Integration Strategy

Two distinct "analytics" concerns — keep them separate:

### 30.1 Product analytics beacons (the backend's `analytics_events`)

The app reports reading engagement to the **frozen** analytics endpoints so writer dashboards work:

- `POST /analytics/pieces/:id/view` — a view (server dedups per viewer/day; the client just fires).
- `POST /analytics/pieces/:id/read` — reports dwell + completion; the server applies the definition
  (**≥30s dwell AND ≥50% scroll = a completed read**). The `RecordReadProgress` use case computes and
  throttles this client-side before beaconing.

Rules: these beacons are **fire-and-forget** (a lost beacon is acceptable; they never block UI and
never surface errors), **coalesced/throttled** (never per-scroll-tick), and carry `deviceType`
derived from the platform. They do **not** go through the retry or refresh machinery aggressively —
best-effort only.

### 30.2 Behavioral/telemetry analytics (Firebase Analytics — optional)

Product usage analytics (screen views, funnels) via Firebase Analytics is **optional and Phase-2-
adjacent**. If adopted, it must respect the same PII discipline (no email/username/token in event
params) and be behind a config flag. It is **separate** from the server's `analytics_events` (which
is the writer-facing product metric, not app telemetry).

### 30.3 Abstraction

An `AnalyticsService` interface (`core/analytics`) with a no-op default and swappable implementations
(server beacons; optional Firebase) — so features call a single typed API and analytics providers are
overridable/disable-able per environment and testable.

---

## 31. Firebase Integration Strategy

Firebase is **optional infrastructure**, integrated behind interfaces so the app does not hard-depend
on it and so it can be disabled per environment.

| Firebase product | Use | Phase | Notes |
| --- | --- | --- | --- |
| **Crashlytics** | crash + non-fatal reporting | Phase 1 (optional) | `sendDefaultPii = false`; user context is **id only** (never email/username); mirrors the backend Sentry rule |
| **Cloud Messaging (FCM)** | push notifications | **Phase 2 seam** | Phase 1 notifications are in-app polling only (§32) |
| **Analytics** | behavioral telemetry | optional | §30.2 |
| **Remote Config / App Check** | future | later | not Phase 1 |

Rules: all Firebase access sits behind `core/` service interfaces; no widget or feature imports the
Firebase SDK directly. Initialization is in `bootstrap`, gated by config. Crash reporting must scrub
PII exactly like logging (§29). If Sentry (`sentryDsn`) is used instead of/alongside Crashlytics, the
same id-only, no-body-on-auth-routes discipline applies.

---

## 32. Push Notification Architecture

**Phase 1 reality:** the backend ships **in-app notifications only** — no email, no push (ADR §10).
Mobile Phase 1 therefore delivers notifications by **polling**, and leaves a clean seam for FCM push
in Phase 2.

### 32.1 Phase 1 — polling

- The notifications inbox (`GET /notifications`) is a Live-tier paginated provider.
- The **unread count** (`GET /notifications/unread-count`) is a small Live-tier polled provider
  (~30s), driving the badge (capped display "99+"/"9+" per `docs/41`). Polling backs off when the app
  is backgrounded and refreshes on resume/reconnect.
- There is a documented **SSE/stream seam** on the backend api-client; if the backend later exposes a
  stream, the notifications provider swaps its source with no UI change.

### 32.2 Phase 2 — FCM push (seam)

The architecture pre-places the seam so push is additive:

```
Device → FCM token → (additive endpoint, Phase 2: POST /devices or /notification-tokens)
Server → FCM → data message { route, entityId, ... }
App (foreground) → merge into notifications provider + local notification (§33)
App (background/tap) → deep link via router (§12.4) to the target route
```

When the backend ships the additive device-registration endpoint and server-side push, mobile adds:
a token-registration service (register on login, refresh on rotation, unregister on logout), an FCM
message handler, and payload→route mapping. **No architectural refactor** — it is a new `core/push`
service + a notifications-provider source. Until then, `enablePush` stays off.

---

## 33. Local Notification Architecture

Local (on-device) notifications via `flutter_local_notifications`, behind a `core/notifications`
service interface. Uses in Qalam:

- **Foreground presentation** of an incoming push (Phase 2) as a local banner when the app is open.
- **Scheduled reminders** — e.g. a reminder that a scheduled piece is about to publish, or a gentle
  "come back and write" nudge — strictly opt-in and preference-gated (`/settings/notifications`).
- Local notifications carry the same `route`+identifiers payload as push, so tapping deep-links
  through the router (§12.4).

Phase 1 scope is minimal (foreground/scheduled helper only); it is fully realized alongside FCM in
Phase 2. All scheduling respects the user's notification preferences and OS permission state, and
requests permission contextually (not on first launch).

---

## 34. File Upload Architecture

Uploads adapt to the frozen contract: **multipart to dedicated endpoints; there is no pre-signed-URL
flow in `v1`.** The server re-validates, re-encodes (stripping EXIF/GPS), stores to object storage,
and returns a **key** (not a URL).

### 34.1 Endpoints

| Endpoint | Field | Returns | Client cap |
| --- | --- | --- | --- |
| `POST /profile/avatar` | `file` | `{ key }` | 5MB effective |
| `POST /profile/cover` | `file` | `{ key }` | 10MB effective |
| `POST /pieces/:id/cover` | `file` | `{ key }` | 10MB (cover) |

### 34.2 Rules

- Multipart field name is **`file`**; **never set `Content-Type`** manually (the platform sets the
  boundary).
- Accepted types **JPEG / PNG / WebP**; validate type + size **client-side** before upload (fast
  fail), but expect the server to also reject with `MEDIA_TYPE_UNSUPPORTED` (415) / `MEDIA_TOO_LARGE`
  (413).
- Show **upload progress** (Dio `onSendProgress`). The upload path attaches the Bearer token but
  **bypasses the 401→refresh interceptor** (§15.5) — a 401 surfaces to the caller, which refreshes via
  a normal request and retries.
- The response `{ key }` is stored on the entity as a key; the CDN URL is built at render time (§35).
- Client-side **downscale/compress** large images before upload (respect the caps; reduce bandwidth).
- **Presigned/direct-to-storage is NOT a v1 mechanism** — do not build it. If the backend later adds a
  presigned ticket flow (the roadmap mentions a media rate tier), it is additive; the `FileUploadService`
  gains a variant then.

### 34.3 Service shape

A `FileUploadService` (`core/media` or `features/profile|writing` data) exposes `uploadAvatar`,
`uploadCover`, `uploadPieceCover`, each returning the storage key or a `Failure`, with a progress
stream. Cancellation is supported (Dio `CancelToken`) so leaving the screen aborts the upload.

---

## 35. Image Loading Strategy

Images are referenced by **storage key**, resolved to a CDN URL client-side, and cached.

### 35.1 Key → URL

`core/media` builds the URL from a key: `mediaUrl(key) = {cdnBase}/{key}`, where `cdnBase = cdnUrl ??
origin(apiUrl)` (trailing slashes stripped; an already-absolute `http(s)` key is returned as-is;
null/empty key → no image / placeholder). This mirrors the web `lib/media.ts`.

### 35.2 Loading + caching

- Use **`cached_network_image`** (or equivalent) for disk+memory caching, placeholder, and error
  widget.
- Provide **explicit dimensions / aspect ratios** to avoid layout shift (covers 2:1, avatars circular
  32/48/80 per `docs/41`).
- **Lazy-load** off-screen images; use appropriately sized variants where the CDN offers them.
- **Dark mode**: cover/hero images render at ~0.92 brightness in dark (a color filter), removed on
  focus — matching the web. Never invert user images.
- Placeholders are design-system skeletons (`docs/41`), not spinners.
- **Memory:** cap the image cache size and evict aggressively on memory pressure (§37); large lists
  use `cacheWidth`/`cacheHeight` to decode at display size, not source size.

### 35.3 Avatars / covers as content vs chrome

User content images (piece covers, avatars) route through `cached_network_image`. There is **no
WebView** anywhere — piece *content* is TipTap JSON rendered to widgets (§19.4), not HTML.

---

## 36. Performance Guidelines

Targets: smooth 60/120fps scrolling, cold reads under a second from cache, no jank on the reading
surface. The client also contributes to *server* scale by being frugal.

- **Lists are lazy and windowed.** All timelines use builder-style lazy lists over cursor pagination;
  never materialize a whole list. Prefetch the next page a screen-height before the end.
- **Const everything constructible.** Prefer `const` widgets; extract stable subtrees so rebuilds are
  localized.
- **Narrow provider subscriptions.** `select` to the exact field; never `watch` a whole large state
  object in a leaf widget.
- **Split heavy islands.** The reading renderer, the editor, and the analytics charts are heavy —
  build them as isolated widgets loaded when their route mounts (Flutter deferred loading where it
  pays off), so the feed/list paths stay light.
- **Parse off the UI thread.** Large TipTap documents and big JSON payloads are parsed/mapped in an
  isolate (`compute`) when they are large enough to jank a frame.
- **Debounce & coalesce.** Autosave debounces 2s; search debounces input; analytics beacons coalesce;
  clap taps batch into one call per 600ms burst.
- **Respect the wire.** Cursor pages of ≤50; honor `Retry-After`; single-flight refresh; never poll
  faster than the Live tier; back off polling when backgrounded.
- **Images decode at display size** (`cacheWidth`/`cacheHeight`); cap the image cache.
- **Avoid rebuild storms** from animations — animate with implicit/explicit animations on
  opacity/transform only (never layout), matching `docs/41` motion rules.
- **Measure.** Use the Flutter DevTools timeline + a startup-time budget; a route that regresses
  frame timing is a review-blocker.

---

## 37. Memory Management

- **`autoDispose` by default** (§8): screen providers free their state and cancel in-flight requests
  when the screen leaves. Only cross-cutting providers are `keepAlive`.
- **Dispose controllers**: scroll controllers, text controllers, animation controllers, `CancelToken`s
  are disposed/cancelled in the owning widget's dispose / provider's `onDispose`.
- **Bound the caches**: the image cache has an explicit size/entry cap; Hive list boxes retain a
  bounded number of pages per key (evict oldest); the query cache prunes unused entries (§25.2).
- **Paginate, don't accumulate unbounded**: a very long infinite list trims off-screen pages from
  memory (keeping them in Hive) so a 2,000-item scroll session does not hold 2,000 widgets/entities
  live.
- **Cancel on navigation**: leaving a screen cancels its in-flight network + uploads via
  `CancelToken`s tied to the provider lifecycle.
- **Watch for leaks**: `ProviderObserver` + DevTools memory view; a provider that should `autoDispose`
  but is kept alive by a stray listener is a bug to fix, not to work around with `keepAlive`.

---

## 38. Testing Strategy

Testing mirrors the backend/frontend discipline: **coverage floors on logic layers, behavior-first,
factories, mock-at-the-boundary-you-own.** Runner: `flutter_test` (+ `integration_test`/`patrol` for
e2e), `mocktail`/`mockito` for fakes.

### 38.1 What must be tested (mandatory)

| Layer | Test kind | Floor |
| --- | --- | --- |
| **Mappers** (DTO⇄entity) | unit, incl. null + unknown-field payloads | high — they guard the wire boundary |
| **Use cases** | unit with faked repositories | every happy + error path |
| **Repositories** | unit with faked remote+local sources; cache-then-network, offline, invalidation | every branch |
| **Notifiers / providers** | `ProviderContainer` with overridden repos; loading/data/error, optimistic rollback | behavior |
| **Error mapping** (status/code → Failure) | unit, table-driven | every mapped code |
| **`qalam_shared`** (mirrored constants/enums) | unit — values match the backend | exact-value assertions |
| **Guards / router redirects** | unit — auth/guest/verified, returnTo safety | every branch |

### 38.2 Widget & golden tests

- **Widget tests** for interactive widgets with logic (forms, clap button batching, feed card
  actions). Test behavior, not pixel snapshots — except:
- **Golden tests** are mandatory for the **design system** and specifically for **RTL/Nastaliq
  rendering** — the mobile analogue of the web's Nastaliq golden-sample screenshot-diff CI harness.
  Golden coverage: light/dark, LTR/RTL, each reading font/size, key components. A render regression in
  Urdu/Nastaliq is a build-blocker.

### 38.3 Integration / e2e

`integration_test` (or `patrol`) covers the critical flows end-to-end against a mocked or
staging backend: login → feed → open piece → clap; register → set username; write draft → autosave →
publish; offline read from cache.

### 38.4 Test discipline

AAA (Arrange–Act–Assert), one behavior per test, no logic in tests. Factories in `test/factories/`
build valid-by-default entities/DTOs; no shared mutable fixtures. Mock at the boundary you own
(notifiers mock repositories; repositories mock data sources; data sources mock Dio/`qalam_api`).
Time/uuid/random are injected (never call `DateTime.now()` directly in testable code) so tests are
deterministic.

### 38.5 CI gates

`flutter analyze` clean, `dart format` clean, tests green, coverage floor met on logic layers, golden
tests pass (incl. RTL). Mirrors the web DoD.

---

## 39. Security Architecture

The mobile security posture implements the frozen security architecture (`docs/13`) plus mobile-
specific hardening (flagged as extensions where the source doc did not specify them).

### 39.1 From the frozen contract (must comply)

- **Token storage:** access + refresh in secure storage (Keychain / EncryptedSharedPreferences);
  access also in memory for the hot path (§27). Never in Hive, logs, URLs, analytics, or crash
  reports.
- **`X-Client: mobile`** channel header on every request (enables body-refresh; keeps the server's
  channel model honest).
- **Rotating refresh + single-flight** (§15) — the single most important client security behavior;
  prevents self-inflicted family revocation and limits a stolen token's window to one rotation.
- **JWT is a UX hint only** — never verify signature client-side, never gate a security decision on
  decoded claims; the server is authoritative (§11.4).
- **TLS everywhere.** Send only the CORS-allowed header set the backend expects (`Authorization`,
  `Content-Type`, `X-Request-Id`, `X-Client`, `Idempotency-Key`).
- **Password policy** mirrored (10–128) for UX; server enforces breached-list + Argon2id.
- **PII discipline:** never log tokens, passwords, OAuth codes, or emails; crash-report user context
  is id-only, `sendDefaultPii = false`.
- **OAuth uses Authorization Code + PKCE**; Apple Sign-In is Phase 2 (seam ready).
- **Content safety:** render only the whitelisted TipTap node/mark set; no WebView for content; user
  strings are plain text; bidi-isolate usernames/URLs.

### 39.2 Mobile-specific hardening (extensions — flagged, tiered)

These are **not** in the source security doc; they are mobile additions. Tier them so Phase 1 is not
blocked:

| Hardening | Phase | Notes |
| --- | --- | --- |
| Secure storage with device-only Keychain accessibility | Phase 1 | no iCloud sync of tokens |
| Certificate pinning | Phase 1.5 / configurable | pin the API cert/public key in Dio; must have a rotation plan (pin the CA or 2 keys) to avoid bricking on cert rotation |
| Jailbreak / root detection | optional / later | soft signal (warn/limit), never a hard block that punishes false positives |
| Biometric / passcode gate on app open or token access | optional | user-preference; protects a stolen unlocked device |
| Screenshot/screen-recording protection on auth screens | optional | platform flags |
| Obfuscation (`--obfuscate --split-debug-info`) | release builds | standard release hardening |

Each extension is behind config/preference and documented as an addition to (not a contradiction of)
the frozen security architecture.

---

## 40. Future AI Integration Strategy (Phase 2)

AI is **entirely Phase 2** (ADR §10) and requires **no architectural refactor** — it is a new,
additive feature module.

- **Backend seam already exists:** an `ai` BullMQ queue is registered as a no-worker Phase-2
  placeholder; Phase 2 adds AI endpoints additively to `v1` (never breaking existing responses).
- **Mobile shape:** a new `features/ai/` module (domain/data/presentation) with its own repository
  over the future AI endpoints, plus AI affordances *composed into* existing screens (e.g. an assist
  action in the editor, AI-surfaced discovery in feed) via the design system — without editors/feed
  taking a dependency on `features/ai` internals (cross-feature coupling stays through the router /
  shared entities).
- **Async by nature:** AI operations may be long-running (queued server-side). The mobile pattern is
  a request that returns a job/handle, then a poll or (Phase-2) push/stream for the result — the same
  cache-then-refresh machinery, no new architecture.
- **Config-gated:** an `ai` feature flag (server feature-flags + client config) so AI can be dark-
  launched and rolled out per the platform's feature-flag system.

Because AI is additive and behind a flag, shipping it touches only the new module + a few composition
points — the layers, networking, auth, and error model are untouched.

---

## 41. Future Creator Economy Integration Strategy (Phase 2)

Payments / subscriptions / monetization are **entirely Phase 2** (ADR §10; no `plan` columns exist in
Phase 1 by design). The architecture accommodates them additively.

- **New `features/payments/` (or `monetization/`) module** with its own repository over future
  additive endpoints (subscriptions, entitlements, payouts).
- **Store billing** (Apple StoreKit / Google Play Billing, or an abstraction like RevenueCat) sits
  behind a `core/billing` service interface — the app never couples UI to a billing SDK. Server
  remains the authority on entitlement state; the client reads entitlements from an additive endpoint
  and gates premium UI as a hint (server re-checks).
- **Entitlement gating** reuses the same "capability as UX hint, server authoritative" pattern as
  PBAC (§11.4): the client may hide/show premium affordances, but access is enforced server-side.
- **Apple Sign-In** (needed for App Store policy alongside social login) is the same Phase-2 additive
  identity provider the auth flow is already built to accept (§14.4), zero refactor.
- **Config/flag-gated** rollout, like AI.

No layer, no networking, no auth change is required — creator-economy features are new modules +
additive endpoints + a billing service behind an interface.

---

## 42. Future Offline Writing Architecture (Phase 2+, gated on product re-decision)

Offline **writing/sync** is currently a **permanent Non-Goal** (ADR §10). This section defines the
**seam** so that if the product later approves it, no architectural rework is needed — it is purely
additive.

### 42.1 The seam already present

- Draft content is **TipTap JSON**, the same shape locally and on the wire — a local draft store would
  persist the identical structure.
- Drafts use **optimistic-concurrency on `updated_at`** with a `PIECE_STALE_WRITE` conflict signal —
  the backend already models the conflict a sync engine must resolve.
- The repository pattern (§16) already abstracts "where a draft lives"; adding a local draft source is
  a new data source behind the existing `PieceRepository`.

### 42.2 What a future offline-writing capability would add (and only that)

```
features/writing/data:
  + local_draft_data_source (Drift/Hive)      # durable local drafts
  + sync_engine (core/sync, new)              # queue local edits, replay on reconnect,
                                              #   resolve PIECE_STALE_WRITE (last-writer prompt / merge)
  + outbox pattern for queued publish/edit intents
presentation:
  + offline-draft indicators, conflict-resolution UI
```

### 42.3 Guardrails

- This is built **only after an explicit product re-decision** overrides the ADR Non-Goal, and with
  its own ADR (like AI).
- Until then, the app must **not** ship a partial local-first store — half an offline story is worse
  than none. Drafts remain server-backed with graceful offline degradation (§23).
- The seam is documented here so the temptation to "just add a little local draft cache" is resolved
  the right way: it goes through this design, not ad hoc.

---

## 43. Code Review Checklist

A PR is merge-ready only if every box is checked (the mobile Definition of Done):

**Architecture & layering**
- [ ] Feature-first structure respected; new code in the right feature + layer.
- [ ] No feature imports another feature; no `app/` import from a feature; domain imports nothing
      outward (no Flutter/Dio/Hive/`qalam_api`).
- [ ] No I/O or business logic in widgets; no Dio/DTO/status-code branching in presentation.
- [ ] Repository not bypassed; data source is the only place `qalam_api`/Dio/Hive is touched.
- [ ] No singleton / service locator; all wiring is Riverpod; correct `autoDispose`/`keepAlive`.

**Contract fidelity**
- [ ] DTOs are generated, not hand-written; mappers ignore unknown fields; timestamps UTC.
- [ ] Enums/limits/error-codes match `qalam_shared` (which matches `@qalam/shared`) exactly.
- [ ] Cursor pagination reads `meta.pagination`; only declared query params sent; booleans literal;
      arrays comma-joined.
- [ ] `X-Client: mobile` on requests; publish carries `Idempotency-Key`; only publish is retriable.

**Auth & security**
- [ ] Refresh is single-flight; tokens only in secure storage (+ in-memory access); atomic rotation.
- [ ] No token/password/email/OAuth-code in logs, URLs, analytics, or crash reports.
- [ ] JWT used as UX hint only; server-authoritative gating respected.

**State & errors**
- [ ] State classified into the right bucket (server/UI/session/form/URL).
- [ ] Errors mapped from `error.code` to `Failure`; user copy from the error catalog, not `message`.
- [ ] Optimistic updates only for reversible actions; rollback on failure; publish never optimistic.

**Design system & i18n**
- [ ] Uses design-system tokens/components (`docs/41`); no raw colors/sizes; works in light + dark.
- [ ] RTL correct (directional insets, per-content-direction); Nastaliq metrics honored; golden tests
      updated and passing.

**Quality**
- [ ] `flutter analyze` + `dart format` clean; no `dynamic`; no non-null `!` in production code.
- [ ] Tests added per §38 with coverage floor; deterministic (injected time/uuid).
- [ ] `openapi.json` regenerated if the spec changed; `qalam_api` diff reviewed.
- [ ] Conventional commit (scope `mobile`); self-reviewed.

---

## 44. Architecture Constraints

Hard constraints. Violations are review-blockers, not preferences.

1. **Never use singletons or service locators.** DI is Riverpod only.
2. **Never perform HTTP requests directly inside widgets.** All HTTP goes through `core/network` via a
   feature's data source, behind a repository.
3. **Never place business logic inside widgets.** Widgets render and delegate.
4. **Never let features directly depend on each other.** Cross-feature coupling only via router,
   shared entities, or cache keys.
5. **Never duplicate backend DTOs.** DTOs are generated from `openapi.json`; domain entities are ours.
6. **Never duplicate backend business rules.** Client rules exist only as UX mirrors of shared
   constants; the server is authoritative.
7. **Never bypass repositories.** Presentation → domain interface → repository → data source.
8. **Never bypass Riverpod.** No ad-hoc global state, no `InheritedWidget` for app state, no static
   mutable singletons.
9. **Never create circular dependencies.** The import graph is a DAG.
10. **Every feature must remain independently testable and deletable** (the `rm -rf` test).
11. **Strict Dart.** No `dynamic` at boundaries (parse to typed models immediately); explicit return
    types on public members; no non-null `!` in production code; exhaustive `switch` on sealed types.
12. **No raw colors/px/durations** in widgets — design-system tokens only (`docs/41`).
13. **RTL and both themes are day-one** for every screen touched.
14. **Additive-only against `v1`** — ignore unknown fields, send only declared params, never depend on
    undocumented behavior; a breaking need is escalated (it implies a `/api/v2`, which is a backend
    decision, not a mobile workaround).
15. **No offline write store** in Phase 1 (§42).
16. **No WebView for user content** — TipTap JSON renders to widgets.

---

## 45. Technical Debt Rules

- **Debt is explicit or it does not exist.** Any deliberate shortcut is a `// TODO(mobile-debt): …`
  with a tracked issue reference and a stated payoff condition. Silent shortcuts are bugs.
- **Contract gaps are documented, not hacked.** Known frozen-contract limitations (slug cold-load
  §12.3; no presigned upload §34; no push in Phase 1 §32; missing geo/device analytics on some admin
  surfaces) are recorded here and worked around cleanly (graceful fallback + a seam), never patched
  by guessing server behavior.
- **No speculative generality.** Do not build the offline-write engine, the push service, or the AI
  module before their phase — build the *seam* (documented) and stop.
- **Cache is disposable debt-free.** Never migrate a cache schema; bump the version and clear. Do not
  accumulate cache-migration logic.
- **Generated code is not debt to refactor.** Do not hand-tune `qalam_api`; if it is wrong, fix the
  spec/generator config and regenerate.
- **Debt has an owner and a trigger.** Each debt item names when it must be paid (e.g. "before M6,"
  "when `GET /pieces/by-slug` ships"). Debt without a trigger is deleted or done.
- **Lint/format debt is zero.** `analyze` warnings are not allowed to accumulate; the build stays
  green.

---

## 46. Quality Gates

Before any mobile work is considered done, and before M1 begins, these gates must hold. They also map
directly to the task's acceptance criteria.

| Gate | How it is satisfied |
| --- | --- |
| **Supports all planned mobile epics (M1–M10)** | The layering + networking + auth + design system in §1–§42 cover every M-track surface in §47; each epic is "a new feature module + routes," no architecture change. |
| **Compatible with the completed backend** | Consumes frozen `v1` byte-for-byte: envelope, `meta.pagination`, 69 error codes, cursor pagination, `X-Client: mobile` body-refresh, idempotent publish, multipart uploads, UTC timestamps, exact enum wire strings. DTOs generated from the same `openapi.json`. |
| **Compatible with the completed React app** | Same feature boundaries, same route vocabulary, same query-key/cache-invalidation model, same auth/refresh contract, same optimistic/staleness discipline, same shared `@qalam/shared` vocabulary — so behavior matches across clients. |
| **Compatible with the completed Admin app** | Mobile is the reader/writer surface only; admin remains web-only. Mobile never touches `/admin/*`; PBAC gating is a UX hint with the server authoritative, so no admin capability leaks and no conflict arises. |
| **Future AI requires no refactor** | §40 — additive `features/ai` + additive endpoints + flag; the `ai` queue seam already exists server-side. |
| **Future payments require no refactor** | §41 — additive `features/payments` + `core/billing` interface + additive endpoints; entitlement gating reuses the PBAC pattern; Apple login is the ready auth seam. |
| **Future offline writing requires no refactor** | §42 — the repository/TipTap-JSON/`updated_at`-conflict seam is in place; a future capability adds a local source + sync engine only, gated on a product re-decision. |
| **Future creator-economy features require no refactor** | §41 — same additive-module + billing-interface story. |

**Standing quality gates for every PR:** `flutter analyze`/`format` clean; tests green with coverage
floors (§38); golden tests incl. RTL/Nastaliq pass; both themes and both directions verified on
touched screens; conventional commit (scope `mobile`); `qalam_api` regenerated if the spec changed.

---

## 47. Mobile Epic Roadmap (M1–M10)

Mobile epics are **not defined anywhere in the existing docs** — this section defines them. They are
sequenced to follow the surfaces that actually exist server-side (auth → identity/social → writing/
publishing → reading → feeds/search → notifications/analytics), and to build the architectural
foundation before features. Each epic is *additive to the app* and touches only its own feature
module(s) + routes.

> Sequencing principle: **foundation first, then the personas** (Farheen the Urdu poet, Ravi the
> Hindi story-writer, Sana the multilingual reader/curator — `docs/01`), then polish. AI, payments,
> Apple login, and offline writing are **out of the M1–M10 core** (they are Phase-2 additive modules
> per §40–§42).

| Epic | Name | Scope | Depends on | Key surfaces / endpoints |
| --- | --- | --- | --- | --- |
| **M1** | Foundation & App Shell | Repo, flavors/config, DI (Riverpod), Dio + interceptors, envelope/error model, `qalam_api` codegen, `qalam_shared` mirror, Hive + secure storage, GoRouter shell + guards skeleton, design-system token layer + theming (light/dark, RTL scaffolding), logging, connectivity. **No product feature yet.** | — | `core/*`, `design_system/*`, health check against API |
| **M2** | Auth & Session | Login, register (permanent username, one-time confirm), Google OAuth (PKCE), email verification state, forgot/reset password, boot silent-restore, single-flight refresh, logout/logout-all, session notifier + guards live. | M1 | `/auth/*` |
| **M3** | Profiles & Follow Graph | Own + others' profiles (`/@handle`), edit profile (pen name, bio, links, avatar/cover upload), follow/unfollow, private-account follow requests, followers/following lists. | M2 | `/me`, `/users/:username`, follows, `/profile/avatar|cover` |
| **M4** | Feed & Discovery | Home feed (Following/Latest/Trending tabs), Discover (writers/pieces/tags/genres/languages), filters, cursor infinite scroll, cache-then-network, pull-to-refresh. | M3 | `/feed/*`, `/discover/*` |
| **M5** | Reading Experience | TipTap-JSON reading renderer (whitelisted nodes/marks, footnotes), per-script typography + RTL/Nastaliq metrics (golden-tested), chrome-recede, reading progress, analytics view/read beacons. | M4 | `GET /pieces/:id`, `/analytics/pieces/:id/view|read` |
| **M6** | Writing & Publishing | Editor (marks/lists/blockquote/footnotes/mentions/hashtags), autosave (debounced, `updated_at` conflict), drafts list, publish/preview/schedule sheet, cover upload, idempotent publish. | M5 | `/pieces`, `/me/drafts`, publish/schedule/cover |
| **M7** | Social & Engagement | Like, clap (batched, ≤50 cap), bookmark, comments + threaded replies (depth 3), responses, share, engagement counts; optimistic updates + rollback. | M5 | `/pieces/:id/likes|claps|bookmarks|comments|responses|shares`, `/comments/*` |
| **M8** | Search | Global grouped search, per-type results (pieces/writers/tags/genres/languages), autocomplete, trending, recent (server + local), query-state discipline. | M4 | `/search/*` |
| **M9** | Notifications & Activity | Inbox (filters, infinite), unread-count polling badge, mark read/read-all/archive/delete, preferences; SSE/push seam placed. | M3 | `/notifications*`, `/notification-preferences` |
| **M10** | Writer Analytics & Curation | Writer dashboard (`/me/stats`), per-piece analytics, growth series, charts (a11y + sr tables), export; collections/reading-lists curation surfaces (where endpoints exist); production hardening (cert pinning, obfuscation, crash reporting, QA/golden sweep, store readiness). | M6, M7 | `/analytics/*`, `/collections/*` |

**Phase-2 additive modules (post-M10, not part of the core M-track):** AI assist (§40), payments/
subscriptions + Apple Sign-In (§41), FCM push (§32), offline writing (§42) — each gated by a feature
flag and its own ADR, added as a new module with zero refactor of M1–M10.

---

*End of `40_MobileArchitecture.md`. Companion: `41_MobileDesignSystem.md`. Do not begin M1
implementation until this architecture is approved.*
