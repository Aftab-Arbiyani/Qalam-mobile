/// AF4 retrieval vocabulary (mirrors the backend `@qalam/shared` retrieval enums —
/// docs 36). Plain Dart enums with a `wire` value + `fromWire` (forward-compatible:
/// an unknown wire string maps to a safe default). These are IDENTIFIERS the client
/// sends/receives; no business logic lives here — the backend Retrieval Platform owns
/// intent detection, planning, ranking, and retrieval.
library;

/// The slice of a story an "Ask My Book" question is grounded against.
enum AskScope {
  book('book', 'Whole book'),
  chapter('chapter', 'This chapter'),
  scene('scene', 'This scene'),
  character('character', 'A character'),
  timeline('timeline', 'Timeline'),
  relationship('relationship', 'A relationship'),
  world('world', 'The world'),
  theme('theme', 'Themes'),
  lore('lore', 'Lore');

  const AskScope(this.wire, this.label);

  final String wire;
  final String label;

  static AskScope fromWire(String? wire) => AskScope.values.firstWhere(
    (AskScope s) => s.wire == wire,
    orElse: () => AskScope.book,
  );
}

/// A structured view over the story knowledge graph (the Story Explorer tabs).
enum ExplorerView {
  characters('characters', 'Characters'),
  relationships('relationships', 'Relationships'),
  timeline('timeline', 'Timeline'),
  locations('locations', 'Locations'),
  events('events', 'Events'),
  objects('objects', 'Objects'),
  concepts('concepts', 'Concepts'),
  map('map', 'Story map');

  const ExplorerView(this.wire, this.label);

  final String wire;
  final String label;

  static ExplorerView fromWire(String? wire) => ExplorerView.values.firstWhere(
    (ExplorerView v) => v.wire == wire,
    orElse: () => ExplorerView.map,
  );
}

/// A recommendation surface.
enum RecommendationKind {
  relatedStories('related_stories', 'Related stories'),
  relatedChapters('related_chapters', 'Related chapters'),
  relatedCharacters('related_characters', 'Related characters'),
  relatedTopics('related_topics', 'Related topics'),
  continueReading('continue_reading', 'Continue reading'),
  authors('authors', 'Authors to follow'),
  genres('genres', 'Genres for you'),
  collections('collections', 'Collections'),
  feed('feed', 'For you'),
  trending('trending', 'Trending');

  const RecommendationKind(this.wire, this.label);

  final String wire;
  final String label;

  static RecommendationKind fromWire(String? wire) =>
      RecommendationKind.values.firstWhere(
        (RecommendationKind k) => k.wire == wire,
        orElse: () => RecommendationKind.trending,
      );
}
