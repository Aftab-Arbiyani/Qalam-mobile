# 44 — Mobile M4 Readiness Report (Writing & Publishing)

> **Epic M4 — the mobile writing experience.** Create / edit / draft / publish /
> schedule / preview pieces, with autosave, offline drafts, and background draft
> synchronization. Additive to `mobile/` only; integrates with the frozen `v1`
> backend byte-for-byte (no mocked/invented APIs). Companion: `40_MobileArchitecture.md`,
> `41_MobileDesignSystem.md`, `43_MobileM3ReadinessReport.md`.

**Status:** ✅ Complete. `flutter analyze` clean · `dart format` clean · **216 tests
pass** (61 new) · release APK builds (`app-release.apk`, 62 MB).

---

## 1. Folder tree (new/changed)

```
lib/features/writing/
├── writing.dart                         # barrel: DraftsScreen, EditorScreen, PreviewScreen
├── domain/
│   ├── editor/
│   │   ├── marked_text.dart             # inline text + bold/italic/underline ranges (edit-mapped)
│   │   ├── editor_block.dart            # EditorBlockType + EditorBlock (id, type, MarkedText)
│   │   ├── editor_document.dart         # List<EditorBlock> + split/merge/insert/remove/wordCount
│   │   └── tiptap_codec.dart            # EditorDocument ⇄ TipTap JSON (server-whitelisted shape)
│   ├── entities/
│   │   ├── draft.dart                   # editable aggregate (freezed+json, Hive-persisted)
│   │   ├── draft_summary.dart           # lightweight drafts-list row
│   │   └── draft_sync.dart              # DraftSyncState / DraftIntent / ConflictResolution
│   ├── value_objects/
│   │   ├── draft_validation.dart        # client-side publish-readiness (mirrors PIECE_INCOMPLETE)
│   │   └── editor_preferences.dart      # font size / line height / width / surface / autosave
│   └── repositories/
│       ├── piece_editor_repository.dart # authoring boundary (create/update/publish/schedule/…)
│       └── editor_taxonomy_repository.dart
├── data/
│   ├── mappers/piece_write_mappers.dart # Draft ⇄ Create/Update DTO + PieceResponseDto merge
│   ├── datasources/
│   │   ├── piece_editor_remote_data_source.dart   # HTTP over ApiClient (incl. multipart cover)
│   │   ├── editor_taxonomy_remote_data_source.dart
│   │   └── draft_local_data_source.dart # Hive `drafts` box (offline-first store + outbox)
│   ├── repositories/
│   │   ├── piece_editor_repository_impl.dart
│   │   └── editor_taxonomy_repository_impl.dart
│   └── sync/draft_sync_engine.dart      # outbox drain, conflict detection, reconnect retry
└── presentation/
    ├── providers/writing_providers.dart # DI + keep-alive sync engine + revision/cover-progress
    ├── controllers/                     # current_draft, draft_list, editor_prefs, taxonomy, editor_state
    ├── editor/                          # rich_text_controller, block_editor, formatting_toolbar, selection
    ├── widgets/                         # cover_field, metadata_section, publish_sheet, prefs_sheet, status_chips
    └── screens/                         # editor_screen, drafts_screen, preview_screen

core/ changes: network/api_client.dart (+upload), network/api_paths.dart (+authoring paths),
media/cover_image_picker.dart (new), storage/hive_boxes.dart (+drafts box),
storage/preferences_store.dart (+editor prefs), di/providers.dart (+draftsBox, +coverImagePicker),
bootstrap.dart (+drafts box wiring). app/router: routes.dart + app_router.dart (editor routes).
pubspec.yaml: +image_picker. ios/Runner/Info.plist: +photo/camera usage descriptions.
```

## 2. Editor architecture

- **Hand-rolled, block-based editor** whose internal model *mirrors the backend
  TipTap schema* (per the approved decision — no `flutter_quill`, no foreign
  document model). The document is `EditorDocument` = ordered `EditorBlock`s; each
  block is one `EditorBlockType` (paragraph, heading 2–4, blockquote, bullet/ordered
  list) carrying `MarkedText` (text + bold/italic/underline ranges). **The model is
  structurally incapable of producing a node/mark the server rejects** (422
  `PIECE_CONTENT_INVALID`).
- **Rendering/editing bridge:** `RichTextEditingController extends TextEditingController`
  overrides `buildTextSpan` to paint marks and maps mark ranges through every edit
  (common-prefix/suffix diff) so marks stay pinned to their characters. `BlockEditor`
  owns one controller + focus node per block, reconciled against controller state
  (so mark toggles / splits / merges reflect without cursor jumps). Enter splits a
  block; Backspace at offset 0 merges into the previous one.
- **Serialization:** `tiptap_codec` encodes to `{type:'doc',content:[…]}` and decodes
  tolerantly (unknown nodes skipped; mentions/hashtags authored elsewhere flatten to
  display text — lossy-but-safe, never a 422).
- **No business logic in widgets** — every mutation funnels through
  `CurrentDraftController` (docs/40 §44).

## 3. Draft synchronization architecture

- **Offline-first.** Every create/edit writes to the local Hive `drafts` box first
  (instant, offline-capable). Each `Draft` carries sync metadata: `syncState`
  (`synced/pending/syncing/failed/conflict`), `intent` (`save/publish/schedule/delete`),
  a local `version` counter (draft version tracking), and `remoteUpdatedAt` (the
  conflict base).
- **`DraftSyncEngine`** (keep-alive, background) drains the outbox — dirty drafts,
  FIFO by edit time — through the **same `PieceEditorRepository`** the online path
  uses. Per draft: (1) create or update content (create if no `remoteId`); (2) upload
  a pending cover; (3) run the queued lifecycle intent (publish/schedule/delete).
- **Conflict detection is client-side** because frozen `v1` has *no* stale-write
  rejection: before updating, the engine re-reads the server piece and compares
  `updatedAt` against the local base; a newer server timestamp → `conflict` for the
  user to resolve (keep-mine / use-theirs). We never invent a server rule.
- **Retry is event-driven** (reconnect, app-resume, explicit retry) — no battery-
  draining polling. Transport failures stay `pending` (auto-retry on reconnect);
  domain/validation failures become `failed` with a reason.

## 4. Offline storage strategy

- Hive `drafts` box (added alongside the existing `reading` box). Like reading
  history it is **precious user work, never wiped on a cache-schema bump**;
  unparseable records are skipped, not fatal. Drafts persist as JSON (the identical
  TipTap `content` shape locally and on the wire — docs/40 §42.1 seam). The server
  drafts-list page is also cached so the drafts screen renders offline.

## 5. Publishing flow

Save draft → `POST /pieces` or `PATCH /pieces/:id`. Publish now → `POST /pieces/:id/publish`
(carries a stable Idempotency-Key so a re-queue is a safe replay). Schedule →
`POST /pieces/:id/schedule {scheduledAt}` (future-dated). The publish sheet gates on
client-side validation (title + language + genre + content — a mirror of the server's
`PIECE_INCOMPLETE`) and confirms visibility; offline, publish/schedule **queue** and
replay on reconnect. Preview is rendered locally (no server round-trip, works offline).

## 6. State management summary

Riverpod only, code-gen `@riverpod`. **Current draft:** `currentDraftController`
(autoDispose family, `AsyncNotifier<EditorState>`) — load/hydrate, autosave, block ops,
lifecycle. **Draft list:** `draftListController` (union of local + server drafts).
**Sync queue/status:** `draftSyncEngine` (keep-alive) + `draftsRevision` /
`draftSyncSummary` / `coverUploadProgress` derived providers. **Publishing:** folded
into `currentDraftController` (`publish`/`schedule`). **Editor preferences:**
`editorPreferencesController` (keep-alive, device-persisted). No global mutable state;
no service locators.

## 7. API integration summary (frozen `v1`, verified)

| Action | Endpoint |
| --- | --- |
| Create draft | `POST /pieces` |
| Update / save | `PATCH /pieces/:id` |
| List drafts | `GET /me/drafts` (cursor) |
| Hydrate / conflict base | `GET /pieces/:id` |
| Publish | `POST /pieces/:id/publish` (Idempotency-Key) |
| Schedule | `POST /pieces/:id/schedule` |
| Delete | `DELETE /pieces/:id` (204) |
| Cover upload | `POST /pieces/:id/cover` (multipart `file`, ≤10 MB, JPEG/PNG/WebP → `{key}`) |
| Language/genre options | `GET /discover/languages` · `GET /discover/genres` |

Only whitelisted, writable fields are ever sent (never `status`/`slug`/`scheduledAt`/
`coverImageKey` — `forbidNonWhitelisted` would 400). `languageCode` is always sent
(API-required). Cover upload bypasses the 401→refresh interceptor per docs/40 §34.2.

## 8. Performance optimizations

Lazy editor init (route-mounted); debounced autosave (2 s) to local storage, server
sync decoupled (on exit / explicit / reconnect — respects the wire); client-side
image downscale + compression at pick time; background sync is event-driven, single-
flight; `const` widgets; narrow provider reads; memory-lean drafts list (`DraftSummary`
omits `content`); off-screen-safe block controllers reconciled by id.

## 9. Test coverage (61 new; 216 total pass)

`marked_text` (edit-mapping, toggle, runs, split/concat) · `tiptap_codec`
(round-trip per block/mark + decode tolerance + mention/hashtag flatten) ·
`editor_document` (split/merge/insert/remove/wordCount/id-collision) ·
`piece_write_mappers` (whitelist-only body, server merge, list mapping) ·
`draft_validation` · `draft_store` (Hive round-trip, pending FIFO, corruption skip) ·
`draft_sync_engine` (create/update/publish-intent/**offline-retry**/**conflict**/delete) ·
`current_draft_controller` (load, edit-marks-pending, tag cap, publish, saveNow) ·
`block_editor` widget (typing → document, Enter split) · writing chips **golden**
(light + dark).

## 10. Manual testing guide

1. **New draft:** Write tab → New piece → type; watch "Saving…"→"Saved".
2. **Rich text:** select text → Bold/Italic/Underline; change block to H2/Quote/List.
3. **Metadata:** set language (required), genre, tags (cap 5), visibility, featured quote.
4. **Cover:** add cover (gallery/camera) → progress bar → replace/remove.
5. **Preview:** tap Preview → theme-aware reading render + progress bar + reading time.
6. **Publish/Schedule:** Publish → validation gate → confirm; or Schedule a future time.
7. **Offline drafts:** enable airplane mode → create/edit → offline badge + "Not synced";
   re-enable → auto-syncs (badge → "Synced").
8. **Conflict:** edit the same piece on web + mobile → mobile shows the conflict banner →
   resolve keep-mine / use-theirs.
9. **Crash recovery:** kill mid-edit → reopen → draft restored from local store.
10. **Preferences:** editor settings → font size / spacing / width / theme / autosave toggle.

## 11. Extensibility for future AI (no refactor required)

The document model is the extension seam: **AI writing assistant / grammar suggestions
/ voice dictation** all produce or transform `MarkedText`/`EditorDocument` and route
through `CurrentDraftController` — a future `features/ai` module composes an assist
action into the editor via the router without touching the editor's model or the sync
engine. **Collaborative editing** slots onto the same repository interface + the
already-present `updatedAt` conflict seam (a future CRDT/OT source is an additional
data source behind `PieceEditorRepository`). **Markdown import** is a new codec
alongside `tiptap_codec` producing an `EditorDocument`. None require changing the
document model, the repository interface, or the offline sync architecture.

---

## Known contract-bound gaps (documented, not hacks)

- **No link mark / images in body:** the backend sanitizer rejects them; the editor
  deliberately does not offer them (the brief's "Links" bullet is overridden by "do
  not introduce formatting unsupported by the backend"). Consistent with the reader.
- **Taxonomy source:** language/genre pickers use `GET /discover/{languages,genres}`
  (no dedicated list endpoint exists in `v1`).
- **Conflict detection is client-side** (`updatedAt` compare) since `v1` has no
  optimistic-concurrency rejection.
- **Local preview** (not the `POST /pieces/:id/preview` endpoint) — consistent with
  the app's no-server-render, offline-first stance (docs/40 §35.3).

*End of `44_MobileM4ReadinessReport.md`. Stop after M4 — do not begin M5.*
