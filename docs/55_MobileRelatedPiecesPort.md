# 55 — Mobile "More like this" (parity port W-1)

**Status:** ✅ Complete · **Scope:** port the web reader's related-pieces section to the mobile reader. **A port, not a redesign. No backend change. No new product surface beyond the section itself.**

Parity authority: **[platfrom/docs/48 §3.1](../../platfrom/docs/48_PlatformParityRegister.md)** — this was the single item where mobile was behind web, created by W1 building past its reference. Decided 2026-07-27, delivered 2026-07-28, ahead of W3 and every other W-track row.

Web reference ported from: `platfrom/frontend/src/features/reading/{hooks/use-related-pieces.ts, components/related-pieces.tsx}` and `api/reading.api.ts#related`.

---

## 1. What it does

Up to **4** pieces sharing the piece's **first** tag, with the current piece filtered out of its own suggestions, at the end of the reader. Behaviour is identical to web:

| Condition            | Result                                                         |
| -------------------- | -------------------------------------------------------------- |
| Piece has no tags    | No section, **and no request** — the provider is never watched. |
| Load fails           | Nothing renders. No error view, no retry, no snackbar.          |
| Result empty         | Nothing renders — no heading, no empty state.                   |
| Result includes self | Self is filtered; one extra item is requested so 4 still show.  |

The rule behind all four rows: the section is a suggestion, and **it must never cost the reader the piece they came for**.

---

## 2. Data path — the same tag search web uses

`GET /search/pieces?q=<tag name>&tag=<tag slug>&sort=trending&limit=5`

The frozen contract requires a non-empty `q`, so the tag's **name** is the query and its **slug** is the filter — FTS matches tags, so the two agree rather than fight. `limit=5` is `4 + 1`, so filtering out the current piece still leaves a full section.

This is **not** the AF4 recommender (`GET /ai/recommendations`): that needs auth plus the `ai.use` permission, which a signed-out reader does not have. Same reasoning as web — it belongs to a later AI surface, not to this section.

---

## 3. Files

| Layer      | File                                                                    | Change                                                                                       |
| ---------- | ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Domain     | `lib/features/reading/domain/repositories/reading_repository.dart`      | `+ getRelatedPieces(TagRef tag, {int limit})` → `Result<List<PieceSummary>>`                  |
| Data       | `lib/features/reading/data/datasources/piece_remote_data_source.dart`   | `+ getRelatedPieces` — the tag-filtered `/search/pieces` page                                 |
| Data       | `lib/features/reading/data/repositories/reading_repository_impl.dart`   | Implements it; **uncached** (see §4)                                                          |
| Controller | `lib/features/reading/presentation/controllers/related_pieces_controller.dart` | `relatedPiecesProvider`, family-keyed by `(pieceId, tag)`; filters self, takes 4, never throws |
| Widget     | `lib/features/reading/presentation/widgets/related_pieces.dart`         | `RelatedPieces` — heading + one card of compact rows; renders `SizedBox.shrink()` when empty  |
| Screen     | `lib/features/reading/presentation/screens/reading_screen.dart`         | Renders it at the end of `_ReaderBody`                                                       |
| Test       | `test/features/reading/related_pieces_test.dart`                        | 5 widget tests — one per row of the table in §1                                              |
| Test       | `test/support/fake_reading_repository.dart`                             | `related` / `relatedFails` / `lastRelatedTag` / `lastRelatedLimit`                            |

No new entity: it reuses the shared `PieceSummary` + `pieceSummaryFromJson`, which the feed and search already use.

---

## 4. The three decisions worth recording

1. **Reading owns its own data path.** `features/search` already calls `/search/pieces`, but `docs/folder-structure.md` and [40 §7](./40_MobileArchitecture.md) forbid a feature importing another feature, so the call lives in reading's own `PieceRemoteDataSource`. Web has the same shape for the same reason (its `features/reading/api/` layer, not `features/search`).
2. **Not cached** — consistent with every other suggestion surface in the app, not an exception for this one. `features/ai` recommendations, semantic search, and search suggestions are all `guardResult` straight to the remote with no cache write. [40 §25.4](./40_MobileArchitecture.md#254-what-is-and-isnt-cached) previously implied all list pages are cached; it now states the actual rule for this class of surface, with both reasons: a cached suggestion offline links to a piece that is _not_ cached (a dead end), and "nothing to show" is a correct outcome for something non-critical.
3. **Position differs from web, deliberately.** Web renders the section below its author card, which sits at the **end** of its page. Mobile's author card sits **above** the prose, so the faithful equivalent position is the end of the reader — after the comments/responses footer — not directly under the card. Filed as an accepted layout difference in [platfrom/docs/48 §4.1](../../platfrom/docs/48_PlatformParityRegister.md), which is where the register requires known differences to live permanently (§3.1 is a closed-item record, not a durable home).

Design-system entry: [41 §11.19](./41_MobileDesignSystem.md) (`RelatedPieces`) and [41 §35](./41_MobileDesignSystem.md).

---

## 5. Verification

| Gate                                | Result                                                                                                       |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `flutter analyze`                   | ✅ No issues found                                                                                            |
| `flutter test` (reading)            | ✅ 6/6 — the 5 new tests + the existing reader screen test                                                     |
| `flutter test` (full suite)         | 507 pass, **2 pre-existing failures** unrelated to this change: `comment_tile_golden_test` light + dark, 0.03% / 156px golden drift. Reproduced on a clean tree at `83cf00f` before this work. |
| `dart format --set-exit-if-changed` | ✅ on changed files only (the repo baseline predates tall-style — a whole-tree format is not run)               |

**Parity check** ([48 §6](../../platfrom/docs/48_PlatformParityRegister.md)): this delivered exactly what 48 §3.1 named and nothing else. Web's version was re-read surface-by-surface before building; the two differences found are recorded in §4 above rather than silently kept. Mobile is no longer behind web on any item — §3 of the register is now empty.
