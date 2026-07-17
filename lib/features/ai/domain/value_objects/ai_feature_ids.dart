/// Stable AI feature identifiers (AF2). These mirror the backend `AiFeature` wire
/// values (docs/34) and are what the client sends as `feature` on a completion and
/// what it matches against `GET /ai/features`. They are IDENTIFIERS, never prompts —
/// prompt bodies live only on the server (constraint: never hardcode prompts in UI).
library;

abstract final class AiFeatureIds {
  /// The in-editor writing assistant (continue/rewrite/expand/tone/…). One feature
  /// + flag for the whole surface; the specific action is a prompt-template key.
  static const String writingAssistant = 'writing_assistant';

  /// The craft coach (chapter/scene/pacing/readability/consistency/review).
  static const String craftCoach = 'craft_coach';

  /// The infra playground surface (raw completion / prompt testing).
  static const String playground = 'playground';
}
