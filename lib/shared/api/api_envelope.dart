/// Wire models for the frozen `v1` response envelope (docs/40 §13.3, §13.7).
///
/// Every endpoint returns `{ success, data, meta? }` or
/// `{ success:false, error:{ code, message, details?, requestId? } }`. The
/// generic `data` payload is decoded by the caller (see `ApiClient`); this file
/// models the parts with a fixed shape: the error payload and the pagination
/// meta. Cursor meta nests under `meta.pagination` — NOT flat on `meta`.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_envelope.freezed.dart';
part 'api_envelope.g.dart';

/// The `error` object of a failure envelope. Branch on [code], never [message].
@freezed
abstract class ApiErrorPayload with _$ApiErrorPayload {
  const factory ApiErrorPayload({
    required String code,
    @Default('') String message,
    @Default(<Object?>[]) List<Object?> details,
    String? requestId,
  }) = _ApiErrorPayload;

  factory ApiErrorPayload.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorPayloadFromJson(json);
}

/// A single field-level validation issue inside `error.details`
/// (`VALIDATION_FAILED`). `field` uses dot/bracket paths (`profile.penName`).
@freezed
abstract class FieldError with _$FieldError {
  const factory FieldError({
    required String field,
    @Default('') String rule,
    @Default('') String message,
  }) = _FieldError;

  factory FieldError.fromJson(Map<String, dynamic> json) =>
      _$FieldErrorFromJson(json);
}

/// Cursor pagination meta — feeds/timelines. Opaque `nextCursor`; `null` = end.
@freezed
abstract class CursorMeta with _$CursorMeta {
  const factory CursorMeta({
    String? nextCursor,
    @Default(false) bool hasMore,
    @Default(20) int limit,
  }) = _CursorMeta;

  factory CursorMeta.fromJson(Map<String, dynamic> json) =>
      _$CursorMetaFromJson(json);
}

/// Offset pagination meta — admin tables only (unused on the reader app, modelled
/// for completeness).
@freezed
abstract class OffsetMeta with _$OffsetMeta {
  const factory OffsetMeta({
    @Default(1) int page,
    @Default(20) int limit,
    @Default(0) int total,
    @Default(0) int totalPages,
  }) = _OffsetMeta;

  factory OffsetMeta.fromJson(Map<String, dynamic> json) =>
      _$OffsetMetaFromJson(json);
}

/// One page of a cursor-paginated list: the decoded items plus their cursor meta.
/// Generic and immutable; not a Freezed union because `T` is decoded by the
/// caller's mapper. `useInfiniteQuery`-style pagination reads [meta].nextCursor.
@immutable
class CursorPage<T> {
  const CursorPage({required this.items, required this.meta});

  final List<T> items;
  final CursorMeta meta;

  bool get hasMore => meta.hasMore && meta.nextCursor != null;

  CursorPage<T> appended(CursorPage<T> next) =>
      CursorPage<T>(items: <T>[...items, ...next.items], meta: next.meta);

  @override
  bool operator ==(Object other) =>
      other is CursorPage<T> &&
      other.meta == meta &&
      other.items.length == items.length &&
      _listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(meta, Object.hashAll(items));

  static bool _listEquals<E>(List<E> a, List<E> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
