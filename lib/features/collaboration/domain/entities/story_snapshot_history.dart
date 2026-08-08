/// A story's version history (B7, `platfrom/docs/45` §4.12) — what
/// `GET /stories/{id}/snapshots` answers now that history depth is a plan limit.
library;

import '../../../../core/utils/typedefs.dart';
import 'story_snapshot.dart';

/// Mirrors `SnapshotHistoryDto`.
///
/// The route answers an OBJECT, not a bare list. [items] is CLAMPED to the depth the plan of the
/// author who **owns** the story shows; [total] counts every version stored, hidden ones included.
/// Both are needed to say "5 of 32 versions" — a clamped list on its own is indistinguishable from
/// a short history, so a client reading only `items.length` would state a number that is false and
/// the hidden versions would be invisible rather than for sale.
///
/// **[limit] uses the ORDINARY plan-limit sentinel: `0` means unlimited.** B6's `maxCollaborators`
/// is the one inverted key in this product (-1 unlimited, 0 none) and the two rows are easy to
/// confuse because both read the story owner's plan — but B7's Free tier is five versions, not
/// zero, so there is nothing for an inverted sentinel to express here. Branch on [unlimited]
/// anyway: the server decides the convention, and reading its boolean keeps this right either way.
///
/// Nothing is ever deleted. A bigger plan restores the hidden versions retroactively.
class StorySnapshotHistory {
  const StorySnapshotHistory({
    required this.items,
    required this.total,
    required this.visible,
    required this.hidden,
    required this.limit,
    required this.unlimited,
  });

  /// The versions the plan shows, newest first.
  final List<StorySnapshot> items;

  /// Every version stored for this story — including the ones outside the window.
  final int total;

  /// How many this response carries.
  final int visible;

  /// Stored but not shown on this plan. Never deleted.
  final int hidden;

  /// The owner's plan depth. `0` = unlimited (the ordinary sentinel — NOT B6's -1).
  final int limit;

  final bool unlimited;

  /// True once older versions exist and are being withheld — the only state with an upsell.
  bool get isLimited => !unlimited && hidden > 0;

  /// An empty history, for a story whose versions could not be read.
  ///
  /// `unlimited: true` so nothing is claimed to be hidden: on an error the honest statement is
  /// "we do not know", and inventing an upsell out of a failed request would sell a limit the
  /// author may not even be under. The opposite choice from B6's seat fallback, because the risks
  /// invert — a wrongly-offered seat leaks revenue, a wrongly-claimed hidden version is a lie.
  static const StorySnapshotHistory empty = StorySnapshotHistory(
    items: <StorySnapshot>[],
    total: 0,
    visible: 0,
    hidden: 0,
    limit: 0,
    unlimited: true,
  );

  factory StorySnapshotHistory.fromJson(Json json) {
    final List<StorySnapshot> items =
        (json['items'] as List<Object?>? ?? const <Object?>[])
            .whereType<Map<String, Object?>>()
            .map(StorySnapshot.fromJson)
            .toList();
    return StorySnapshotHistory(
      items: items,
      // Falls back to the list length rather than 0: a total the server did not send must never
      // read as "fewer versions than are on screen", which would render "5 of 0 versions".
      total: _int(json['total'], items.length),
      visible: _int(json['visible'], items.length),
      hidden: _int(json['hidden'], 0),
      limit: _int(json['limit'], 0),
      // Defaults to true: without the server's word, claim nothing is hidden.
      unlimited: json['unlimited'] as bool? ?? true,
    );
  }
}

int _int(Object? raw, int fallback) => raw is num ? raw.toInt() : fallback;
