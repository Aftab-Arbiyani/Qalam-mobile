/// The unread-notification count (docs/40 §32.1) — the small polled object that
/// drives the nav badge. The backend returns `{ count, capped }`: [capped] is
/// true when the true count exceeds the server's display cap, so the badge shows
/// e.g. "99+" honestly rather than a stale exact number. `fromJson`/`toJson`
/// exist only for the Hive cache round-trip.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'unread_count.freezed.dart';
part 'unread_count.g.dart';

@freezed
abstract class UnreadCount with _$UnreadCount {
  const UnreadCount._();

  const factory UnreadCount({
    @Default(0) int count,
    @Default(false) bool capped,
  }) = _UnreadCount;

  factory UnreadCount.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountFromJson(json);

  static const UnreadCount zero = UnreadCount();

  bool get hasUnread => count > 0;
}
