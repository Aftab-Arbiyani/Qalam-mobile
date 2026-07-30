/// Tiny defensive JSON readers shared by the AF4 retrieval entities. Pure helpers,
/// no logic — keep parsing tolerant so a shape drift never crashes a screen.
library;

import '../../../../core/utils/typedefs.dart';

List<T> rjList<T>(Object? raw, T Function(Json) fromJson) {
  if (raw is! List) return const <Never>[];
  return raw
      .whereType<Map<dynamic, dynamic>>()
      .map((Map<dynamic, dynamic> e) => fromJson(Json.from(e)))
      .toList(growable: false);
}

double rjDouble(Object? raw) => (raw as num?)?.toDouble() ?? 0;

int rjInt(Object? raw) => (raw as num?)?.toInt() ?? 0;

String rjString(Object? raw) => raw is String ? raw : '';

Json rjMap(Object? raw) =>
    raw is Map ? Json.from(raw) : const <String, dynamic>{};
