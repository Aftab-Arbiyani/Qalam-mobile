# 56 — Mobile AF5 / AF6 contract audit

**Date:** 2026-07-28 · **Method:** static contract diff, no live stack · **Scope:** every endpoint the
mobile AF5 (monetization) and AF6 (collaboration / publishing / trust) clients call.

**Source of truth:** the backend, read as source — `platfrom/backend/src/modules/{collaboration,
publishing,trust,monetization}` controllers, request/response DTOs, mappers and services, plus
`packages/shared/src/{collaboration,publishing,policy,trust,monetization,enums}.ts`. The DTO is the
contract; the mobile entity is the claim under test.

**Under test:** `qalam-mobile/lib/features/collaboration/**`, `lib/features/monetization/**`,
`lib/core/billing/**`, plus the two shared boundaries every finding runs through —
`lib/core/network/api_client.dart` and `lib/core/network/api_paths.dart`.

**No application code was changed by the audit itself** beyond the two one-liners recorded in §8. The
repair pass that followed (same day) is recorded in §0 and inline per defect; the register text below
is preserved as written so the diagnosis stays auditable, with a status marker and a **FIXED** note
appended to each entry.

**Evidence rule.** Nothing here is sourced from a readiness report (docs/47–55), a CLAUDE.md claim,
or memory. Every finding carries a backend quote and a mobile quote. Where the code alone cannot
settle the behaviour, the finding is marked **NEEDS-LIVE-CONFIRMATION** rather than guessed.

> **Status re-verified 2026-08-20 — and this document is NOT the status source of truth.**
> Every entry still carrying an open marker was re-read against the code that owns it. **Five had
> already been fixed** and said otherwise: **C-14** (2026-07-29), **T-3** (2026-08-03), **M5-1**
> (2026-08-03), **M5-4** (2026-07-29), and the §9 summary's "all 5 AF5 findings remain open by design",
> which was true of one pass's scope and false as a count for three weeks. Each is struck in place with
> the anchor that disproves it.
>
> **One entry is genuinely open: C-15.** (M5-2 / AF5-cs closed 2026-08-21 — struck below.) It is carried
> as a schedulable line in
> [`platfrom/docs/48` §3.22, the open ledger](../../platfrom/docs/48_PlatformParityRegister.md) — the
> single place where "what is open" is answered across both repos. **This document owns the
> *diagnosis*; the ledger owns the *status*.** Do not schedule, size, or report a finding from a heading
> in here; re-verify its anchor first, and when it closes, strike it here **and** delete its ledger line
> in the same commit as the fix.

---

## 0. Repair status (updated 2026-07-28, same day)

**All 26 findings are FIXED**, each with a regression test that fails against the pre-fix code.
**C-2** was the last one open — a backend change, out of reach of the mobile-only repair pass — and
landed in the cross-repo pass recorded in §0b, together with the server-side arm of **D1**.

### 0b. C-2 + D1 pass (2026-07-28, later — backend + mobile together)

| Change | Where |
| --- | --- |
| C-2: the three editorial actions appended to the explained set | `platfrom` `collaboration/collaboration.constants.ts` |
| D1: accepting a suggestion applies it to the piece body | `platfrom` `collaboration/suggestion.service.ts`, `content-text.util.ts`, `pieces/pieces.service.ts` (`replaceContent`), `publishing/snapshot.service.ts` (`capture`) |
| The mobile mirror folded to one list of 12; the accept toast reverted | `collaboration_enums.dart`, `suggestions_screen.dart`, `edit_suggestion.dart` |

Live evidence, local stack, writer as story owner:

- `GET /stories/:id/capabilities` returns **12** elements and the owner is `allowed: true` on
  `story.edit`, `publication.publish` and `review.approve`. Verified on the **existing** dev DB, not a
  fresh one: `story.edit`'s base permission is `collaboration.use` (the permission behind the PBAC
  seed-grant defect), and `PermissionRule` (rule 3) runs *before* `OwnershipRule` (rule 4), so an
  `allow` here proves the grant is present — `role_permissions` confirms the `user → collaboration.use`
  row directly.
- Accepting a suggestion rewrote the prose (`"Autosaved prose that…"` → `"Autosaved QALAMREWRITE
  that…"`), captured a `pre_edit` snapshot whose content equals the **pre**-edit body, and returned an
  unchanged `SuggestionDto`.
- A stale anchor — `originalText` still present in the document but no longer at `[from, to)` —
  returned **409 `SUGGESTION_CONFLICT`**, left the body byte-identical, and left the suggestion
  `pending`.

Three follow-on defects were found during this pass and recorded: **C-13, C-14, C-15** (§2.6).

### 0c. C-13 fix + two-projection pin (2026-07-29)

**C-13 is now FIXED on both clients** and the `extractPlainText` naming hazard is closed — §2.7.
Web's accept invalidates `qk.pieces.all`; mobile's invalidates the piece read and the snapshot list;
reject and withdraw deliberately still don't. The collaboration flattener is renamed `anchorText` and
its divergence from `@qalam/utils` `extractPlainText` is pinned by a test that fails if either side
moves. **C-14 and C-15 remain open** — both web-only, neither touched.

Verification: backend `jest` **942 / 133 suites**, `tsc` + `eslint` clean. Frontend `vitest`
**362 / 82 files**, `tsc` + `eslint` clean. Mobile `flutter analyze` clean, `flutter test`
**566 pass / 1 skipped / 2 failed** (the same two pre-existing goldens), `live` suite **6 pass**.
The D1 live checks were re-run end to end after the rename: rewrite applied, `pre_edit` snapshot
equals the pre-edit body, stale anchor still 409 with the body untouched, fixture restored.

| Test file | Covers |
| --- | --- |
| `test/features/collaboration/capability_contract_test.dart` | C-1, C-2 (12 tests, incl. a byte-for-byte captured live payload — re-captured from the C-2-fixed server) |
| `test/features/collaboration/publishing_contract_test.dart` | P-1 … P-8 (16 tests) |
| `test/features/collaboration/collaboration_contract_test.dart` | C-3 … C-12, T-1, T-2 (20 tests) |
| `test/features/collaboration/af6_live_observation_test.dart` | C-1, C-2, P-4, T-4 against a **real backend** (6 tests, tagged `live`) |
| `test/features/collaboration/invite_contract_test.dart` | M-1 (pre-existing) |

Verification at hand-off: `flutter analyze` clean; `flutter test` **563 pass / 1 skipped / 2 failed**,
the two failures being the pre-existing `comment_tile_golden_test` drift documented in docs/50 and
unrelated to AF6. The `live` suite is skipped by default (`dart_test.yaml`) and run with
`flutter test --run-skipped --tags live` against `pnpm e2e:up`; it passes (6 tests). On the backend
side, `jest` is **936 pass / 132 suites** with `tsc --noEmit` and `eslint` clean.

**The live suite is the process fix.** Every pre-existing AF6 test mocked the data source, so no test
ever decoded a real capability payload — which is exactly why a defect that hid every affordance in
the feature (C-1) survived a green suite, a readiness report and three prior audits.

---

## 1. Headline

| Track | Verdict as audited | State after repair |
| --- | --- | --- |
| **AF5 — monetization** | Field-for-field correct on every one of the 19 endpoints it calls. Two integration gaps, no wire defects. | Unchanged — out of the repair pass's scope. |
| **AF6 — collaboration** | The capability map — the single thing all AF6 UI gates on — is decoded from the wrong shape, so **every gate in the feature resolves to denied**. Plus 11 further defects. | C-1 fixed and verified live; all 12 collaboration defects closed, C-2 by the backend change in §0b. Three follow-on defects opened (C-13/14/15, §2.6). |
| **AF6 — publishing** | Five of nine calls cannot succeed or return a different entity than the client decodes. | All 8 publishing defects closed; the five publishing gates now receive a real verdict (C-2). |
| **AF6 — trust** | Read path correct; the block list mis-identifies the blocked user, and the whole block/mute surface has no UI. | T-1/T-2 closed; the missing blocks UI remains a build. |

Two facts that frame every estimate below:

- **AF6 has no entry point.** No widget outside `lib/features/collaboration/` navigates to any of the
  six AF6 routes (R-1). The surface is reachable only by deep link. That is why 9 of the 20 AF6
  defects have never been observed: nothing has ever called them.
- **The three previously-found defects (M-1, M-2, M-3) were not a cluster; they were a sample.** M-1
  is fixed and verified. M-2 and M-3 are re-derived below from source (C-3, C-5) and are still open,
  alongside a critical defect (C-1) that none of the three earlier audits reached.

Shared boundaries that several findings depend on:

- `main.ts:167-177` — `new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform:
  true, transformOptions: { enableImplicitConversion: false } })`. A body key no DTO declares is a
  **400 `VALIDATION_FAILED`**, not a silently-ignored field. This applies only to handlers that
  declare `@Body()`; a handler with no `@Body()` never sees the body at all (P-8).
- `common/interceptors/transform.interceptor.ts:38-40` — every response becomes
  `{ success: true, data }` unless the handler already returned an envelope.
- `lib/core/network/api_client.dart:343-348` — `_extractData` requires `body['success'] == true` and
  returns `body['data']`; `_dataAsJson` (`:326-330`) throws `API_MALFORMED_RESPONSE` when that value
  is not a Map. A legitimate `data: null` is therefore an exception on the client (P-4).
- `lib/core/network/api_client.dart:56-70` — `getList` reads `data` as an array and **discards
  `meta`**; only `getPage` (`:73-89`) reads `meta.pagination` (C-10).

---

## 2. Defect register

Severity per `/finding-format` (critical / high / medium / low). **Reachable** = whether any current
UI path can trigger it; an unreachable defect is still a defect (it is what a web port would copy)
but it changes sizing, so it is stated rather than folded into severity.

### 2.1 AF6 — collaboration

---

#### C-1 · **critical** · ✅ **FIXED** · capability map decoded from the wrong shape → every gate denies

**Backend.** `platfrom/backend/src/modules/collaboration/dto/collaboration-response.dto.ts:111-115`

```ts
/** The full capability map for a story (`GET /stories/:storyId/capabilities`). */
export class CapabilitiesDto {
  @ApiProperty() storyId!: string;
  @ApiProperty({ type: [CapabilityDto] }) capabilities!: CapabilityDto[];
}
```

`collaboration.mappers.ts:93-101` flattens the engine's `explain` map into that **array**, each
element `{ action, effect, allowed, reason, obligations }`. Route:
`collaboration.controller.ts:148-158`. On the wire, after the interceptor:

```json
{"success":true,"data":{"storyId":"…","capabilities":[{"action":"story.comment","effect":"allow","allowed":true,…}]}}
```

**Mobile.** `lib/features/collaboration/domain/entities/policy_capability.dart:71-82`

```dart
factory StoryCapabilities.fromJson(Json json) {
  final Map<String, PolicyCapability> caps = <String, PolicyCapability>{};
  json.forEach((String action, dynamic value) {
    if (value is Map) {
      caps[action] = PolicyCapability.fromJson(action, Map<String, dynamic>.from(value));
    }
  });
  return StoryCapabilities(capabilities: caps);
}
```

It iterates the payload as if it were `{action: decision}`. The two keys it actually receives are
`storyId` (a `String`) and `capabilities` (a `List`) — neither is a `Map`, so **both are skipped and
the map is empty**. `capabilityFor` then returns `PolicyCapability.deny` for everything
(`:65-69`), `allows()` is always `false` (`:69`), and `CapabilityGate` renders `locked` on every
action (`presentation/widgets/capability_gate.dart:42`).

**Wire-level failure.** HTTP 200, no exception, no error state. All ten `CapabilityGate` call sites
render their fallback — which defaults to `SizedBox.shrink()` (`capability_gate.dart:38`) — so the
comment composer, resolve, withdraw, accept/reject, invite, manage-members, publish, review and
snapshot affordances are all silently **invisible**, on every story, for the owner included.

**Fix size.** ~6 lines in one factory: read `json['capabilities'] as List`, key each element by its
own `action` field. Add a decode test with a real payload.

**FIXED.** `policy_capability.dart` — `StoryCapabilities.fromJson` now iterates
`json['capabilities']` and keys by each element's own `action`; `PolicyCapability.fromJson` reads the
action from the payload instead of a map key; `storyId` is read from the envelope; the phantom
`matchedRule` (which `toCapabilityDtos` drops) is gone. `capabilityFor` keeps its default-deny and
`readOnly` stays fail-closed. Tests: `capability_contract_test.dart` (8 decode cases) +
`af6_live_observation_test.dart`. Proven to fail before the fix — an identical assertion
(`allows('story.comment')`) returned `false` pre-fix and `true` post-fix.

**Observed live**: `GET /api/v1/stories/:id/capabilities` returns
`{"storyId":"…","capabilities":[{"action":"story.view","effect":"allow","allowed":true,"reason":"You own this resource.","obligations":[]}, …]}`
— 9 elements, owner allowed all 9. The payload is captured byte-for-byte in the test.

---

#### C-2 · **high** · ✅ **FIXED (backend + mobile, §0b)** · three gated actions are not in the capability map at all

**Backend.** `collaboration/collaboration.constants.ts:44-54` — the set `explain` is asked for:

```ts
export const COLLABORATION_CAPABILITY_ACTIONS: readonly PolicyActionCode[] = [
  POLICY_ACTIONS.StoryView, POLICY_ACTIONS.StoryComment, POLICY_ACTIONS.StorySuggest,
  POLICY_ACTIONS.StoryInvite, POLICY_ACTIONS.StoryManageMembers, POLICY_ACTIONS.StoryManageRoles,
  POLICY_ACTIONS.CommentResolve, POLICY_ACTIONS.CommentDelete, POLICY_ACTIONS.SuggestionResolve,
];
```

Nine actions. `story.edit`, `publication.publish` and `review.approve` exist in the catalogue
(`packages/shared/src/policy.ts:84,94,100`) but are **not explained** by this endpoint.

**Mobile.** `domain/entities/collaboration_enums.dart:112-136` declares
`storyEdit`, `publicationPublish`, `reviewApprove` and omits `story.manage_roles` and
`comment.delete`. Those three absent-from-the-map actions are exactly what the publishing screen
gates on: `presentation/screens/publishing_workflow_screen.dart:129` (`storyEdit` → Request review),
`:146` (`reviewApprove` → Approve / Request changes), `:204` (`publicationPublish` → the entire
Publication card, i.e. Publish, Unpublish and all four visibility chips), `:298` and `:346`
(`storyEdit` → Create snapshot, Revert).

**Wire-level failure.** Independent of C-1: after C-1 is fixed these five gates still receive no
decision and fall to `PolicyCapability.deny` (`policy_capability.dart:47-54`), so the publishing
workflow screen renders its cards with **no buttons at all**.

**Fix size.** One-line backend change (append the three actions to
`COLLABORATION_CAPABILITY_ACTIONS`) plus aligning the mobile mirror; or client-side, gate on
actions the map carries. Backend-side is correct — the client should never re-derive which action
governs publishing.

**NOT FIXED — no mobile-side fix exists.** Confirmed by reading the whole path:

- `collaboration.controller.ts:148-158` — the route takes `@CurrentUser` and
  `@Param('storyId')` only. No `@Query`, no `@Body`: a client cannot ask for more actions.
- `membership.service.ts:253-261` — `getCapabilities` passes the module constant
  `COLLABORATION_CAPABILITY_ACTIONS` to `explain`.
- `policy-engine.service.ts:132-143` — `explain(subject, actions, resource)` takes `actions` as a
  server argument.
- A grep for `capabilities` across every `*.controller.ts` finds exactly one endpoint, so there is no
  second source. `publishing.constants.ts` is audit-action strings only; `policy.constants.ts` is the
  rule tables — and it **confirms all three actions are real and role-gated**
  (`ACTION_MIN_STORY_ROLE`: `story.edit` → Editor, `review.approve` → Editor,
  `publication.publish` → CoAuthor).

The needed diff is one line in `collaboration.constants.ts`:

```ts
export const COLLABORATION_CAPABILITY_ACTIONS: readonly PolicyActionCode[] = [
  … POLICY_ACTIONS.SuggestionResolve,
+ POLICY_ACTIONS.StoryEdit, POLICY_ACTIONS.PublicationPublish, POLICY_ACTIONS.ReviewApprove,
];
```

**What the mobile pass did instead**, without re-deriving authorization: `PolicyAction.all` — a dead
list that *looked* like the request set and had zero consumers — was replaced by
`PolicyAction.serverExplained` (the true 9) and `PolicyAction.notExplainedByServer` (the 3), both
documented and pinned by tests. `capability_contract_test.dart` asserted the gap; the live test proved
it on a running server (the story's **owner** was denied all three).

**FIXED (2026-07-28, §0b).** The three actions were appended to `COLLABORATION_CAPABILITY_ACTIONS`
exactly as diffed above. Nothing depended on the list's length: the only consumer is
`membership.service.ts:253-261`, and both clients key decisions by action string
(`StoryCapabilities.fromJson` on mobile, `useCapability` on web) — a grep over `backend/src`,
`frontend/src` and `admin/src` for the constant and for `capabilities` found no length or index
assumption, and no backend test asserted nine.

On the mobile side `notExplainedByServer` was **deleted** and its three actions folded into
`serverExplained` (now 12, in the backend constant's order). The two pins that were written to fail
when this landed did fail, as designed, and were rewritten to assert the closed state: the captured
live payload in `capability_contract_test.dart` was re-captured from the fixed server (12 elements,
byte-for-byte), and `af6_live_observation_test.dart` now asserts the owner *is* allowed all three
against the running stack.

**Consequence for the Stage-1 observation:** the five publishing gates now receive a real verdict.

---

#### C-3 · **high** · ✅ **FIXED** · suggestion create can only 400 (re-derivation of M-2)

**Backend.** `collaboration/dto/collaboration-request.dto.ts:176-194`

```ts
export class CreateSuggestionDto {
  @ApiProperty({ type: SuggestionAnchorDto })
  @ValidateNested()
  @Type(() => SuggestionAnchorDto)
  anchor!: SuggestionAnchorDto;          // required — no @IsOptional
  … originalText!: string;
  … suggestedText!: string;
}
```

`SuggestionAnchorDto` (`:163-173`) requires integer `from` and `to`. Route:
`collaboration.controller.ts:298-307`, consumed at `suggestion.service.ts:88`
(`anchor: { from: dto.anchor.from, to: dto.anchor.to }`).

**Mobile.** `data/datasources/collaboration_remote_data_source.dart:198-213`

```dart
body: <String, Object?>{
  'originalText': originalText,
  'suggestedText': suggestedText,
  'blockId': ?blockId,
  'rationale': ?rationale,
},
```

No `anchor`; two keys no DTO declares.

**Wire-level failure.** `400 VALIDATION_FAILED` on every call — `anchor should not be null or
undefined` always, plus `property blockId should not exist` / `property rationale should not exist`
whenever either is supplied. **Reachable: no** — `suggestions_screen.dart` has no compose affordance;
`addSuggestion` is only reachable through `collaboration_controller.dart:136-151`, which nothing
calls. The suggestion *queue* renders; there is no way to add to it from the app.

**Fix size.** Replace `blockId`/`rationale` with `anchor: {from, to}` end-to-end (datasource, repo,
controller, `EditSuggestion`) and build a compose affordance — ~1 day, because the anchor has to come
from a real text selection in the editor, which the suggestions screen does not have.

**FIXED (contract).** New `text_anchor.dart` models the real `{from, to, quote?}` shape with separate
`toCommentJson()` / `toSuggestionJson()` bodies, because `SuggestionAnchorDto` declares no `quote`.
`addSuggestion` now takes a **required** `TextAnchor` and sends exactly
`{anchor:{from,to}, originalText, suggestedText}`; `blockId` and `rationale` are gone from the
datasource, repository and controller. Test: `collaboration_contract_test.dart` → "suggestion create
body (C-3)" asserts the exact body and the absence of all three offending keys.

**Still no compose affordance** — that is a UI feature needing an editor text selection, not a
contract defect, and it is out of the repair pass's scope. The call is now correct when made.

---

#### C-4 · **high** · ✅ **FIXED** · `EditSuggestion` parses four keys the wire never sends and ignores the one that matters

**Backend.** `collaboration/dto/collaboration-response.dto.ts:72-83` +
`collaboration.mappers.ts:66-79`:

```ts
return { id, storyId, authorId,
  anchor: { from: s.anchor.from, to: s.anchor.to },
  originalText, suggestedText, status,
  resolvedById: s.resolvedById,
  resolvedAt: s.resolvedAt?.toISOString() ?? null,
  createdAt: … };
```

No `blockId`, no `rationale`, no `resolvedBy`, no author name.

**Mobile.** `domain/entities/edit_suggestion.dart:44-57`

```dart
authorName: json['authorName'] as String? ?? json['author'] as String?,
blockId: json['blockId'] as String?,
rationale: json['rationale'] as String? ?? json['note'] as String?,
resolvedBy: json['resolvedBy'] as String?,
```

and `anchor` is never read at all.

**Wire-level failure.** Four permanently-null fields, no exception.
`suggestions_screen.dart:99` renders `suggestion.authorName ?? suggestion.authorId` → a raw UUID
where a name belongs; `:121-124` guards on `rationale` so that block never renders; `resolvedBy` is
null even on a resolved suggestion (the wire says `resolvedById`). Dropping `anchor` is the material
loss: the client holds a before/after diff with **no location**, so it can never show the change in
context or apply it (see §3, D1).

**Fix size.** ~10 lines: rename to `resolvedById`, drop `blockId`/`rationale`/`authorName`, add
`anchor`.

**FIXED.** `EditSuggestion` now mirrors `SuggestionDto` field for field: `anchor` (a `TextAnchor`),
`resolvedById`, `resolvedAt`, `createdAt`, and no `blockId`/`rationale`/`authorName`. The screen shows
`shortActorId(authorId)` instead of a name it cannot know, renders the anchor range, and the
rationale block is gone. Test: "EditSuggestion mirrors SuggestionDto (C-4)".

---

#### C-5 · **high** · ✅ **FIXED** · comment replies are never fetched and never sent (re-derivation of M-3)

**Backend.** `CommentDto` (`collaboration/dto/collaboration-response.dto.ts:43-57`) has **no
`replies` field**. Threads are a separate endpoint:

```ts
@Get('comments/:id/thread')                                    // collaboration.controller.ts:246-251
thread(@Param('id', ParseUUIDPipe) id: string): Promise<CommentThreadDto>
```

returning `{ comment: CommentDto, replies: CommentDto[] }` (`:60-63`), served by
`comment.service.ts:216-223`. The list endpoint returns **root comments only** —
`comment.service.ts:203` calls `this.repo.listRootComments(...)`.

**Mobile.** `domain/entities/collaboration_comment.dart:84-91` reads `json['replies']`, and
`collaboration_remote_data_source.dart:138-186` has no `thread` method (comments / addComment /
reply / resolve / delete only). `ApiPaths` has no thread path either
(`lib/core/network/api_paths.dart:112-117`).

**Wire-level failure.** `comment.replies` is always `[]`, so
`comments_screen.dart:111` (`for (final CollaborationComment reply in comment.replies)`) never
renders anything. The screen is called "the threaded discussion on a story"
(`comments_screen.dart:1`) and can show no thread. `replyToComment` exists on the controller
(`collaboration_controller.dart:112-123`) with no UI caller, so no reply can be written either.

**Fix size.** Add `thread(commentId)` to the datasource/repo/provider, add a Reply affordance +
expand-thread on the root row — ~half a day.

**FIXED.** Added `ApiPaths.collaborationCommentThread`, `commentThread()` on the datasource and
repository, a `CommentThread` entity for `CommentThreadDto`, and `storyCommentThreadProvider`. The
`replies` field is gone from `CollaborationComment` — it was never on the wire. The screen now has an
expandable **Replies** row per thread that fetches on demand, plus a reply composer posting to
`POST /comments/:id/replies` behind a `story.comment` gate. Tests: "comment threads (C-5)" — decode,
the `/comments/{id}/thread` call, and a guard that `CommentDto` carries no `replies`.

---

#### C-6 · **high** · ✅ **FIXED** · comment anchor shape is wrong in both directions

**Backend.** `collaboration/dto/collaboration-request.dto.ts:103-119` — `CommentAnchorDto` accepts
exactly `from` (required int ≥ 0), `to` (required int ≥ 0), `quote?`. Echoed back as
`CommentAnchorViewDto` (`collaboration-response.dto.ts:36-40`) and mapped at
`collaboration.mappers.ts:55-56`.

**Mobile.** `domain/entities/collaboration_comment.dart:29-34`

```dart
Json toJson() => <String, Object?>{
  'blockId': ?blockId, 'start': ?start, 'end': ?end, 'quote': ?quote,
};
```

**Wire-level failure.** An inline comment sends three undeclared keys and omits two required ones →
`400 VALIDATION_FAILED`. **Reachable: no** — the composer sends no anchor
(`comments_screen.dart:252-254` calls `addComment(storyId:, body:)`, and the controller defaults
`kind: CommentKind.general, anchor: null`, `collaboration_controller.dart:93-99`), so general
comments post correctly today. On the read side `CommentAnchor.fromJson` (`:22-27`) reads
`blockId`/`start`/`end` → null, but does read `quote`, so the quoted-passage block at
`comments_screen.dart:171-186` works. Only the character range is lost.

**Fix size.** ~6 lines on the anchor entity; inline anchoring itself needs an editor selection, same
dependency as C-3.

**FIXED.** `CommentAnchor` (`{blockId, start, end, quote}`) is replaced by `TextAnchor`
(`{from, to, quote?}`) in both directions. `TextAnchor.fromJson` returns **null** when `from`/`to` are
absent rather than fabricating a zero range. Tests: "comment anchor + body (C-6, C-7)" — asserts the
outgoing anchor keys, the absence of `blockId`/`start`/`end`, and the null-on-missing-range case.

---

#### C-7 · **medium** · ✅ **FIXED** · `parentId` on comment create is not an accepted key

`CreateCommentDto` (`collaboration-request.dto.ts:122-145`) declares `body`, `kind?`, `anchor?`,
`mentions?` — no `parentId`; replies have their own route
(`collaboration.controller.ts:253-262`). Mobile sends `'parentId': ?parentId`
(`collaboration_remote_data_source.dart:162`), plumbed from
`collaboration_controller.dart:99,107`. `400` the moment it is non-null. **Reachable: no** — no
caller passes it. Fix: delete the parameter (3 lines).

**FIXED.** `parentId` is removed from the datasource, repository and controller `addComment`
signatures; replies go only through `POST /comments/:id/replies`, which the new reply composer uses.
Test: the C-6/C-7 group asserts `body.containsKey('parentId')` is false.

---

#### C-8 · **medium** · ✅ **FIXED** · presence heartbeat sends `blockId`

`PresenceHeartbeatDto` (`collaboration-request.dto.ts:197-201`) accepts only `state`; the controller
reads `dto.state` alone (`collaboration.controller.ts:363-369`). Mobile sends
`{'state': state, 'blockId': ?blockId}` (`collaboration_remote_data_source.dart:251-258`) from
`collaboration_controller.dart:163-170`. `400` when non-null. **Reachable: no** — the only caller
(`presence_bar.dart`) leaves it null. Fix: delete the parameter.

**FIXED.** `blockId` is removed from `heartbeat` at every layer; the body is now exactly `{state}`.
Test: "presence heartbeat body (C-8)".

---

#### C-9 · **medium** · ✅ **FIXED (client half)** · the collaborators list can only show UUIDs

**Backend.** `MemberDto` (`collaboration-response.dto.ts:14-20`) is exactly
`{ userId, role, invitedById, joinedAt }`; the owner row is synthesised with `joinedAt: null`
(`collaboration.mappers.ts:30-32`, used at `membership.service.ts:80`).

**Mobile.** `domain/entities/story_member.dart:38-52` additionally reads `displayName`/`name`,
`username`, `avatarKey`/`avatarUrl`, `invitedBy` (the wire says `invitedById`) and `storyId` (not in
`MemberDto`). `label` (`:36`) therefore always falls through to `userId`, and
`collaborators_screen.dart:293,300` renders a bare UUID as the collaborator's name and avatar seed.

**Wire-level failure.** Silent nulls, no exception. Cosmetic but disqualifying for the screen's
purpose. There is no by-id profile endpoint — `GET /users/:username` is by handle
(`users/profiles.controller.ts:111`) — so the client cannot resolve names itself without N handle
lookups it does not have handles for. **Fix requires a product decision:** add
`username`/`penName`/`avatarKey` to `MemberDto` (server-side, ~15 lines including the mapper and a
join) or accept ids in the UI. Same problem on `InvitationDto`, where the client already made the
honest choice — `shortActorId` (`story_invitation.dart:117-124`).

**FIXED (client half).** `StoryMember` now mirrors `MemberDto` exactly — `{userId, role, invitedById,
joinedAt}` — with the four phantom fields and the never-sent `storyId` removed, and `invitedById` read
from the real key. `label` returns `shortActorId(userId)`, taking the same honest route
`InvitationDto` already took, so the screen shows a recognisable shortened id rather than a full UUID
pretending to be a name. Tests: "StoryMember mirrors MemberDto (C-9)".

**The product decision is still open**: showing real names needs `MemberDto` to carry them (backend),
so it is deliberately not resolved here.

---

#### C-10 · **medium** · ✅ **FIXED** · every collaboration list is capped at 20 rows with no way to page

**Backend.** All three list endpoints are cursor-paginated and attach `meta.pagination` explicitly —
`collaboration.controller.ts:63-65` (`listEnvelope`), `:224-233` (comments), `:287-296`
(suggestions), `:346-355` (activity) — with `cursor`, `limit` (1…50, default 20) and, for comments
and suggestions, a `status` filter (`collaboration-request.dto.ts:35-68`;
`collaboration.constants.ts:56-59`).

**Mobile.** All three are fetched with `getList` and **no query at all** —
`collaboration_remote_data_source.dart:139-146`, `:189-196`, `:231-238` — and `getList` discards
`meta` (`api_client.dart:56-70`). The repository and provider signatures carry no cursor either
(`collaboration_repository_impl.dart:95-96,139-140,172-173`;
`collaboration_providers.dart:97-115`), and the screens use `RefreshIndicator` only
(`comments_screen.dart:82-83`, `suggestions_screen.dart:63-65`).

**Wire-level failure.** No exception; the 21st comment simply does not exist as far as the app is
concerned, and the open/resolved filter is unreachable. Fix: switch to `getPage` + a paged provider
— the pattern already exists in AF5 (`monetization_remote_data_source.dart:98-102`).

**FIXED.** `comments`, `suggestions` and `activity` now use `getPage` and forward
`cursor`/`limit`/`status`, returning a `CursorPage` through the repository and providers — so
`meta.pagination` survives and the open/resolved filter is reachable. Test: "cursor pagination
(C-10)" asserts the forwarded query and that `nextCursor`/`hasMore` arrive.

Note the screens still render only the first page; the cursor is now *available* to a load-more
affordance rather than discarded at the network boundary.

---

#### C-11 · **low** · ✅ **FIXED** · activity feed reads a `summary` the wire never sends, and nothing reads the feed

`ActivityDto` (`collaboration-response.dto.ts:86-93`) is `{ id, storyId, actorId, type, metadata,
createdAt }`. `collaboration_activity_entry.dart:37` reads `json['summary'] ?? json['message']` →
always `''`, and its doc comment (`:23`) names event types (`member.added`, `comment.created`) that
do not exist — the real catalogue is snake_case (`packages/shared/src/collaboration.ts:92-106`:
`member_joined`, `comment_added`, …). Latent: `storyActivityProvider`
(`collaboration_providers.dart:136-145`) has **no consumer** anywhere in the app.

**FIXED.** `summary`, `message`, `actorName` and `actor` are gone; `actorId` is now required, and the
doc comment states the real snake_case catalogue instead of the invented dot-cased names. Test:
"ActivityDto (C-11)". The provider still has no consumer — an activity-feed UI is a feature, not a
contract fix.

---

#### C-12 · **low** · ✅ **FIXED** · Withdraw is gated on the wrong policy action

Backend authorizes withdraw through `SuggestionResolve` with the engine's self-service rule —
`suggestion.service.ts:211-217`, documented at `:205-209` ("the author retracts their own
suggestion"). Mobile gates the Withdraw button on `PolicyAction.storySuggest`
(`suggestions_screen.dart:131-133`). Once C-1 is fixed, any user who may *suggest* will see
**Withdraw on other people's suggestions**, and tapping it 403s. Fix: gate on `suggestion.resolve`,
or on `authorId == me`.

**FIXED via `authorId == me`.** Gating on `suggestion.resolve` would also be wrong: the capability map
evaluates it against the **story**, so the engine's self-service arm (which needs
`resource.ownerId == suggestion.authorId`) is never exercised there — a reviewer gets `allowed: false`
at story level yet may still withdraw their own suggestion. So the client asks the only question it
can answer: *did I write this?* `SessionState` carries no user id, so the datasource reads `GET /me`
itself (exactly the precedent `resolveInvitee` set for `GET /users/{username}`, and for the same
folder-structure reason), exposed as `viewerIdProvider`. Used **only** for this affordance, never as
an authorization decision.

---

### 2.2 AF6 — publishing

---

#### P-1 · **high** · ✅ **FIXED** · five actions return a piece; the client decodes a publication event / snapshot

**Backend.** `publishing/publishing.controller.ts:55-102` — `publish`, `unpublish`, `schedule`,
`changeVisibility` — and `:185-196` (`revertSnapshot`) all declare
`@ApiOkResponse({ type: PieceResponseDto })` and return `Promise<PieceResponseDto>`.
`PieceResponseDto` (`pieces/dto/piece-response.dto.ts:14-40`) is the full piece:
`{ id, author, title, subtitle, slug, content, …, status, visibility, wordCount,
readingTimeSeconds, scheduledAt, publishedAt, archivedAt, createdAt, updatedAt }`.

**Mobile.** `data/datasources/publishing_remote_data_source.dart:21-58` decodes all four publication
actions with `PublicationEvent.fromJson`, and `:133-139` decodes the revert with
`StorySnapshot.fromJson`.

**Wire-level failure.** No exception — every mismatched field defaults.
`PublicationEvent` (`domain/entities/publication_event.dart:76-86`) comes back with `type: ''`
(no `type` on a piece), `storyId: ''`, `actorId: null`, `scheduledFor: null` (the wire says
`scheduledAt`), `createdAt` = the **piece's** creation time rather than the event time, and `id` =
the **piece id** rather than an event id. `revertToSnapshot` similarly yields a `StorySnapshot` whose
`id` is the piece id — feed that to `GET /snapshots/:id` and it 404s.

Today the screens use the return value only to decide the toast (`publishing_workflow_screen.dart`
`_run(...)` calls) and then re-read (`publishing_controller.dart:132-136`), so the corrupt entity is
discarded before it is displayed. It is nonetheless the wrong contract and the wrong thing to port.

**Fix size.** Decode the piece (there is already a `Piece` entity in the authoring feature) or have
the endpoints return the event. Cross-feature import is barred by the folder-structure rule, so the
honest client-side fix is a small publishing-local `PublishedStory` entity — ~30 lines. Server-side
(return `PublicationEventDto`) is smaller but changes a shipped contract; **this is a decision, not
a defect fix.**

**FIXED by correcting the decode, not the endpoint.** Chosen deliberately: changing five shipped
response contracts to suit one client is the wrong direction, and the piece-in-its-new-state is
genuinely more useful to a publishing screen than an event row. New publishing-local
`StoryPublicationState` (`story_publication_state.dart`) mirrors the fields of `PieceResponseDto` a
publishing UI needs — `id, title, status, visibility, wordCount, slug, scheduledAt, publishedAt,
archivedAt, updatedAt` — and deliberately omits `content` (the full TipTap document, which this screen
does not render). All five call sites now decode it; `publish`/`unpublish`/`schedule`/
`changeVisibility` and `revertToSnapshot` return it through the repository and controller. No
cross-feature import. Tests: "publication actions decode the piece, not an event (P-1)" — including
that revert's `id` is the piece id, the value that would have 404'd against `GET /snapshots/{id}`.

---

#### P-2 · **high** · ✅ **FIXED** · `schedule` sends the wrong key and one the DTO rejects

**Backend.** `publishing/dto/publishing-request.dto.ts:12-16`

```ts
export class SchedulePublicationDto {
  @ApiProperty({ format: 'date-time', example: '2026-08-01T09:00:00.000Z' })
  @IsDateString()
  scheduledAt!: string;
}
```

Consumed as `dto.scheduledAt` (`publishing.controller.ts:89`). `@Body()` is declared, so validation
applies.

**Mobile.** `publishing_remote_data_source.dart:38-49` sends
`{'scheduledFor': …, 'visibility': ?visibility}`.

**Wire-level failure.** `400 VALIDATION_FAILED` on every call: `property scheduledFor should not
exist`, `property visibility should not exist` (when set), and `scheduledAt must be a valid ISO 8601
date string` (missing). **Reachable: no** — `PublishingController.schedule`
(`publishing_controller.dart:45-56`) has no UI caller; the publishing screen offers publish,
unpublish, visibility, snapshot and revert only. Fix: rename the key, drop `visibility` (2 lines).

**FIXED.** The body is now exactly `{scheduledAt: <ISO-8601 UTC>}`; the parameter is renamed
`scheduledAt` up through the repository and controller so the wrong name cannot be reintroduced from
a caller. Test: "schedule body (P-2)" asserts the exact body and the absence of both offending keys.

---

#### P-3 · **high** · ✅ **FIXED** · the "Followers" visibility chip does not exist server-side

**Backend.** `packages/shared/src/enums.ts:26-31`

```ts
export const Visibility = { Public: 'public', Unlisted: 'unlisted', Private: 'private' } as const;
```

`ChangeVisibilityDto` (`publishing-request.dto.ts:19-23`) is `@IsIn(Object.values(Visibility))`.

**Mobile.** `domain/entities/collaboration_enums.dart:140-152`

```dart
abstract final class StoryVisibility {
  static const String private = 'private';
  static const String unlisted = 'unlisted';
  static const String followers = 'followers';   // ← not a Visibility value
  static const String public = 'public';
  static const List<String> ordered = <String>[private, unlisted, followers, public];
}
```

and the publish card renders one chip per value of `ordered`:
`publishing_workflow_screen.dart:251-265`.

**Wire-level failure.** Tapping **Followers** → `PATCH /stories/:id/visibility` with
`{"visibility":"followers"}` → `400 VALIDATION_FAILED` (`visibility must be one of the following
values: public, unlisted, private`), surfaced as a snackbar with the raw server message. **Reachable:
yes** (once C-1/C-2 let the card render). Fix: delete `followers` and the chip (2 lines) — the
comment on `:138-139` already concedes it is "not in the core policy vocab".

**FIXED.** `StoryVisibility` is now exactly `{private, unlisted, public}` — a true mirror of
`Visibility` — so the chip row (which iterates `ordered`) can no longer render an invalid value, and
the `Followers` arm is removed from `visibilityLabel`. Test: "visibility (P-3)" pins the mirror
against the server enum and asserts `followers` is absent.

---

#### P-4 · **high** · ✅ **FIXED** · a story with no review session throws instead of reading "Draft"

**Backend.** `publishing.controller.ts:142-148` returns `Promise<ReviewDto | null>`;
`review.service.ts:176-179`:

```ts
async get(storyId: string): Promise<ReviewDto | null> {
  const session = await this.repo.findCurrentSession(storyId);
  return session === null ? null : toReviewDto(session);
}
```

so with no session the wire is `200 {"success":true,"data":null}`
(`transform.interceptor.ts:38-40` wraps `null` as data).

**Mobile.** `publishing_remote_data_source.dart:70-75` uses `_api.get(..., decode:
ReviewSession.fromJson)`; `api_client.dart:52` calls `decode(_dataAsJson(response))`, and
`_dataAsJson` (`:326-330`) throws `API_MALFORMED_RESPONSE` because `data` is `null`. The provider
only converts `NOT_FOUND` to null:

```dart
// lib/features/collaboration/presentation/providers/collaboration_providers.dart:164-168
Err<ReviewSession>(:final Failure failure) =>
  failure.code == ErrorCodes.notFound ? null : throw failure,
```

`API_MALFORMED_RESPONSE` ≠ `NOT_FOUND`, so it rethrows.

**Wire-level failure.** The Review card renders `QErrorView` ("Malformed response (expected an
object)") instead of the Draft chip — `publishing_workflow_screen.dart:91-94` vs the `review == null`
branch at `:108-111` that was written for exactly this case and can never be reached. This is the
**default state of every story that has never been submitted for review**, i.e. the first thing any
user sees on that screen.

**Fix size.** Either add a nullable read to `ApiClient` (`getOrNull`) or have the endpoint 404 —
~10 lines client-side, and it makes the already-written `review == null` branch live.

**FIXED with an explicit nullable variant, not a loosened shared contract.** `_dataAsJson` backs
`get`, `post`, `patch` **and** `upload` — every feature in the app — so relaxing it would make a null
`data` acceptable everywhere, including on mutations where it really is malformed. Instead
`ApiClient.getOrNull` (+ a private `_dataAsJsonOrNull`) opts in per call site: `null` data yields
null, and anything else non-object still raises `API_MALFORMED_RESPONSE`. `review()` returns
`ReviewSession?` through the repository, and `storyReviewProvider` no longer tests for a `NOT_FOUND`
code the endpoint never sends — so the screen's `review == null` → Draft branch is now reachable.
Tests: "review null-data path (P-4)" (both branches) + `collaboration_repository_test.dart` +
the live suite.

**Confirmed live** (this closes NEEDS-LIVE-CONFIRMATION #4): `GET /api/v1/stories/:id/review` on a
story with no session returns exactly `{"success":true,"data":null}`.

---

#### P-5 · **medium** · ✅ **FIXED** · `requestChanges` sends `note`; the DTO declares `notes`

`RequestChangesDto` (`publishing-request.dto.ts:26-32`) declares `notes?` (optional, ≤ 5000),
consumed as `dto.notes` (`publishing.controller.ts:139`). Mobile sends `{'note': ?note}`
(`publishing_remote_data_source.dart:96-103`) from `publishing_controller.dart:88-94`. The current
caller supplies nothing (`publishing_workflow_screen.dart:156-158`), so the key is omitted and the
call passes — it becomes a `400` the moment a notes field is added to the UI, which is precisely what
"request changes" needs. Fix: rename to `notes` (1 line).

**FIXED.** Renamed to `notes` at the datasource, repository and controller. Test: "request-changes
body (P-5)" asserts `{notes: …}` and the absence of `note`.

---

#### P-6 · **medium** · ✅ **FIXED** · `ReviewSession` reads two keys the wire renames and ignores `decision`

`ReviewDto` (`publishing/dto/publishing-response.dto.ts:6-18`) is `{ id, storyId, requestedById,
state, reviewerId, decision, notes, submittedAt, decidedAt, createdAt, updatedAt }`.
`domain/entities/review_session.dart:40-51` reads `requestedBy` (wire: `requestedById`) and
`requestedAt` (wire: `submittedAt`) → both permanently null, and never reads `decision`
(`approve` / `request_changes` / `reject`, `packages/shared/src/publishing.ts:26-31`), so the client
cannot distinguish *why* a review left `in_review`. `state` and `notes` match; nothing currently
renders the null fields. Fix: ~4 lines.

**FIXED.** `ReviewSession` now mirrors `ReviewDto`: `requestedById`, `submittedAt`, `decision`,
`reviewerId`, `notes`, `decidedAt` — and the two `*Name` fields, which the wire never sends, are gone.
Test: "ReviewSession mirrors ReviewDto (P-6)".

---

#### P-7 · **medium** · ✅ **FIXED** · snapshots: the client invents `label`, drops `title`/`reason`, and its POST body is discarded

`SnapshotDto` (`publishing-response.dto.ts:21-32`) is `{ id, storyId, version, title, content,
wordCount, reason, createdById, createdAt }`. `domain/entities/story_snapshot.dart:29-39` reads
`label`/`name`, `createdBy`, `createdByName` — none emitted — and ignores `title`, `reason` and
`createdById`. `publishing_workflow_screen.dart:338-341` renders `snapshot.label ?? 'Version
${snapshot.version ?? ''}'`, so every row falls back to the version number and the snapshot's
`title` and `reason` (`publish` / `manual` / `pre_edit` / `review` / `restore`,
`packages/shared/src/publishing.ts:52-59`) are never shown.

**FIXED.** `StorySnapshot` now mirrors `SnapshotDto` — `version`, `title`, `reason`, `createdById`,
`wordCount` — with `label`/`createdBy`/`createdByName` removed. `label` became a derived getter
(`title`, falling back to `Version N`), and the snapshot row shows date · version · reason via a new
`snapshotReasonLabel`. `createSnapshot` sends no body. Tests: "StorySnapshot mirrors SnapshotDto
(P-7)", including the empty-title fallback.

Separately, `createSnapshot` sends `{'label': ?label}` (`publishing_remote_data_source.dart:115-122`)
to a handler that **declares no `@Body()`** (`publishing.controller.ts:163-172`, which hard-codes
`SnapshotReason.Manual`). The label is silently dropped with no error. Fix: read the real fields, drop
`label` (~8 lines).

---

#### P-8 · **medium** · ✅ **FIXED** · publish / unpublish / requestReview silently drop the parameters the client sends

`publish` (`publishing.controller.ts:55-65`), `unpublish` (`:67-77`) and `requestReview`
(`:106-115`) declare **no `@Body()`**. Mobile sends `{visibility?, note?}`
(`publishing_remote_data_source.dart:21-36`) and `{reviewerId?, note?}` (`:77-85`).

Because there is no `@Body()`, `ValidationPipe` never inspects the payload — so unlike P-2/P-3 these
are **not** 400s. They are worse in one respect: the user's intent ("publish as unlisted", "send this
to Amina for review") is accepted by the client, transmitted, and thrown away with a success
response. Fix: drop the parameters from the client (the features do not exist server-side) or add
them to the contract — a decision, sized separately.

**FIXED by dropping them.** `publish`, `unpublish`, `requestReview`, `approveReview` and
`createSnapshot` now send **no body**, and the parameters are removed from the datasource, repository
and controller signatures, so no UI can offer a control whose value would be silently thrown away.
Publish-with-a-visibility remains expressible as publish + `changeVisibility`. Tests: "bodies the
server never read are gone (P-8)" and the createSnapshot case.

---

### 2.3 AF6 — trust

---

#### T-1 · **high** · ✅ **FIXED** · `BlockEntry.userId` resolves to the block-row id, not the blocked user

**Backend.** `trust/dto/trust-response.dto.ts:40-46`

```ts
export class BlockDto {
  @ApiProperty() id!: string;
  @ApiProperty() blockerId!: string;
  @ApiProperty() blockedId!: string;
  @ApiProperty({ enum: ['block', 'mute'] }) kind!: BlockKind;
  @ApiProperty() createdAt!: string;
}
```

**Mobile.** `domain/entities/block_entry.dart:35-46`

```dart
final String userId = json['userId'] as String? ?? json['id'] as String? ?? '';
return BlockEntry(id: json['id'] as String? ?? userId, userId: userId, …);
```

There is no `userId` key on the wire and `blockedId` is never read, so `userId` silently becomes the
**block relationship's own id**.

**Wire-level failure.** Both ids are UUIDs, so `ParseUUIDPipe` passes and
`DELETE /users/{blockRowId}/block` reaches the service, which finds no such block →
`404 BLOCK_NOT_FOUND` (`trust/trust.exceptions.ts:34`). The list also shows the block-row id as the
person's name (`block_entry.dart:32`), since `username`/`displayName`/`avatarKey` are never emitted
either. **Reachable: no** — see T-3. Fix: read `blockedId` (1 line); the display-name gap is the same
decision as C-9.

**FIXED.** `BlockEntry` now mirrors `BlockDto` — `{id, blockerId, blockedId, kind, createdAt}` — with
the `userId ?? id` fallback and the three phantom profile fields removed. `blockedId` is documented as
the id the block/mute routes take, and `id` as the relationship row that must never be passed to
them. Test: "BlockDto (T-1)" asserts `blockedId != id`.

---

#### T-2 · **medium** · ✅ **FIXED** · `UserRestriction` reads `active` and `startsAt`, neither emitted; ignores `scope`

`RestrictionDto` (`trust-response.dto.ts:13-23`) is `{ id, userId, type, scope, reason, issuedById,
expiresAt, liftedAt, createdAt }`. `domain/entities/trust_summary.dart:30-37` reads `active`
(defaulting to `true`, `:36`) and `startsAt` — neither exists — and never reads `scope`.

The `active` default is **accidentally correct**: `TrustSummaryDto.restrictions` is documented and
built as "Currently-active restrictions" (`trust-response.dto.ts:56-57`), so
`activeRestrictions` (`trust_summary.dart:55-57`) filters nothing and gets the right answer. It is
correct by coincidence, not by contract — if the endpoint ever returns history, every lifted
restriction becomes active in the UI.

`scope` (`global` / `publishing` / `collaboration` / `comments` / `reporting`,
`packages/shared/src/trust.ts:50-57`) is the field that says *what* is restricted, and
`restricted_state_screen.dart:102-107` cannot show it. Fix: read `liftedAt` instead of `active`, read
`scope`, drop `startsAt` (~5 lines).

**FIXED.** `UserRestriction` now reads `scope`, `liftedAt` and `createdAt`; `active` became a derived
getter (`liftedAt == null`) instead of a defaulted phantom field, so the accidental correctness is now
contractual. Added the `RestrictionScope` mirror. Tests: "RestrictionDto (T-2)" — in-force, lifted, and
that `TrustSummary.activeRestrictions` filters on the derived flag.

---

#### T-3 · ~~**medium**~~ · ✅ **CLOSED 2026-08-03 (`48` M-4); verified in code 2026-08-20** · block / mute management is fully wired and completely unreachable

> **Verified 2026-08-20.** `BlocksScreen` is routed — `app/router/routes.dart:120`,
> `settingsBlocks = '/settings/blocks'` — and reached from the settings hub, whose own comment names
> itself as "the only entry point to `/settings/blocks`" (`settings_hub_screen.dart:110`). The wiring
> this entry said had no way in now has exactly one, deliberately. Closed as the entry-point half of
> `platfrom/docs/48` **M-4** ("ported, with the entry point treated as part of the port").

`trust.controller.ts:50-102` exposes `GET /me/blocks` and block/unblock/mute/unmute. Mobile has the
datasource (`trust_remote_data_source.dart:25-39`), the repository
(`trust_repository_impl.dart:26-38`), a controller with all four actions
(`trust_controller.dart:22-28`) and a `myBlocks` read provider
(`collaboration_providers.dart:207-213`) — and **no screen and no caller**: a grep across `lib`
finds `.block(` / `.unblock(` / `.mute(` / `.unmute(` only in those two files, and
`myBlocksProvider` only in `trust_controller.dart:47` (its own invalidation). The only trust screen
is `RestrictedStateScreen`, which reads the summary alone
(`restricted_state_screen.dart:26`).

This is the T-1 defect's shield and the reason it has never been seen. For W3c it means blocks/mutes
is a **build**, not a port.

**PARTIAL.** T-1 (the wrong id) is fixed, so the plumbing is now correct. A blocks-management **screen
is still not built** — that is a UI feature, not a contract repair, and inventing one was outside this
pass. It remains a build for W3c, as stated.

---

#### T-4 · *(no defect)* · `TrustSummary` matches `TrustSummaryDto` field for field

`trust_summary.dart:82-94` reads `score`, `level`, `status`, `activeStrikeWeight`, `restrictions` —
exactly `TrustSummaryDto` (`trust-response.dto.ts:49-58`). The `TrustStatus`
(`collaboration_enums.dart:91-100` vs `packages/shared/src/policy.ts:49-58`) and `RestrictionType`
(`:103-109` vs `packages/shared/src/trust.ts:40-47`) mirrors are complete and correct. Recorded
because it is the one AF6 read path a web port can copy verbatim.

---

### 2.4 AF6 — reachability

---

#### R-1 · **high** · ✅ **FIXED** · nothing in the app navigates to any AF6 screen

All six routes are registered — `lib/app/router/app_router.dart:550-601` — with helpers at
`lib/app/router/routes.dart:62-71`, whose comment claims they are "Deep-linkable from a story's
overflow menu". A grep for `collaborators`, `/publishing`, `/suggestions`, `me/invitations`,
`'/restricted'`, `invitationsInbox` and `trustRestricted` across `lib`, excluding
`lib/features/collaboration/`, `api_paths.dart`, `routes.dart` and `app_router.dart`, returns
**nothing**. There is no overflow menu entry, no settings link, no notification deep link.

**Consequence for this audit:** it explains why C-3, C-6, C-7, C-8, P-2, T-1 and T-3 were never
observed, and why docs/50's manual-test list could not have been executed as written (§6). It also
means "AF6 works on mobile" cannot be true in any user-facing sense today.

**FIXED.** Entry points added from the existing IA rather than invented:

- **Story-scoped** (Collaborators / Review comments / Suggestions / Publishing workflow) — added to the
  two overflow menus that already exist: `editor_screen.dart` `_overflow` and the drafts row menu in
  `drafts_screen.dart`, both following the precedent set there by the AI entries (a
  `PopupMenuDivider` + a flag-gated group). Gated on `enableCollaboration` **and** `draft.isRemote`,
  because the routes take the server piece id (`storyId === pieceId`) behind a `ParseUUIDPipe` — a
  never-synced draft has no story and its local route id would be rejected.
- **Invitations inbox** — a "Collaboration → Story invitations" tile in the settings hub, matching the
  flag-gated "Premium" section that already links `/billing` there.
- **Restricted state** — reached by *noticing*, as expected: a new `RestrictedBanner` on the editor,
  beside the existing `ConnectivityBanner`, which watches `trustSummaryProvider` and renders nothing
  in good standing. **There is no router-level interception and none was added**: `guardRedirect`
  (`lib/app/router/guards.dart`) is a deliberately pure, synchronous function of the session
  tri-state, and resolving trust needs an async server read, so a redirect there would break its
  stated contract. The banner is owned by the collaboration feature and exported from its barrel,
  which already documents this exact composition route for other features.

Cross-feature rules respected: the writing feature pushes AF6 routes **by name** (the sanctioned
contract) and imports only the collaboration barrel's public surface.

---

### 2.5 AF5 — monetization

Every request body and every response key the mobile client reads was checked against the DTOs.
**No wire-level defects.** For the record, the paths (`lib/core/network/api_paths.dart:67-96`) match
`@Controller('monetization')` + the route decorators one-for-one; the bodies at
`monetization_remote_data_source.dart:51-176` match `CreateSubscriptionDto`, `ChangePlanDto`,
`CancelSubscriptionDto`, `PurchaseCreditsDto`, `RestorePurchasesDto` and `ValidateCouponDto`
(`dto/monetization-request.dto.ts:32-124`) key-for-key including optionality; the five paginated
reads correctly use `getPage` and read `meta.pagination` (`monetization.controller.ts:405-427` vs
`api_client.dart:73-89`); and every enum mirror in `monetization_enums.dart` matches
`packages/shared/src/monetization.ts` value-for-value.

---

#### M5-1 · ~~**medium**~~ · ✅ **CLOSED 2026-08-03 (+ D3, 2026-08-17); verified in code 2026-08-20** · `PremiumGate` is used zero times; no premium surface gates on entitlements

> **Verified 2026-08-20.** `PremiumGate` now has real call sites outside its own feature — the two AF2
> writing surfaces (`features/ai/presentation/panels/writing_assistant_panel.dart`,
> `craft_coach_panel.dart`, gated by **D3**) and three collaboration notices
> (`capability_gate.dart`, `collaborator_seat_notice.dart`, `snapshot_history_notice.dart`), beside
> `subscription_screen.dart` and `credit_dashboard_screen.dart`. `premiumFeatureAllowedProvider` — the
> exported-and-unused provider this entry named — **no longer exists anywhere in `lib/`** (deleted as
> `48` **M5-5**). Tracked in `platfrom/docs/48` as **M5-1** and closed there on 2026-08-03.

`presentation/widgets/premium_gate.dart:21` declares the gate and its own doc comment says "Every
premium affordance elsewhere wraps its content in `PremiumGate`"; it is exported at
`monetization.dart:10`. A grep for `PremiumGate`, `premiumFeatureAllowedProvider` and
`entitlementSnapshotProvider` across `lib` finds **no use outside the monetization feature itself**
(only `plans_screen.dart:195` and the provider's own definition). The AF2 writing-assistant and
craft-coach surfaces, AF4 discovery/search, and analytics — the features `PremiumFeature`
(`monetization_enums.dart:60-69`) names — contain no entitlement check.

**Failure mode.** Not a wire defect: the server meters and enforces every AI call, so this is not a
paywall bypass. It is a UX defect — a free user gets a raw `402`/`403` from the server where a lock
card was designed. Fix: wrap the affordances (small per site, ~8 sites).

---

#### M5-2 · **medium** · ✅ **CLOSED 2026-08-21 (AF5-cs)** · `clientSecret` is dropped from the checkout result

> **Fixed 2026-08-21.** `CheckoutResult` now reads all three fields
> (`domain/entities/billing.dart:126` constructor, `:141` `fromJson`) and exposes
> `needsClientConfirmation` (`:133-134`). `plans_screen.dart`'s `_select` no longer falls through to the
> success snackbar when a checkout returns a secret and no URL — it shows an honest refusal instead.
> This is the "read + honest refusal" fix the ledger sized, not the on-device confirmation UI: a
> provider that actually needs the secret still cannot complete a purchase on mobile, it just no longer
> claims it did. Regression guard: `test/features/monetization/checkout_client_secret_test.dart`. Ledger
> line deleted from `platfrom/docs/48` §3.22a in the same commit.

`CheckoutDto` (`dto/monetization-response.dto.ts:24-28`) is `{ subscription, checkoutUrl,
clientSecret }`, populated at `monetization.controller.ts:184-188`. Mobile's `CheckoutResult`
(`domain/entities/billing.dart:114-127`) reads only `subscription` and `checkoutUrl`.

Consequence depends on when the backend sets one versus the other — **NEEDS-LIVE-CONFIRMATION**
against a configured Stripe key. From the source, the client can complete a checkout only via
`checkoutUrl` (`needsRedirect`, `billing.dart:120`); if a provider path returns a `clientSecret` and
no URL, the mobile flow has nothing to open and stalls with a "success" result. Fix: read the field
(2 lines); acting on it is a native-payment-sheet task.

---

#### M5-3 · **medium** · ✅ **NOT A DEFECT — the seam is the design; re-verified 2026-08-20** · credit purchase and restore cannot complete on any current build

`NoopStoreBillingGateway` (`lib/core/billing/store_billing_gateway.dart:93-110`) reports
`isAvailable => false` and throws `StoreBillingUnavailable` from `purchase`/`restorePurchases`, and
it is the bound default (`monetization_providers.dart:45-46`).
`subscription_controller.dart:96-99` and `:75-78` therefore throw before any HTTP call. Server-side
agrees a receipt is mandatory — `monetization.controller.ts:308-310` raises
`RECEIPT_VALIDATION_FAILED` without one.

This is the documented seam design, not a defect — recorded so W-row sizing does not assume the
credit-pack and restore flows are exercised code. Everything up to the store SDK is correct.

---

#### M5-4 · ~~**low**~~ · ✅ **CLOSED 2026-07-29 (`48` W4-2); verified in code 2026-08-20** · the declared response class for `purchases/restore` is not what the route returns

> **Verified 2026-08-20.** The route now declares the class that matches reality:
> `@ApiOkResponse({ type: RestoreResultDto })` (`monetization.controller.ts:359`), and
> `RestoreResultDto` is exactly `{ restored, providerRef, expiresAt }`
> (`dto/monetization-response.dto.ts:167-171`) — the shape the handler returns and the shape mobile's
> `RestoreResult` reads. The wrong response class is gone; `RestorePurchasesDto` survives only as the
> **request** body (`:362`). Swagger and `@qalam/api-types` therefore emit the true shape, which was
> this entry's whole concern. Closed on the backend as `48` **W4-2**.

`monetization.controller.ts:358-369` returns an inline `{ restored, providerRef, expiresAt }`, while
`RestorePurchasesDto` (`dto/monetization-response.dto.ts:155-159`) declares `{ restored,
subscription, creditsGranted }` and is not referenced by the route. Mobile's `RestoreResult`
(`billing.dart:137-140`) reads `restored` + `expiresAt` — i.e. **the client matches reality and the
DTO class is the wrong one**. Flagged because the web port must generate from the controller, not
from this class, and because Swagger/`@qalam/api-types` will emit the wrong shape. Fix: backend, ~6
lines.

---

#### M5-5 · **low** · minor read-side omissions

- `CreditBalance` (`domain/entities/credit.dart:105-110`) does not read `updatedAt`, which
  `CreditBalanceDto` (`monetization-response.dto.ts:92-98`) emits. Unused; no impact.
- `monetization_enums.dart:60-69` omits the reserved `marketplace` / `collaboration` / `enterprise`
  features and `PaymentProvider.manual` (`packages/shared/src/monetization.ts:118-121, 241`). No plan
  grants them (`DEFAULT_PLAN_FEATURES`, `:500-528`), and `featureLabel`
  (`presentation/domain_labels.dart:33-43`) has a `_ => feature` fallback, so an unknown feature
  renders its raw code rather than crashing. Correct as-is.

---

### 2.6 Found while landing C-2 + D1 (2026-07-28, later)

Recorded, **not fixed** — each is outside the scope of the pass that found it.

---

#### C-13 · **high** · ✅ **FIXED (both clients, §2.7)** · accepting a suggestion rewrites the prose, and no client re-reads the piece

**Precondition.** As of the D1 fix (§3b) `POST /suggestions/:id/accept` replaces the anchored range of
the piece body server-side. Every client cache holding that body is stale the instant it returns.

**Mobile.** `presentation/controllers/collaboration_controller.dart:221-224`:

```dart
void _refreshSuggestions() {
  ref.invalidate(storySuggestionsProvider);
  ref.invalidate(storyCapabilitiesProvider);
}
```

That is the whole post-accept refresh, and it is what `acceptSuggestion` (`:152-153`) passes. Nothing
invalidates the piece — not the reader's content provider, not the editor's draft.

**Web.** `frontend/src/features/collaboration/hooks/use-suggestions.ts` — `invalidateSuggestions`
invalidates `['stories', storyId, 'suggestions']` only, and `acceptSuggestion.onSuccess` is exactly
that function. `qk.pieces.*` is untouched.

**Why it matters more than a stale render.** A reader showing the pre-accept text is a display bug. An
**editor** holding pre-accept content that then autosaves is a data-loss bug: the save writes the old
passage back over the applied edit, and the suggestion stays marked accepted.

**Correction (the original entry overstated the mobile half).** The two clients are not equally
exposed, and the difference is the presence of a stale-write check:

- **Web has no check.** `use-draft-autosave.ts:92-95` PATCHes `{title, content, languageCode}` on a
  2s debounce with nothing compared against the server's `updatedAt`, and `use-piece.ts` hydrates
  TipTap from `qk.pieces.detail` **once** with a 60s `staleTime`. Accept → return to the editor
  inside that window → the editor seeds the PRE-accept body → the next keystroke PATCHes it back
  over the applied edit. **This is the real data-loss path.**
- **Mobile is already guarded.** `draft_sync_engine.dart:149-168` `_pushUpdate` re-reads the server
  head and refuses when `serverAt.isAfter(base)`, yielding `DraftSyncState.conflict` /
  `lastError: 'server_changed'` and the existing keep-server / keep-local resolution
  (`current_draft_controller.dart:328-354`). So a body the accept moved surfaces as a conflict, not
  a silent overwrite. Mobile's exposure was a stale *render*, not lost text.

**FIXED (2026-07-29, §2.7).** Both clients now drop the piece caches in the accept path only —
reject and withdraw move no prose and keep the narrow refresh. §3 point 3 predicted this
requirement; the server arm landed without it.

---

#### C-14 · ~~**medium**~~ · ✅ **CLOSED 2026-07-29 (W3c-4), heading corrected 2026-08-20** · the web suggestion UI tells the writer the opposite of what the server now does

> **Verified in code 2026-08-20.** The interim copy is gone from
> `frontend/src/features/collaboration/components/suggestion-card.tsx`, and its own spec now asserts
> the **absence** of the sentence (`suggestion-card.spec.tsx:89`,
> `queryByText(/apply the replacement in the editor/i)).not.toBeInTheDocument()`). Closed with the copy
> and its three assertions on 2026-07-29 as `platfrom/docs/48` **W3c-4**; this heading stood open for
> 22 days afterwards, which is the drift `48 §3.22` now guards against.

`frontend/src/features/collaboration/components/suggestion-card.tsx:75` renders, to the user:

> Accepted — apply the replacement in the editor. Accepting records the decision; it does not …

and the file header (`:16-19`) plus `use-suggestions.ts:17-19` state the same as contract fact
("**Accepting does not rewrite the prose.**"). All three were true when written and are now wrong. The
mobile equivalents were corrected in this pass (`suggestions_screen.dart`, `edit_suggestion.dart`);
the web ones were out of scope. Web-only, text + doc-comment change.

---

#### C-15 · **medium** · **mobile half CLOSED 2026-08-21; web half still OPEN** · the web composer's hand-typed offset cannot produce a reliable anchor, and (until now) mobile had no composer at all

`suggestion-composer.tsx:68-77` asks the writer to type "Starts at character" and derives `to` from the
replaced text's length; its own header explains why (a standalone route with no editor selection to
read). Under the old server behaviour a wrong offset was harmless — the conflict check was
`text.includes(originalText)`, which ignored the anchor entirely. The D1 fix makes the check
**offset-exact** (`text.slice(from, to) === originalText`; see §3b), so a hand-typed offset that is off
by one now returns 409 instead of succeeding. This half is unchanged and still open — re-scoped
2026-08-21 to ≈3–4 d once the actual accept-time coordinate space was traced through.

~~Web-only. Mobile is unaffected in practice...~~ **This was wrong, corrected 2026-08-20 in
`platfrom/docs/48` §3.22a before mobile's half was built**: the "mobile is unaffected" premise rested on
R-1 (no AF6 entry point at all), and R-1 closed 2026-08-03. The real reason mobile never produced an
anchor was that it had no composer, not that reaching one was blocked.

**Mobile's half closed 2026-08-21.** Rather than build the same free-range, editor-integrated selection
web still needs, mobile ships whole-paragraph granularity: a reader taps a whole block to propose an
edit to it, sidestepping character-level selection UI entirely (this app had zero precedent for it
anywhere — comments have the identical anchor-less gap, §2.1). `parseContentWithAnchors`
(`lib/features/reading/domain/content_parser.dart`) computes the block's offset directly in the
backend's `anchorText` coordinate space — same-object-identity-keyed against the render tree so the tap
target and the offset can never desync — and correctly walks a forward-compatible unknown block type's
nested text rather than skipping it, which a design-validation pass caught before it shipped
(`content_parser_test.dart` pins it as a regression case). `SuggestionComposerSheet`
(`features/collaboration/presentation/widgets/`) is the compose UI; `ReaderActionBar`'s new "Suggest an
edit" entry (gated on `story.suggest`) is the entry point. Tested (`flutter test`, `flutter analyze`
clean) but **not live-verified against a running backend** — do that before trusting it fully.

---

### 2.7 C-13 fix + the two-projection hazard (2026-07-29)

Two follow-ups to the C-2 / D1 pass, one a defect fix and one a trap closed before it fired.

---

#### C-13 fix · the accept path drops the piece caches, on both clients

**Web** — `frontend/src/features/collaboration/hooks/use-suggestions.ts`:

```ts
const invalidateAfterApply = async (): Promise<void> => {
  await Promise.all([
    invalidateSuggestions(),
    client.invalidateQueries({ queryKey: qk.pieces.all }),
  ]);
};
// acceptSuggestion.onSuccess = invalidateAfterApply  (reject/withdraw keep invalidateSuggestions)
```

The whole `qk.pieces` prefix, not `detail(storyId)`: the reader is **slug**-keyed
(`qk.pieces.bySlug`) and the accept path has no slug to name, and `query-keys.ts` already documents
the prefix as the way a content mutation clears both views at once.

**Mobile** — `collaboration_controller.dart`, a second refresh next to the existing one:

```dart
void _refreshAppliedSuggestion() {
  _refreshSuggestions();
  ref.invalidate(pieceDetailControllerProvider);   // reader — getPiece is network-first
  ref.invalidate(storySnapshotsProvider);          // the accept captured a pre_edit version
}
```

`ReadingRepositoryImpl.getPiece` is network-first (the Hive copy is a transport-error fallback only),
so the invalidation is a real re-read and it refreshes the cached body too.

**The open mobile editor is deliberately NOT force-refreshed.** Its document is local-first
(`CurrentDraftController` hydrates from the Hive draft, never from `pieceDetailControllerProvider`),
so adopting the server copy would discard unsynced local edits. The writer is protected by the sync
engine's existing stale-write check instead — see the correction in C-13. Reaching across into the
editor's draft store to reconcile a server-applied edit is a real piece of work (it is the same
problem `resolveConflict` already models) and is not in this fix.

**Tests**, both written to fail against the pre-fix code and confirmed to do so:

| Test | Asserts |
| --- | --- |
| `frontend/.../hooks/use-suggestions.spec.tsx` (4) | accept invalidates `qk.pieces.all` **and** the suggestions key; reject and withdraw touch no `pieces` key; both piece views share the prefix |
| `test/features/collaboration/collaboration_controller_test.dart` (+3) | accept forces exactly one extra `getPiece`; reject and withdraw force none |

Asserting the negative for reject/withdraw is the half that keeps this honest — a blanket
"invalidate everything on any resolution" would pass the accept test and quietly refetch the piece
on every rejection.

---

#### The two-projection hazard · `anchorText` vs `@qalam/utils` `extractPlainText`

Not a defect — a trap. The platform flattens a TipTap document to a string in two places and the two
**already disagree**, measurably:

```
{p:"first"}{p:"second"}  →  @qalam/utils: "first second" (12)   collaboration: "firstsecond" (11)
```

`@qalam/utils` inserts `' '` between text nodes and collapses/trims (it feeds FTS, word count and
reading time); the collaboration copy concatenates verbatim. Every block boundary shifts every later
offset by one.

**They must not be unified, and the raw concatenation is the one anchors require.** Its offsets map
one-to-one onto characters that really exist inside text leaves, which is what lets
`replaceTextRange` find and rewrite the passage. Under the utils projection an offset can land on a
separator no leaf contains — an anchor naming a character there is nothing to replace.

So the hazard was not drift, it was the shared **name**: two functions called `extractPlainText`, one
import line apart, inviting exactly the "deduplication" that would silently move every stored anchor.
Closed by:

1. **Renaming** the collaboration one to `anchorText`, with the comparison table and the reasoning in
   the file header.
2. **One leaf predicate** (`isTextLeaf`, `type === 'text'` + string `text`) shared by the read and the
   write, and matching `@qalam/utils`. Previously the read accepted any node carrying a string
   `text`; had the read and the write ever disagreed about what counts as text, offsets and edits
   would have addressed different documents.
3. **`content-text.divergence.spec.ts`** (6 tests) — imports both implementations and pins the
   difference on one document: the two strings, the one-character-per-boundary delta, agreement on a
   single block, agreement on which nodes are leaves, verbatim vs collapsed whitespace, and the
   `anchorText` → `replaceTextRange` round trip. A change to **either** side fails here.

---

## 3. D1 evidence — what accepting a suggestion actually does today

The question in `platfrom/docs/45` §4.4 is whether the **server** rewrites the piece on accept or the
**client** applies the replacement. This section only establishes the facts.

**The server does not touch the piece.** `collaboration/suggestion.service.ts:47-55` states it
outright:

```ts
/**
 * Story edit suggestions / "track changes" (AF6). … Accept marks the suggestion accepted after a
 * conflict check (the story text must still contain `originalText`); it does NOT
 * mutate the piece content — applying the edit is the writer's editor action.
 */
```

and the implementation matches. `accept` (`:145-174`) does exactly four things: assert
`SuggestionResolve` on the policy engine (`:147-151`), assert the suggestion is still pending
(`:153`), run the conflict check (`:154`), then `settle(...)` (`:156-161`).

`settle` (`:266-286`) is the only write:

```ts
private settle(suggestion, status, resolverId, activityType): Promise<StorySuggestion> {
  suggestion.status = status;
  suggestion.resolvedById = resolverId;
  suggestion.resolvedAt = new Date();
  return this.repo.withTransaction(async (manager) => {
    const saved = await this.repo.saveSuggestion(suggestion, manager);
    await this.activity.record(suggestion.storyId, resolverId, activityType,
      { suggestionId: suggestion.id }, manager);
    return saved;
  });
}
```

Three columns on `story_suggestion` plus one `collaboration_activity` row. No `PiecesService` write,
no snapshot, no `publication_event`.

The conflict check is **read-only** — `assertNoConflict` (`:252-264`) loads the piece as the owner,
extracts plain text, and throws `SuggestionConflictException` if `originalText` is no longer present:

```ts
const piece = await this.pieces.getById(storyId, ownerId);
const text = extractPlainText(piece.content);
if (!text.includes(suggestion.originalText)) { throw new SuggestionConflictException(); }
```

**No revision is recorded.** The publishing module's snapshot service is the only revision mechanism
(`publishing/snapshot.service.ts`, reasons `publish` / `manual` / `pre_edit` / `review` / `restore`,
`packages/shared/src/publishing.ts:52-59`) and nothing in the suggestion path calls it. The
collaboration activity feed gets `suggestion_accepted`
(`packages/shared/src/collaboration.ts:101`) — an audit entry, not a content version.

**Therefore: the suggestion is merely marked accepted.** The piece body is byte-identical before and
after.

**What the client must do, given that.** Under today's server behaviour, accepting is a *bookkeeping*
action, and a client that says otherwise is lying:

1. **Stop claiming a change was applied.** `suggestions_screen.dart:170` passes
   `'Suggestion accepted.'` as the success message — corrected in §8.2 to say what happened.
2. **If the client is to apply the edit** (the client-side arm of D1), it needs three things it does
   not have: the anchor (`from`/`to`) — dropped by C-4 and never sent by C-3; a text-editing surface
   on the suggestions screen (there is none — it is a read-and-resolve list); and a piece-content
   write path, which lives in the authoring feature that collaboration may not import. That arm is a
   genuine integration, not a wiring change.
3. **If the server is to apply the edit** (the server-side arm), the client changes almost nothing:
   accept already returns the settled `SuggestionDto`, and the screen already re-reads on success
   (`collaboration_controller.dart:223-226`). It would additionally need to invalidate whatever
   renders the piece body.
4. **Either way, surface the conflict.** `SUGGESTION_CONFLICT` (`collaboration.exceptions.ts:174`) is
   the signal that the text moved underneath a pending suggestion. Mobile shows it as a generic
   snackbar (`suggestions_screen.dart:193-195` → `_errorMessage`), with no "this no longer applies"
   affordance. That is true regardless of how D1 lands.

This section states facts only; the decision remains open.

---

## 3b. D1 resolved — the SERVER applies the edit (2026-07-28, later)

The decision landed on the server-side arm. §3 above is preserved as the pre-fix diagnosis; this is
what replaced it.

**`accept` now applies the suggestion.** `collaboration/suggestion.service.ts`:

```ts
this.assertPending(suggestion);
const content = await this.resolveAnchor(suggestion, facts.authorId);

await this.snapshots.capture(suggestion.storyId, user, SnapshotReason.PreEdit);
const saved = await this.repo.withTransaction(async (manager) => {
  await this.pieces.replaceContent(suggestion.storyId, facts.authorId, content, manager);
  return this.settle(suggestion, SuggestionStatus.Accepted, user.id,
    ActivityType.SuggestionAccepted, manager);
});
```

Five decisions, each made to avoid a second mechanism:

1. **One authorization path.** The existing `engine.assert(SuggestionResolve)` is the only decision.
   The snapshot goes through a new non-asserting `SnapshotService.capture` rather than `create`,
   because `create` asserts `PublicationPublish` — a *different* action with a different restriction
   scope, which would deny a co-author who may legitimately accept but not publish. `create` is now
   `assert → capture`; nothing about the publish path changed.
2. **One transaction for the rewrite and the resolution.** `PiecesService.replaceContent(id, ownerId,
   content, manager)` is new and takes a **required** `EntityManager`, so it enlists in the caller's
   transaction (the house pattern per `common/database/transaction-runner.ts`). It reuses
   `sanitizeContent` + `deriveContentMetrics`, so the content write is not reimplemented outside the
   pieces module. `settle` gained an optional `manager` for the same reason. A failed apply can no
   longer leave a suggestion marked accepted.
3. **The snapshot sits outside that transaction**, before the write — the same ordering
   `PublishingService.publish` uses. A `pre_edit` snapshot of content that then failed to change is
   inert; the inverse (an accepted suggestion whose prose never changed) is the defect being fixed. No
   new table and no migration: `story_snapshots` with `reason = 'pre_edit'` already existed for exactly
   this case.
4. **The anchor is offset-exact, and a stale anchor writes nothing.** `resolveAnchor` replaces the old
   `assertNoConflict`: the text at `[from, to)` in the plain-text projection must still equal
   `originalText`, and the range must still fit the document, else **409 `SUGGESTION_CONFLICT`**. No
   fuzzy matching and no relocating to another occurrence — silently rewriting a passage the author
   never agreed to is worse than refusing an acceptance the reviewer can re-propose. The old
   `includes` check would have applied the edit at whatever offset the anchor named, however wrong.
5. **The response shape is unchanged** — still the settled `SuggestionDto`.

**The write itself** is `content-text.util.ts` `replaceTextRange`, the inverse of the
`extractPlainText` projection the anchors are expressed in (confirmed as the contract from both
clients: web's "Offset in the piece's text", mobile's `TextAnchor`). The replacement lands in the first
text leaf the range actually covers, keeping that leaf's marks; the remainder is removed from the
following leaves; a leaf left empty is dropped. Node types, attrs, marks and structure are otherwise
untouched.

**Tests.** `suggestion.service.spec.ts` grew four cases — the rewrite, the `pre_edit` capture, the
single transaction (all three writes receive the same manager), and two stale-anchor branches
including *"`originalText` still occurs elsewhere"*. `content-text.util.spec.ts` is new: eight cases
over single-leaf, cross-leaf, cross-block, mark preservation, empty-leaf drop and insertion.
Live evidence is in §0b.

**What the clients owed:** re-reading the piece body after an accept — recorded as **C-13**, a real
defect rather than the prediction §3 point 3 made, and fixed on both clients in §2.7.

---

## 4. Per-surface verdict

**PORTABLE** — mobile is a correct reference for the web port.
**FIX-THEN-PORT** — defects listed; fix them and mobile becomes the reference.
**BUILD-FROM-CONTRACT** — mobile is too wrong to port from; build from the DTO.

**Updated after the repair pass.** The "Was" column is the original verdict; "Now" is the verdict
after the fixes. Every row that moved did so because the defects behind it are closed **and** covered
by a regression test — not because the estimate was revised.

| # | Surface | Endpoints | Was | Now | Why it moved (or did not) |
| --- | --- | --- | --- | --- | --- |
| 1 | Membership (list / add / role / remove / leave) | 5 | FIX-THEN-PORT | **PORTABLE** | C-9 closed: `StoryMember` mirrors `MemberDto` exactly. Names still need a backend field — a product gap, not a client defect. |
| 2 | Invitations | 6 | PORTABLE | **PORTABLE** | Unchanged (M-1 already live-verified). |
| 3 | Capability map | 1 | BUILD-FROM-CONTRACT | **PORTABLE** | C-1 fixed and proven against a captured live payload. The decoder is now the clearest reference in the feature — web should copy its shape handling. C-2 (the server-side gap that affected both clients equally) is closed; the explained set is 12. |
| 4 | Comments | 5 (+1 now called) | BUILD-FROM-CONTRACT | **PORTABLE** | C-5/C-6/C-7/C-10 closed: the thread endpoint is called, the anchor is `{from,to,quote}`, `parentId` is gone, the list is paged. A web port can follow this shape directly. |
| 5 | Suggestions | 4 | BUILD-FROM-CONTRACT | **FIX-THEN-PORT** | C-3/C-4/C-10/C-12 closed, so the read + resolve + withdraw paths are a valid reference. Held back from PORTABLE for two reasons: **there is still no compose affordance**, so a web port has no create-UI precedent to copy — only the (now correct) request shape. The accept path itself IS now a reference: it applies the edit server-side and both clients drop the piece caches (C-13, §2.7). |
| 6 | Presence + activity | 3 | FIX-THEN-PORT | **PORTABLE** | C-8/C-10/C-11 closed. The activity feed still has no consumer, so the *screen* is a build — the contract is a valid reference. |
| 7 | Publication actions | 4 | BUILD-FROM-CONTRACT | **PORTABLE** | P-1/P-2/P-3/P-8 closed. All four now decode `PieceResponseDto` correctly and send only bodies the server reads. |
| 8 | Review workflow | 4 | BUILD-FROM-CONTRACT | **PORTABLE** | P-4/P-5/P-6/P-8 closed — including the null-session path, which is the single most valuable thing for web to copy (it will hit the same `data: null`). |
| 9 | Snapshots + revert | 4 | FIX-THEN-PORT | **PORTABLE** | P-1/P-7 closed: real `version`/`title`/`reason`, no invented label, revert decodes the piece. |
| 10 | Publication history | 1 | FIX-THEN-PORT | **PORTABLE** | `PublicationEvent` is now used only where the wire really sends an event (the history list), which it always matched. |
| 11 | Trust standing (`/me/trust`) | 1 | PORTABLE | **PORTABLE** | T-2 closed on top (scope + `liftedAt`); confirmed live. |
| 12 | Blocks / mutes | 5 | BUILD-FROM-CONTRACT | **FIX-THEN-PORT** | T-1 closed, so the entity and all five calls are correct and portable. **Still BUILD for the UI**: no blocks screen exists on mobile (T-3), so there is no interface to port — only the data layer. |
| 13 | AF5 plans + entitlements | 3 | PORTABLE | **PORTABLE** | Untouched — no AF5 defects. |
| 14 | AF5 subscription lifecycle | 8 | PORTABLE | **PORTABLE** | Untouched. |
| 15 | AF5 usage + credits | 4 | PORTABLE | **PORTABLE** | Untouched. |
| 16 | AF5 billing history | 3 | PORTABLE | **PORTABLE** | Untouched. |
| 17 | AF5 restore + coupons | 2 | PORTABLE | **PORTABLE** | Untouched. M5-4 is still a backend DTO-class inconsistency; generate web types from the controller. |
| 18 | AF5 premium gating (client-side) | — | BUILD-FROM-CONTRACT | **BUILD-FROM-CONTRACT** | **Did not move.** M5-1 is untouched: `PremiumGate` still has zero usages, so there is still nothing to port. Out of scope for an AF6 repair pass. |

**Totals: 6 PORTABLE → 14 PORTABLE, 4 FIX-THEN-PORT → 2, 8 BUILD-FROM-CONTRACT → 1.**

**The three rows that did NOT reach PORTABLE, and exactly why:**

- **Suggestions (5)** and **Blocks/mutes (12)** — data layer correct and tested; the *UI* to port does
  not exist (no suggestion composer, no blocks screen). Both are UI builds, and both were already
  described as builds in the original sizing, so the estimates below do not move much.
- **AF5 premium gating (18)** — deliberately untouched by this pass.

## 5. Sizing for docs/45

Baseline used: W3a (collaboration core — collaborators page, invite dialog, story invitations,
invitations inbox, three shared components) landed against a **PORTABLE** mobile reference. Sizes
below are relative to that row, so docs/45 can carry a real number per row.

| Row | Scope | Mobile reference | Size | Why |
| --- | --- | --- | --- | --- |
| **W3b** — inline review | comments (general + inline anchors, threads, resolve, @mentions), suggestions (accept/reject/withdraw + conflict) | **BUILD-FROM-CONTRACT** (rows 4, 5) | **≈1.6 × W3a** | Threads have no client implementation to copy (C-5): `GET /comments/:id/thread` is uncalled and `replies` is never emitted, so the thread model is designed from the DTO. Inline anchors are wrong in both directions (C-6) and suggestion create cannot validate (C-3), so both anchored paths are built from `CommentAnchorDto`/`SuggestionAnchorDto`. `@mentions` are unbuilt on both clients (docs/45 §4.4 P-2) — they are new work either way. Only resolve/reject/withdraw and the list rendering can be read off mobile, and even those need C-10 pagination the mobile client lacks. |
| **W3c** — publishing + trust | review→approve→publish, snapshots + revert, publication history, restricted-state walls, blocks/mutes | **BUILD-FROM-CONTRACT** (rows 7, 8, 12) + **FIX-THEN-PORT** (9, 10, 11) | **≈1.8 × W3a** | Five of nine publishing calls are wrong (P-1…P-5) and the review "no session" path — the default state — throws on mobile (P-4), so the state machine is modelled from `ReviewDto`/`ReviewState` rather than copied. Blocks/mutes has **no mobile UI at all** (T-3) and its entity mis-identifies the user (T-1): pure new build from `BlockDto`. Two credits: the restricted-state wall reads `TrustSummaryDto` correctly (T-4) and is portable, and snapshots/history need only the P-1/P-7 response-shape correction, not a redesign. |
| **W7** (AF6 part) | conversation layer, @mentions | n/a here | **unchanged by this audit** | The AF6-adjacent item is P-2 (@mentions), unbuilt on both clients; the AF6 comment `mentions` array is accepted by `CreateCommentDto`/`CreateReplyDto` (`collaboration-request.dto.ts:140-144, 155-159`) and correctly sent when non-empty by mobile (`collaboration_remote_data_source.dart:161`) — there is simply no composer UI. Sizing unaffected. |
| **W8** (AF5 part) | AI usage screens | **PORTABLE** (rows 13–17) | **≈0.7 × the pre-audit estimate** | AF5 has no wire defects; the mobile datasource/entities are a faithful, complete reference for all 19 endpoints, including cursor pagination done correctly. Deduct nothing for contract discovery. **Add** one item that this audit found: M5-1 — client-side premium gating does not exist on mobile, so web must build its own lock affordances from `EntitlementSnapshotDto` rather than port them, and mobile should get the same treatment for parity. |

**Ordering consequence.** C-1 is not W3b or W3c work — it is a live mobile bug that makes the whole
AF6 feature inoperable, alongside R-1 (no entry point). Fixing them is a prerequisite for anyone
manually validating either row, and neither is on the critical path of the web port.

### 5b. Re-sized after the repair pass

The repair changed the *inputs* to these estimates: 8 BUILD-FROM-CONTRACT rows became 1, so most of
W3b/W3c is now a port from a tested reference rather than a design-from-DTO.

| Row | Was | Now | What changed |
| --- | --- | --- | --- |
| **W3b** — inline review | ≈1.6 × W3a | **≈1.0 × W3a** | Comments moved to PORTABLE: the thread model, the anchor shape and the paged list are all built and tested, so web copies them instead of deriving them from `CommentThreadDto`. Suggestions' read/resolve/withdraw are portable too. The residual is the **compose UI** (no mobile precedent) and `@mentions` (unbuilt on both clients) — both genuinely new work, which is why this is not below 1.0. |
| **W3c** — publishing + trust | ≈1.8 × W3a | **≈1.1 × W3a** | Publication actions, the review state machine (including the `data: null` → Draft path web will hit identically), snapshots and history are all PORTABLE and covered. The residual is the **blocks/mutes screen**, still a build, plus the restricted-state wall — which mobile now has an entry point for, so the pattern is portable. |
| **W7** (AF6 part) | unchanged | **unchanged** | Still `@mentions`, still unbuilt both sides. The `mentions` array is correctly sent when non-empty. |
| **W8** (AF5 part) | ≈0.7 × pre-audit | **≈0.7 × pre-audit** | Untouched by this pass. M5-1 still stands: web builds its own lock affordances. |

**~~One dependency to schedule, not absorb:~~ landed 2026-07-28 (§0b).** C-2 was a one-line backend
change (`COLLABORATION_CAPABILITY_ACTIONS`); until it landed, publishing affordances default-denied on
**both** clients. It is in, so a web port of W3c inherits working gates.

**What a web port still needs to absorb** (§2.6): **C-14** and **C-15**, both web-only and both in
already-existing web code — the suggestion card's now-false text, and the composer's hand-typed
anchor. **C-13** is done on both clients (§2.7), so the accept path's cache handling is a reference
rather than a debt.

---

## 6. Corrections for docs/50 (`50_MobileAF6ReadinessReport.md`)

The manual-test list at docs/50 §"Manual testing" (lines 64-71) reads:

> Enable with `--dart-define=QALAM_ENABLE_COLLABORATION=true`. From a piece the user owns: open
> **Collaborators** (invite by **handle** → the invitee sees it in **Invitations Inbox** → accept),
> **Comments** (inline thread + resolve), **Suggestions** (propose → owner accepts), **Publishing**
> (request review → approve → publish; snapshots + history). Sign in as a restricted user to see
> **Restricted State**; the capability gates hide disallowed actions throughout.

The 2026-07-28 correction note already downgrades this list to "unverified". This audit converts
"unverified" to a per-claim verdict.

| # | docs/50 claim | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | "From a piece the user owns: **open Collaborators / Comments / Suggestions / Publishing**" | **REFUTED** | R-1 — no navigation to any AF6 route exists anywhere in the app. These screens cannot be *opened* from a piece; only a deep link reaches them. |
| 2 | "invite by **handle** → invitee sees it in **Invitations Inbox** → accept" | **CONFIRMED** | The only claim with independent live evidence (docs/50 "Invite by handle", regression tests in `test/features/collaboration/invite_contract_test.dart`). Re-derived here: body `{inviteeId, role}` matches `CreateInvitationDto` (`collaboration-request.dto.ts:92-100`), accept decodes `MemberDto` (`invitation.service.ts:160`), and `StoryInvitation` mirrors `InvitationDto`. Verdict row 2 = PORTABLE. |
| 3 | "**Comments** (inline thread + resolve)" | **REFUTED, twice over** | *Inline*: the anchor the client sends is `{blockId, start, end, quote}` against a DTO that requires `{from, to}` → 400 (C-6), and no UI sends an anchor at all. *Thread*: `CommentDto` has no `replies` and `GET /comments/:id/thread` is never called, so `comment.replies` is always empty and `comments_screen.dart:111` renders nothing (C-5). A **general** comment does post correctly, and *resolve* is contract-correct — but its button is inside a `CapabilityGate` that always denies (C-1), so it cannot be clicked. |
| 4 | "**Suggestions** (propose → owner accepts)" | **REFUTED** | *Propose*: no compose affordance exists, and `addSuggestion` would 400 (missing required `anchor`, two undeclared keys — C-3). *Accepts*: the Accept button is gated on `suggestion.resolve`, denied by C-1. Even had it been clicked, the toast overstated the result (§3, fixed in §8.2). |
| 5 | "**Publishing** (request review → approve → publish; snapshots + history)" | **REFUTED** | Every button on that screen is gated on `story.edit` / `review.approve` / `publication.publish` — three actions the capability endpoint does not return (C-2) on top of C-1, so the cards render empty. Independently, the Review card shows an error rather than "Draft" for any story without a review session (P-4), which is every story before the flow starts. Snapshots and history do read correctly, so only their *display* claim survives. |
| 6 | "Sign in as a restricted user to see **Restricted State**" | **CANNOT JUDGE** | The contract is correct (T-4: `TrustSummary` mirrors `TrustSummaryDto`; `RestrictionType`/`TrustStatus` mirrors complete), so the screen will render real data once reached. Whether a *restricted* user actually resolves to a restricted `TrustStatus` depends on strike/restriction seeding and `TrustStatusService`, which a static diff cannot exercise — **NEEDS-LIVE-CONFIRMATION**. Note the screen is only reachable at `/restricted` by deep link (R-1), and `scope` is not displayed (T-2). |
| 7 | "the capability gates hide disallowed actions throughout" | **REFUTED — and inverted** | C-1: the gates hide **every** action, allowed or not, because the capability map decodes empty. The sentence is accidentally true and completely misleading; it is the single most consequential wrong claim in the document. |

**Recommended edit to docs/50:** replace the manual-test paragraph with the deep-link URLs the
screens actually live at, and mark items 1, 3, 4, 5, 7 as blocked on C-1, C-2, C-5, C-6 and R-1.
Keep item 2 as the only verified flow.

### 6b. Re-adjudicated after the repair pass

| # | Claim | Then | Now |
| --- | --- | --- | --- |
| 1 | "open Collaborators / Comments / Suggestions / Publishing from a piece" | REFUTED | **NOW TRUE** — R-1 fixed: the editor overflow and the drafts row menu both open all four for a synced draft. |
| 2 | invite by handle → inbox → accept | CONFIRMED | **CONFIRMED** — plus the inbox now has an entry point (Settings → Collaboration). |
| 3 | "Comments (inline thread + resolve)" | REFUTED twice | **THREAD: now true** (C-5 fixed — expandable replies + reply composer). **RESOLVE: now true** (C-1 fixed, so the gate resolves from a real decision). **INLINE COMPOSE: still not true** — the anchor contract is fixed (C-6) but no UI creates an inline anchor. |
| 4 | "Suggestions (propose → owner accepts)" | REFUTED | **ACCEPT: now true, and now real** — per §3b the server applies the edit, so "accepts" means the prose changed; the toast says "Suggestion accepted." again. **PROPOSE: still not true** — the request shape is correct (C-3) but there is no compose affordance. |
| 5 | "Publishing (request review → approve → publish; snapshots + history)" | REFUTED | **NOW TRUE for display and for the gates.** The Review card reads Draft instead of erroring (P-4), snapshots/history/visibility render real data, and as of C-2 (§0b) all five gates receive a real verdict, so the buttons render for an owner. The flow itself is untested end-to-end. |
| 6 | "Sign in as a restricted user to see Restricted State" | CANNOT JUDGE | **STILL CANNOT FULLY JUDGE**, but closer: the trust contract is confirmed live (a seeded writer decodes as `normal`, `isRestricted == false`, so the banner correctly stays hidden), and there is now a route in (the banner). Whether a *restricted* user resolves to a restricted status still needs a seeded restriction — the one remaining live item. |
| 7 | "the capability gates hide disallowed actions throughout" | REFUTED — inverted | **NOW TRUE for all 12 actions**, verified against a live server: an owner is allowed every one and the gates render. (Was true for 9 until C-2 landed; §0b.) |

---

## 7. NEEDS-LIVE-CONFIRMATION queue

Batch these against a live backend later; each is a shape the code alone cannot settle.

| # | Question | Why source is not enough |
| --- | --- | --- |
| 1 | Does a restricted user's `GET /me/trust` return a non-`normal` `status` with populated `restrictions`? | Depends on strike seeding and `TrustStatusService` runtime state, not on a DTO (docs/50 claim 6). **Half-confirmed:** the *unrestricted* case is verified live (`{"score":50,"level":"member","status":"normal","activeStrikeWeight":0,"restrictions":[]}`) and the banner correctly stays hidden. The restricted case still needs a seeded restriction. |
| 2 | Does `POST /monetization/subscription` ever return `clientSecret` with a null `checkoutUrl`? | `StripeAdapter` behaviour is key-gated and provider-dependent. Mobile now refuses honestly either way (M5-2, closed 2026-08-21) — this question is only about whether the path is ever live, not about client behaviour. |
| 3 | Exact `VALIDATION_FAILED` `details[]` payload for the C-3 / C-6 / P-2 / P-3 bodies. | `validationExceptionFactory` shapes `{field, rule, message}`; the field names are worth pinning in the regression tests that accompany the fixes. |
| 4 | ~~Confirm `GET /stories/:id/review` emits `{"success":true,"data":null}`~~ | ✅ **CONFIRMED 2026-07-28.** Returns exactly `{"success":true,"data":null}`. P-4 fixed client-side with `getOrNull`; pinned by a live test. |
| 5 | Whether `ParseUUIDPipe` on `/users/:id/block` accepts a block-row UUID and the service then 404s, versus some earlier rejection. | Both ids are UUIDs; T-1's exact status code depends on service lookup order. The defect stands either way. |

---

## 8. The two requested one-liners

Neither is a fix to a finding above; both were requested with this audit.

### 8.1 `RATE_LIMIT_ENABLED=false` in the E2E stack

`platfrom/scripts/stack-up.sh` did not set it, although `docs/e2e/06_PhasePlan.md` §6 and CI both
require it. Added alongside the other stack env exports. Detail in the commit; no application code
touched.

### 8.2 The misleading "Suggestion accepted." toast

`lib/features/collaboration/presentation/screens/suggestions_screen.dart:170` claimed success for an
operation that, per §3, changed three columns and rewrote nothing. Replaced with a message that stated
what actually happened. This is the correction docs/45 §4.4 asks for "whichever way D1 lands".

**Reverted 2026-07-28 (§0b/§3b):** D1 landed on the server-side arm, so the accept *does* rewrite the
prose and `'Suggestion accepted.'` is accurate again. The interim wording ("Marked accepted — apply the
change in the editor.") was correct for exactly as long as the server behaviour it described. The web
card still carries the interim claim — **C-14**.

---

## 9. Summary

**Re-counted 2026-08-20 against the code, not against these headings; M5-2 closed 2026-08-21.** The
table below is the current count; the original is kept underneath it because the delta is the finding —
**five entries this document called open had already been fixed**, four of them for over three weeks,
and a sixth (M5-2) closed the day after this count was taken.

Every row reconciles as **fixed + open + not-a-defect = total**; the two not-a-defect entries are
**M5-3** (the store seam, working as designed) and **M5-5** (recorded "correct as-is" in its own entry).
They are neither work nor debt, and counting them as either is what inflated the AF5 figure.

| Severity  | AF6    | AF5   | Total  | Fixed  | Open           | Not a defect |
| --------- | ------ | ----- | ------ | ------ | -------------- | ------------ |
| critical  | 1      | 0     | **1**  | 1      | 0              | —            |
| high      | 11     | 0     | **11** | 11     | 0              | —            |
| medium    | 10     | 3     | **13** | 11     | **1** — C-15 (web) | 1 (M5-3) |
| low       | 2      | 2     | **4**  | 3      | 0              | 1 (M5-5)     |
| **Total** | **24** | **5** | **29** | **26** | **1**          | **2**        |

Closed since the last count, each verified in code with the anchor recorded on the entry itself:
**C-14** (copy gone, its spec asserts the absence), **T-3** (block/mute entry point shipped), **M5-1**
(`PremiumGate` has seven call sites; `premiumFeatureAllowedProvider` deleted), **M5-4**
(`RestoreResultDto` now declared and correct), all 2026-08-20; **M5-2** (`CheckoutResult` now reads
`clientSecret` and refuses honestly instead of claiming success), 2026-08-21. **C-15's mobile half also
closed 2026-08-21** (§2.6) — the only piece still open is web's offset-mapping fix.

The remaining entry is carried as a schedulable line in
[`platfrom/docs/48` §3.22a](../../platfrom/docs/48_PlatformParityRegister.md) — **C-15**. That register
is the source of truth for *status*; this document is the source of truth for *diagnosis*, and when the
two disagree the code decides.

<details><summary>The original count, for the record (2026-07-29)</summary>

| Severity | AF6 | AF5 | Total | Fixed | Open |
| --- | --- | --- | --- | --- | --- |
| critical | 1 | 0 | **1** | 1 | 0 |
| high | 11 | 0 | **11** | 11 | 0 |
| medium | 10 | 3 | **13** | 8 | 5 (C-14, C-15 web; 3 AF5) |
| low | 2 | 2 | **4** | 2 | 2 (AF5, out of scope) |
| **Total** | **24** | **5** | **29** | **22 of 24 AF6** | **2 AF6 + 5 AF5** |

</details>

The register grew by three after the original 26: **C-13, C-14, C-15** were found while landing C-2 and
D1 (§2.6). C-2 — the one finding the mobile-only repair pass could not close — is fixed (§0b), and so
is C-13 (§0c/§2.7). ~~The two still open are **web-only**: the suggestion card's now-false text (C-14)
and the composer's hand-typed anchor (C-15).~~ **CORRECTED 2026-08-20:** C-14 shipped on 2026-07-29 with
W3c-4. **C-15 was then found not to be web-only either** (`platfrom/docs/48` §3.22a, same date) — mobile
had no composer at all, which is a worse gap than web's unreliable one. **CORRECTED AGAIN 2026-08-21:**
mobile's half is now built (§2.6); web's offset-mapping fix is the only piece of C-15 still open.

~~All 5 AF5 findings remain open by design: this repair pass was scoped to AF6, and none of the AF5
items is a wire defect (they are two integration gaps, one seam-by-design note, and two low-severity
notes — one of which is a backend DTO-class inconsistency).~~ **CORRECTED 2026-08-20 — this sentence
was the most misleading line in the document, and it was quoted forward twice.** Of the five: **M5-1
closed** 2026-08-03 (+ D3), **M5-4 closed** 2026-07-29, **M5-3** is a documented seam and never was a
defect, **M5-5** was recorded "correct as-is" in its own entry, and **M5-2 closed 2026-08-21**. **AF5
has zero open findings.** "Scoped to AF6" explained why they were not fixed *in that pass*; it did not
make them permanently open, and reading it as a standing count is how AF5 kept being sized as
four-items-of-work it did not have.

Of the 21 AF6 findings, **9 were unreachable when this was written** (C-3, C-6, C-7, C-8, P-2, P-5,
P-8 partially, T-1, T-3) purely because R-1 meant nothing called them — which is the audit's real
finding about process, not code: a screen list, a green widget-test suite and a readiness report all
passed over a feature whose primary gating mechanism decoded to an empty map. **R-1 and T-3 are both
closed now** (verified 2026-08-20: `app/router/routes.dart:120` routes `/settings/blocks`, reached from
the one entry point at `settings_hub_screen.dart:110`), so that paragraph is history rather than status.

AF5, built to the same design and reviewed by the same process, is clean on all 19 endpoints. The
difference is not care; it is that AF5's shapes are flat DTOs the entities mirror one-to-one, while
AF6's are nested envelopes (`CapabilitiesDto`, `CommentThreadDto`), cross-module returns
(`PieceResponseDto`) and nullable reads — exactly the three places a mirror-by-hand client drifts.
Worth a codegen conversation for the AF6 shapes specifically.
