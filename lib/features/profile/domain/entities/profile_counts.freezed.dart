// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_counts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileCounts {

 int get followers; int get following; int get piecesPublished; int get totalReads; int get totalLikes; int get totalClaps; int get bookmarksReceived; int get responseCount;
/// Create a copy of ProfileCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCountsCopyWith<ProfileCounts> get copyWith => _$ProfileCountsCopyWithImpl<ProfileCounts>(this as ProfileCounts, _$identity);

  /// Serializes this ProfileCounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileCounts&&(identical(other.followers, followers) || other.followers == followers)&&(identical(other.following, following) || other.following == following)&&(identical(other.piecesPublished, piecesPublished) || other.piecesPublished == piecesPublished)&&(identical(other.totalReads, totalReads) || other.totalReads == totalReads)&&(identical(other.totalLikes, totalLikes) || other.totalLikes == totalLikes)&&(identical(other.totalClaps, totalClaps) || other.totalClaps == totalClaps)&&(identical(other.bookmarksReceived, bookmarksReceived) || other.bookmarksReceived == bookmarksReceived)&&(identical(other.responseCount, responseCount) || other.responseCount == responseCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,followers,following,piecesPublished,totalReads,totalLikes,totalClaps,bookmarksReceived,responseCount);

@override
String toString() {
  return 'ProfileCounts(followers: $followers, following: $following, piecesPublished: $piecesPublished, totalReads: $totalReads, totalLikes: $totalLikes, totalClaps: $totalClaps, bookmarksReceived: $bookmarksReceived, responseCount: $responseCount)';
}


}

/// @nodoc
abstract mixin class $ProfileCountsCopyWith<$Res>  {
  factory $ProfileCountsCopyWith(ProfileCounts value, $Res Function(ProfileCounts) _then) = _$ProfileCountsCopyWithImpl;
@useResult
$Res call({
 int followers, int following, int piecesPublished, int totalReads, int totalLikes, int totalClaps, int bookmarksReceived, int responseCount
});




}
/// @nodoc
class _$ProfileCountsCopyWithImpl<$Res>
    implements $ProfileCountsCopyWith<$Res> {
  _$ProfileCountsCopyWithImpl(this._self, this._then);

  final ProfileCounts _self;
  final $Res Function(ProfileCounts) _then;

/// Create a copy of ProfileCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? followers = null,Object? following = null,Object? piecesPublished = null,Object? totalReads = null,Object? totalLikes = null,Object? totalClaps = null,Object? bookmarksReceived = null,Object? responseCount = null,}) {
  return _then(_self.copyWith(
followers: null == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as int,following: null == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as int,piecesPublished: null == piecesPublished ? _self.piecesPublished : piecesPublished // ignore: cast_nullable_to_non_nullable
as int,totalReads: null == totalReads ? _self.totalReads : totalReads // ignore: cast_nullable_to_non_nullable
as int,totalLikes: null == totalLikes ? _self.totalLikes : totalLikes // ignore: cast_nullable_to_non_nullable
as int,totalClaps: null == totalClaps ? _self.totalClaps : totalClaps // ignore: cast_nullable_to_non_nullable
as int,bookmarksReceived: null == bookmarksReceived ? _self.bookmarksReceived : bookmarksReceived // ignore: cast_nullable_to_non_nullable
as int,responseCount: null == responseCount ? _self.responseCount : responseCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileCounts].
extension ProfileCountsPatterns on ProfileCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileCounts value)  $default,){
final _that = this;
switch (_that) {
case _ProfileCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileCounts value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int followers,  int following,  int piecesPublished,  int totalReads,  int totalLikes,  int totalClaps,  int bookmarksReceived,  int responseCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileCounts() when $default != null:
return $default(_that.followers,_that.following,_that.piecesPublished,_that.totalReads,_that.totalLikes,_that.totalClaps,_that.bookmarksReceived,_that.responseCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int followers,  int following,  int piecesPublished,  int totalReads,  int totalLikes,  int totalClaps,  int bookmarksReceived,  int responseCount)  $default,) {final _that = this;
switch (_that) {
case _ProfileCounts():
return $default(_that.followers,_that.following,_that.piecesPublished,_that.totalReads,_that.totalLikes,_that.totalClaps,_that.bookmarksReceived,_that.responseCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int followers,  int following,  int piecesPublished,  int totalReads,  int totalLikes,  int totalClaps,  int bookmarksReceived,  int responseCount)?  $default,) {final _that = this;
switch (_that) {
case _ProfileCounts() when $default != null:
return $default(_that.followers,_that.following,_that.piecesPublished,_that.totalReads,_that.totalLikes,_that.totalClaps,_that.bookmarksReceived,_that.responseCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileCounts implements ProfileCounts {
  const _ProfileCounts({this.followers = 0, this.following = 0, this.piecesPublished = 0, this.totalReads = 0, this.totalLikes = 0, this.totalClaps = 0, this.bookmarksReceived = 0, this.responseCount = 0});
  factory _ProfileCounts.fromJson(Map<String, dynamic> json) => _$ProfileCountsFromJson(json);

@override@JsonKey() final  int followers;
@override@JsonKey() final  int following;
@override@JsonKey() final  int piecesPublished;
@override@JsonKey() final  int totalReads;
@override@JsonKey() final  int totalLikes;
@override@JsonKey() final  int totalClaps;
@override@JsonKey() final  int bookmarksReceived;
@override@JsonKey() final  int responseCount;

/// Create a copy of ProfileCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCountsCopyWith<_ProfileCounts> get copyWith => __$ProfileCountsCopyWithImpl<_ProfileCounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileCountsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileCounts&&(identical(other.followers, followers) || other.followers == followers)&&(identical(other.following, following) || other.following == following)&&(identical(other.piecesPublished, piecesPublished) || other.piecesPublished == piecesPublished)&&(identical(other.totalReads, totalReads) || other.totalReads == totalReads)&&(identical(other.totalLikes, totalLikes) || other.totalLikes == totalLikes)&&(identical(other.totalClaps, totalClaps) || other.totalClaps == totalClaps)&&(identical(other.bookmarksReceived, bookmarksReceived) || other.bookmarksReceived == bookmarksReceived)&&(identical(other.responseCount, responseCount) || other.responseCount == responseCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,followers,following,piecesPublished,totalReads,totalLikes,totalClaps,bookmarksReceived,responseCount);

@override
String toString() {
  return 'ProfileCounts(followers: $followers, following: $following, piecesPublished: $piecesPublished, totalReads: $totalReads, totalLikes: $totalLikes, totalClaps: $totalClaps, bookmarksReceived: $bookmarksReceived, responseCount: $responseCount)';
}


}

/// @nodoc
abstract mixin class _$ProfileCountsCopyWith<$Res> implements $ProfileCountsCopyWith<$Res> {
  factory _$ProfileCountsCopyWith(_ProfileCounts value, $Res Function(_ProfileCounts) _then) = __$ProfileCountsCopyWithImpl;
@override @useResult
$Res call({
 int followers, int following, int piecesPublished, int totalReads, int totalLikes, int totalClaps, int bookmarksReceived, int responseCount
});




}
/// @nodoc
class __$ProfileCountsCopyWithImpl<$Res>
    implements _$ProfileCountsCopyWith<$Res> {
  __$ProfileCountsCopyWithImpl(this._self, this._then);

  final _ProfileCounts _self;
  final $Res Function(_ProfileCounts) _then;

/// Create a copy of ProfileCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? followers = null,Object? following = null,Object? piecesPublished = null,Object? totalReads = null,Object? totalLikes = null,Object? totalClaps = null,Object? bookmarksReceived = null,Object? responseCount = null,}) {
  return _then(_ProfileCounts(
followers: null == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as int,following: null == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as int,piecesPublished: null == piecesPublished ? _self.piecesPublished : piecesPublished // ignore: cast_nullable_to_non_nullable
as int,totalReads: null == totalReads ? _self.totalReads : totalReads // ignore: cast_nullable_to_non_nullable
as int,totalLikes: null == totalLikes ? _self.totalLikes : totalLikes // ignore: cast_nullable_to_non_nullable
as int,totalClaps: null == totalClaps ? _self.totalClaps : totalClaps // ignore: cast_nullable_to_non_nullable
as int,bookmarksReceived: null == bookmarksReceived ? _self.bookmarksReceived : bookmarksReceived // ignore: cast_nullable_to_non_nullable
as int,responseCount: null == responseCount ? _self.responseCount : responseCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
