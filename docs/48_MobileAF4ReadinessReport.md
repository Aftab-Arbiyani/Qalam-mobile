# 48 — Mobile AF4 Readiness Report (Discovery / Search / Recommendation)

> ⚠️ **AMENDED BY D5, 2026-09-03** ([platfrom docs/48 §5.2](../../platfrom/docs/48_PlatformParityRegister.md#d5--the-ai-surface-is-removed-the-tools-stay-owner-2026-09-02)). **Ask My Book is deleted** — its backend routes already
> 404 (`7f3b459`), so `ask_book_screen.dart` and everything reaching it are broken on `develop`
> until mobile's M1 phase removes them (tracked as **D5-clients** in the register's §3.22a). The
> "Discover with AI" hub and the standalone AI Search screen go too: retrieval-backed search becomes
> the ordinary `/search` tab, **public** — the server no longer requires an account, a flag or
> `ai.use`, and there is no "AI answer". Story Explorer survives as **Story Map**, and it gains a
> "Map this story" action, which is the first way any client could ever build the graph it renders.
>
> ⚠️ One trap for whoever does M1: mobile's `AiFeatures.isEnabled` treats an **absent** flag as OFF,
> where web treats it as available. The server still seeds `feature.ai.semanticSearch.enabled` and
> `feature.ai.recommendations.enabled` purely so this screen does not go dark before M2 lands.

> **Status:** Flutter client **implemented + verified**. Consumes the completed AF4 backend
> (Retrieval Platform — `platfrom/docs/36`) with **no duplicated backend logic**: intent
> detection, query classification, retrieval planning, ranking, context assembly, and
> recommendation logic all live on the server; the app renders the structured, grounded
> responses and streams answers. Additive-only inside `lib/features/ai/` (the AF1/AF2 AI
> module); reuses `core/` (ApiClient, error mapping, Hive) and `shared/` (design system).

**Design law honoured:** Flutter is a presentation layer only. The backend is the source of
truth. The client never re-ranks, re-retrieves, or re-derives recommendations — it sends a
request through the reused `ApiClient` and renders what the Retrieval Platform returns.

---

## 1. Updated Flutter folder tree (AF4 additions, all in `lib/features/ai/`)

```
lib/features/ai/
├── domain/
│   ├── entities/
│   │   ├── retrieval.dart              # evidence, related entity, navigation target,
│   │   │                               #   ranking explanation, meta, SearchResultItem,
│   │   │                               #   SemanticSearchResponse, RecommendationItem/Response
│   │   ├── story_graph.dart            # StoryGraphNode/Edge, ExplorerViewResult (+toJson cache)
│   │   ├── ask_answer.dart             # AskCitation, AskBookAnswer, AskStreamEvent(+type map)
│   │   ├── saved_search.dart           # SavedSearch (+toJson mirror)
│   │   └── retrieval_json.dart         # tiny defensive JSON readers
│   ├── value_objects/
│   │   ├── retrieval_vocab.dart        # AskScope / ExplorerView / RecommendationKind (wire+label)
│   │   └── retrieval_requests.dart     # SemanticSearchRequest / AskBookRequest / RecommendationQuery
│   └── repositories/ai_repository.dart # + 9 AF4 methods (search/suggest/saved×3/ask/askStream/explorer/recs)
├── data/
│   ├── datasources/ai_remote_data_source.dart  # + AF4 endpoints (reuses ApiClient + streamSse)
│   ├── repositories/ai_repository_impl.dart     # + AF4 methods (guardResult / stream passthrough)
│   └── local/
│       ├── saved_searches_store.dart   # prefs-box mirror (clone of recents pattern)
│       ├── ai_search_history_store.dart# prefs-box recent AI queries
│       └── explorer_cache_store.dart   # cache-box last-viewed explorer pages
└── presentation/
    ├── controllers/
    │   ├── semantic_search_controller.dart    # RetrievalSession + results + suggestions
    │   ├── ai_search_history_controller.dart
    │   ├── saved_searches_controller.dart
    │   ├── recommendations_controller.dart
    │   ├── story_explorer_controller.dart     # cache-fallback
    │   └── ask_book_controller.dart           # streaming (reuses streamSse transport)
    ├── providers/retrieval_providers.dart     # the 3 store providers
    ├── screens/
    │   ├── ai_discovery_screen.dart           # hub: search bar + recommendation shelves
    │   ├── semantic_search_screen.dart        # search + suggestions + history + saved + results
    │   ├── story_explorer_screen.dart         # 8 graph views + interactive node sheet
    │   └── ask_book_screen.dart               # scope chips + streamed answer + citations
    └── widgets/
        ├── retrieval_cards.dart               # SearchResultCard, RecommendationCard
        ├── retrieval_widgets.dart             # EvidenceList, RelatedEntitiesRow, RankingLine
        ├── search_result_sheet.dart           # result detail (graph-node results)
        ├── story_node_sheet.dart              # node detail + tappable neighbours (graph walk)
        └── retrieval_navigation.dart          # NavigationTarget → route (interactive nav)
lib/core/network/api_paths.dart          # + /ai/search, /ai/ask[/stream], /ai/explorer, /ai/recommendations
lib/shared/domain/error_codes.dart       # + STORY_NOT_FOUND / RETRIEVAL_* / SAVED_SEARCH_*
lib/features/ai/presentation/support/ai_error_copy.dart  # + AF4 recovery copy
lib/app/router/{routes,app_router}.dart  # + aiDiscovery/aiSearch/aiExplorer(:storyId)/aiAsk(:storyId)
```

## 2. Screens implemented

- **AI Discovery hub** — a tap-through search bar + explainable recommendation shelves
  (Trending, For You / Personalized Feed, Continue Reading, Recommended Authors, Recommended
  Genres). Reachable from the AI conversations screen ("Discover with AI") and deep-linkable
  at `/ai/discovery`.
- **Semantic Search** — `QSearchField` → landing (recent + saved searches) → as-you-type
  **suggestions** (debounced) → ranked, grounded **results**. Each result card shows the
  structured object, summary, why-surfaced reason, a ranking line (relevance %), **related
  entities** (tap to navigate), and **expandable evidence/sources**. An "AI answer" toggle
  requests a grounded synthesis. Save-search flow. Covers natural-language + character / scene
  / chapter / location / timeline / event / relationship / dialogue / quote / concept / world.
- **Story Explorer** — segmented views over the knowledge graph: **Characters, Relationships,
  Timeline, Locations, Events, Objects, Concepts, Map**. Renders from graph node/edge objects;
  tapping a node opens a detail sheet with its facts, evidence, and **tappable neighbours**
  (walk linked entities). "Ask about this story" jumps to Ask.
- **Ask My Book / Ask Chapter** — scope chips (book/chapter/scene/character/timeline/
  relationship/world/theme/lore), a question field, a **streamed** answer (token-by-token) with
  a Stop control, and a cited **Sources** list. Errors surface via `AiErrorCopy` with retry.

## 3. Providers implemented (Riverpod code-gen)

`RetrievalSessionController` (search session UI state), `semanticSearchResults` (family),
`searchSuggestions` (family), `AiSearchHistoryController`, `SavedSearchesController` (local-first
+ server sync), `recommendations` (family), `explorerView` (family, cache-fallback),
`AskBookController` (streaming), plus the 3 store providers. Server state is repository-backed;
UI/session state is a notifier — never mirrored (docs 40 §8).

## 4. Repository integrations

All AF4 calls go through the **existing** `AiRepository` → `AiRemoteDataSource` → `ApiClient`
(no new API client). Endpoints: `POST /ai/search`, `GET /ai/search/suggestions`,
`GET|POST /ai/search/saved`, `DELETE /ai/search/saved/:id`, `POST /ai/ask`,
`POST /ai/ask/stream` (SSE), `GET /ai/explorer/:storyId/:view`, `GET /ai/recommendations`.
Auth (bearer), retry (GET), envelope unwrap, and `ApiException → Failure` mapping are all
inherited. Streaming reuses `ApiClient.streamSse` + a `CancelToken` (cancelling the stream
aborts the request); the Ask stream maps `sources → start → delta* → done|error`.

## 5. Navigation summary

Full-screen, session-gated routes under `/ai` (already `isProtected`): `aiDiscovery`,
`aiSearch`, `aiExplorer/:storyId`, `aiAsk/:storyId`. Interactive navigation between linked
entities: a `NavigationTarget` maps to a route by kind (`piece → /p/:id`, `author →
/u/:username`, `genre/tag → /discover`); graph-node targets open an in-place detail sheet whose
neighbours re-open the sheet (graph walk). Cross-feature coupling is router-name only — no
feature imports another feature.

## 6. Test coverage

**20 AF4 tests, all green** (`test/features/ai/`): entity parsing + defensive tolerance +
`toJson` round-trip (`retrieval_entities_test`); the 3 offline stores over real Hive boxes
(`retrieval_stores_test`); controllers/providers — semantic search, **Ask streaming**
(accumulation + citations + error), saved searches, recommendations, explorer, retrieval
session (`retrieval_controllers_test`); result/recommendation card rendering + tap
(`retrieval_cards_test`); the Explorer screen rendering + **interactive node sheet** + empty
state (`story_explorer_screen_test`). The shared `FakeAiRepository` gained AF4 canned responses
+ recorded inputs.

## 7. Manual testing guide

1. Run the AF4 backend (`platfrom`, `docs/36` §15) with a provider key; enable
   `feature.ai.enabled` + `feature.ai.semanticSearch|recommendations|askBook.enabled`.
2. Build the app with AI on: `flutter run --dart-define=QALAM_ENABLE_AI=true` (else the AF4
   surfaces show a calm "AI is off" state).
3. Open **AI conversations → Discover with AI** (or deep-link `/ai/discovery`). Confirm the
   recommendation shelves populate and cards show a "why" reason.
4. Tap the search bar → type a query → confirm suggestions, then submit → ranked results with
   evidence (expand Sources), related-entity chips, and a relevance line. Toggle "AI answer" for
   a grounded synthesis. Save the search; reopen search to see it under **Saved**; recents appear
   under **Recent**.
5. Deep-link `/ai/explorer/<pieceId>` (a story with an analysed graph). Switch views; tap a node
   → detail sheet; tap a **Connected** neighbour to walk the graph. Tap the chat icon → Ask.
6. On `/ai/ask/<pieceId>`, pick a scope, ask a question → watch the answer stream, then the
   **Sources** list. Tap **Stop** mid-stream. Disable a flag on the server → the ask surfaces a
   graceful "turned off" message; go offline → the last-viewed explorer renders from cache.

## 8. Confirmation — no duplicated backend logic

Flutter fully consumes the completed AF4 backend and **duplicates none of it**. Search,
ranking, retrieval, recommendation, and graph-traversal logic all execute server-side; the
client sends a request via the reused `ApiClient` and renders the returned structured objects
(results, evidence, ranking explanations, recommendation reasons, graph nodes/edges). The AF4
client is additive inside `lib/features/ai/`, reuses AF1/AF2's network + streaming + error +
markdown stack unchanged, and follows the existing design system, offline (cached-reads-only),
accessibility (semantic labels, live-region streaming, ≥44px targets, reduce-motion), and
Riverpod conventions.

**Verification:** `flutter analyze` — 0 issues; **20/20 AF4 tests pass** (full suite green
except 2 pre-existing `comment_tile` golden diffs, unrelated — see docs/47); `flutter build apk
--release` — success (66.9 MB). React frontend + admin remain follow-up seams.
