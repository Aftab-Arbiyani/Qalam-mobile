/// What the editor hands the Story Map route so "Map this story" has text to send
/// (**D5**).
///
/// `POST /story-intelligence/:storyId/map/stream` takes the story's content in the
/// request rather than reading the server's copy of the piece — deliberately, so a
/// writer can map a draft they have not saved. The consequence is that the Story Map
/// screen cannot work from its `:storyId` alone, and this is the parcel that closes the
/// gap: the editor pushes it as go_router's `extra`.
///
/// A class rather than a record because `extra` is typed `Object?` and is matched with
/// `is` on the far side; a record type would match any structurally identical one.
library;

class StoryMapSeed {
  const StoryMapSeed({required this.content, this.title});

  /// The story's full plain text.
  final String content;

  /// The story's title, used to frame the analyses. Optional server-side.
  final String? title;
}
