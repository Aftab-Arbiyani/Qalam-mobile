/// Stable AI feature identifiers (AF2). These mirror the backend `AiFeature` wire
/// values (docs/34) and are what the client sends as `feature` on a completion and
/// what it matches against `GET /ai/features`. They are IDENTIFIERS, never prompts —
/// prompt bodies live only on the server (constraint: never hardcode prompts in UI).
///
/// **D5 (owner, 2026-09-02) shrank this to three.** The wire values stay exactly as
/// they are — the rename is user-facing copy only (decision 10), so `writing_assistant`
/// is still Polish's internal id and `craft_coach` still Manuscript feedback's. What
/// left are the three AF4 ids:
///
/// - `ask_book` — the feature itself is gone (B2 deleted the route and its flag).
/// - `semantic_search` and `recommendations` — the *surfaces* stay, but search is now
///   public and recommendations are gated on having a session, not on a flag. Reading
///   a flag for them was actively dangerous here: mobile's [AiFeatures.isEnabled]
///   answers **false for a flag it cannot find**, so when Phase V deletes those two
///   rows server-side an id left in this file would take mobile's search dark while
///   web — whose resolver treats a missing flag as available — carried on working.
library;

import '../../../monetization/domain/entities/monetization_enums.dart';

abstract final class AiFeatureIds {
  /// **Polish** — the in-editor writing tool (simplify / condense / improve·aspect).
  /// One feature + flag for the whole surface; the specific action is a prompt key.
  static const String writingAssistant = 'writing_assistant';

  /// **Manuscript feedback** — the coaching lenses (chapter/scene/pacing/
  /// readability/consistency/review).
  static const String craftCoach = 'craft_coach';

  /// The infra playground surface (raw completion / prompt testing).
  static const String playground = 'playground';

  /// Every id this client knows, so the premium map below can be checked for totality.
  static const Set<String> all = <String>{
    writingAssistant,
    craftCoach,
    playground,
  };
}

/// Which PREMIUM code (if any) each AI feature is sold under — the Dart mirror of the
/// server's `AI_FEATURE_PREMIUM_CODE` (`packages/shared/src/ai.ts`), and the client half of
/// **D3**: the free tier gets no AI writing (owner, 2026-08-08; `platfrom/docs/45` §4 row D3,
/// `docs/48` §6.13).
///
/// ⚠️ This is a deliberate behaviour REGRESSION for existing free writers. It was flagged
/// before the decision was taken and accepted — there is no grandfather clause here on
/// purpose.
///
/// **Read it with [premiumCodeFor], never by indexing.** A `null` means "no premium code",
/// NOT "ungated": the AI feature flag (`GET /ai/features`) and the per-feature usage
/// allowance (asserted by the server's usage meter) still apply regardless.
///
/// **Where it stops, and why.** Both writing tools are sold behind `ai_writing`;
/// `playground` is infrastructure, not a sold capability. Search and recommendations
/// have no row because they have no id any more — **D5** made search public for
/// everyone including anonymous readers, which settles what D4 had already decided
/// (owner, 2026-08-21) in the strongest possible way: they are free in every tier,
/// permanently, and a client-only wall in front of a route the server serves to
/// everybody would now be a defect rather than merely premature.
///
/// **`story_intelligence` is NOT in this map**, because it gates a screen rather than an
/// AI request: the five AF3 analysis kinds have no id here — even now that "Map this
/// story" can spend them, the client triggers the batch through
/// `POST /story-intelligence/:id/map/stream` and the server meters each kind itself —
/// and Story Map's own gate is a `PremiumGate` in `story_explorer_screen.dart` over the
/// server's `assertGraphReadEntitled`. Give this client an analysis id and it needs a row
/// below mapping to `PremiumFeature.storyIntelligence`.
///
/// The server's map is the wider one: it also covers the vestigial `grammar`/`rewrite`/
/// `summarization` ids and the five AF3 analyses, none of which this client has an id for.
/// Adding an id here without adding its row below fails [aiPremiumMapIsTotal], which the
/// test suite asserts — a new AI surface must DECLARE that it is free, never default to it.
const Map<String, String?> aiFeaturePremiumCode = <String, String?>{
  // ── Paid: the writing tools (D3) ───────────────────────────────────────────
  AiFeatureIds.writingAssistant: PremiumFeature.aiWriting,
  AiFeatureIds.craftCoach: PremiumFeature.aiWriting,
  // ── Infrastructure ────────────────────────────────────────────────────────
  AiFeatureIds.playground: null,
};

/// The premium code an AI request must be entitled to, or `null` when the feature is not
/// sold behind one. The only correct way to read [aiFeaturePremiumCode].
///
/// An UNKNOWN id answers `null` rather than throwing: this is asked on a UI path, and a
/// server that has learned a feature this build has not must not crash the panel. The
/// totality check below is what stops that being a silent hole for ids this build DOES know.
String? premiumCodeFor(String? feature) =>
    feature == null ? null : aiFeaturePremiumCode[feature];

/// Whether [aiFeaturePremiumCode] covers every id in [AiFeatureIds.all], in both
/// directions. Asserted by `test/features/ai/ai_writing_gate_test.dart` — Dart has no
/// compile-time exhaustiveness for a `Map` literal, so this stands in for the server's
/// `satisfies Record<AiFeature, …>` totality pin.
bool aiPremiumMapIsTotal() =>
    aiFeaturePremiumCode.keys.toSet().length == aiFeaturePremiumCode.length &&
    aiFeaturePremiumCode.keys.toSet().difference(AiFeatureIds.all).isEmpty &&
    AiFeatureIds.all.difference(aiFeaturePremiumCode.keys.toSet()).isEmpty;
