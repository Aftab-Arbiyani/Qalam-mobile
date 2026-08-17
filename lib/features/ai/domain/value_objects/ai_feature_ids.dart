/// Stable AI feature identifiers (AF2). These mirror the backend `AiFeature` wire
/// values (docs/34) and are what the client sends as `feature` on a completion and
/// what it matches against `GET /ai/features`. They are IDENTIFIERS, never prompts —
/// prompt bodies live only on the server (constraint: never hardcode prompts in UI).
library;

import '../../../monetization/domain/entities/monetization_enums.dart';

abstract final class AiFeatureIds {
  /// The in-editor writing assistant (continue/rewrite/expand/tone/…). One feature
  /// + flag for the whole surface; the specific action is a prompt-template key.
  static const String writingAssistant = 'writing_assistant';

  /// The craft coach (chapter/scene/pacing/readability/consistency/review).
  static const String craftCoach = 'craft_coach';

  /// The infra playground surface (raw completion / prompt testing).
  static const String playground = 'playground';

  // AF4 — AI Discovery / Search / Recommendation. Mirror the backend `AiFeature`
  // wire values; used to gate the AF4 surfaces via `GET /ai/features`.
  static const String semanticSearch = 'semantic_search';
  static const String recommendations = 'recommendations';
  static const String askBook = 'ask_book';

  /// Every id this client knows, so the premium map below can be checked for totality.
  static const Set<String> all = <String>{
    writingAssistant,
    craftCoach,
    playground,
    semanticSearch,
    recommendations,
    askBook,
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
/// NOT "ungated": the AI feature flag (`GET /ai/features`) and the AI budget (`ai_budget`,
/// asserted by the server's usage meter) still apply to every feature regardless.
///
/// **Where it stops, and why.** Only the two AF2 surfaces are sold behind `ai_writing`. The
/// AF4 ids map to `null` **deliberately** — `semantic_search`, `recommendations` and
/// `ask_book` belong to **D4**, whose scope the owner has DEFERRED, and `docs/48` §5.2
/// consequence 1 ("a client must not gate on the seven") still binds for every code but
/// `ai_writing`. Gating them here would put a client-only wall in front of a route the
/// server serves, and would silently pre-empt a decision nobody has taken. `playground` is
/// infrastructure, not a sold capability.
///
/// The server's map is the wider one: it also covers the vestigial `grammar`/`rewrite`/
/// `summarization` ids and the five AF3 analyses, none of which this client has an id for.
/// Adding an id here without adding its row below fails [aiPremiumMapIsTotal], which the
/// test suite asserts — a new AI surface must DECLARE that it is free, never default to it.
const Map<String, String?> aiFeaturePremiumCode = <String, String?>{
  // ── Paid: AI writing (D3) ──────────────────────────────────────────────────
  AiFeatureIds.writingAssistant: PremiumFeature.aiWriting,
  AiFeatureIds.craftCoach: PremiumFeature.aiWriting,
  // ── D4's codes — NOT gated (scope deferred by the owner) ───────────────────
  AiFeatureIds.semanticSearch: null,
  AiFeatureIds.recommendations: null,
  AiFeatureIds.askBook: null,
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
