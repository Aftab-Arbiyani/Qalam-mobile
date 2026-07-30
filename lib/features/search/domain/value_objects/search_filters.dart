/// The piece-search filter set (docs/40 §13.6, E8) — language(s), genre(s), a
/// tag, a published-date window, a reading-time window, and a sort order. An
/// immutable value type with correct equality so it is a stable Riverpod family
/// key and a stable cache-key component. [toPieceParams] / [toWriterParams]
/// produce exactly the declared wire params (nulls omitted, lists comma-joined by
/// the query encoder) — the backend rejects unknown params (docs/40 §13.6).
/// Persisted verbatim to device prefs so a session's filters survive (docs/40 §25).
library;

import '../../../../core/utils/typedefs.dart';
import '../../../../shared/domain/enums.dart';

class SearchFilters {
  const SearchFilters({
    this.languages = const <String>[],
    this.genres = const <String>[],
    this.tag,
    this.dateFrom,
    this.dateTo,
    this.minReadingTimeSeconds,
    this.maxReadingTimeSeconds,
    this.sort = SearchSort.relevance,
  });

  factory SearchFilters.fromJson(Json json) => SearchFilters(
    languages: _stringList(json['languages']),
    genres: _stringList(json['genres']),
    tag: json['tag'] as String?,
    dateFrom: _date(json['dateFrom']),
    dateTo: _date(json['dateTo']),
    minReadingTimeSeconds: (json['minReadingTimeSeconds'] as num?)?.toInt(),
    maxReadingTimeSeconds: (json['maxReadingTimeSeconds'] as num?)?.toInt(),
    sort: SearchSort.fromWire(json['sort'] as String?),
  );

  /// The empty filter set — the session default (only relevance sort).
  static const SearchFilters none = SearchFilters();

  final List<String> languages;
  final List<String> genres;
  final String? tag;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? minReadingTimeSeconds;
  final int? maxReadingTimeSeconds;
  final SearchSort sort;

  /// True when nothing narrows the search and the sort is the default.
  bool get isEmpty =>
      languages.isEmpty &&
      genres.isEmpty &&
      tag == null &&
      dateFrom == null &&
      dateTo == null &&
      minReadingTimeSeconds == null &&
      maxReadingTimeSeconds == null &&
      sort == SearchSort.relevance;

  /// How many filters are active (for the "Filters (n)" affordance). Sort counts
  /// only when it is not the default.
  int get activeCount {
    var count = 0;
    if (languages.isNotEmpty) count++;
    if (genres.isNotEmpty) count++;
    if (tag != null) count++;
    if (dateFrom != null || dateTo != null) count++;
    if (minReadingTimeSeconds != null || maxReadingTimeSeconds != null) count++;
    if (sort != SearchSort.relevance) count++;
    return count;
  }

  /// Query params for `GET /search/pieces` (the full filter set).
  Json toPieceParams() => <String, dynamic>{
    if (languages.isNotEmpty) 'language': languages,
    if (genres.isNotEmpty) 'genre': genres,
    if (tag != null) 'tag': tag,
    if (dateFrom != null) 'dateFrom': dateFrom!.toUtc().toIso8601String(),
    if (dateTo != null) 'dateTo': dateTo!.toUtc().toIso8601String(),
    if (minReadingTimeSeconds != null) 'minReadingTime': minReadingTimeSeconds,
    if (maxReadingTimeSeconds != null) 'maxReadingTime': maxReadingTimeSeconds,
    'sort': sort.wire,
  };

  /// Query params for `GET /search/writers` — only language + genre apply, and
  /// the endpoint takes a single value for each (the writer's declared craft).
  Json toWriterParams() => <String, dynamic>{
    if (languages.isNotEmpty) 'language': languages.first,
    if (genres.isNotEmpty) 'genre': genres.first,
  };

  Json toJson() => <String, dynamic>{
    'languages': languages,
    'genres': genres,
    if (tag != null) 'tag': tag,
    if (dateFrom != null) 'dateFrom': dateFrom!.toUtc().toIso8601String(),
    if (dateTo != null) 'dateTo': dateTo!.toUtc().toIso8601String(),
    if (minReadingTimeSeconds != null)
      'minReadingTimeSeconds': minReadingTimeSeconds,
    if (maxReadingTimeSeconds != null)
      'maxReadingTimeSeconds': maxReadingTimeSeconds,
    'sort': sort.wire,
  };

  /// A stable, order-independent identity for cache keys / family args.
  String get signature => <String>[
    'l=${(<String>[...languages]..sort()).join(',')}',
    'g=${(<String>[...genres]..sort()).join(',')}',
    't=${tag ?? ''}',
    'df=${dateFrom?.toUtc().toIso8601String() ?? ''}',
    'dt=${dateTo?.toUtc().toIso8601String() ?? ''}',
    'rmin=${minReadingTimeSeconds ?? ''}',
    'rmax=${maxReadingTimeSeconds ?? ''}',
    's=${sort.wire}',
  ].join('|');

  SearchFilters copyWith({
    List<String>? languages,
    List<String>? genres,
    Object? tag = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    Object? minReadingTimeSeconds = _sentinel,
    Object? maxReadingTimeSeconds = _sentinel,
    SearchSort? sort,
  }) => SearchFilters(
    languages: languages ?? this.languages,
    genres: genres ?? this.genres,
    tag: identical(tag, _sentinel) ? this.tag : tag as String?,
    dateFrom: identical(dateFrom, _sentinel) ? this.dateFrom : dateFrom as DateTime?,
    dateTo: identical(dateTo, _sentinel) ? this.dateTo : dateTo as DateTime?,
    minReadingTimeSeconds: identical(minReadingTimeSeconds, _sentinel)
        ? this.minReadingTimeSeconds
        : minReadingTimeSeconds as int?,
    maxReadingTimeSeconds: identical(maxReadingTimeSeconds, _sentinel)
        ? this.maxReadingTimeSeconds
        : maxReadingTimeSeconds as int?,
    sort: sort ?? this.sort,
  );

  @override
  bool operator ==(Object other) =>
      other is SearchFilters && other.signature == signature;

  @override
  int get hashCode => signature.hashCode;

  static const Object _sentinel = Object();

  static List<String> _stringList(Object? raw) => raw is List
      ? raw.whereType<String>().toList(growable: false)
      : const <String>[];

  static DateTime? _date(Object? raw) =>
      raw is String ? DateTime.tryParse(raw) : null;
}
