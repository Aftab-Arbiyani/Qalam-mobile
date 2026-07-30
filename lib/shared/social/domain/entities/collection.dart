/// A collection / reading list (docs/40 E7) — mirrors the backend
/// `CollectionResponseDto`. Owner-only in Phase 1; the auto-created "Favorites"
/// collection has [isDefault] true (its title cannot be changed and it cannot be
/// deleted). [CollectionPieceItem] is a piece inside a collection. Cached to Hive.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/enums.dart';

part 'collection.freezed.dart';
part 'collection.g.dart';

@freezed
abstract class Collection with _$Collection {
  const Collection._();

  const factory Collection({
    required String id,
    @Default('') String title,
    @Default('') String slug,
    String? description,
    String? coverImageKey,
    @Default(Visibility.private) Visibility visibility,
    @Default(false) bool isDefault,
    @Default(0) int piecesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Collection;

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);

  bool get isPrivate => visibility == Visibility.private;
}

@freezed
abstract class CollectionPieceItem with _$CollectionPieceItem {
  const factory CollectionPieceItem({
    required String pieceId,
    String? slug,
    @Default('') String title,
    @Default(0) int position,
    String? note,
    DateTime? addedAt,
  }) = _CollectionPieceItem;

  factory CollectionPieceItem.fromJson(Map<String, dynamic> json) =>
      _$CollectionPieceItemFromJson(json);
}
