// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'writer_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WriterSummary {

 String get username; String? get penName; String? get avatarKey; String? get bio; int get followersCount; int get piecesCount;
/// Create a copy of WriterSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WriterSummaryCopyWith<WriterSummary> get copyWith => _$WriterSummaryCopyWithImpl<WriterSummary>(this as WriterSummary, _$identity);

  /// Serializes this WriterSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WriterSummary&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.piecesCount, piecesCount) || other.piecesCount == piecesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,penName,avatarKey,bio,followersCount,piecesCount);

@override
String toString() {
  return 'WriterSummary(username: $username, penName: $penName, avatarKey: $avatarKey, bio: $bio, followersCount: $followersCount, piecesCount: $piecesCount)';
}


}

/// @nodoc
abstract mixin class $WriterSummaryCopyWith<$Res>  {
  factory $WriterSummaryCopyWith(WriterSummary value, $Res Function(WriterSummary) _then) = _$WriterSummaryCopyWithImpl;
@useResult
$Res call({
 String username, String? penName, String? avatarKey, String? bio, int followersCount, int piecesCount
});




}
/// @nodoc
class _$WriterSummaryCopyWithImpl<$Res>
    implements $WriterSummaryCopyWith<$Res> {
  _$WriterSummaryCopyWithImpl(this._self, this._then);

  final WriterSummary _self;
  final $Res Function(WriterSummary) _then;

/// Create a copy of WriterSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? penName = freezed,Object? avatarKey = freezed,Object? bio = freezed,Object? followersCount = null,Object? piecesCount = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: freezed == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String?,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,piecesCount: null == piecesCount ? _self.piecesCount : piecesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WriterSummary].
extension WriterSummaryPatterns on WriterSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WriterSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WriterSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WriterSummary value)  $default,){
final _that = this;
switch (_that) {
case _WriterSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WriterSummary value)?  $default,){
final _that = this;
switch (_that) {
case _WriterSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String? penName,  String? avatarKey,  String? bio,  int followersCount,  int piecesCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WriterSummary() when $default != null:
return $default(_that.username,_that.penName,_that.avatarKey,_that.bio,_that.followersCount,_that.piecesCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String? penName,  String? avatarKey,  String? bio,  int followersCount,  int piecesCount)  $default,) {final _that = this;
switch (_that) {
case _WriterSummary():
return $default(_that.username,_that.penName,_that.avatarKey,_that.bio,_that.followersCount,_that.piecesCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String? penName,  String? avatarKey,  String? bio,  int followersCount,  int piecesCount)?  $default,) {final _that = this;
switch (_that) {
case _WriterSummary() when $default != null:
return $default(_that.username,_that.penName,_that.avatarKey,_that.bio,_that.followersCount,_that.piecesCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WriterSummary extends WriterSummary {
  const _WriterSummary({required this.username, this.penName, this.avatarKey, this.bio, this.followersCount = 0, this.piecesCount = 0}): super._();
  factory _WriterSummary.fromJson(Map<String, dynamic> json) => _$WriterSummaryFromJson(json);

@override final  String username;
@override final  String? penName;
@override final  String? avatarKey;
@override final  String? bio;
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int piecesCount;

/// Create a copy of WriterSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WriterSummaryCopyWith<_WriterSummary> get copyWith => __$WriterSummaryCopyWithImpl<_WriterSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WriterSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WriterSummary&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.piecesCount, piecesCount) || other.piecesCount == piecesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,penName,avatarKey,bio,followersCount,piecesCount);

@override
String toString() {
  return 'WriterSummary(username: $username, penName: $penName, avatarKey: $avatarKey, bio: $bio, followersCount: $followersCount, piecesCount: $piecesCount)';
}


}

/// @nodoc
abstract mixin class _$WriterSummaryCopyWith<$Res> implements $WriterSummaryCopyWith<$Res> {
  factory _$WriterSummaryCopyWith(_WriterSummary value, $Res Function(_WriterSummary) _then) = __$WriterSummaryCopyWithImpl;
@override @useResult
$Res call({
 String username, String? penName, String? avatarKey, String? bio, int followersCount, int piecesCount
});




}
/// @nodoc
class __$WriterSummaryCopyWithImpl<$Res>
    implements _$WriterSummaryCopyWith<$Res> {
  __$WriterSummaryCopyWithImpl(this._self, this._then);

  final _WriterSummary _self;
  final $Res Function(_WriterSummary) _then;

/// Create a copy of WriterSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? penName = freezed,Object? avatarKey = freezed,Object? bio = freezed,Object? followersCount = null,Object? piecesCount = null,}) {
  return _then(_WriterSummary(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: freezed == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String?,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,piecesCount: null == piecesCount ? _self.piecesCount : piecesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
