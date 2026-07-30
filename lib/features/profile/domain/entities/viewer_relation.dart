/// The viewer's relationship to a profile owner (docs/40 §19.1) — mirrors the
/// backend `ViewerRelationDto` embedded in every profile response. Drives the
/// follow-button state on a public profile and the "this is you" affordances on
/// your own. Follow ACTIONS are a later social epic; M5 only reads this.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'viewer_relation.freezed.dart';
part 'viewer_relation.g.dart';

@freezed
abstract class ViewerRelation with _$ViewerRelation {
  const factory ViewerRelation({
    @Default(false) bool isSelf,
    @Default(false) bool isFollowing,
    @Default(false) bool hasPendingRequest,
  }) = _ViewerRelation;

  factory ViewerRelation.fromJson(Map<String, dynamic> json) =>
      _$ViewerRelationFromJson(json);
}
