/// A saved AI search (docs 36). Owner-scoped on the server; also mirrored on-device
/// so the list is available offline (same pattern as recent searches). `toJson`
/// round-trips for the local mirror. Dedup key = name.
library;

import '../../../../core/utils/typedefs.dart';
import 'retrieval_json.dart';

class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.name,
    required this.query,
    required this.queryType,
    required this.storyId,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String query;
  final String? queryType;
  final String? storyId;
  final DateTime createdAt;

  /// Dedup key — saved searches are unique by name (per user).
  String get key => name.toLowerCase().trim();

  factory SavedSearch.fromJson(Json json) => SavedSearch(
    id: rjString(json['id']),
    name: rjString(json['name']),
    query: rjString(json['query']),
    queryType: json['queryType'] as String?,
    storyId: json['storyId'] as String?,
    createdAt:
        DateTime.tryParse(rjString(json['createdAt']))?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );

  Json toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'query': query,
    'queryType': queryType,
    'storyId': storyId,
    'createdAt': createdAt.toIso8601String(),
  };
}
