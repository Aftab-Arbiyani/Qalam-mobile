/// Client-side publish readiness (M4; docs/40 §19.3, §2.1 — UX mirror only).
///
/// Mirrors the server's `assertPublishable` (title + genre + non-empty content;
/// plus the always-required `languageCode`) so the UI can gate the Publish/Schedule
/// buttons and point at what's missing — instant feedback ONLY. The server stays
/// authoritative: publish/schedule may still return 422 `PIECE_INCOMPLETE`, and the
/// client surfaces that too. We never invent a rule the backend doesn't enforce.
library;

import 'package:flutter/foundation.dart';

import '../entities/draft.dart';

/// A single requirement a piece must meet before it can be published/scheduled.
enum PublishRequirement { title, language, genre, content }

@immutable
class DraftValidation {
  const DraftValidation(this.missing);

  final List<PublishRequirement> missing;

  static const DraftValidation ok = DraftValidation(<PublishRequirement>[]);

  bool get canPublish => missing.isEmpty;

  bool isMissing(PublishRequirement r) => missing.contains(r);

  /// Compute readiness for [draft]. Order matters for messaging (title first).
  static DraftValidation of(Draft draft) {
    final List<PublishRequirement> missing = <PublishRequirement>[
      if (draft.title.trim().isEmpty) PublishRequirement.title,
      if (!draft.hasLanguage) PublishRequirement.language,
      if (draft.genreSlug == null || draft.genreSlug!.trim().isEmpty)
        PublishRequirement.genre,
      if (draft.wordCount <= 0) PublishRequirement.content,
    ];
    return DraftValidation(missing);
  }

  @override
  bool operator ==(Object other) =>
      other is DraftValidation && listEquals(other.missing, missing);

  @override
  int get hashCode => Object.hashAll(missing);
}
