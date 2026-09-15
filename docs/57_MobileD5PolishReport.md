# 57 — Mobile D5: Polish · Manuscript feedback · Story Map

**Status:** ✅ Complete (M1–M4) · **Decision:** [D5, owner 2026-09-02](../../platfrom/docs/48_PlatformParityRegister.md#d5--the-ai-surface-is-removed-the-tools-stay-owner-2026-09-02) · **Landed:** 2026-09-07
**Commits:** `8e6e302` (M1) · `5f410c7` (M2) · `efb4aff` (M3) · this one (M4)
**Net:** 176 files, +5,906 / −10,767 — D5 is the first phase in this repo that removed more than it added.

---

## 1. What the decision was, in one paragraph

Umberleaf's audience — literary writers and poets — rejects being *sold* a machine, rejects prose
generation, and rejects the suspicion that their unpublished work is being used without their
knowing. The app led with "AI": on the editor toolbar, on plan cards, on a "Discover with AI" hub, in
settings, and in a usage meter denominated in tokens. **D5 removes the surface, not the platform.**
The AF1 orchestrator, providers, prompts and usage logs are untouched. What changed is what a writer
sees, what they are offered, and what they are charged in.

Three tools survive, named for what they do:

| Was | Is | Sold as |
| --- | --- | --- |
| Writing Assistant (continue / rewrite / expand / tone / freeform / improve / simplify / condense) | **Polish** — simplify, condense, improve·{8 aspects} | Plus and above |
| Craft Coach | **Manuscript feedback** | Plus and above |
| Story Explorer (a graph nothing could fill) | **Story Map**, with **"Map this story"** | Pro and above |

Deleted outright: Ask My Book, AI conversations, the Prompt Library, the AI usage screen, the
"Discover with AI" hub, the standalone semantic-search screen, the per-account AI switch screen, and
the entire credit economy.

---

## 2. What each phase did

### M1 — the editor's three tools (`8e6e302`)

`polish_sheet.dart` replaces `writing_assistant_panel.dart`. Same mechanism — streams through the
AF1 orchestrator, writes only through `AiEditorTarget`, never touches the document itself — with a
much smaller offer: **Simplify, Condense and the eight Improve aspects, laid out flat**. The five
generation actions are gone and so are their server prompt keys (B2 pruned the catalogue), so
`AssistantActionKind` and `prompt-catalog.ts` are two halves of one contract that a test now pins to
exactly three keys.

**Story Map stopped being hollow.** `POST /story-intelligence/:id/analyze` shipped with the graph
platform and **no client anywhere could reach it** ([48 §3.22d]) — so every view of every story said
"nothing here yet", permanently. "Map this story" runs all five analyses and folds each into the
graph. It takes the story's **text**, not just its id, so an unsaved draft can be mapped: the editor
pushes a `StoryMapSeed` through go_router's `extra`, and a deep link says *"Open this story in the
editor to map it"* rather than offering a button whose request would 400.

### M2 — one search, and a boundary repaired (`5f410c7`)

Search, saved searches and recommendations moved to **`lib/shared/retrieval/`**. They lived in
`features/ai` because AF4 *arrived* as part of the AI platform; three features consume them and
features never import features ([folder-structure.md](./folder-structure.md)). `AiRepository` is five
methods now and is exactly the three writing tools.

The "All" tab ran the grouped `GET /search` preview while a separate screen on `/ai` ran the ranked
one. **Offering both asked the reader to pick an implementation** — a question they have no way to
answer. "All" is the ranked engine; the narrower scope tabs are untouched, because a scope refines
the reader's own intent rather than choosing a mechanism.

The "Discover with AI" hub was deleted and its shelves moved to `/discover`. The hub was the mistake,
not the shelves: it put personalised recommendations behind a door named after the technology.

### M3 — allowances, no credits (`efb4aff`)

The usage screen was token counts, an estimated dollar cost, a projected monthly spend and a
per-feature token breakdown. **All four gone.** None was a fact about writing — a poet cannot decide
anything from "42,150 tokens", and showing them the provider's cost of serving them makes an editing
tool feel like a taxi meter running over their draft. It is one line per tool: *"12 of 30 today"*.

Plan cards named a credit balance; they name what those credits bought, through an **allowlist**
(§4.2). The credit economy — dashboard, route, entities, repository methods, `/monetization/credits*`,
`Plan.monthlyCredits`, `PremiumFeature.aiBudget` — is deleted.

### M4 — the copy sweep (this commit)

The plan's gate:

```
grep -rn --include=*.dart -E "'[^']*\bAI\b[^']*'" lib | grep -v '\.g\.dart' | grep -v '///'
```

returns **zero**. Several sentences needed rewriting rather than renaming, because they named a
*vendor* ("The AI service had a problem") or a *remedy that no longer exists* ("Turn it back on in
Settings › AI") — neither of which a writer can act on. `STORY_NOT_FOUND` said "Analyse this story
first" at a time when nothing could analyse anything; it now names the control that exists.

A grep that ran once proves nothing about tomorrow, so `ai_copy_sweep_test.dart` walks **every**
`AiErrorCopy` branch — all 27 codes × 3 feature variants — and fails on the word.

---

## 3. The one thing D5 removed that it did not replace

**A writer who turned AI off before D5 is stuck.** B5's per-account switch stays live server-side and
defaults to true, but its settings screen is deleted, so there is no way to turn it back on.

`AI_DISABLED_BY_USER` therefore shares the platform-off copy now: *"Writing tools aren't available."*
The two codes were deliberately kept apart on the W4 principle ([48 §3.6]) — an admin's switch you
can only wait out, versus your own switch one screen away — and the second half of that distinction
is what D5 deleted. **Copy that names a remedy which no longer exists is worse than copy that names
none**: it sends someone looking for a control they will not find. The distinct code is still mapped,
because an unmapped code falls through to the retryable generic and invites an infinite retry.

Recorded, not fixed.

---

## 4. Three decisions worth reading before changing this code

### 4.1 The auth split is enforced at the request, not the render

Two retrieval calls are public (search, suggestions) and four need a session (saved searches ×3,
recommendations). Before D5 what kept the authenticated ones off public pages was a **feature flag,
incidentally** — and removing that flag is exactly how the equivalent web change broke a signed-out
reader's page ([48 §3.25]): a 401 outside `/auth/*` is terminal to `ApiClient`, so it ends the session
and clears the caches, and the symptom appears nowhere near the cause.

**Mobile is the worse case**, because `AiFeatures.isEnabled` answers **false for a flag it cannot
find**. An id left in `AiFeatureIds` for search or recommendations would have taken mobile's search
dark the moment Phase V deleted the server row, while web — whose resolver treats a missing flag as
available — carried on working. Those ids are gone.

So: `recommendationsProvider` watches the session and answers empty without reaching the network;
`SavedSearchesController` refuses to sync without one and clears on sign-out; and
`search_anonymous_test.dart` arranges `aiFeaturesProvider` to **throw**, because a render-only check
cannot tell "not shown" from "requested and 401'd".

### 4.2 `planLimitSpec` is an allowlist, not a formatter

A plan's `limits` map is open. The obvious implementation — iterate it, prettify each key — is
precisely how `aiMonthlyTokens: 250000` walks back onto a plan card D5 just cleared. **A key nobody
has decided how to present is not shown**, and adding one is a deliberate act.

It also carries the sentinel reading **per key**, because they are not uniform: `0` means unlimited
almost everywhere, but `maxCollaborators` inverts it (`-1` unlimited, `0` none). One shared rule
would advertise "Unlimited collaborators" on a plan that allows none — silent *and* inverted.

### 4.3 A spent allowance never offers a plan, and now names the tool

The three allowances sit in **different windows** — Polish and feedback reset daily, story analyses
monthly. "You've used your allowance" leaves a writer guessing which stopped, and a wrong guess means
waiting a month for something that returns tomorrow. Both `FeatureLockCard` and `AiErrorCopy` name it.

Neither offers an upgrade. An allowance resets on its own; selling a plan there sells someone
something they do not need ([48 §5.2] consequence 2). That is the whole reason quota and entitlement
stay separate remedies.

---

## 5. What the build taught that the plan did not know

- **A latent lifetime bug in the Polish session controller.** It only ever `read` the autoDispose
  stream provider, so between starting a stream and the sheet's first rebuild the provider could be
  swept — cancelling the subscription, hanging the run in `streaming` forever, and mounting a
  *second* instance for the view. Invisible against a real network; wide open against a fake that
  answers in microtasks, which is how a widget test found it. Now `listen`ed, which is the honest
  statement of the dependency.
- **The retrieval engine has no offline replay.** Deleting the grouped preview took its object cache
  with it, so a reader offline on the "All" scope sees an error where the per-type tabs still show
  their last results. Real gap.
- **`AiSearchHistoryStore` duplicated `SearchRecentsStore`** on the same landing — two histories of
  the same searches, one of them unreachable. Deleted.
- **Two things were kept on purpose that a tidier sweep would have removed**: `PurchaseKind.credits`
  and the credit-pack rows on billing history. A pack bought before D5 is a real row someone can
  scroll to; it is relabelled ("Credit pack"), not erased. Removing the economy does not entitle the
  app to misdescribe its own past.
- **`ai_budget` renders as its raw wire code on plan cards** until Phase V contracts the catalogue.
  Ugly and temporary, and deliberately preferred over a friendly name that would put a credit balance
  back on the card D5 cleared.

---

## 6. Verification

- `flutter analyze` — clean.
- `flutter test` — **829 passing, run twice** each phase (the M-5 flake history in [48 §3.22c]).
- The M4 grep gate — zero.
- Codegen re-run and committed at every phase.

**Not verified: a real device against a live backend.** Nothing here has been smoke-tested by hand.
The manual list below is the outstanding half, and it is the only way to catch what unit tests
structurally cannot — the same class of gap the browser suite caught on web ([48 §3.25]).

### Manual smoke — outstanding

Run the **development** flavor against a backend with `AI_STUB_ENABLED=true AI_DEFAULT_PROVIDER=stub`.

1. Plus writer → toolbar **Polish** → "Clarity" → stream → Apply → Undo. Disclosure line present once.
2. Plus writer → **Manuscript feedback** → "Pacing" report. No token line; disclosure once.
3. Free writer → both lock cards read "Polish & feedback is on Plus and above". No allowance wording.
4. Signed out → `/search`: suggestions, ranked results, scope tabs. **No Saved shelf, no save action.**
5. Signed in → save a search → sign out → the saved list is empty.
6. Pro writer → Story Map → **"Map this story"** → 5-step progress → views fill, including "Overview".
7. Plus writer → Story Map → lock card, not a paywall-shaped error.
8. Settings hub → no AI tile. Deep links `/settings/ai`, `/ai/ask/x`, `/ai/search`, `/ai/discovery`,
   `/billing/credits` → Unknown route.
9. Billing → **Usage** cards. Compare plans → per-tool rows, no tokens, no credits.
10. Spend an allowance → the mid-flight refusal names the tool and offers no upgrade.
11. Signed in → `/discover` → "Recommended for you" and "Pick up next" shelves. Signed out → neither,
    and the page still renders.

---

## 7. What is still open, and it is not mobile

| | |
| --- | --- |
| **F3** | The E2E suite is rewritten but has **never run against a browser**, and six visual baselines need a CI re-mint. A dispatch cancels a live push run — check `gh run list` first. |
| **V** | Vocabulary contract: the deprecated enum values, `@umberleaf/api-types` shapes and inert wire fields, in one coordinated PR. Mobile's half is small — it is already off all of them. |
| **C** | DB contract: drop `ai_conversations`, `ai_messages`, `credit_wallets`, `credit_transactions`. |

Wire compatibility until V is deliberate. `forbidNonWhitelisted` is live, so a field removed from a
DTO is a **400** for an already-shipped client, not a no-op — which is why every client half went
first and the contraction goes last.

[48 §3.6]: ../../platfrom/docs/48_PlatformParityRegister.md
[48 §3.22c]: ../../platfrom/docs/48_PlatformParityRegister.md
[48 §3.22d]: ../../platfrom/docs/48_PlatformParityRegister.md
[48 §3.25]: ../../platfrom/docs/48_PlatformParityRegister.md
[48 §5.2]: ../../platfrom/docs/48_PlatformParityRegister.md
