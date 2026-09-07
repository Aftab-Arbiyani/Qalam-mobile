/// Retrieval vocabulary (mirrors the backend `@qalam/shared` retrieval enums —
/// docs 36). Plain Dart enums with a `wire` value + `fromWire` (forward-compatible:
/// an unknown wire string maps to a safe default). These are IDENTIFIERS the client
/// sends/receives; no business logic lives here — the backend Retrieval Platform owns
/// intent detection, planning, ranking, and retrieval.
///
/// **D5** deleted `AskScope` with Ask My Book, and de-branded the recommendation
/// labels — the wire values are untouched (decision 10), only what a reader sees.
library;

/// A structured view over the story knowledge graph (the Story Map tabs).
///
/// The `map` view is labelled **"Overview"** since **D5**: the feature is now called
/// Story Map, and a tab inside it cannot carry the same name as the thing that
/// contains it. Its wire value is untouched.
enum ExplorerView {
  characters('characters', 'Characters'),
  relationships('relationships', 'Relationships'),
  timeline('timeline', 'Timeline'),
  locations('locations', 'Locations'),
  events('events', 'Events'),
  objects('objects', 'Objects'),
  concepts('concepts', 'Concepts'),
  map('map', 'Overview');

  const ExplorerView(this.wire, this.label);

  final String wire;
  final String label;

  static ExplorerView fromWire(String? wire) => ExplorerView.values.firstWhere(
    (ExplorerView v) => v.wire == wire,
    orElse: () => ExplorerView.map,
  );
}

/// A recommendation surface.
/// A recommendation surface. The labels are what a reader sees, so **D5** renamed the
/// two shelf kinds that used to read as machine output: `feed` was "For you" and
/// `continueReading` was "Continue reading" — a phrase the feed already uses for the
/// reader's own unfinished pieces, which is a different thing entirely.
enum RecommendationKind {
  relatedStories('related_stories', 'Related stories'),
  relatedChapters('related_chapters', 'Related chapters'),
  relatedCharacters('related_characters', 'Related characters'),
  relatedTopics('related_topics', 'Related topics'),
  continueReading('continue_reading', 'Pick up next'),
  authors('authors', 'Authors to follow'),
  genres('genres', 'Genres for you'),
  collections('collections', 'Collections'),
  feed('feed', 'Recommended for you'),
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
