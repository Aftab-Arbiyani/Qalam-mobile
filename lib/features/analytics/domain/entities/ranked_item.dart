/// A ranked (key, label, count) row (docs/40 §30) — the shared shape the backend
/// `RankedItemDto` uses for favourite genres/languages, trending lists, etc.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranked_item.freezed.dart';
part 'ranked_item.g.dart';

@freezed
abstract class RankedItem with _$RankedItem {
  const factory RankedItem({
    @Default('') String key,
    @Default('') String label,
    @Default(0) int count,
  }) = _RankedItem;

  factory RankedItem.fromJson(Map<String, dynamic> json) =>
      _$RankedItemFromJson(json);
}
