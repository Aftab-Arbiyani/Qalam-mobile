# 43 — Mobile Readiness Report (Epic M3: Home Feed & Reading Experience)

> **Scope:** M3 — the complete **Home Feed** and **Reading Experience** for Qalam Mobile,
> built additively on the M1 foundation and M2 auth. Governing docs:
> `docs/40_MobileArchitecture.md`, `docs/41_MobileDesignSystem.md`. Backend `v1` is frozen;
> this epic only *consumes* existing endpoints — no API was invented or mocked.
> **Toolchain:** Flutter 3.44 · Dart 3.12.
>
> **Naming note.** The user-facing epic "M3" here combines what `docs/40 §47` numbers as
> M4 (Feed & Discovery) + M5 (Reading) + the reader-facing slice of M7 (like/bookmark/
> follow/share/report — **no comments, no claps** this epic). The user brief is authoritative
> for scope.

---

## 1. Folder tree (as built)

```
lib/
├── core/
│   ├── reading_history/                 # cross-cutting device reading history (feed reads, reader writes)
│   │   ├── reading_history_entry.dart          (freezed entity + json)
│   │   ├── reading_history_store.dart          (Hive-backed store; only toucher of the reading box)
│   │   └── reading_history_controller.dart     (keep-alive notifier + continue/recent selectors)
│   ├── storage/  (+ reading box wired in hive_boxes/bootstrap/di)
│   ├── config/app_config.dart           (+ webUrl / shareBaseUrl for share links)
│   └── utils/json_read.dart             (tolerant wire readers for mappers)
├── shared/
│   ├── domain/entities/  author.dart · taxonomy.dart  (cross-cutting value objects)
│   ├── data/entity_mappers.dart         (shared wire→entity mappers: author/language/genre/tag)
│   ├── util/relative_time.dart          (relative + readable dates)
│   └── widgets/content/  author_byline.dart · reading_progress_bar.dart
├── features/feed/                        # ALL feed tabs + discovery (one feature, shared infra)
│   ├── domain/  entities/(piece_summary, writer_summary, trend_item, bookmark_item, cached_page)
│   │            · repositories/feed_repository.dart · value_objects/feed_query.dart (FeedTab, FeedQuery)
│   ├── data/    mappers/feed_mappers · datasources/(feed_remote, feed_local) · repositories/feed_repository_impl
│   └── presentation/
│        ├── providers/feed_providers.dart
│        ├── state/paged_list_state.dart        (PagedListState<T> + FeedPaginator<T> — the shared engine)
│        ├── controllers/(feed_list_controller [family:FeedTab], bookmarks_controller, discovery_controllers)
│        ├── widgets/(paged_feed_view, piece_card, feed_skeleton_list, piece_feed_tab,
│        │           bookmarks_tab, bookmark_card, history_tab, history_card, discovery_widgets)
│        └── screens/(feed_screen, discover_screen)
└── features/reading/                     # the reader
    ├── domain/  content_parser.dart · entities/(content_node, piece_detail, piece_engagement, writer_profile)
    │            · repositories/(reading_repository, engagement_repository) · value_objects/reader_preferences
    ├── data/    mappers/piece_mappers · datasources/(piece_remote, piece_local, engagement_remote)
    │            · repositories/(reading_repository_impl, engagement_repository_impl)
    └── presentation/
         ├── providers/reading_providers.dart
         ├── controllers/(piece_detail, engagement, writer_profile, reader_preferences)
         ├── widgets/(content_renderer, quote_card, reader_author_card, reader_action_bar,
         │           reader_settings_sheet, reader_report_sheet)
         └── screens/reading_screen.dart
test/  features/feed/* · features/reading/* · core/reading_history/* · support/(fake_feed/reading repos)
```

64 new hand-written source files + 32 test files (208 hand-written `lib` sources total).

## 2. Feed architecture

One **shared feed infrastructure** serves every feed type — the epic's "no duplicated feed
code" rule is met by construction:

- **`PagedListState<T>`** — the generic accumulated-list state (items, cursor, hasMore,
  isLoadingMore, isStale, loadMoreFailure).
- **`FeedPaginator<T>`** — the single pagination engine: `first()` (throws `Failure` → the
  provider surfaces `AsyncError`), `next()` (append / end-of-list no-op / capture load-more
  failure). No per-feed pagination code exists anywhere else.
- **`FeedRepository` + `_load<T>()`** — one cache-then-network engine drives all 7 surfaces
  (4 feeds, 3 discovery lists + bookmarks): page-1 caches items and falls back to the cached
  page (marked stale) on failure; later pages are network-only (cursors are never cached).
- **`FeedListController` (family: `FeedTab`)** — one controller for Following / For You /
  Trending / Latest. `bookmarksController` reuses the same engine over `/me/bookmarks`.
- **`PagedFeedView<T>`** — the single feed UI: skeleton → error (retry) → empty →
  infinite `QPagedListView` with pull-to-refresh; a load-more failure is a quiet toast, not a
  full error state.
- **Home Feed** (`feed_screen.dart`): a scrollable tab bar — **For You · Following · Trending ·
  Latest · Bookmarks · Reading History** — landing on For You (public). Following/Bookmarks
  gate to a calm sign-in prompt when signed out. A compass action opens Discovery.

## 3. Reading architecture

- **`reading_screen.dart`** — an immersive, chrome-receding reader: cover **hero**, rich
  typography (per-script size + line-height + direction), author card, meta (date · read time ·
  genre · language), featured **QuoteCard**, TipTap content, tags; a 2px reading-progress bar;
  a bottom action bar. Owns its own error boundary (404 → "not available"; else retry) and
  shows a stale banner when served from cache offline.
- **TipTap-JSON renderer** (`content_parser.dart` → `content_node.dart` → `content_renderer.dart`):
  the raw `pieces.content` map is parsed once into a typed, exhaustively-matchable tree, then
  rendered to native widgets — **never a WebView, never HTML**. Whitelist mirrors the server:
  `paragraph, heading(2–4), blockquote, bulletList, orderedList, listItem, text, hardBreak,
  footnote, mention, hashtag`; marks `bold/italic/underline` (italic suppressed for Urdu).
  Unknown nodes degrade gracefully (block → subtle placeholder; inline → skipped) — additive-safe.
- **Media handling:** body content has **no image node** in `v1` (confirmed against the
  sanitizer) — the only image is the top-level cover (hero). Inline "quotes" = the top-level
  `featuredQuote` (QuoteCard); block quotes = the `blockquote` node; lists = bullet/ordered;
  basic rich text = the whitelisted marks. Unsupported content is handled gracefully.
- **Reusable for every content type:** the reader takes only a piece id; nothing is
  piece-type-specific, so future content kinds reuse it unchanged.

## 4. State management summary (Riverpod only, no global mutable state)

| State | Kind | Owner |
| --- | --- | --- |
| Feed pages (4 tabs) | server | `feedListController` family (`AsyncValue<PagedListState>`) |
| Bookmarks feed | server | `bookmarksController` |
| Discovery shelves | server | `discoverPiecesShelf` / `discoverWritersShelf` / `trendingTagsShelf` |
| Piece detail | server | `pieceDetailController` (family: id) |
| Engagement (counts + viewer) | server + optimistic | `engagementController` (family: id) |
| Writer profile (author card) | server + optimistic | `writerProfileController` (family: username) |
| Reading history / continue / recent | client (device) | `readingHistoryController` (keep-alive) + selectors |
| Reader preferences | client (device) | `readerPreferencesController` (keep-alive) |
| Theme | client (device) | `themeModeController` (existing) |

Repositories are bound to interfaces via one-line providers; everything is overridable for tests.

## 5. API integration summary (frozen `v1`, consumed only)

| Capability | Endpoint |
| --- | --- |
| Following / Latest / Trending feeds | `GET /feed/{following,latest,trending}` |
| **For You** | `GET /feed/discover` (author-diverse; no dedicated for-you endpoint exists) |
| Discovery pieces / writers / tags | `GET /discover/{pieces,writers,tags}` (`?kind=`) |
| Bookmarks feed | `GET /me/bookmarks` |
| Piece detail | `GET /pieces/:id` (UUID; public + optional-auth) |
| Engagement counts + viewer flags | `GET /pieces/:id/engagement` |
| Like / Unlike | `POST` / `DELETE /pieces/:id/likes` |
| Bookmark / Unbookmark | `POST` / `DELETE /pieces/:id/bookmarks` |
| Share | `POST /pieces/:id/shares` (`copy_link`) |
| Follow / Unfollow | `POST` / `DELETE /users/:id/follow` |
| Author profile (card) | `GET /users/:username` |
| Report | `POST /reports` |
| View / read beacons | `POST /analytics/pieces/:id/{view,read}` |

**Contract-reality decisions** (no invented endpoints): "For You" → `/feed/discover`;
**Continue Reading / Recently Read** are local (no backend reading-history surface exists —
"synchronize where supported" ⇒ local only); "Recommended" → `/discover/pieces?kind=most_clapped`;
"Trending Writers" → `/discover/writers?kind=popular`. Follow needs the author **user id**,
which the piece response lacks — so the Author Card fetches `GET /users/:username` for the id +
avatar + follow relation. **Write Response / Quote are navigation-only** (editor is a later epic);
Quote has no `v1` endpoint.

## 6. Offline cache strategy

- Cache-first through the Hive `cache` box (`CacheStore` + TTL tiers). Page-1 of every feed/
  discovery surface and every opened piece/engagement/profile are cached; a fetch failure while
  offline serves the cached copy **marked stale** (banner shown), else a `NetworkFailure`.
- Cursors are never cached (opaque); offline lists can't paginate (correct degradation).
- **Reading history + last position + preferences live in dedicated device storage** — fully
  available offline; the reader resumes from the saved position with no network.
- Cache is disposable (schema-bump clears it); the reading box is user data (never wiped on a
  bump), cleared on logout for device privacy. `explicit_to_json` guarantees entities round-trip
  correctly through any cache backend.

## 7. Reader preferences implementation

`ReaderPreferences` (font size S/M/L, line-height compact/normal/relaxed, reading width
narrow/medium/wide) is a pure value object persisted per-device via `PreferencesStore` and
applied **live**. Font size and line-height are **per-script**: Latin 18/20/22 vs Nastaliq
20/22/24, base leading 1.7 Latin / 2.1 Nastaliq scaled by the multiplier and **clamped so Urdu
never drops below 2.0** (docs/41 §4.4). Width caps the reading column on tablets/landscape;
phones render full-width-minus-gutter. Theme (light/dark/system) is surfaced in the same reader
settings sheet (owned by `themeModeController`). All persist across restarts and logout.

## 8. Performance optimizations

Cursor pagination with prefetch (`QPagedListView` triggers load a screen-height early);
`const` widgets throughout; narrow provider subscriptions; kept-alive feed tabs preserve scroll
+ pages; TipTap parsed **once** per piece (cached in state, not re-parsed on rebuild); images via
`cached_network_image` with explicit aspect ratios (no layout shift); scroll-progress via a
`ValueNotifier` (only the 2px bar rebuilds, not the page); autosave of reading position is
debounced (1.2s) and dwell time accrued once at session end; analytics beacons are
fire-and-forget; discovery shelves load first-page-only and hide on empty/error.

## 9. Test coverage

**155 tests pass** (49 new for M3). New logic-layer + widget + golden coverage:

- **Content parser** (7) — nodes/marks, heading clamp, lists, footnote/mention/hashtag, unknown/
  null/malformed tolerance, link-mark drop.
- **Mappers** (11) — feed + piece/engagement/profile wire→entity, nulls, unknown-enum fallback.
- **Reader preferences** (6) — per-script px, line-height scaling, Nastaliq ≥2.0 floor, wire round-trip.
- **Reading history** (6) — record/merge, continue vs recent, completion stickiness, offline card
  fields, remove/clear.
- **Feed paginator** (6) — first/next/append/end-of-list/error capture/stale.
- **Feed repository** (4) — cache-then-network, offline fallback (stale), no-cache failure, later-page failure.
- **Engagement controller** (6) — optimistic like/unlike/bookmark + reconciliation + rollback + share.
- **Widget** (2) — PieceCard render; ReadingScreen render + view beacon + action bar.
- **Golden** (2) — content renderer LTR + **RTL (Nastaliq layout)** — the mandated RTL golden.

## 10. Manual testing guide

1. **Feed loading / pagination / pull-to-refresh:** open the app → For You loads; scroll to the
   bottom → next page prefetches; pull down → refreshes. Repeat on Trending / Latest.
2. **Following gate:** signed out, tap **Following** / **Bookmarks** → sign-in prompt. Sign in →
   real content.
3. **Reading:** tap any card → reader opens (cover hero from history/discovery cards); scroll →
   top chrome recedes, progress bar fills; leave and reopen → resumes at last position.
4. **Reader preferences:** tap the "Aa" icon → change size / spacing / width / theme → the prose
   reflows live; reopen the app → settings persisted.
5. **RTL:** open an Urdu piece → right-to-left prose, Nastaliq line-height, no italics.
6. **Social:** like / bookmark → instant (optimistic) with haptics; share → link copied; ⋯ →
   Report (reason sheet), Write a response / Quote → navigates to the write surface.
7. **History / Continue Reading:** partly read a piece → it appears under **History** and the
   **Continue Reading** shelf in Discover with a progress bar; Clear empties it.
8. **Offline:** enable airplane mode → previously-opened feeds/pieces still render with an
   "offline / saved copy" indicator; a cold, never-cached surface shows the offline empty state.
9. **Discovery:** compass icon → shelves (Featured / Recommended / Popular & Featured writers /
   Trending tags); pull to refresh.

## 11. Reusability confirmation

- **Feed:** `PagedListState<T>` + `FeedPaginator<T>` + `PagedFeedView<T>` + the repository's
  generic `_load<T>()` are type-generic and endpoint-agnostic. A future timeline (search results,
  notifications, comments, followers) reuses them by supplying a fetch callback + item widget —
  **no new pagination/caching/UI code**. `FeedTab` extends to new tabs by adding one enum value.
- **Reading:** the reader takes only a piece id and renders any whitelisted TipTap content;
  new content types/nodes slot into `content_parser` + `content_renderer` with a graceful default
  for anything unknown — the reading screen is unchanged.
- **Reading history / preferences** live in `core`/`shared`, already consumed by two features,
  ready for any future surface.

---

## Quality gates

| Gate | Status |
| --- | --- |
| `flutter analyze` — zero issues | ✅ `No issues found!` |
| `flutter test` | ✅ 155 passing |
| `dart format` — clean | ✅ `--set-exit-if-changed` clean |
| No warnings / TODOs / dead code | ✅ |
| No duplicated feed code / reader widgets | ✅ (one shared feed engine + one reader) |
| Offline reading / infinite scroll / pull-to-refresh | ✅ verified (tests + manual) |
| Reading preferences persist | ✅ |
| Production build succeeds | ✅ `app-release.apk (58.4MB)` |

**Verdict: M3 is complete and production-ready.** The feed and reading infrastructure is
reusable by future mobile epics with no refactor. **Stop after M3 — M4 is not begun.**
