# 47 — Mobile AF2 Readiness Report (AI Writing Assistant + Craft Coach)

> **Status:** Mobile + additive backend enablers **implemented + verified**. React
> frontend + admin are documented as seams for a follow-up (scope decision for this
> session). AF2 reuses the **entire** AF1 AI platform (docs/34) — no architectural
> duplication of prompts, streaming, token accounting, conversations, or safety.

---

## 1. Folder tree

Backend enablers (additive, no migration — boot upsert seeds prompts + flags):

```
platfrom/packages/shared/src/ai.ts            # + AiFeature.WritingAssistant, FLAGGED_AI_FEATURES
platfrom/backend/src/modules/settings/settings.catalog.ts   # + feature.ai.writingAssistant.enabled (disabled)
platfrom/backend/src/modules/ai/prompts/prompt-catalog.ts   # + 14 templates (writing_assistant.*, craft_coach.*)
platfrom/backend/src/modules/ai/prompts/prompt-catalog.spec.ts  # catalog + flag guards
```

Mobile (`lib/features/ai/` extends the AF1 foundation; `~4.7k` new lines):

```
lib/features/ai/
├── ai.dart                              # barrel (public reuse surface)
├── domain/
│   ├── entities/
│   │   ├── ai_completion.dart           # + AiContextRequest, context on request (AF2)
│   │   ├── ai_stream_event.dart         # (AF1)
│   │   ├── ai_feature_flag.dart         # (AF1)
│   │   ├── ai_conversation.dart         # summary/detail/message (AF2)
│   │   ├── ai_usage.dart                # usage windows + per-feature (AF2)
│   │   └── ai_suggestion.dart           # THE reusable Suggestion model + word-level diff
│   ├── value_objects/
│   │   ├── ai_feature_ids.dart          # feature id constants (not prompts)
│   │   ├── ai_writing_context.dart      # operand + metadata → AF1 context requests
│   │   ├── writing_action.dart          # action → server promptKey + variables
│   │   ├── coach_tool.dart              # coach lens → server promptKey
│   │   ├── coach_report.dart            # ONE defensive JSON parser for all coach tools
│   │   └── prompt_preset.dart           # prompt-library presets (user instructions)
│   └── repositories/ai_repository.dart  # + conversations + usage (AF2)
├── data/
│   ├── datasources/ai_remote_data_source.dart   # + conversation/usage endpoints
│   ├── repositories/ai_repository_impl.dart
│   └── local/prompt_library_store.dart  # favourites/custom/history/pins (Hive prefs)
└── presentation/
    ├── controllers/
    │   ├── ai_stream_controller.dart              # (AF1) reused; + conversationId in state
    │   ├── assistant_session_controller.dart      # stream → immutable AiSuggestion
    │   ├── craft_coach_controller.dart            # buffered → CoachReport
    │   ├── prompt_library_controller.dart
    │   ├── conversations_controller.dart
    │   └── conversation_detail_controller.dart
    ├── providers/ai_providers.dart      # + aiUsage, promptLibraryStore
    ├── editor/ai_editor_target.dart     # editor seam (interface owned by AI)
    ├── support/ai_error_copy.dart       # error-code → recovery copy
    ├── widgets/{ai_markdown,ai_streaming_text,token_usage_line,suggestion_diff_view,coach_report_view}.dart
    ├── panels/{writing_assistant_panel,craft_coach_panel}.dart
    └── screens/{ai_conversations,ai_conversation,prompt_library,ai_usage}_screen.dart

lib/features/writing/                    # editor integration (host implements the seam)
├── domain/editor/editor_document.dart   # + generic insertParagraphsAfter / appendParagraphs
├── presentation/controllers/current_draft_controller.dart  # + replaceRange/insert/append/replaceDocument
├── presentation/controllers/draft_list_controller.dart     # + newDraftFromText ("Save as draft")
├── presentation/editor/draft_ai_editor_target.dart         # implements AiEditorTarget
├── presentation/editor/formatting_toolbar.dart             # + gated AI button
└── presentation/screens/editor_screen.dart                 # + Craft Coach action + AI overflow

lib/app/router/{routes,app_router}.dart  # + /ai/conversations, /ai/conversations/:id, /ai/prompts, /ai/usage
```

## 2. AI Writing Assistant architecture

Continue / Rewrite / Expand / Condense / Simplify / Improve·{aspect} / Tone·{tone} /
free-form "Ask AI". **One feature (`writing_assistant`), one flag** — each action is a
**server prompt-template key + variables** (`WritingAction` → `promptKey` +
`promptVariables`); no prompt text lives in the client. The `AssistantSessionController`
builds an `AiCompletionRequest` (feature + promptKey + operand as the user message +
`writing_metadata`/`selection` context), delegates streaming to the **reused AF1
`aiStreamControllerProvider`**, and on completion packages the result into an immutable
`AiSuggestion` (content, prompt used, context snapshot, provider/model/token usage, diff
metadata, timestamp). The suggestion is **never** written to the document by the AI.

## 3. Craft Coach architecture

Chapter / Scene feedback, Pacing, Readability, Consistency, and a Full review (strengths,
weaknesses, improvement suggestions, writing score, actionable recommendations, coach
summary). Each `CraftCoachTool` maps to a `craft_coach.*` template that instructs a single
shared JSON schema; the client parses it with **one** defensive parser (`CoachReport.tryParse`
— tolerates code fences/prose, clamps the score, falls back to raw text). Buffered
completion (no reliance on provider JSON-mode → provider-agnostic). Coaching never edits
the document.

## 4. Editor integration architecture

The editor stays the **sole owner** of document state. The AI feature defines an
`AiEditorTarget` interface (apply ops that each return an `AiApplyHandle` with an `undo`
closure); the writing feature implements it (`DraftAiEditorTarget`) against
`CurrentDraftController`. Applies route through **generic** editor commands —
`replaceRange` / `insertParagraphsAfter` / `appendParagraphs` / `replaceDocument` — that
funnel through the existing `_editDocument → _commit → _markDirty → debounced autosave →
offline sync → version bump` path. Result: an accepted suggestion produces the **same
editor events as manual typing**; "Undo AI application" restores a pre-apply snapshot
through the same path. No AI-specific mutation exists. Entry points: a flag-gated AI
button in the formatting toolbar (Writing Assistant) and a Craft Coach app-bar action,
plus overflow links to Conversations / Prompt Library / Usage.

## 5. Prompt library architecture

Built-in presets (General Writing, Novel, Short Story, Essay, Blog, Poetry, Academic) +
Custom prompts + Favourites + History, persisted on-device (`PromptLibraryStore` over the
Hive `prefs` box). Presets are **saved user instructions** for the free-form assistant —
not AI system prompts (those remain server-side, versioned).

## 6. Conversation architecture

Reuses the AF1 conversation API verbatim: list (cursor-paginated), create, detail, rename,
archive, delete, export. Client adds on-device **pins** (frozen `v1` has no pin field) and
client-side **search**. Continuation streams a new turn with the conversation id through
the reused stream controller, then reloads the persisted history.

## 7. Streaming flow

`client → POST /ai/completions/stream (SSE) → start → delta* → done | error`. Tokens
accumulate in `AiStreamController` (transient UI state), rendered with a typing animation
+ blinking caret (`AiStreamingText`, respects reduce-motion). Cancel aborts the request
(subscription cancel → `CancelToken`). Retry / Regenerate re-run the last action; the
settled result becomes the immutable suggestion. Coach uses a buffered call with a progress
indicator.

## 8. State management summary

Reuses AF1 providers (`aiRepositoryProvider`, `aiStreamControllerProvider`,
`aiFeaturesProvider`). New Riverpod controllers: `assistantSessionController`,
`craftCoachController`, `promptLibraryController`, `conversationsController`,
`conversationDetailController`, plus `aiUsageProvider` + `promptLibraryStoreProvider`.
Selection/context is a plain `AiWritingContext` snapshot the editor hands in — no
duplicated AI state, and the AI feature never imports editor internals (dependency
inversion via `AiEditorTarget`).

## 9. API integration summary

No new endpoints. All traffic goes through the AF1 surface via `ApiClient`:
`GET /ai/features`, `POST /ai/completions[/stream]`, `GET /ai/usage/me`,
`POST|GET /ai/conversations`, `GET|PATCH|DELETE /ai/conversations/:id`,
`GET /ai/conversations/:id/export`. `feature` never selects a prompt — the client always
sends `promptKey` (system prompt) + operand (user message) + `context` requests. The client
never talks to a provider or sees an API key.

## 10. Performance optimizations

- Reuses AF1 SSE streaming (incremental token render; no buffering the whole response).
- Coach `maxTokens` bounded (2048) to avoid truncated JSON; parsed lazily.
- `AiSuggestion.diff` computed lazily (bounded word-level LCS).
- Prompt library / pins are in-memory Hive reads (synchronous, no network).
- Conversations lazy-loaded (cursor pagination + load-more on scroll).
- Zero new dependencies (lean in-house Markdown + code renderer).

## 11. Test coverage

New AF2 tests (all green): `coach_report`, `suggestion_diff` + suggestion immutability,
`writing_action` mapping, `ai_wire_parse` (usage + conversation parsing + preset round-trip),
`ai_stream_controller` (reused, + conversationId), `assistant_session_controller`
(stream→suggestion, request shape, error), `craft_coach_controller` (report / raw / error),
`prompt_library_controller`, `conversations_controller` (list/pin/delete),
`editor_ai_apply` (generic doc mutations + controller apply proving dirty/version/undo), and
widget tests (`CoachReportView`, `AiMarkdown` code block). Backend: `prompt-catalog.spec`
(placeholder validity, key uniqueness, parametrised render, coach JSON contract, flag seed).

Gates: `flutter analyze` **0 issues**; `flutter test` **433 pass** (2 failures are
pre-existing `comment_tile` golden pixel diffs — 0.03%, unrelated to AF2; repo already
treats golden drift as environmental per commit `c5539ac`). `flutter build apk --debug`
**succeeds**. Backend `tsc --noEmit` clean, `nest build` succeeds, 82 AI+settings tests pass.

## 12. Manual testing guide

1. Backend up + at least one provider key set (`OPENAI_API_KEY=…`); run backend so boot
   upserts the AF2 prompts (`writing_assistant.*`, `craft_coach.*`) + the two flags.
2. As an admin (`settings.manage`), enable `feature.ai.enabled`, `feature.ai.writingAssistant.enabled`,
   `feature.ai.craftCoach.enabled`.
3. Build the app with `--dart-define=QALAM_ENABLE_AI=true`.
4. Open a draft → the ✨ button appears in the formatting toolbar. Select text → Rewrite →
   watch it stream → Compare (diff) → Apply → confirm the editor updated and shows "Applied";
   Undo → confirm it reverts. Try Insert below / Append / Copy / Save as draft.
5. "Ask AI" → pick a Prompt Library preset → send → apply. Confirm it appears in Recent.
6. App-bar 🎓 (Craft Coach) → Full review → confirm score + strengths/weaknesses/recommendations.
7. Overflow → AI conversations (search/pin/rename/archive/delete/continue), Prompt Library,
   AI usage (tokens/cost/quota/per-feature).
8. Turn a flag off → confirm the affordance disappears (or errors gracefully with recovery).

## 13. Reuse confirmation

Every writing feature reuses the AF1 AI platform without architectural duplication:
provider abstraction, prompt management (templates by key), context builders
(`selection` + `writing_metadata`, passed as request params — offline-safe), streaming
protocol, conversations, token accounting, and the safety pipeline are all the AF1
implementations, reached through the one orchestrator (`AiCompletionService`) via the AF1
`/ai/*` API. A feature = a flag + prompt template(s) + a call to the orchestrator. No
prompt text, stream logic, or token math is duplicated in the client; the editor owns
documents, the AI owns suggestions.
