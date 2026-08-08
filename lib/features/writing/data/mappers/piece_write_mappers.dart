/// Wire ⇄ [Draft] mappers for authoring (docs/40 §18). The only code that knows
/// both the `CreatePieceDto`/`UpdatePieceDto` request shape and the
/// `PieceResponseDto`/`PieceListItemDto` response shape. Request bodies send ONLY
/// the server-whitelisted, writable fields (never `status`/`slug`/`scheduledAt`/
/// `coverImageKey`, which `forbidNonWhitelisted` would reject); responses merge the
/// server truth back onto the local record. Pure, total, tolerant of nulls.
library;

import '../../../../core/utils/json_read.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/data/entity_mappers.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/enums.dart';
import '../../domain/entities/draft.dart';
import '../../domain/entities/draft_summary.dart';
import '../../domain/entities/draft_sync.dart';
import '../../domain/entities/piece_allowance.dart';

/// Build the `CreatePieceDto`/`UpdatePieceDto` body from a [draft]. `languageCode`
/// is always sent (required on create). Nullable optionals are OMITTED when unset
/// so a PATCH never accidentally clears them (there is no "clear genre" intent in
/// the UI). `status`/`slug`/`scheduledAt`/`coverImageKey` are NEVER sent.
Json pieceRequestBody(Draft draft) => <String, Object?>{
  'title': draft.title.trim(),
  'subtitle': draft.subtitle.trim(),
  'featuredQuote': draft.featuredQuote.trim(),
  'content': draft.content,
  'languageCode': draft.languageCode,
  if (draft.genreSlug != null && draft.genreSlug!.trim().isNotEmpty)
    'genreSlug': draft.genreSlug,
  'visibility': draft.visibility.wire,
  'tags': draft.tags,
};

/// Merge a `PieceResponseDto` onto [base], preserving local identity + creation
/// time but adopting server truth and marking the record synced. Called only after
/// a successful push (create/update/publish/schedule), when server == local.
Draft mergeServerPiece(Draft base, Json json, {required DateTime now}) {
  final Object? languageRaw = json['language'];
  final LanguageRef? language = languageRaw == null
      ? null
      : languageFromWire(languageRaw);
  final GenreRef? genre = genreFromWireOrNull(json['genre']);
  return base.copyWith(
    remoteId: asString(json['id']),
    title: asString(json['title']),
    subtitle: asStringOrNull(json['subtitle']) ?? '',
    featuredQuote: asStringOrNull(json['featuredQuote']) ?? '',
    content: asMap(json['content']),
    languageCode: language?.code ?? base.languageCode,
    languageName: language?.nativeName ?? base.languageName,
    direction: language?.direction ?? base.direction,
    genreSlug: genre?.slug,
    genreName: genre?.name,
    tags: _tagNames(json['tags']),
    visibility: Visibility.fromWire(asStringOrNull(json['visibility'])),
    status: PieceStatus.fromWire(
      asStringOrNull(json['status']),
      fallback: base.status,
    ),
    slug: asStringOrNull(json['slug']),
    coverImageKey: asStringOrNull(json['coverImageKey']),
    scheduledAt: asUtcDateOrNull(json['scheduledAt']),
    publishedAt: asUtcDateOrNull(json['publishedAt']),
    remoteUpdatedAt: asUtcDateOrNull(json['updatedAt']),
    wordCount: asInt(json['wordCount']),
    readingTimeSeconds: asInt(json['readingTimeSeconds']),
    localUpdatedAt: now,
    syncState: DraftSyncState.synced,
    intent: DraftIntent.save,
    pendingCoverPath: null,
    lastError: null,
  );
}

/// Build a fresh local [Draft] from a server piece (a server-only draft opened for
/// editing on this device for the first time).
Draft draftFromServerPiece(
  Json json, {
  required String localId,
  required DateTime now,
}) {
  final DateTime created = asUtcDateOrNull(json['createdAt']) ?? now;
  final Draft seed = Draft(
    localId: localId,
    createdAt: created,
    localUpdatedAt: now,
  );
  return mergeServerPiece(seed, json, now: now);
}

/// Map a `PieceListItemDto` to a server-only [DraftSummary] (no local record yet).
DraftSummary draftSummaryFromListItem(Json json) => DraftSummary(
  remoteId: asString(json['id']),
  title: asString(json['title']),
  status: PieceStatus.fromWire(asStringOrNull(json['status'])),
  visibility: Visibility.fromWire(asStringOrNull(json['visibility'])),
  coverImageKey: asStringOrNull(json['coverImageKey']),
  wordCount: asInt(json['wordCount']),
  readingTimeSeconds: asInt(json['readingTimeSeconds']),
  publishedAt: asUtcDateOrNull(json['publishedAt']),
  scheduledAt: asUtcDateOrNull(json['scheduledAt']),
  updatedAt: asUtcDateOrNull(json['updatedAt']),
);

/// Map `PieceLimitDto` to the [PieceAllowance] the writer's surfaces read (B4).
///
/// `canCreate` is taken from the server rather than derived here: the server owns the
/// verdict, and a client that recomputes it is a second rule to keep in step. It defaults
/// to permissive only when the field is missing entirely, which no current server sends —
/// and the create is checked server-side regardless, so the cost of being wrong is a 402,
/// not an escaped cap.
PieceAllowance pieceAllowanceFromJson(Json json) {
  final int limit = asInt(json['limit']);
  final bool unlimited = asBool(json['unlimited'], limit <= 0);
  return PieceAllowance(
    used: asInt(json['used']),
    limit: limit,
    remaining: unlimited ? null : asInt(json['remaining']),
    unlimited: unlimited,
    canCreate: asBool(json['canCreate'], true),
  );
}

List<String> _tagNames(Object? raw) => asMapList(raw)
    .map(tagFromWire)
    .map((TagRef t) => t.name.isNotEmpty ? t.name : t.slug)
    .where((String s) => s.isNotEmpty)
    .toList(growable: false);
