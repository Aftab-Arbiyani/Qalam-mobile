// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_piece.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfilePiece {

 String get id; String get title; String? get slug; String? get coverImageKey; int get wordCount; int get readingTimeSeconds; DateTime? get publishedAt;
/// Create a copy of ProfilePiece
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfilePieceCopyWith<ProfilePiece> get copyWith => _$ProfilePieceCopyWithImpl<ProfilePiece>(this as ProfilePiece, _$identity);

  /// Serializes this ProfilePiece to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfilePiece&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,coverImageKey,wordCount,readingTimeSeconds,publishedAt);

@override
String toString() {
  return 'ProfilePiece(id: $id, title: $title, slug: $slug, coverImageKey: $coverImageKey, wordCount: $wordCount, readingTimeSeconds: $readingTimeSeconds, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $ProfilePieceCopyWith<$Res>  {
  factory $ProfilePieceCopyWith(ProfilePiece value, $Res Function(ProfilePiece) _then) = _$ProfilePieceCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? slug, String? coverImageKey, int wordCount, int readingTimeSeconds, DateTime? publishedAt
});




}
/// @nodoc
class _$ProfilePieceCopyWithImpl<$Res>
    implements $ProfilePieceCopyWith<$Res> {
  _$ProfilePieceCopyWithImpl(this._self, this._then);

  final ProfilePiece _self;
  final $Res Function(ProfilePiece) _then;

/// Create a copy of ProfilePiece
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? slug = freezed,Object? coverImageKey = freezed,Object? wordCount = null,Object? readingTimeSeconds = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfilePiece].
extension ProfilePiecePatterns on ProfilePiece {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfilePiece value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfilePiece() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfilePiece value)  $default,){
final _that = this;
switch (_that) {
case _ProfilePiece():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfilePiece value)?  $default,){
final _that = this;
switch (_that) {
case _ProfilePiece() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? slug,  String? coverImageKey,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfilePiece() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.coverImageKey,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? slug,  String? coverImageKey,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _ProfilePiece():
return $default(_that.id,_that.title,_that.slug,_that.coverImageKey,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? slug,  String? coverImageKey,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProfilePiece() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.coverImageKey,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfilePiece implements ProfilePiece {
  const _ProfilePiece({required this.id, this.title = '', this.slug, this.coverImageKey, this.wordCount = 0, this.readingTimeSeconds = 0, this.publishedAt});
  factory _ProfilePiece.fromJson(Map<String, dynamic> json) => _$ProfilePieceFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override final  String? slug;
@override final  String? coverImageKey;
@override@JsonKey() final  int wordCount;
@override@JsonKey() final  int readingTimeSeconds;
@override final  DateTime? publishedAt;

/// Create a copy of ProfilePiece
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfilePieceCopyWith<_ProfilePiece> get copyWith => __$ProfilePieceCopyWithImpl<_ProfilePiece>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfilePieceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfilePiece&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,coverImageKey,wordCount,readingTimeSeconds,publishedAt);

@override
String toString() {
  return 'ProfilePiece(id: $id, title: $title, slug: $slug, coverImageKey: $coverImageKey, wordCount: $wordCount, readingTimeSeconds: $readingTimeSeconds, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$ProfilePieceCopyWith<$Res> implements $ProfilePieceCopyWith<$Res> {
  factory _$ProfilePieceCopyWith(_ProfilePiece value, $Res Function(_ProfilePiece) _then) = __$ProfilePieceCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? slug, String? coverImageKey, int wordCount, int readingTimeSeconds, DateTime? publishedAt
});




}
/// @nodoc
class __$ProfilePieceCopyWithImpl<$Res>
    implements _$ProfilePieceCopyWith<$Res> {
  __$ProfilePieceCopyWithImpl(this._self, this._then);

  final _ProfilePiece _self;
  final $Res Function(_ProfilePiece) _then;

/// Create a copy of ProfilePiece
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? slug = freezed,Object? coverImageKey = freezed,Object? wordCount = null,Object? readingTimeSeconds = null,Object? publishedAt = freezed,}) {
  return _then(_ProfilePiece(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
