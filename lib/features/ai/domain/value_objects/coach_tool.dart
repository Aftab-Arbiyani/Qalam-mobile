/// Craft Coach tools (AF2) — the client vocabulary mapping each coaching lens to a
/// **server** prompt-template key (docs/34). Each coach template returns the SAME
/// structured JSON (see [CoachReport]); the tool only changes the lens. No prompt
/// text lives here — only identifiers + display copy. Pure Dart.
library;

enum CraftCoachTool {
  chapterFeedback(
    'craft_coach.chapter_feedback',
    'Chapter feedback',
    'Holistic developmental notes on the whole chapter.',
  ),
  sceneFeedback(
    'craft_coach.scene_feedback',
    'Scene feedback',
    'Stakes, tension, blocking, and sensory grounding.',
  ),
  pacing(
    'craft_coach.pacing',
    'Pacing analysis',
    'Where the writing drags, rushes, or stalls.',
  ),
  readability(
    'craft_coach.readability',
    'Readability review',
    'Sentence variety, clarity, and flow.',
  ),
  consistency(
    'craft_coach.consistency',
    'Consistency review',
    'Tense, POV, names, timeline, and stated facts.',
  ),
  review(
    'craft_coach.review',
    'Full craft review',
    'Strengths, weaknesses, score, and next steps.',
  );

  const CraftCoachTool(this.promptKey, this.label, this.description);

  final String promptKey;
  final String label;
  final String description;
}
