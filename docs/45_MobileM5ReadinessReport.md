# Mobile M5 — Profile & Settings — Readiness Report

Epic **M5 (Profile & Settings)** for the Qalam Flutter client. Scope was strictly
`mobile/`; the frozen `v1` backend, web, and admin were never modified. No mock
APIs, no invented contracts — every network call maps to a real, verified
`/api/v1` endpoint.

**Quality gates (all green):** `flutter analyze` → 0 issues · `flutter test` →
**269 passing (53 new)** · `dart format --set-exit-if-changed` → clean ·
`flutter build apk --release` → built `app-release.apk` (62.9 MB).

---

## 1. Folder tree (new / changed)

```
lib/
├── features/
│   ├── profile/                                    # NEW feature
│   │   ├── profile.dart                             # barrel (screens only)
│   │   ├── domain/
│   │   │   ├── entities/{profile,profile_counts,viewer_relation,profile_piece}.dart
│   │   │   ├── value_objects/profile_edit.dart
│   │   │   └── repositories/profile_repository.dart
│   │   ├── data/
│   │   │   ├── mappers/profile_mappers.dart
│   │   │   ├── datasources/profile_remote_data_source.dart
│   │   │   └── repositories/profile_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/profile_providers.dart
│   │       ├── controllers/{my_profile,public_profile,profile_edit,profile_stats,my_pieces}_controller.dart
│   │       ├── screens/{my_profile,public_profile,profile_edit,privacy_settings}_screen.dart
│   │       └── widgets/{profile_header,profile_stats_row,profile_bio_block,profile_skeleton,profile_image_fields}.dart
│   ├── settings/                                    # NEW (thin, navigation-only)
│   │   └── presentation/screens/settings_hub_screen.dart
│   ├── auth/                                        # EXTENDED
│   │   ├── domain/usecases/change_password.dart
│   │   └── presentation/
│   │       ├── controllers/{change_password,account_info}_controller.dart
│   │       └── screens/{account_settings,change_password}_screen.dart
│   └── reading/                                     # EXTENDED
│       └── presentation/
│           ├── screens/appearance_settings_screen.dart
│           └── widgets/labeled_segment.dart         # extracted, shared w/ reader sheet
└── shared/
    ├── taxonomy/{domain,data}/… + taxonomy_providers.dart   # RELOCATED from writing
    ├── pagination/{cached_page,paged_list_state}.dart        # PROMOTED from feed
    ├── preferences/{default_feed,content_privacy,app_preferences_controllers}.dart  # NEW
    └── widgets/
        ├── media/image_cropper.dart                 # NEW (QImageCropper)
        └── settings/settings_tiles.dart             # NEW (QSettingsSection/Tile/SwitchTile)
```

Retired (dead code removed): `features/auth/.../account_screen.dart` (M2
placeholder, superseded by My Profile + Account Settings) and
`features/shell/.../settings_placeholder_page.dart`.

## 2. Profile architecture

Feature-first clean architecture matching every prior epic: `domain` (Flutter/
Dio/Hive-free) → `data` → `presentation`. `Profile` is a new, richer entity
mirroring the backend `ProfileResponseDto`; it is deliberately **separate** from
the reader author-card's minimal `WriterProfile` (features never import features).
`ProfileRepository` is the single boundary for `/me`, `/users/:username`,
`PATCH /me`, and avatar/cover uploads, returning domain `Result`/`Failure`.

Surfaces:
- **My Profile** (`/me` tab) — header, bio, stat tiles, and the user's own
  published-pieces grid (paginated). Edit + Settings entries.
- **Public Profile** (`/u/:username`, deep-linkable, works signed-out) — read-only
  header + bio + writer stats; a private account shows a restricted teaser.
- **Edit Profile** (`/me/edit`) — display name, bio, location, website, genres,
  default language; avatar + cover upload with crop.

## 3. Settings architecture

The settings surfaces are **distributed to the features that own their data** —
required by the "features never import each other" rule; a monolithic `settings`
feature would have had to import `auth`, `reading`, and `profile`. A thin
`settings` feature holds only the navigation-only **hub** (`/settings`), which
pushes routes by name. Section screens:
- **Account** (`/settings/account`, in `auth`) — identity, sign-in method,
  "this device" card, change-password entry, logout / logout-everywhere.
- **Change Password** (`/settings/account/password`, in `auth`).
- **Appearance & Reading** (`/settings/appearance`, in `reading`) — theme, text
  size, line spacing, reading width, default feed, autoplay.
- **Privacy** (`/settings/privacy`, in `profile`) — private account + content
  display toggles.

Shared settings row primitives (`QSettingsSection/Tile/SwitchTile`) live in
`shared/widgets/settings/` so section screens compose them without importing each
other.

## 4. State management summary (Riverpod `@riverpod` codegen)

| Provider | Shape | Backs |
|---|---|---|
| `myProfileControllerProvider` | AsyncNotifier<Profile> | `GET /me` (+ optimistic `applyProfile`, `setPrivate`) |
| `publicProfileControllerProvider(username)` | family AsyncNotifier<Profile> | `GET /users/:username` |
| `profileEditControllerProvider` | freezed-state notifier | edit form (validation, dirty, upload progress, save) |
| `profileStatsControllerProvider` | AsyncNotifier<ProfileStats> | bounded draft/bookmark counts + local reading-history count |
| `myPiecesControllerProvider` | AsyncNotifier<PagedListState<ProfilePiece>> + `CursorPaginator` | `GET /me/pieces?status=published` |
| `changePasswordControllerProvider` | freezed-state notifier | change-password form |
| `signInMethodProvider` / `deviceSessionInfoProvider` | provider / FutureProvider | account "this device" facts |
| `defaultFeedControllerProvider` / `autoplayMediaControllerProvider` / `contentPrivacyControllerProvider` | keepAlive notifiers | new device prefs |
| `profileRepositoryProvider` / `taxonomyRepositoryProvider` | keepAlive DI | repositories |

No global mutable state; all mutation through notifiers + repositories. No HTTP in
widgets.

## 5. API integration summary

New `ApiPaths` constants: `profileAvatar = /profile/avatar`,
`profileCover = /profile/cover`. Reused (real, verified): `GET/PATCH /me`,
`GET /users/:username`, `GET /me/pieces?status=published`, `GET /me/drafts`,
`GET /me/bookmarks`, `POST /auth/change-password`, `POST /auth/logout[-all]`,
`GET /discover/{languages,genres}`. All through `ApiClient`; uploads use its
multipart `upload()` (progress + per-key `CancelToken`, bypasses the refresh
interceptor). Field-level validation errors map onto form fields by `error.code` +
`details[].field`.

## 6. Offline strategy

- **Viewing** (own + public profile, published grid) — cache-then-network under
  `CacheTier.identity`/`content`, offline fallback to the last-cached copy **only**
  on transport errors (a real 404/403 is never masked). Profiles + first page of
  pieces are viewable offline; reader/privacy prefs are already Hive-local.
- **Editing** (PATCH, uploads, change-password) — connectivity-required, **fail
  fast** with a retryable failure. Deliberately **no outbox**: unlike drafts
  (long-form creation where lost work is unacceptable), profile edits are short,
  low-frequency, and conflict-prone (server re-encodes images, resolves language
  codes); a queued stale PATCH could silently clobber a change made elsewhere.
  A dirty edit form warns before discarding via a confirm dialog.

## 7. Upload implementation summary

Pick (`coverImagePicker`, platform downscale) → **crop** (`QImageCropper` — a
dependency-free pan/zoom cropper over a fixed-aspect frame: 1:1 avatar, 3:1 cover)
→ client-side type/size validation against shared `Limits` → repository
`uploadAvatar/uploadCover()` → `ApiClient.upload()` with progress → returns
`{key}` → optimistic `Profile.copyWith` pushed through `MyProfileController` +
cancel-on-leave. No native cropper dependency was added (stack stays fixed).

## 8. Performance optimizations

`cached_network_image` (via `QNetworkImage`/`QAvatar`) for avatar/banner/thumbs;
Hero avatar transition keyed by username; `const` widgets throughout; `QSkeleton`
first-paint; lazy `SliverList` + infinite pagination for the pieces grid; stat
counts bounded to one `limit=50` page (no full walk); optimistic edit/upload
updates avoid refetches; `.select` on providers to minimize rebuilds.

## 9. Test coverage (53 new; 269 total)

- **Unit** — profile mappers (restricted vs full, socialLinks, patch-body
  quirks), `ProfileRepositoryImpl` (cache-then-network, transport-only fallback,
  404 not masked, bounded counts, page caching, update-cache-refresh),
  change-password controller (validation + field-mapped server errors), shared
  prefs round-trip.
- **Controllers** — my/public profile load + error, edit validation/dirty/save/
  field-error mapping, stats bounding, pieces pagination, `setPrivate`
  optimistic-and-revert, avatar upload → live profile.
- **Widget** — My Profile (render + empty), Public Profile (private teaser),
  Privacy toggle → repo, Settings hub, Appearance controls, Change-password
  validation, Edit-form render; the M2 auth flow updated to the new profile/
  settings navigation incl. logout.
- **Golden** — `ProfileHeader` (light), `ProfileStatsRow` (light + dark).

## 10. Manual testing guide

1. Sign in → land on **My Profile**; toggle airplane mode → profile still renders
   from cache.
2. Edit profile → change name/bio/genres/language → Save → returns with a
   confirmation; leaving with unsaved edits prompts a discard dialog.
3. Change avatar & cover → pick → pan/zoom crop → "Use photo" → progress overlay →
   image updates.
4. Settings → Account → Change password: wrong current → inline "incorrect"; valid
   → "Password changed" and session stays signed in (rotated tokens adopted).
5. Settings → Appearance: change theme / text size / reading width / default feed /
   autoplay → all persist across a restart; default feed changes the landing tab.
6. Settings → Privacy: toggle Private account (verify `PATCH /me`); toggle the two
   content-display switches → reading/bookmarks tiles show/hide on My Profile.
7. Open a public profile by username (incl. a private account → teaser).
8. Sign out / sign out everywhere from Account settings.

## 11. Reusable by future social features (confirmation)

The M5 infrastructure is the extension point for the deferred social epics —
**none built here**: `Profile`/`ProfileCounts`/`ViewerRelation` entities and
`ProfileRepository` already carry follower/following counts and the viewer
relation; `ProfileHeader` exposes a `trailing` slot for a Follow button;
`PublicProfileScreen` is the target for author links; the shared `taxonomy/`,
`pagination/`, `preferences/`, `QImageCropper`, and `QSettings*` modules are
feature-agnostic. Followers/Following/Collections/Verification/Badges/
Subscriptions/Profile-Themes plug into these seams without touching the profile
core.

## 12. Frozen-`v1` gaps worked around (documented, not mocked)

Mirrors the M3/M4 approach of honestly mapping product features onto the frozen
contract:
- **No public pieces list** for other authors (`/me/pieces` is caller-scoped;
  `/search/pieces` needs a query) → Public Profile shows the real
  `piecesPublished` **count** only; My Profile gets a real grid of its own pieces.
- **No join date, no draft/bookmark totals** → drafts/bookmarks use a bounded
  first-page count ("N+"); reading-history count is exact & local; no "joined"
  line.
- **No default-language name** — the profile DTO returns a language **UUID** the
  client can't resolve to a picker option, so the edit language field seeds empty
  (picking sets it; untouched = unchanged).
- **Absent endpoints → honest substitutes:** delete-account & change-email →
  omitted; connected-accounts → read-only "sign-in method"; session list →
  "this device" card + sign-out-everywhere; mentions/messages → omitted; reading-
  history/bookmarks visibility → local display toggles (nothing cross-user to
  enforce).
- **Reader prefs are local-only** (per brief) even though the backend can sync
  `theme`.

## Out of scope (per brief — not implemented)

Followers, Following, Comments, Responses, Collections, Notifications, Search,
Analytics, AI, Creator Verification, Premium, Badges, Achievements, Subscriptions,
Profile Themes. **Stopped after M5 — M6 not begun.**
