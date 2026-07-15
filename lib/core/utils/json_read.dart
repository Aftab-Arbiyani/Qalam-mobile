/// Tolerant JSON field readers for wire→entity mappers (docs/40 §18).
///
/// The wire is frozen but additive; a mapper must never throw on a missing field,
/// a null, or an unexpected type (docs/40 §18.2). These helpers coerce defensively
/// so every mapper stays a small, total function. Enum coercion stays with each
/// enum's `fromWire` (tolerant fallback); these cover the scalar/collection cases.
library;

import 'typedefs.dart';

String asString(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;

/// A nullable string — preserves `null`; non-strings become `null`.
String? asStringOrNull(Object? value) => value is String ? value : null;

int asInt(Object? value, [int fallback = 0]) =>
    value is int ? value : (value is num ? value.toInt() : fallback);

double asDouble(Object? value, [double fallback = 0]) =>
    value is num ? value.toDouble() : fallback;

bool asBool(Object? value, [bool fallback = false]) =>
    value is bool ? value : fallback;

/// Parse an ISO-8601 timestamp to UTC [DateTime]; null/garbage → null.
DateTime? asUtcDateOrNull(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value)?.toUtc();
}

/// A nested object as a typed [Json]; non-maps → an empty map.
Json asMap(Object? value) =>
    value is Map ? Json.from(value) : <String, dynamic>{};

/// A list of nested objects as `List<Json>`; non-lists → empty.
List<Json> asMapList(Object? value) => value is List
    ? value
          .whereType<Map<dynamic, dynamic>>()
          .map(Json.from)
          .toList(growable: false)
    : const <Json>[];
