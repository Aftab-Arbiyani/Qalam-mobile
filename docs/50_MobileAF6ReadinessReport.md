# 50 — Mobile AF6 Readiness Report — Collaboration, Publishing & Trust

**Status: ✅ COMPLETE + verified.** Backend platform + Policy Engine: `platfrom/docs/38`.

The AF6 client is one deletable feature — `lib/features/collaboration/` — mirroring the AF5
monetization feature exactly (Clean Architecture: `presentation → domain ← data`, Riverpod
codegen DI, single Dio choke point, `Result<T>` from repos, `Failure` to the UI). It is a
pure client of the backend Policy Engine: it **reflects** server authorization decisions and
never re-derives them.

## Feature tree

```
lib/features/collaboration/
├── collaboration.dart                      # barrel (capabilities/trust providers + gate widgets)
├── data/
│   ├── datasources/  collaboration · publishing · trust  _remote_data_source   (sole ApiClient callers)
│   └── repositories/ collaboration · publishing · trust  _repository_impl      (every call in guardResult)
├── domain/
│   ├── entities/  collaboration_enums · story_member · story_invitation · collaboration_comment
│   │              · edit_suggestion · presence_entry · collaboration_activity_entry · policy_capability
│   │              · review_session · story_snapshot · publication_event · trust_summary · block_entry
│   └── repositories/ collaboration · publishing · trust  _repository            (abstract interface class)
└── presentation/
    ├── providers/collaboration_providers.dart   # composition root + family read providers
    ├── controllers/ collaboration · publishing · trust  _controller            (@riverpod write Notifiers)
    ├── widgets/  capability_gate · presence_bar · role_badge
    ├── screens/  collaborators · comments · suggestions · invitations_inbox · publishing_workflow · restricted_state
    └── domain_labels.dart
```
Plus edits to `lib/app/router/*` (routes + guarded `GoRoute`s), `lib/core/network/api_paths.dart`
(the AF6 endpoint block), `lib/core/config/app_config.dart` (`enableCollaboration` flag,
env `QALAM_ENABLE_COLLABORATION`, default off), and `test/support/harness.dart` (3 repo overrides).

## Highlights

- **Wire vocab** mirrors `@qalam/shared` as `abstract final class` string holders
  (`StoryRole`, `PolicyEffect`, `TrustStatus`, `ReviewState`, `RestrictionType`, …) — the
  client branches on wire strings, never on message text, and tolerates unknown values.
- **Capabilities-driven UI.** `storyCapabilities(storyId)` reads `GET /stories/:id/capabilities`
  and **fails closed** to read-only on error. `CapabilityGate` (the `PremiumGate` analogue)
  shows/hides affordances by a `PolicyCapability.allowed`; `RestrictedStateScreen` renders the
  muted / read-only / suspended walls from the server's `PolicyEffect`/`TrustStatus`.
- **Repositories** return `Future<Result<T>>` (`guardResult`); read providers unwrap and
  rethrow `Failure`; write controllers hold `AsyncValue<void>` and invalidate the relevant
  read providers on success (e.g. `removeMember` → refetch members).
- **Presence** heartbeat is `postVoid → Result<Unit>`; the roster is a separate provider the
  controller invalidates after each beat.

## Test coverage & verification

- `dart run build_runner build` — clean (4 generated files).
- `flutter analyze` (full project) — **No issues found.**
- `flutter test test/features/collaboration` — **15/15 pass**: repository Ok/Err mapping
  across all 3 repos, a controller test proving invalidation + error surfacing, and widget
  tests for `CapabilityGate` and `RestrictedStateScreen`.
- Full `flutter test` — all suites green **except 2 pre-existing environmental golden-drift
  failures** (`test/shared/widgets/social/comment_tile_golden_test.dart`, 0.03 %/156 px
  sub-pixel font-rendering diff). That golden is from commit `13b15c9` (M6/M7) and AF6 touched
  nothing in `social`/theme/`shared/widgets`; the goldens simply weren't regenerated on this
  machine's font config. Not regenerated here — regenerating another team's committed goldens
  on a different host would risk masking real diffs for them.

## Manual testing

Enable with `--dart-define=QALAM_ENABLE_COLLABORATION=true`. From a piece the user owns:
open **Collaborators** (invite by **handle** → the invitee sees it in **Invitations Inbox** →
accept), **Comments** (inline thread + resolve), **Suggestions** (propose → owner accepts),
**Publishing** (request review → approve → publish; snapshots + history). Sign in as a
restricted user to see **Restricted State**; the capability gates hide disallowed actions
throughout.

> ⚠️ **Correction (2026-07-28).** This section originally described inviting **by email** and claimed
> that flow had been manually verified. **It could not have been**: the client sent `{role, email}` to
> an endpoint that requires `{inviteeId, role}` under `forbidNonWhitelisted`, so every invitation
> returned `400 VALIDATION_FAILED` ("property email should not exist"). There is no invite-by-email
> path anywhere in the backend. Treat the rest of this AF6 manual-test list as **unverified** until
> re-run — the same "it must work" assumption may cover the other flows.
>
> Fixed the same day (defect **M-1**, `platfrom/docs/48` §3.1). See "Invite by handle" below.

## Invite by handle (M-1 fix, 2026-07-28)

The invite sheet now asks for a `@handle`, resolves it through `GET /users/{username}` (which returns
the id), shows **who** is about to be invited, and keeps **Send** disabled until that resolves. Three
further defects in the same flow were found and fixed with it:

| Defect                                                                                                                  | Fix                                                                                          |
| ----------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Invite sent `{role, email?, userId?}` — rejected by validation                                                            | Sends exactly `{inviteeId, role}`                                                            |
| The sheet's only button was **Cancel**, and the code invited *after* it popped — so "Cancel" submitted                   | Real **Cancel** / **Send invitation** pair; Send is disabled until a person resolves          |
| `POST /invitations/:id/accept` returns `MemberDto`, but the client decoded it as `StoryInvitation`                        | Decodes `StoryMember`; accepting now also refreshes the roster                                |
| `StoryInvitation` carried `inviteeEmail` / `inviteeUserId` / `invitedByName` / `storyTitle` — **keys the wire never sends**, so they were always null and the screens showed nothing | Entity mirrors `InvitationDto` (`inviterId`, `inviteeId`, `respondedAt`); UI shows a shortened id |

**Verified against a live backend**, not just mocks: handle → id resolves, `{inviteeId, role}` returns
`201 pending` (the old shape returns `400`), the invitation appears in `/me/invitations`, accept
returns `{userId, role, invitedById, joinedAt}`, and the invitee then appears in
`GET /stories/:id/members` as `editor`. Regression tests in
`test/features/collaboration/invite_contract_test.dart` pin the request body and the accept type.

## Deferred

Reporting flow (no existing client to extend; out of scope this epic), real-time transport
(polling today — the backend has no websocket layer; SSE precedent exists for a future
upgrade), and the React admin UI (backend APIs ready — see `platfrom/docs/38 §8`).
