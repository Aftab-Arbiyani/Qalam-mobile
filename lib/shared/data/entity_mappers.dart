/// Wire → entity mappers for the cross-cutting `shared/domain` value objects
/// (docs/40 §18). Author / language / genre / tag appear on many wire shapes
/// (feed cards, piece detail, discovery), so their mappers live in `shared/data`
/// and are imported by every feature's data layer — never re-implemented per
/// feature (features never import features, docs/40 §7.3). Pure, total, tolerant.
library;

import '../../core/utils/json_read.dart';
import '../../core/utils/typedefs.dart';
import '../domain/entities/author.dart';
import '../domain/entities/taxonomy.dart';
import '../domain/enums.dart';

Author authorFromWire(Object? raw) {
  final Json json = asMap(raw);
  return Author(
    username: asString(json['username']),
    penName: asStringOrNull(json['penName']),
    avatarKey: asStringOrNull(json['avatarKey']),
  );
}

LanguageRef languageFromWire(Object? raw) {
  final Json json = asMap(raw);
  return LanguageRef(
    code: asString(json['code']),
    nativeName: asString(json['nativeName']),
    direction: TextDirectionKind.fromWire(asStringOrNull(json['direction'])),
  );
}

/// A nullable genre — the wire sends `null` for genre-less pieces.
GenreRef? genreFromWireOrNull(Object? raw) {
  if (raw is! Map) return null;
  final Json json = Json.from(raw);
  return GenreRef(slug: asString(json['slug']), name: asString(json['name']));
}

TagRef tagFromWire(Object? raw) {
  final Json json = asMap(raw);
  return TagRef(slug: asString(json['slug']), name: asString(json['name']));
}
