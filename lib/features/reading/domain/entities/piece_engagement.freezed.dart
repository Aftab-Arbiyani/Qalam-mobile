// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'piece_engagement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PieceEngagement {

 int get likes; int get claps; int get bookmarks; int get comments; int get responses; int get shares; bool get hasLiked; bool get hasBookmarked; int get clapCount;
/// Create a copy of PieceEngagement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PieceEngagementCopyWith<PieceEngagement> get copyWith => _$PieceEngagementCopyWithImpl<PieceEngagement>(this as PieceEngagement, _$identity);

  /// Serializes this PieceEngagement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PieceEngagement&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.claps, claps) || other.claps == claps)&&(identical(other.bookmarks, bookmarks) || other.bookmarks == bookmarks)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.responses, responses) || other.responses == responses)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.hasLiked, hasLiked) || other.hasLiked == hasLiked)&&(identical(other.hasBookmarked, hasBookmarked) || other.hasBookmarked == hasBookmarked)&&(identical(other.clapCount, clapCount) || other.clapCount == clapCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,likes,claps,bookmarks,comments,responses,shares,hasLiked,hasBookmarked,clapCount);

@override
String toString() {
  return 'PieceEngagement(likes: $likes, claps: $claps, bookmarks: $bookmarks, comments: $comments, responses: $responses, shares: $shares, hasLiked: $hasLiked, hasBookmarked: $hasBookmarked, clapCount: $clapCount)';
}


}

/// @nodoc
abstract mixin class $PieceEngagementCopyWith<$Res>  {
  factory $PieceEngagementCopyWith(PieceEngagement value, $Res Function(PieceEngagement) _then) = _$PieceEngagementCopyWithImpl;
@useResult
$Res call({
 int likes, int claps, int bookmarks, int comments, int responses, int shares, bool hasLiked, bool hasBookmarked, int clapCount
});




}
/// @nodoc
class _$PieceEngagementCopyWithImpl<$Res>
    implements $PieceEngagementCopyWith<$Res> {
  _$PieceEngagementCopyWithImpl(this._self, this._then);

  final PieceEngagement _self;
  final $Res Function(PieceEngagement) _then;

/// Create a copy of PieceEngagement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? likes = null,Object? claps = null,Object? bookmarks = null,Object? comments = null,Object? responses = null,Object? shares = null,Object? hasLiked = null,Object? hasBookmarked = null,Object? clapCount = null,}) {
  return _then(_self.copyWith(
likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,claps: null == claps ? _self.claps : claps // ignore: cast_nullable_to_non_nullable
as int,bookmarks: null == bookmarks ? _self.bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as int,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as int,hasLiked: null == hasLiked ? _self.hasLiked : hasLiked // ignore: cast_nullable_to_non_nullable
as bool,hasBookmarked: null == hasBookmarked ? _self.hasBookmarked : hasBookmarked // ignore: cast_nullable_to_non_nullable
as bool,clapCount: null == clapCount ? _self.clapCount : clapCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PieceEngagement].
extension PieceEngagementPatterns on PieceEngagement {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PieceEngagement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PieceEngagement() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PieceEngagement value)  $default,){
final _that = this;
switch (_that) {
case _PieceEngagement():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PieceEngagement value)?  $default,){
final _that = this;
switch (_that) {
case _PieceEngagement() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int likes,  int claps,  int bookmarks,  int comments,  int responses,  int shares,  bool hasLiked,  bool hasBookmarked,  int clapCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PieceEngagement() when $default != null:
return $default(_that.likes,_that.claps,_that.bookmarks,_that.comments,_that.responses,_that.shares,_that.hasLiked,_that.hasBookmarked,_that.clapCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int likes,  int claps,  int bookmarks,  int comments,  int responses,  int shares,  bool hasLiked,  bool hasBookmarked,  int clapCount)  $default,) {final _that = this;
switch (_that) {
case _PieceEngagement():
return $default(_that.likes,_that.claps,_that.bookmarks,_that.comments,_that.responses,_that.shares,_that.hasLiked,_that.hasBookmarked,_that.clapCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int likes,  int claps,  int bookmarks,  int comments,  int responses,  int shares,  bool hasLiked,  bool hasBookmarked,  int clapCount)?  $default,) {final _that = this;
switch (_that) {
case _PieceEngagement() when $default != null:
return $default(_that.likes,_that.claps,_that.bookmarks,_that.comments,_that.responses,_that.shares,_that.hasLiked,_that.hasBookmarked,_that.clapCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PieceEngagement implements PieceEngagement {
  const _PieceEngagement({this.likes = 0, this.claps = 0, this.bookmarks = 0, this.comments = 0, this.responses = 0, this.shares = 0, this.hasLiked = false, this.hasBookmarked = false, this.clapCount = 0});
  factory _PieceEngagement.fromJson(Map<String, dynamic> json) => _$PieceEngagementFromJson(json);

@override@JsonKey() final  int likes;
@override@JsonKey() final  int claps;
@override@JsonKey() final  int bookmarks;
@override@JsonKey() final  int comments;
@override@JsonKey() final  int responses;
@override@JsonKey() final  int shares;
@override@JsonKey() final  bool hasLiked;
@override@JsonKey() final  bool hasBookmarked;
@override@JsonKey() final  int clapCount;

/// Create a copy of PieceEngagement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PieceEngagementCopyWith<_PieceEngagement> get copyWith => __$PieceEngagementCopyWithImpl<_PieceEngagement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PieceEngagementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PieceEngagement&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.claps, claps) || other.claps == claps)&&(identical(other.bookmarks, bookmarks) || other.bookmarks == bookmarks)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.responses, responses) || other.responses == responses)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.hasLiked, hasLiked) || other.hasLiked == hasLiked)&&(identical(other.hasBookmarked, hasBookmarked) || other.hasBookmarked == hasBookmarked)&&(identical(other.clapCount, clapCount) || other.clapCount == clapCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,likes,claps,bookmarks,comments,responses,shares,hasLiked,hasBookmarked,clapCount);

@override
String toString() {
  return 'PieceEngagement(likes: $likes, claps: $claps, bookmarks: $bookmarks, comments: $comments, responses: $responses, shares: $shares, hasLiked: $hasLiked, hasBookmarked: $hasBookmarked, clapCount: $clapCount)';
}


}

/// @nodoc
abstract mixin class _$PieceEngagementCopyWith<$Res> implements $PieceEngagementCopyWith<$Res> {
  factory _$PieceEngagementCopyWith(_PieceEngagement value, $Res Function(_PieceEngagement) _then) = __$PieceEngagementCopyWithImpl;
@override @useResult
$Res call({
 int likes, int claps, int bookmarks, int comments, int responses, int shares, bool hasLiked, bool hasBookmarked, int clapCount
});




}
/// @nodoc
class __$PieceEngagementCopyWithImpl<$Res>
    implements _$PieceEngagementCopyWith<$Res> {
  __$PieceEngagementCopyWithImpl(this._self, this._then);

  final _PieceEngagement _self;
  final $Res Function(_PieceEngagement) _then;

/// Create a copy of PieceEngagement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? likes = null,Object? claps = null,Object? bookmarks = null,Object? comments = null,Object? responses = null,Object? shares = null,Object? hasLiked = null,Object? hasBookmarked = null,Object? clapCount = null,}) {
  return _then(_PieceEngagement(
likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,claps: null == claps ? _self.claps : claps // ignore: cast_nullable_to_non_nullable
as int,bookmarks: null == bookmarks ? _self.bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as int,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as int,hasLiked: null == hasLiked ? _self.hasLiked : hasLiked // ignore: cast_nullable_to_non_nullable
as bool,hasBookmarked: null == hasBookmarked ? _self.hasBookmarked : hasBookmarked // ignore: cast_nullable_to_non_nullable
as bool,clapCount: null == clapCount ? _self.clapCount : clapCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
